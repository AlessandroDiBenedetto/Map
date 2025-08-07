// widget_tree.dart

import 'package:flutter/material.dart';
import '../widgets/nav_bar.dart';
import 'package:poc_map/page/credit.dart';
import 'package:poc_map/page/map.dart';

class WidgetTree extends StatefulWidget {
  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  int _selectedIndex = 0; // Nuovo stato per l'indice della pagina selezionata

  // Lista dei widget delle pagine.
  // Le istanze dei widget sono create una sola volta e mantenute.
  final List<Widget> _pages = [const maps(), Credit()];

  /// Metodo chiamato quando un elemento della BottomNavigationBar viene toccato.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index:
            _selectedIndex, // Mostra il widget corrispondente all'indice selezionato
        children: _pages,
      ),
      bottomNavigationBar: NavBarMap(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
