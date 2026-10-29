import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../utils/url_launcher_helper.dart';

Widget createPlatformVideoPlayer({required String videoUrl, required VoidCallback onToggleFullscreen}) {
  final targetUrl = videoUrl.startsWith('http')
      ? videoUrl
      : 'https://raw.githubusercontent.com/taresha9926-max/bishe-car-wash-new/main/assets/videos/ad_video.mp4';

  return InkWell(
    onTap: () {
      UrlLauncherHelper.openUrl(targetUrl);
    },
    borderRadius: BorderRadius.circular(16),
    child: Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Opacity(
            opacity: 0.08,
            child: Icon(Icons.local_car_wash_rounded, size: 160, color: Colors.white),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.25),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary.withOpacity(0.6), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.play_arrow_rounded, size: 44, color: Colors.white),
              ),
              const SizedBox(height: 12),
              const Text(
                'BISHE Auto Detailing Commercial',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                'Tap to Play in Full HD • Official Video Reel',
                style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
