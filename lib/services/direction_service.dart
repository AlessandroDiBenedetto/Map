import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum TravelMode { walking, driving }

/// Servizio per il calcolo delle direzioni, distanze e tempi stimati.
class DirectionService {
  final String _openRouteServiceApiKey =
      'eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6IjNkMmQxYzRkOGRkODRjZGVhNWJiYmE0MWU2ZWQwY2YwIiwiaCI6Im11cm11cjY0In0=';
  final String _openRouteServiceBaseUrl =
      'https://api.openrouteservice.org/v2/directions/';

  // Velocità media stimata in km/h per il trasporto a piedi.
  final double _averageSpeedWalkingKmPerHour = 5.0;

  // Velocità media stimata in km/h per il trasporto in macchina.
  final double _averageSpeedDrivingKmPerHour = 40.0;

  double calculateDistance(LatLng start, LatLng end) {
    const Distance distance = Distance();
    return distance(start, end) / 1000.0;
  }

  int estimateTravelTimeMinutes(double distanceKm, TravelMode mode) {
    double speed;
    switch (mode) {
      case TravelMode.walking:
        speed = _averageSpeedWalkingKmPerHour;
        break;
      case TravelMode.driving:
        speed = _averageSpeedDrivingKmPerHour;
        break;
    }

    if (speed <= 0) {
      return 0;
    }
    double timeHours = distanceKm / speed;
    return (timeHours * 60).round();
  }

  /// Calcola sia la distanza che il tempo stimato tra due punti per una data modalità di trasporto.
  Map<String, dynamic> getDistanceAndTime(
    LatLng start,
    LatLng end,
    TravelMode mode,
  ) {
    final double distanceKm = calculateDistance(start, end);
    final int timeMinutes = estimateTravelTimeMinutes(distanceKm, mode);

    return {'distance': distanceKm, 'time': timeMinutes};
  }

  /// Ottiene un percorso reale tra due punti usando OpenRouteService.
  /// Restituisce una lista di LatLng che rappresentano il percorso.
  Future<List<LatLng>> getRealRoute(
    LatLng start,
    LatLng end,
    TravelMode mode,
  ) async {
    String profile;
    switch (mode) {
      case TravelMode.driving:
        profile = 'driving-car';
        break;
      case TravelMode.walking:
        profile = 'foot-walking';
        break;
      default:
        profile = 'driving-car';
    }

    // Costruisci l'URL della richiesta. Le coordinate sono in formato longitudine,latitudine.
    final String url =
        '$_openRouteServiceBaseUrl$profile?api_key=$_openRouteServiceApiKey&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Controlla se la risposta contiene le features e la geometria
        if (data.containsKey('features') &&
            data['features'] is List &&
            data['features'].isNotEmpty &&
            data['features'][0].containsKey('geometry') &&
            data['features'][0]['geometry'].containsKey('coordinates') &&
            data['features'][0]['geometry']['coordinates'] is List) {
          final List<dynamic> coordinates =
              data['features'][0]['geometry']['coordinates'];

          // conversione in LatLng(latitude, longitude)
          return coordinates.map<LatLng>((coord) {
            return LatLng(
              coord[1],
              coord[0],
            ); // coord[1] è latitudine, coord[0] è longitudine
          }).toList();
        } else {
          print(
            'Risposta API OpenRouteService non valida: Struttura dati attesa non trovata.',
          );
          return [];
        }
      } else {
        print(
          'Errore API OpenRouteService: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print('Errore durante la richiesta del percorso: $e');
      return [];
    }
  }
}
