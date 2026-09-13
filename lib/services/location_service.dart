import 'package:geolocator/geolocator.dart';

class LocationResult {
  final double? lat;
  final double? lng;
  final String? error;

  LocationResult({this.lat, this.lng, this.error});

  bool get success => lat != null && lng != null;
}

class LocationService {
  static Future<LocationResult> getCurrent() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        return LocationResult(error: 'يرجى تشغيل خدمة الموقع GPS من إعدادات الهاتف');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        return LocationResult(error: 'تم رفض إذن الوصول إلى الموقع');
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationResult(
          error: 'تم رفض إذن الموقع نهائياً.\nيرجى السماح من إعدادات التطبيق.',
        );
      }

      var pos = await Geolocator.getLastKnownPosition();
      pos ??= await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      return LocationResult(lat: pos.latitude, lng: pos.longitude);
    } catch (e) {
      return LocationResult(error: 'حدث خطأ أثناء الحصول على الموقع');
    }
  }
}