import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart' as ul;

class UrlLauncherHelper {
  UrlLauncherHelper._();

  static Future<bool> openUrl(String url) async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      final uri = Uri.parse(url.trim());
      return await ul.launchUrl(uri, mode: ul.LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Error launching URL $url: $e');
      try {
        final uri = Uri.parse(url.trim());
        return await ul.launchUrl(uri);
      } catch (e2) {
        debugPrint('Fallback launch failed for $url: $e2');
        return false;
      }
    }
  }
}
