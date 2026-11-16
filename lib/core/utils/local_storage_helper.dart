import 'local_storage_stub.dart'
    if (dart.library.html) 'local_storage_web.dart' as storage;

class LocalStorageHelper {
  LocalStorageHelper._();

  static const String keyGeminiApiKey = 'bishe_gemini_api_key';

  static String? getString(String key) => storage.getLocalStorageItem(key);
  static void setString(String key, String? value) => storage.setLocalStorageItem(key, value);
}
