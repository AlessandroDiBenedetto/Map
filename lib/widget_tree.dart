// widget_tree.dart

import 'package:flutter/material.dart';
// import 'package:poc_map/data/notifiers.dart'; // Non più necessario se la navigazione è gestita internamente
import 'package:poc_map/navBar/navBar.dart'; // Assicurati che il percorso sia corretto
import 'package:poc_map/page/credit.dart'; // Assicurati che il percorso sia corretto
import 'package:poc_map/page/map.dart'; // Assicurati che il percorso sia corretto

class WidgetTree extends StatefulWidget {
  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  int _selectedIndex = 0; // Nuovo stato per l'indice della pagina selezionata

  // Lista dei widget delle pagine.
  // Le istanze dei widget sono create una sola volta e mantenute.
  final List<Widget> _pages = [
    const maps(), // La tua pagina della mappa (assicurati che sia const se possibile)
    Credit(), // La tua pagina dei crediti (assicurati che sia const se possibile)
  ];

  /// Metodo chiamato quando un elemento della BottomNavigationBar viene toccato.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Aggiorna l'indice selezionato
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index:
            _selectedIndex, // Mostra il widget corrispondente all'indice selezionato
        children: _pages, // La lista delle pagine
      ),
      bottomNavigationBar: NavBarMap(
        selectedIndex: _selectedIndex, // Passa l'indice corrente alla NavBar
        onItemTapped:
            _onItemTapped, // Passa la callback per aggiornare l'indice
      ),
    );
  }
}
