import 'package:poc_map/models/poi_model.dart';
import 'package:poc_map/data/static_pois.dart';
class PoiService {
  /// Restituisce tutti i POI statici disponibili.
  List<Poi> getAllPois() {
    return staticPois;
  }

  /// Filtra i POI in base a una stringa di ricerca.
  /// La ricerca non è case-sensitive e cerca corrispondenze parziali nel nome del POI.
  List<Poi> searchPois(String query) {
    if (query.isEmpty) {
      return [];
    }
    final lowerCaseQuery = query.toLowerCase();
    return staticPois.where((poi) {
      return poi.name.toLowerCase().contains(lowerCaseQuery);
    }).toList();
  }
}
