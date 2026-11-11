import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

Future<String?> getCurrentCoordinatesPlatform() async {
  try {
    final pos = await html.window.navigator.geolocation
        .getCurrentPosition(enableHighAccuracy: true, timeout: const Duration(seconds: 8));
    final coords = pos.coords;
    if (coords?.latitude != null && coords?.longitude != null) {
      final lat = coords!.latitude!.toDouble().toStringAsFixed(5);
      final lng = coords.longitude!.toDouble().toStringAsFixed(5);
      return '$lat, $lng';
    }
  } catch (_) {}
  return null;
}
