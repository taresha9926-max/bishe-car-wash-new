// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

Widget createPlatformVideoPlayer({required String videoUrl, required VoidCallback onToggleFullscreen}) {
  final viewType = 'ad-video-${videoUrl.hashCode}';

  ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
    final video = html.VideoElement()
      ..autoplay = true
      ..loop = true
      ..controls = true
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'cover'
      ..style.backgroundColor = '#000000'
      ..style.borderRadius = '16px';

    // Critical mobile attributes for iOS Safari & Android Chrome autoplay
    video.setAttribute('muted', 'true');
    video.defaultMuted = true;
    video.muted = true;
    video.setAttribute('playsinline', 'true');
    video.setAttribute('webkit-playsinline', 'true');
    video.setAttribute('preload', 'auto');
    video.setAttribute('autoplay', 'true');
    video.setAttribute('loop', 'true');

    // Build fallback sources
    final sources = <String>[];
    if (videoUrl.startsWith('http://') || videoUrl.startsWith('https://') || videoUrl.startsWith('blob:')) {
      sources.add(videoUrl);
    } else {
      // Relative paths for Flutter Web hosting environments
      sources.add('assets/assets/videos/ad_video.mp4');
      sources.add('assets/videos/ad_video.mp4');
      sources.add('ad_video.mp4');
      // Direct raw GitHub fallback
      sources.add('https://raw.githubusercontent.com/taresha9926-max/bishe-car-wash-new/main/assets/videos/ad_video.mp4');
    }

    // Set primary source and attach fallback source tags
    video.src = sources.first;
    for (final src in sources) {
      final sourceEl = html.SourceElement()
        ..src = src
        ..type = 'video/mp4';
      video.append(sourceEl);
    }

    // Safe mobile autoplay trigger with error recovery
    video.onCanPlay.first.then((_) {
      video.play().catchError((_) {
        // Handled: mobile battery saver or autoplay policy blocked initial autoplay
      });
    });

    // Touch and tap handlers for mobile phones
    video.onClick.listen((_) {
      if (video.paused) {
        video.play().catchError((_) {});
      }
    });
    video.onTouchStart.listen((_) {
      if (video.paused) {
        video.play().catchError((_) {});
      }
    });

    return video;
  });

  return ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: HtmlElementView(viewType: viewType),
  );
}
