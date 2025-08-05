import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';

class maps extends StatefulWidget {
   @override
   State<maps> createState() => _MapsState();
}

class _MapsState extends State<maps> {
  final MapController _mapController = MapController();
  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    _loadPosition();
  }

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

  void _loadPosition() async {
    try {
      Position pos = await _determinePosition();
      setState(() {
        _currentPosition = LatLng(pos.latitude, pos.longitude);
      });
    } catch (e) {
      print('Errore posizione: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition == null) {
      // Mostra un loader finché non otteniamo la posizione
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    // Una volta ottenuta la posizione, mostra la mappa
    return Scaffold(
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _currentPosition!,
          initialZoom: 15.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: _currentPosition!,
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.my_location,
                  color: Colors.blue,
                  size: 30,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
