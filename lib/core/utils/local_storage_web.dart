// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

String? getLocalStorageItem(String key) {
  try {
    return html.window.localStorage[key];
  } catch (_) {
    return null;
  }
}

void setLocalStorageItem(String key, String? value) {
  try {
    if (value == null || value.trim().isEmpty) {
      html.window.localStorage.remove(key);
    } else {
      html.window.localStorage[key] = value.trim();
    }
  } catch (_) {}
}
