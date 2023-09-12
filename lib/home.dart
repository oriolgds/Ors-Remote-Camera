

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

// Pages
import 'broadcast.dart' as broad_cast;
import 'connect.dart';

double maxWidth(BuildContext context, double maxWidth){
  return MediaQuery.of(context).size.width > maxWidth ? maxWidth : MediaQuery.of(context).size.width;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool broadcasting = false;
  bool connected = false;
  void getDevicesAvailable() async {

  }
  Future<void> resetAll() async {
    broadcasting = false;
    connected = false;
    broad_cast.takePhotoTimer?.cancel();
  }
  @override
  void initState() {

    super.initState();
  }
  int currentPageIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: currentPageIndex == 1 ? FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            broadcasting = true;
          });
        },

        label: const Text('Crear'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.orange[400],

      ) : null,
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.orange.shade50,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
          resetAll();
        },
        indicatorColor: Theme.of(context).primaryColor.harmonizeWith(Colors.brown),
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Inicio',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.broadcast_on_personal),
            icon: Icon(Icons.broadcast_on_personal_outlined),
            label: 'Retransmitir',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.linked_camera),
            icon: Icon(Icons.linked_camera_outlined),
            label: 'Conectar',
          ),
        ],
      ),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
              gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Colors.orange,
                    Colors.deepOrange
                  ]
              )
          ),
        ),
        toolbarHeight: 80.0,
        title: const Text('Ors Remote Camera'),
        actions: <Widget>[
          IconButton(onPressed: (){
            FocusScope.of(context).unfocus();
          }, icon: const Icon(Icons.menu)),
        ],
      ),
      body: [
        Center(
          child: SingleChildScrollView(
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 20.0),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                      child: Image.asset('lib/assets/img/icon.png', width: maxWidth(context, 300.0),),
                    ),
                  ),
                  Text('¡Hola! ¡Bienvenido a Ors Remote Camera! Con esta app podrás usar un teléfono mobil como si fuera una camara y con otro teléfono consultar las imagenes.', textAlign: TextAlign.justify, style: Theme.of(context).textTheme.bodySmall,),
                ],
              )
            ),
          ),
        ),
        broad_cast.BroadCastPage(broadCasting: broadcasting),
        ConnectPage(connected: connected,)
      ][currentPageIndex]
    );
  }
}
