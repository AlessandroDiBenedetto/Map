import 'package:flutter/material.dart';
import 'package:poc_map/data/notifiers.dart';
import 'package:poc_map/navBar/navBar.dart';
import 'package:poc_map/page/credit.dart';
import 'package:poc_map/page/map.dart';

final List <Widget> pages = [
  maps(),
  Credit(),
];

class WidgetTree extends StatefulWidget {
  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ValueListenableBuilder(
          valueListenable: selectPageNotifier, 
          builder: (context,Page,child){
            return pages.elementAt(Page);
          }
        ),
        bottomNavigationBar: NavBarMap(),
      );
    }
}
