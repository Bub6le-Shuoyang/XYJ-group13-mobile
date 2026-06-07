import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationPoint {
  const LocationPoint({required this.lat, required this.lng});

  final double lat;
  final double lng;
}

class LocationService {
  const LocationService();

  Future<LocationPoint?> getCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final lastKnownPosition = await Geolocator.getLastKnownPosition();
      if (lastKnownPosition != null) {
        return LocationPoint(
          lat: lastKnownPosition.latitude,
          lng: lastKnownPosition.longitude,
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      ).timeout(const Duration(seconds: 5));
      return LocationPoint(lat: position.latitude, lng: position.longitude);
    } catch (_) {
      return null;
    }
  }

  Future<LocationPoint?> geocodeAddress(String address) async {
    final normalizedAddress = address.trim();
    if (normalizedAddress.isEmpty) {
      return null;
    }

    try {
      final locations = await locationFromAddress(normalizedAddress);
      if (locations.isEmpty) {
        return null;
      }
      final first = locations.first;
      return LocationPoint(lat: first.latitude, lng: first.longitude);
    } catch (_) {
      return null;
    }
  }
}
