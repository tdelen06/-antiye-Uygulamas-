import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  Future<Position?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    
    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<Map<String, dynamic>?> fetchCurrentWeather() async {
    try {
      Position? position = await _determinePosition();
      if (position == null) return null;

      double lat = position.latitude;
      double lon = position.longitude;

      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,weather_code',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final temp = data['current']['temperature_2m'];
        final weatherCode = data['current']['weather_code'];

        String weatherDescription = _parseWeatherCode(weatherCode);

        return {
          'temperature': '$temp°C',
          'condition': weatherDescription,
          'latitude': lat,
          'longitude': lon,
        };
      }
    } catch (e) {
      print('Hata: $e');
    }
    return null;
  }

  String _parseWeatherCode(int code) {
    if (code == 0) return 'Güneşli / Açık';
    if (code >= 1 && code <= 3) return 'Parçalı Bulutlu';
    if (code >= 45 && code <= 48) return 'Sisli';
    if (code >= 51 && code <= 67) return 'Yağmurlu';
    if (code >= 71 && code <= 77) return 'Karlı';
    if (code >= 95) return 'Fırtınalı';
    return 'Normal';
  }
}