// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

Widget createPlatformVideoPlayer({required String videoUrl, required VoidCallback onToggleFullscreen}) {
  final viewType = 'ad-video-${videoUrl.hashCode}';
  ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
    final video = html.VideoElement()
      ..src = videoUrl
      ..autoplay = true
      ..loop = true
      ..muted = true
      ..controls = true
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'cover'
      ..style.borderRadius = '16px';
    video.setAttribute('playsinline', 'true');
    video.setAttribute('webkit-playsinline', 'true');
    return video;
  });

  return ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: HtmlElementView(viewType: viewType),
  );
}
