// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void pickVideoPlatform({required void Function(String videoUrl, String fileName) onPicked}) {
  final input = html.FileUploadInputElement()..accept = 'video/mp4,video/webm,video/*';
  input.click();
  input.onChange.listen((event) {
    final files = input.files;
    if (files != null && files.isNotEmpty) {
      final file = files[0];
      final blobUrl = html.Url.createObjectUrlFromBlob(file);
      onPicked(blobUrl, file.name);
    }
  });
}
