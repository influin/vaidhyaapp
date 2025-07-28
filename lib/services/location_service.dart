import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  static Future<Position?> getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return null;

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting current position: $e');
      return null;
    }
  }

  // Add this method to match the call in hospital_discovery_screen.dart
  static Future<Position?> getCurrentLocation() async {
    return await getCurrentPosition();
  }

  static Future<String?> getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}';
      }
    } catch (e) {
      print('Error getting address: $e');
    }
    return null;
  }

  // Store selected location
  static Future<void> saveSelectedLocation({
    required String address,
    required double latitude,
    required double longitude,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_location_address', address);
    await prefs.setDouble('selected_location_latitude', latitude);
    await prefs.setDouble('selected_location_longitude', longitude);
    print('Saved location: $address ($latitude, $longitude)');
  }

  // Load selected location from storage
  static Future<Map<String, dynamic>?> loadSelectedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final address = prefs.getString('selected_location_address');
    final latitude = prefs.getDouble('selected_location_latitude');
    final longitude = prefs.getDouble('selected_location_longitude');
    
    if (address != null && latitude != null && longitude != null) {
      print('Loaded location from storage: $address ($latitude, $longitude)');
      return {
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
      };
    } else {
      print('No saved location found in storage');
      return null;
    }
  }

  // Clear saved location
  static Future<void> clearSelectedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('selected_location_address');
    await prefs.remove('selected_location_latitude');
    await prefs.remove('selected_location_longitude');
    print('Cleared saved location from storage');
  }
}