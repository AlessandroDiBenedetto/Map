// poc_map/searchBar/searchBar.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/poi_model.dart';
import '../services/poi_service.dart';

/// Un widget per la barra di ricerca dei Punti di Interesse (POI).
/// Permette all'utente di digitare un testo di ricerca e visualizza i risultati.
/// Quando un POI viene selezionato, viene richiamata la callback `onPoiSelected`.
class SearchBarMap extends StatefulWidget {
  final Function(Poi)
  onPoiSelected; // Callback per notificare la selezione del POI

  const SearchBarMap({Key? key, required this.onPoiSelected}) : super(key: key);

  @override
  SearchBarMapState createState() => SearchBarMapState(); // Cambiato in SearchBarMapState per il GlobalKey
}

class SearchBarMapState extends State<SearchBarMap> {
  // Reso pubblico per il GlobalKey
  final TextEditingController _searchController = TextEditingController();
  final PoiService _poiService = PoiService();
  List<Poi> _searchResults = [];
  bool _showResults =
      false; // Stato interno che indica se i risultati sono visibili

  // Getter pubblico per permettere al widget padre di sapere se la ricerca è attiva
  bool get isSearchActive => _showResults;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  /// Metodo pubblico per disattivare la ricerca (chiudere i risultati e la tastiera).
  void deactivateSearch() {
    setState(() {
      _showResults = false;
      _searchController.clear(); // Pulisce il testo
    });
    FocusScope.of(context).unfocus(); // Chiude la tastiera
  }

  /// Callback richiamata ogni volta che il testo nella barra di ricerca cambia.
  void _onSearchChanged() {
    final query = _searchController.text;
    setState(() {
      if (query.isEmpty) {
        // Se la query è vuota, mostra i primi 3 POI
        _searchResults = _poiService.getAllPois().take(3).toList();
        _showResults = _searchResults.isNotEmpty;
      } else {
        // Altrimenti, esegui la ricerca normale
        _searchResults = _poiService.searchPois(query);
        _showResults = _searchResults.isNotEmpty;
      }
    });
  }

  /// Gestisce la selezione di un POI dalla lista dei risultati.
  void _onResultTap(Poi poi) {
    // Nasconde i risultati e pulisce la barra di ricerca
    deactivateSearch(); // Usa il nuovo metodo per disattivare la ricerca
    // Notifica il widget padre (MapPage) del POI selezionato
    widget.onPoiSelected(poi);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          borderRadius: BorderRadius.circular(20),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.teal),
            decoration: InputDecoration(
              hintText: 'Seleziona un luogo sulla mappa',
              hintStyle: const TextStyle(color: Colors.teal),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              filled: true,
              fillColor: Colors.grey[850],
              prefixIcon: Icon(Icons.search, color: Colors.teal),
            ),
            onTap: () {
              // Quando l'utente tocca il campo, se è vuoto, mostra i primi 3 POI
              if (_searchController.text.isEmpty) {
                setState(() {
                  _searchResults = _poiService.getAllPois().take(3).toList();
                  _showResults = _searchResults.isNotEmpty;
                });
              } else {
                // Se c'è già testo, mostra i risultati attuali
                setState(() {
                  _showResults = true;
                });
              }
            },
          ),
        ),
        // Mostra i risultati della ricerca solo se _showResults è true e ci sono risultati
        if (_showResults)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.3,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final poi = _searchResults[index];
                return ListTile(
                  title: Text(
                    poi.name,
                    style: const TextStyle(color: Colors.teal),
                  ),
                  onTap: () => _onResultTap(poi),
                );
              },
            ),
          ),
      ],
    );
  }
}
