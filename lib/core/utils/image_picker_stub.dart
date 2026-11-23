import 'image_picker_helper.dart';

void pickImagePlatform({required void Function(PickedReceiptImage image) onPicked}) {
  onPicked(const PickedReceiptImage(
    name: 'receipt_slip.jpg',
    base64Data: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
  ));
}

void takePhotoPlatform({required void Function(PickedReceiptImage image) onPicked}) {
  onPicked(const PickedReceiptImage(
    name: 'camera_capture.jpg',
    base64Data: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
  ));
}
