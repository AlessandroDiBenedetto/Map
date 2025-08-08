// poc_map/widgets/search_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/poi_model.dart';
import '../services/poi_service.dart';

class SearchBarMap extends StatefulWidget {
  final Function(Poi) onPoiSelected;
  final VoidCallback onSearchTapped; // Parametro aggiunto per la callback

  const SearchBarMap({
    Key? key,
    required this.onPoiSelected,
    required this.onSearchTapped, // Richiede la callback
  }) : super(key: key);

  @override
  SearchBarMapState createState() => SearchBarMapState();
}

class SearchBarMapState extends State<SearchBarMap> {
  final TextEditingController _searchController = TextEditingController();
  final PoiService _poiService = PoiService();
  List<Poi> _searchResults = [];
  bool _showResults = false;
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
      _searchController.clear();
    });
    FocusScope.of(context).unfocus();
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
    deactivateSearch();
    widget.onPoiSelected(poi);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Material(
            borderRadius: BorderRadius.circular(20),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Color.fromARGB(255, 243, 250, 255)),
              decoration: InputDecoration(
                hintText: 'Seleziona un luogo sulla mappa',
                hintStyle: const TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                    color: Color.fromARGB(255, 252, 252, 252),
                    width: 2.0,
                  ),
                ),
                filled: true,
                fillColor: Colors.grey[850],
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
              onTap: () {
                // Chiamiamo la callback fornita dal widget padre
                widget.onSearchTapped();
                if (_searchController.text.isEmpty) {
                  setState(() {
                    _searchResults = _poiService.getAllPois().take(3).toList();
                    _showResults = _searchResults.isNotEmpty;
                  });
                }
              },
            ),
          ),
        ),
        // Mostra i risultati della ricerca solo se _showResults è true e ci sono risultati
        if (_showResults)
          Container(
            margin: const EdgeInsets.only(left: 16.0, right: 16.0, top: 0),
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
              padding: EdgeInsets.zero,
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final poi = _searchResults[index];
                return ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  title: Text(
                    poi.name,
                    style: const TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 1),
                      fontSize: 18.0,
                    ),
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
