import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart' as ul;

class UrlLauncherHelper {
  UrlLauncherHelper._();

  static Future<bool> openUrl(String url) async {
    WidgetsFlutterBinding.ensureInitialized();
    var target = url.trim();
    if (target.isEmpty) return false;
    if (!target.startsWith('http://') &&
        !target.startsWith('https://') &&
        !target.startsWith('sms:') &&
        !target.startsWith('tel:')) {
      target = 'https://$target';
    }

    try {
      final uri = Uri.parse(target);
      final ok = await ul.launchUrl(uri, mode: ul.LaunchMode.externalApplication);
      if (ok) return true;
    } catch (e) {
      debugPrint('Error launching URL with externalApplication $target: $e');
    }

    try {
      final uri = Uri.parse(target);
      return await ul.launchUrl(uri, mode: ul.LaunchMode.platformDefault);
    } catch (e2) {
      debugPrint('Fallback launch failed for $target: $e2');
      return false;
    }
  }
}
