import 'package:flutter/material.dart';
import 'package:poc_map/data/notifiers.dart';

//Copiare l'intero file

class NavBarMap extends StatefulWidget {
  @override
  State<NavBarMap> createState() => _NavBarMapState();
}

class _NavBarMapState extends State<NavBarMap> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(valueListenable: selectPageNotifier, builder: (context,selectedPage,child){

    return NavigationBar(
      destinations: [
          NavigationDestination(icon:Icon(Icons.map),label: 'Map',),
          NavigationDestination(icon:Icon(Icons.info),label: 'Credit'),
        ],
        onDestinationSelected: (int value){
          selectPageNotifier.value = value;
        },
        selectedIndex: selectedPage,
          );
        },
      );
    }
}
