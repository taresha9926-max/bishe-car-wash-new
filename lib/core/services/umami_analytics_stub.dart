// Safe stub implementation for native platforms and hermetic unit tests

void platformTrackEvent(String name, [Map<String, dynamic>? data]) {
  // No-op on native platforms / tests
}

void platformTrackView(String url, [String? title]) {
  // No-op on native platforms / tests
}
