import 'package:flutter/material.dart';
import 'video_player_stub.dart' if (dart.library.html) 'video_player_web.dart';

class AdVideoPlayer extends StatelessWidget {
  final String videoUrl;
  final VoidCallback onToggleFullscreen;

  const AdVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.onToggleFullscreen,
  });

  @override
  Widget build(BuildContext context) {
    return createPlatformVideoPlayer(
      videoUrl: videoUrl,
      onToggleFullscreen: onToggleFullscreen,
    );
  }
}
