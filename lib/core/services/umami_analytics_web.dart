import 'dart:js_interop' as js;

@js.JS('bisheTrackEvent')
external void _bisheTrackEvent(js.JSString name, [js.JSAny? data]);

@js.JS('bisheTrackView')
external void _bisheTrackView(js.JSString url, [js.JSString? title]);

void platformTrackEvent(String name, [Map<String, dynamic>? data]) {
  try {
    js.JSAny? jsData;
    if (data != null) {
      jsData = data.jsify();
    }
    _bisheTrackEvent(name.toJS, jsData);
  } catch (_) {}
}

void platformTrackView(String url, [String? title]) {
  try {
    _bisheTrackView(url.toJS, title?.toJS);
  } catch (_) {}
}
