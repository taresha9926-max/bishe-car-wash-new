// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'image_picker_helper.dart';

void pickImagePlatform({required void Function(PickedReceiptImage image) onPicked}) {
  final uploadInput = html.FileUploadInputElement()..accept = 'image/*';
  uploadInput.click();

  uploadInput.onChange.listen((e) {
    final files = uploadInput.files;
    if (files != null && files.isNotEmpty) {
      final file = files[0];
      final reader = html.FileReader();
      reader.readAsDataUrl(file);
      reader.onLoadEnd.listen((e) {
        onPicked(PickedReceiptImage(
          name: file.name,
          base64Data: reader.result as String?,
        ));
      });
    }
  });
}
