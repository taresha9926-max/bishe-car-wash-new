// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'image_picker_helper.dart';

void pickImagePlatform({required void Function(PickedReceiptImage image) onPicked}) {
  final uploadInput = html.FileUploadInputElement()..accept = 'image/*';
  uploadInput.click();

  uploadInput.onChange.listen((e) {
    final files = uploadInput.files;
    if (files != null && files.isNotEmpty) {
      _processFile(files[0], onPicked);
    }
  });
}

void takePhotoPlatform({required void Function(PickedReceiptImage image) onPicked}) {
  final uploadInput = html.FileUploadInputElement()
    ..accept = 'image/*'
    ..setAttribute('capture', 'environment');
  uploadInput.click();

  uploadInput.onChange.listen((e) {
    final files = uploadInput.files;
    if (files != null && files.isNotEmpty) {
      _processFile(files[0], onPicked);
    }
  });
}

void _processFile(html.File file, void Function(PickedReceiptImage image) onPicked) {
  // Use an Object URL and Canvas to downscale high-resolution phone camera photos (<200KB JPEG)
  // to avoid Supabase PostgREST 413 Payload Too Large errors and ensure lightning-fast rendering.
  try {
    final blobUrl = html.Url.createObjectUrl(file);
    final img = html.ImageElement();
    img.src = blobUrl;

    img.onLoad.listen((_) {
      try {
        final naturalWidth = img.naturalWidth ?? 800;
        final naturalHeight = img.naturalHeight ?? 600;
        const maxDim = 1200;

        int targetWidth = naturalWidth;
        int targetHeight = naturalHeight;
        if (naturalWidth > maxDim || naturalHeight > maxDim) {
          if (naturalWidth > naturalHeight) {
            targetWidth = maxDim;
            targetHeight = (naturalHeight * maxDim / naturalWidth).round();
          } else {
            targetHeight = maxDim;
            targetWidth = (naturalWidth * maxDim / naturalHeight).round();
          }
        }

        final canvas = html.CanvasElement(width: targetWidth, height: targetHeight);
        final ctx = canvas.context2D;
        ctx.drawImageScaled(img, 0, 0, targetWidth, targetHeight);
        final compressedDataUrl = canvas.toDataUrl('image/jpeg', 0.82);
        html.Url.revokeObjectUrl(blobUrl);

        onPicked(PickedReceiptImage(
          name: file.name,
          base64Data: compressedDataUrl,
        ));
      } catch (_) {
        html.Url.revokeObjectUrl(blobUrl);
        _fallbackFileReader(file, onPicked);
      }
    });

    img.onError.listen((_) {
      html.Url.revokeObjectUrl(blobUrl);
      _fallbackFileReader(file, onPicked);
    });
  } catch (_) {
    _fallbackFileReader(file, onPicked);
  }
}

void _fallbackFileReader(html.File file, void Function(PickedReceiptImage image) onPicked) {
  final reader = html.FileReader();
  reader.readAsDataUrl(file);
  reader.onLoadEnd.listen((e) {
    onPicked(PickedReceiptImage(
      name: file.name,
      base64Data: reader.result as String?,
    ));
  });
}
