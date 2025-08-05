import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../models/poi_model.dart';
import '../services/poi_service.dart';
import '../services/direction_service.dart';

class maps extends StatefulWidget {
  const maps({Key? key}) : super(key: key);

  @override
  State<maps> createState() => _MapPageState();
}

class _MapPageState extends State<maps> {
  final MapController _mapController = MapController();
  final PoiService _poiService = PoiService();
  final DirectionService _directionService = DirectionService();

  List<Poi> _allPois = []; // Lista di tutti i POI statici caricati all'avvio.
  Poi? _selectedPoi; // Il POI attualmente selezionato dall'utente.
  LatLng? _userLocation; // La posizione attuale dell'utente.
  double _currentDistanceKm = 0.0;
  int _currentTimeMinutes = 0;

  @override
  void initState() {
    super.initState();
    _allPois = _poiService
        .getAllPois(); // Carica tutti i POI all'avvio dell'applicazione.
    _initializeMapAndLocation();
  }

  // Funzione per verificare i permessi e ottenere la posizione.
  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Servizi di localizzazione disattivati');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permesso posizione negato');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permesso posizione negato permanentemente');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Inizializza la geolocalizzazione dell'utente e centra la mappa sulla sua posizione.
  /// Gestisce i permessi e gli errori di localizzazione.
  Future<void> _initializeMapAndLocation() async {
    try {
      Position pos = await _determinePosition();
      setState(() {
        _userLocation = LatLng(
          pos.latitude,
          pos.longitude,
        ); // Aggiorna la posizione dell'utente nello stato.
      });

      // Sposta la mappa sulla posizione dell'utente
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_userLocation != null) {
          _mapController.move(
            _userLocation!,
            15.0,
          ); // Imposta lo zoom iniziale sulla posizione utente.
        } else {
          _mapController.move(
            LatLng(41.9028, 12.4964),
            6.0,
          ); // Roma come fallback.
        }
      });

      // Inizia a monitorare gli aggiornamenti continui della posizione dell'utente direttamente con Geolocator.
      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter:
              10, // Aggiorna la posizione solo se c'è un cambio di almeno 10 metri
        ),
      ).listen((newPosition) {
        setState(() {
          _userLocation = LatLng(
            newPosition.latitude,
            newPosition.longitude,
          ); // Aggiorna la posizione dell'utente in tempo reale.
        });
        // Se un POI è già selezionato, ricalcola distanza e tempo con la nuova posizione dell'utente.
        if (_selectedPoi != null) {
          _onPoiSelected(_selectedPoi!);
        }
      });
    } catch (e) {
      // Gestisce le eccezioni lanciate da _determinePosition
      _showSnackBar(
        'Errore di geolocalizzazione: ${e.toString().replaceFirst('Exception: ', '')}',
      );
      // Sposta la mappa al fallback se la posizione non è disponibile.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(LatLng(41.9028, 12.4964), 6.0);
      });
      setState(() {
        _userLocation =
            null; // Assicura che _userLocation sia null in caso di errore
      });
    }
  }

  /// Mostra una SnackBar con un messaggio informativo all'utente.
  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  /// Aggiorna il POI selezionato, centra la mappa e calcola distanza/tempo.
  void _onPoiSelected(Poi poi) {
    setState(() {
      _selectedPoi = poi;
      // Centra la mappa sul POI selezionato per una migliore visualizzazione.
      _mapController.move(LatLng(poi.latitude, poi.longitude), 15.0);
    });

    if (_userLocation != null) {
      final Map<String, dynamic> drivingInfo = _directionService
          .getDistanceAndTime(
            _userLocation!,
            LatLng(poi.latitude, poi.longitude),
            TravelMode.driving,
          );

      final Map<String, dynamic> walkingInfo = _directionService
          .getDistanceAndTime(
            _userLocation!,
            LatLng(poi.latitude, poi.longitude),
            TravelMode.walking,
          );

      setState(() {
        _currentDistanceKm =
            drivingInfo['distance']; // Aggiorna la distanza calcolata.
        _currentTimeMinutes = drivingInfo['time']; // Aggiorna il tempo stimato.
      });
      // Stampa i dettagli nella console.
      print('POI Selezionato: ${poi.name}');
      print('Distanza (auto): ${_currentDistanceKm.toStringAsFixed(2)} km');
      print('Tempo (auto): $_currentTimeMinutes min');
      print(
        'Distanza (a piedi): ${walkingInfo['distance'].toStringAsFixed(2)} km',
      );
      print('Tempo (a piedi): ${walkingInfo['time']} min');
    } else {
      _showSnackBar(
        'Posizione utente non disponibile per il calcolo della distanza.',
      );
      setState(() {
        _currentDistanceKm = 0.0;
        _currentTimeMinutes = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Crea la lista di tutti i marker da visualizzare sulla mappa.
    // Inizia con i marker per tutti i Punti di Interesse.
    final List<Marker> allMarkers = _allPois.map((poi) {
      return Marker(
        point: LatLng(poi.latitude, poi.longitude),
        width: 80,
        height: 80,
        child: GestureDetector(
          onTap: () {
            _onPoiSelected(poi);
            _showSnackBar('Hai toccato: ${poi.name}');
          },
          child: Icon(
            Icons.location_pin,
            // Cambia colore del marker se è il POI attualmente selezionato.
            color: _selectedPoi?.id == poi.id ? Colors.orange : Colors.blue,
            size: 40.0,
          ),
        ),
      );
    }).toList();

    // Aggiungi il marker della posizione attuale dell'utente se disponibile.
    if (_userLocation != null) {
      allMarkers.add(
        Marker(
          point: _userLocation!,
          width: 80,
          height: 80,
          child: const Icon(
            Icons.my_location,
            color: Colors.red, // Colore rosso per il marker dell'utente.
            size: 40.0,
          ),
        ),
      );
    }

    // Mostra un indicatore di caricamento finché la posizione dell'utente non è stata ottenuta.
    if (_userLocation == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          // Widget principale della Mappa Flutter.
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _userLocation ?? LatLng(41.9028, 12.4964),

              initialZoom: _userLocation != null ? 15.0 : 6.0,
              minZoom: 2.0,
              maxZoom: 18.0,
              keepAlive: true,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.map_poc',
              ),

              MarkerLayer(markers: allMarkers),
              // TODO: aggiungere un PolylineLayer per disegnare il percorso tra due punti.
            ],
          ),

          // TODO: La SearchBar e la PoiInfoCard
        ],
      ),
    );
  }
}
