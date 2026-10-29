import 'video_picker_stub.dart' if (dart.library.html) 'video_picker_web.dart';

class VideoPickerHelper {
  VideoPickerHelper._();

  static void pickVideo({required void Function(String videoUrl, String fileName) onPicked}) {
    pickVideoPlatform(onPicked: onPicked);
  }
}
