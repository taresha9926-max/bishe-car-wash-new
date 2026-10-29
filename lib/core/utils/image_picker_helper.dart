import 'image_picker_stub.dart' if (dart.library.html) 'image_picker_web.dart';

class PickedReceiptImage {
  final String name;
  final String? base64Data;

  const PickedReceiptImage({required this.name, this.base64Data});
}

class ImagePickerHelper {
  ImagePickerHelper._();

  static void pickImage({required void Function(PickedReceiptImage image) onPicked}) {
    pickImagePlatform(onPicked: onPicked);
  }
}
