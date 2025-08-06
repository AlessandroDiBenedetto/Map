// src/widgets/poi_info_card.dart

import 'package:flutter/material.dart';
import '../models/poi_model.dart';
import '../services/direction_service.dart'; // Importa TravelMode

/// Una card per visualizzare le informazioni di un Punto di Interesse selezionato,
/// inclusa la distanza e il tempo stimato per diverse modalità di viaggio.
class PoiInfoCard extends StatefulWidget {
  final Poi poi;
  final double distanceDrivingKm;
  final int timeDrivingMinutes;
  final double distanceWalkingKm;
  final int timeWalkingMinutes;
  // La callback ora accetta la modalità di viaggio selezionata
  final Function(TravelMode) onDirectionsPressed;
  final VoidCallback onClosePressed;

  const PoiInfoCard({
    Key? key,
    required this.poi,
    required this.distanceDrivingKm,
    required this.timeDrivingMinutes,
    required this.distanceWalkingKm,
    required this.timeWalkingMinutes,
    required this.onDirectionsPressed,
    required this.onClosePressed,
  }) : super(key: key);

  @override
  State<PoiInfoCard> createState() => _PoiInfoCardState();
}

class _PoiInfoCardState extends State<PoiInfoCard> {
  TravelMode _selectedTravelMode = TravelMode.driving; // Modalità predefinita

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      margin: const EdgeInsets.all(0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.poi.name,
                  style: const TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: widget.onClosePressed,
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            // Informazioni per la modalità in macchina
            Row(
              children: [
                const Icon(Icons.directions_car, color: Colors.grey, size: 20),
                const SizedBox(width: 8.0),
                Text(
                  'Auto: ${widget.distanceDrivingKm.toStringAsFixed(2)} km, ${widget.timeDrivingMinutes} min',
                  style: const TextStyle(fontSize: 16.0, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            // Informazioni per la modalità a piedi
            Row(
              children: [
                const Icon(Icons.directions_walk, color: Colors.grey, size: 20),
                const SizedBox(width: 8.0),
                Text(
                  'A piedi: ${widget.distanceWalkingKm.toStringAsFixed(2)} km, ${widget.timeWalkingMinutes} min',
                  style: const TextStyle(fontSize: 16.0, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            // Pulsanti di selezione modalità di viaggio
            Center(
              child: SegmentedButton<TravelMode>(
                segments: const <ButtonSegment<TravelMode>>[
                  ButtonSegment<TravelMode>(
                    value: TravelMode.driving,
                    label: Text('Auto'),
                    icon: Icon(Icons.directions_car),
                  ),
                  ButtonSegment<TravelMode>(
                    value: TravelMode.walking,
                    label: Text('A piedi'),
                    icon: Icon(Icons.directions_walk),
                  ),
                ],
                selected: <TravelMode>{_selectedTravelMode},
                onSelectionChanged: (Set<TravelMode> newSelection) {
                  setState(() {
                    _selectedTravelMode = newSelection.first;
                  });
                },
                style: SegmentedButton.styleFrom(
                  selectedForegroundColor: Colors.white,
                  selectedBackgroundColor: Colors.teal,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            // Pulsante "Indicazioni"
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                // Passa la modalità selezionata alla callback
                onPressed: () =>
                    widget.onDirectionsPressed(_selectedTravelMode),
                icon: const Icon(Icons.navigation),
                label: const Text('Indicazioni'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
