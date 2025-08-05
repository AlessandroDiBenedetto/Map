import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//Copiare l'intero file

class SearchBarMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
        borderRadius: BorderRadius.circular(20),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Seleziona un luogo sulla mappa',  // corretto
            hintStyle: TextStyle(color: Colors.deepPurple),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            filled: true,
            fillColor: Colors.black,
            prefixIcon: Icon(Icons.search,color: Colors.deepPurple,),
          ),
        ),
      );
  }
}
