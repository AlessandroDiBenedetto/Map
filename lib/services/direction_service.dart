import 'package:latlong2/latlong.dart';

enum TravelMode { walking, driving }

class DirectionService {
  final double _averageSpeedWalkingKmPerHour = 5.0;

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

  Map<String, dynamic> getDistanceAndTime(
    LatLng start,
    LatLng end,
    TravelMode mode,
  ) {
    final double distanceKm = calculateDistance(start, end);
    final int timeMinutes = estimateTravelTimeMinutes(distanceKm, mode);

    return {'distance': distanceKm, 'time': timeMinutes};
  }
}
