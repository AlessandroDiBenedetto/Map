// poc_map/navBar/navBar.dart

import 'package:flutter/material.dart';
// Rimosso l'import di notifiers.dart in quanto la navigazione sarà gestita dal WidgetTree

class NavBarMap extends StatelessWidget {
  final int selectedIndex; // L'indice della pagina attualmente selezionata
  final Function(int)
  onItemTapped; // Callback per notificare la selezione di un elemento

  const NavBarMap({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Il NavigationBar è ora un widget stateless che riceve il suo stato dal genitore
    return NavigationBar(
      destinations: const [
        NavigationDestination(icon: Icon(Icons.map), label: 'Mappa'),
        NavigationDestination(icon: Icon(Icons.info), label: 'Crediti'),
      ],
      onDestinationSelected:
          onItemTapped, // Chiama la callback fornita dal genitore
      selectedIndex: selectedIndex, // Usa l'indice fornito dal genitore
    );
  }
}
