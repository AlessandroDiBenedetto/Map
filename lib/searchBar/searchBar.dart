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
  SearchBarMapState createState() => SearchBarMapState();
}
class SearchBarMapState extends State<SearchBarMap> {
  final TextEditingController _searchController = TextEditingController();
  final PoiService _poiService = PoiService();
  List<Poi> _searchResults = [];
  bool _showResults =
  false; // Stato interno che indica se i risultati sono visibili
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
                if (_searchController.text.isEmpty) {
                  setState(() {
                    _searchResults = _poiService.getAllPois().take(3).toList();
                    _showResults = _searchResults.isNotEmpty;
                  });
                } else {
                  setState(() {
                    _showResults = true;
                  });
                }
              },
            ),
          ),
        ),
        // Mostra i risultati della ricerca solo se _showResults è true e ci sono risultati
        if (_showResults)
          Container(
            margin: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 0, // Even smaller top margin
            ),
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
              padding: EdgeInsets.zero, // Remove default ListView padding
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final poi = _searchResults[index];
                return ListTile(
                  dense: true, // Makes ListTiles more compact
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical:
                    8.0, // Increased vertical padding for bigger items
                  ),
                  title: Text(
                    poi.name,
                    style: const TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 1),
                      fontSize: 18.0, // Increased text size
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
