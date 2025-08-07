import 'package:flutter/material.dart';
class NavBarMap extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  const NavBarMap({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110, // Reduced height
      child: NavigationBar(
        height: 110, // Explicit height control
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map, size: 22), // Smaller icons
            label: 'Mappa',
          ),
          NavigationDestination(
            icon: Icon(Icons.info, size: 22), // Smaller icons
            label: 'Crediti',
          ),
        ],
        onDestinationSelected: onItemTapped,
        selectedIndex: selectedIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        indicatorColor: Colors.teal.withOpacity(0.3),
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
