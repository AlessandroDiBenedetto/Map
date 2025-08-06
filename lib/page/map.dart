// src/pages/map_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../models/poi_model.dart';
import '../services/poi_service.dart';
import '../services/direction_service.dart';
import 'package:poc_map/searchBar/searchBar.dart';
import '../widgets/poi_info_card.dart';

class maps extends StatefulWidget {
  const maps({Key? key}) : super(key: key);

  @override
  State<maps> createState() => _MapPageState();
}

class _MapPageState extends State<maps> {
  final MapController _mapController = MapController();
  final PoiService _poiService = PoiService();
  final DirectionService _directionService = DirectionService();

  List<Poi> _allPois = [];
  Poi? _selectedPoi;
  LatLng? _userLocation;
  double _currentDrivingDistanceKm = 0.0;
  int _currentDrivingTimeMinutes = 0;
  double _currentWalkingDistanceKm = 0.0;
  int _currentWalkingTimeMinutes = 0;
  List<LatLng> _routePoints = [];

  @override
  void initState() {
    super.initState();
    _allPois = _poiService.getAllPois();
    _initializeMapAndLocation();
  }

  /// Funzione per verificare i permessi e ottenere la posizione.
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

  /// Inizializza la geolocalizzazione dell'utente e centra la mappa.
  Future<void> _initializeMapAndLocation() async {
    try {
      Position pos = await _determinePosition();
      setState(() {
        _userLocation = LatLng(pos.latitude, pos.longitude);
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_userLocation != null) {
          _mapController.move(_userLocation!, 15.0);
        } else {
          _mapController.move(LatLng(41.9028, 12.4964), 6.0); // Roma fallback
        }
      });

      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((newPosition) {
        setState(() {
          _userLocation = LatLng(newPosition.latitude, newPosition.longitude);
        });
        if (_selectedPoi != null) {
          _updatePoiInfo(_selectedPoi!);
        }
      });
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(LatLng(41.9028, 12.4964), 6.0); // Roma fallback
      });
      setState(() {
        _userLocation = null;
      });
    }
  }

  /// Calcola e aggiorna solo le informazioni di distanza/tempo del POI.
  Future<void> _updatePoiInfo(Poi poi) async {
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
        _currentDrivingDistanceKm = drivingInfo['distance'];
        _currentDrivingTimeMinutes = drivingInfo['time'];
        _currentWalkingDistanceKm = walkingInfo['distance'];
        _currentWalkingTimeMinutes = walkingInfo['time'];
      });
      print('POI Selezionato: ${poi.name}');
      print(
        'Distanza (auto): ${_currentDrivingDistanceKm.toStringAsFixed(2)} km',
      );
      print('Tempo (auto): ${_currentDrivingTimeMinutes} min');
      print(
        'Distanza (a piedi): ${_currentWalkingDistanceKm.toStringAsFixed(2)} km',
      );
      print('Tempo (a piedi): ${_currentWalkingTimeMinutes} min');
    } else {
      setState(() {
        _currentDrivingDistanceKm = 0.0;
        _currentDrivingTimeMinutes = 0;
        _currentWalkingDistanceKm = 0.0;
        _currentWalkingTimeMinutes = 0;
      });
    }
  }

  /// Gestisce la selezione di un POI, centrando la mappa e mostrando le info.
  void _onPoiSelected(Poi poi) async {
    setState(() {
      _selectedPoi = poi;
      _mapController.move(LatLng(poi.latitude, poi.longitude), 15.0);
      _routePoints =
          []; // Assicurati che il percorso sia vuoto alla selezione iniziale
    });
    _updatePoiInfo(poi);
  }

  /// Calcola e mostra il percorso reale sulla mappa per la modalità selezionata.
  Future<void> _showRealRoute(TravelMode mode) async {
    // Accetta TravelMode
    if (_userLocation != null && _selectedPoi != null) {
      final List<LatLng> realRoute = await _directionService.getRealRoute(
        _userLocation!,
        LatLng(_selectedPoi!.latitude, _selectedPoi!.longitude),
        mode, // Usa la modalità passata
      );
      setState(() {
        _routePoints = realRoute;
      });

      final LatLngBounds bounds = LatLngBounds.fromPoints([
        _userLocation!,
        LatLng(_selectedPoi!.latitude, _selectedPoi!.longitude),
      ]);
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(80.0)),
      );
    } else {
      setState(() {
        _routePoints = [];
      });
    }
  }

  /// Resetta la selezione del POI e il percorso.
  void _clearSelectionAndRoute() {
    setState(() {
      _selectedPoi = null;
      _routePoints = [];
      _currentDrivingDistanceKm = 0.0;
      _currentDrivingTimeMinutes = 0;
      _currentWalkingDistanceKm = 0.0;
      _currentWalkingTimeMinutes = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Marker> allMarkers = [];

    if (_userLocation != null) {
      allMarkers.add(
        Marker(
          point: _userLocation!,
          width: 80,
          height: 80,
          child: const Icon(Icons.my_location, color: Colors.teal, size: 40.0),
        ),
      );
    }

    if (_selectedPoi != null) {
      allMarkers.add(
        Marker(
          point: LatLng(_selectedPoi!.latitude, _selectedPoi!.longitude),
          width: 80,
          height: 80,
          child: GestureDetector(
            onTap: () {
              _onPoiSelected(_selectedPoi!);
            },
            child: const Icon(
              Icons.location_pin,
              color: Colors.teal,
              size: 40.0,
            ),
          ),
        ),
      );
    } else {
      allMarkers.addAll(
        _allPois.map((poi) {
          return Marker(
            point: LatLng(poi.latitude, poi.longitude),
            width: 80,
            height: 80,
            child: GestureDetector(
              onTap: () {
                _onPoiSelected(poi);
              },
              child: const Icon(
                Icons.location_pin,
                color: Colors.blue,
                size: 40.0,
              ),
            ),
          );
        }).toList(),
      );
    }

    if (_userLocation == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _userLocation ?? LatLng(41.9028, 12.4964),
              initialZoom: _userLocation != null ? 15.0 : 6.0,
              minZoom: 2.0,
              maxZoom: 18.0,
              keepAlive: true,
              // onTap: (tapPosition, latLng) => _clearSelectionAndRoute(), // Rimossa la callback onTap sulla mappa
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.map_poc',
              ),
              MarkerLayer(markers: allMarkers),
              if (_routePoints.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      color: const Color.fromARGB(255, 66, 102, 163),
                      strokeWidth: 5.0,
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: SearchBarMap(
              //onPoiSelected: _onPoiSelected,
            ),
          ),
          // Mostra la PoiInfoCard solo se un POI è selezionato
          if (_selectedPoi != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: PoiInfoCard(
                poi: _selectedPoi!,
                distanceDrivingKm: _currentDrivingDistanceKm,
                timeDrivingMinutes: _currentDrivingTimeMinutes,
                distanceWalkingKm: _currentWalkingDistanceKm,
                timeWalkingMinutes: _currentWalkingTimeMinutes,
                onDirectionsPressed:
                    _showRealRoute, // Passa il metodo che ora accetta TravelMode
                onClosePressed: _clearSelectionAndRoute,
              ),
            ),
        ],
      ),
    );
  }
}
