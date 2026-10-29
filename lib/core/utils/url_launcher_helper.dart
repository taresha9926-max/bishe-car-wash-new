import 'url_launcher_stub.dart' if (dart.library.html) 'url_launcher_web.dart';

class UrlLauncherHelper {
  UrlLauncherHelper._();

  static void openUrl(String url) {
    openUrlPlatform(url);
  }
}
