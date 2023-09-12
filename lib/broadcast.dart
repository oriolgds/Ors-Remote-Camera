import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:ors_remote_camera/home.dart';

class BroadCastPage extends StatefulWidget {
  final bool broadCasting;

  const BroadCastPage({super.key, required this.broadCasting});

  @override
  State<BroadCastPage> createState() => _BroadCastPageState();
}

String generateRandomString(int length) {
  final random = Random();
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  return String.fromCharCodes(
    List.generate(
        length, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
  );
}

Timer? takePhotoTimer;

class _BroadCastPageState extends State<BroadCastPage> {
  bool deletingPreviousRoom = false;
  Timer? takePhotoTimer;
  final storageRef = FirebaseStorage.instance.ref();
  final realtimeRef = FirebaseDatabase.instance.ref();
  String? roomCode;
  bool createNewRoomEnabled = true;
  bool flashEnabled = false;
  late CameraController cameraControllerVar;
  Future<void> destroyPreviousRoom(String? roomCode) async {
    if (roomCode != null) {
      deletingPreviousRoom = true;
      await () async {
        storageRef.child('picture$roomCode.jpeg').delete();
        DatabaseReference ref =
            FirebaseDatabase.instance.ref('rooms/$roomCode');
        ref.remove();
        ref.root.child(roomCode).remove();
      }();
      deletingPreviousRoom = false;
    }
  }

  Future<void> createRoom() async {
    if (!createNewRoomEnabled && deletingPreviousRoom) return;
    createNewRoomEnabled = false;
    String randomString = '';
    destroyPreviousRoom(roomCode);

    DatabaseReference ref;
    DataSnapshot? snap;
    refresh() async {
      randomString = generateRandomString(3);
      setState(() {
        roomCode = randomString;
      });
      debugPrint("Creating room: $randomString");
      ref = FirebaseDatabase.instance.ref('rooms/$randomString');
      snap = await ref.get();
    }

    await refresh();
    // Generate shorts until the room doesn't exist
    while (snap!.exists) {
      await refresh();
    }

    // Insert the new room in the database
    ref = FirebaseDatabase.instance.ref('rooms/$randomString');
    String? brand;
    String? model;
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      brand = androidInfo.brand;
      model = androidInfo.model;
    } else if (kIsWeb) {
      WebBrowserInfo webBrowserInfo = await deviceInfo.webBrowserInfo;
      model = webBrowserInfo.userAgent;
    }

    await ref.set({
      "code": randomString,
      "date": DateTime.now().toString(),
      "operatingSystem": Platform.operatingSystem,
      "localeName": Platform.localeName,
      "numberOfProcessors": Platform.numberOfProcessors,
      "brand": brand,
      "model": model,
    });
    createNewRoomEnabled = true;
  }

  Future<void> cameraController() async {
    debugPrint("Initializing camera");
    List<CameraDescription> cameras = await availableCameras();
    cameraControllerVar = CameraController(cameras[0], ResolutionPreset.low);
    await cameraControllerVar.initialize();
    cameraControllerVar.setFlashMode(FlashMode.off);
  }

  Future<void> uploadImage() async {
    if (deletingPreviousRoom) return;
    debugPrint("Taking picture");
    XFile picture;
    try {
      picture = await cameraControllerVar.takePicture();
    } catch (e) {
      return;
    }
    debugPrint("Picture taken at ${picture.path}");
    File file = File(picture.path);
    final pictureReference = storageRef.child('picture$roomCode.jpeg');

    try {
      await pictureReference.putFile(file);
      debugPrint("Picture uploaded");
    } catch (e) {
      debugPrint(e.toString());
    }
    realtimeRef.child(roomCode!).update({"photoAvaible": 1});
  }

  Future<void> changeFlashState(bool state) async {
    realtimeRef.child('$roomCode').update({
      "flash": !state,
    });
  }

  Future<void> flashListener() async {
    realtimeRef.child('$roomCode/flash').onValue.listen((event) {
      debugPrint('Flash new value ${event.snapshot.value}');
      if(event.snapshot.value == true){
        setState(() {
          flashEnabled = true;
        });
        cameraControllerVar.setFlashMode(FlashMode.torch);
      }
      else {
        setState(() {
          flashEnabled = false;
        });
        cameraControllerVar.setFlashMode(FlashMode.off);
      }
    });
  }

  Future<void> takePhotoListener() async {
    realtimeRef.child(roomCode!).child('photoAvaible').onValue.listen((event) {
      if(event.snapshot.value == 2){
        uploadImage();
      }
    });
  }
  @override
  void didUpdateWidget(covariant BroadCastPage oldWidget) {
    if (widget.broadCasting) {
      createRoom();
      flashListener();
      takePhotoListener();
      uploadImage();

    } else {
      cameraControllerVar.dispose();
      takePhotoTimer?.cancel();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    destroyPreviousRoom(roomCode);
    cameraControllerVar.dispose();
    super.dispose();
  }

  @override
  void initState() {
    cameraController();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (!widget.broadCasting)
            const Text(
              'Aún no estas retransmitiendo video, pulsa en el botón de abajo para crear una retransmisión',
              textAlign: TextAlign.center,
            )
          else
            Column(
              children: [
                Text(
                  'El código de la sala es: ',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.redAccent),
                    child: Text(
                      roomCode ?? "",
                      style: const TextStyle(fontSize: 30),
                    )),
                Wrap(
                  children: [
                    SizedBox(
                        width: maxWidth(context, 200),
                        child: CameraPreview(cameraControllerVar)),
                    IconButton(
                        onPressed: () async {
                          changeFlashState(flashEnabled);
                        },
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Colors.orange.shade100)),
                        icon: flashEnabled
                            ? const Icon(Icons.flash_on)
                            : const Icon(Icons.flash_off))
                  ],
                )
              ],
            )
        ],
      ),
    );
  }
}
