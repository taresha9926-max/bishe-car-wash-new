import 'live_gps_stub.dart' if (dart.library.html) 'live_gps_web.dart';

/// Cross-platform helper to read the device's live GPS coordinates (Lat, Lng).
class LiveGpsHelper {
  LiveGpsHelper._();

  static Future<String?> getCurrentCoordinates() => getCurrentCoordinatesPlatform();
}
