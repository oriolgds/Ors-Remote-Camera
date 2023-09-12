import 'dart:core';
import 'dart:typed_data';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
class ConnectPage extends StatefulWidget {

  bool connected;


  ConnectPage({super.key, required this.connected});
  @override
  State<ConnectPage> createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {
  final storageRef = FirebaseStorage.instance.ref();
  final realtimeRef = FirebaseDatabase.instance.ref();
  final int codeLength = 3;
  final TextEditingController roomCodeInput = TextEditingController();
  bool flashEnabled = false;
  Uint8List imageDisplay = Uint8List.fromList([1, 2, 3, 4]);
  String textFieldCounter = "";
  String? textFieldError;
  String roomCode = "";
  String dateOfTheDownloadedImage = "";
  Future<void> connectToTheRoom() async {
    FocusScope.of(context).unfocus();
    String inputVal = roomCodeInput.value.text;
    if(inputVal.isEmpty || inputVal.length > codeLength || inputVal.length < codeLength){
      return;
    }
    DatabaseReference ref = FirebaseDatabase.instance.ref('rooms/$inputVal');
    final snapShot = await ref.get();
    if(snapShot.exists){
      setState(() {
        widget.connected = true;
      });
      roomCode = inputVal;
      addListenerToImage(inputVal);
      addListenerToFlash();
    }
    else {
      setState(() {
        textFieldError = "La sala no existe";
      });
    }
  }
  Future<void> downloadAndShowImage(String roomCode) async {
    final picture = storageRef.child("picture$roomCode.jpeg");
    picture.getMetadata().then((value){
      DateTime? date = value.timeCreated;
      if(date!=null){
        setState(() {
          dateOfTheDownloadedImage = "${date.hour}:${date.minute}:${date.second}";
        });
      }

    });

    try {
      // Six megabytes
      const mbSize = 1024 * 1024 * 6;
      final Uint8List? data = await picture.getData(mbSize);
      setState(() {
        imageDisplay = data!;
      });
    } on FirebaseException catch (e) {
      debugPrint(e.toString());
    }

  }
  Future<void> addListenerToImage(String roomCode) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref(roomCode);
    ref.update({
      "photoAvaible": 2
    });
    ref.onValue.listen((DatabaseEvent event) {
      if(event.snapshot.child('photoAvaible').value == 1){
        downloadAndShowImage(roomCode);
        ref.update({
          "photoAvaible": 0
        });
      }

    });

  }
  Future<void> changeFlashState() async {
    setState(() {
      flashEnabled = !flashEnabled;
    });
    realtimeRef.child(roomCode).update({
      "flash": flashEnabled,
    });
  }
  Future<void> addListenerToFlash() async {
    realtimeRef.child('$roomCode/flash').onValue.listen((event) {
      if(event.snapshot.value == true){
        setState(() {
          flashEnabled = true;
        });
      }
      else {
        setState(() {
          flashEnabled = false;
        });
      }
    });
  }
  @override
  void dispose() {
    //roomCodeInput.dispose();
    super.dispose();
  }
  @override
  void initState() {
    roomCodeInput.addListener(() {
      if(roomCodeInput.value.text.length > codeLength || roomCodeInput.value.text.length < codeLength){
        setState(() {
          textFieldError = "Longitud de texto invalida";
        });
      }
      else {
        setState(() {
          textFieldError = null;
        });
      }
      setState(() {
        textFieldCounter = "${roomCodeInput.value.text.length}/$codeLength";
      });
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: !widget.connected ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('No estas conectado a ninguna camara. Introduce el código de sala aquí abajo.️', style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center,),
            Container(
              margin: const EdgeInsets.only(top: 20.0),
              child: TextField(
                controller: roomCodeInput,
                textCapitalization: TextCapitalization.none,
                decoration: InputDecoration(
                  errorText: textFieldError,
                  label: const Text('Código de sala'),
                  labelStyle: const TextStyle(color: Colors.deepOrange),
                  prefixIcon: const Icon(Icons.abc),
                  prefixIconColor: Colors.black87,
                  iconColor: Colors.deepOrangeAccent,
                  hintMaxLines: 1,
                  counter: Text(textFieldCounter),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.orange),
                    borderRadius: BorderRadius.all(Radius.circular(20))// Set the color here
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                    borderRadius: BorderRadius.all(Radius.circular(20))/// Set the color when the field is focused
                  ),
                  errorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.all(Radius.circular(20))/// Set the color when the field is focused
                  ),
                  focusedErrorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.all(Radius.circular(20))/// Set the color when the field is focused
                  ),


                ),
                autofocus: false,
              ),
            ),
            FilledButton.tonal(
              onPressed: (){
                connectToTheRoom();
              },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.orange.shade100)
                ),
              child: const Text('Entrar')
            )
          ],
        ) : Column(
          children: [
            const Text('Connected'),
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                Image.memory(imageDisplay),
                IconButton.filledTonal(
                  onPressed: changeFlashState,
                  icon: Icon(flashEnabled ? Icons.flash_on : Icons.flash_off),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.orange.shade100)
                  ),
                ),
                Text(dateOfTheDownloadedImage),
                Center(
                  child: FilledButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.orange)
                    ),
                    onPressed: (){
                      realtimeRef.child(roomCode).update({
                        "photoAvaible": 2
                      });
                    },
                    child: const Text('Pedir imagen')),
                )
              ],
            )

          ],
        ),

      ),
    );
  }
}
