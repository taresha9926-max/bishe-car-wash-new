import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

Widget createPlatformVideoPlayer({required String videoUrl, required VoidCallback onToggleFullscreen}) {
  return Container(
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
                color: AppColors.primary.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 2),
              ),
              child: const Icon(Icons.play_arrow_rounded, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 12),
            const Text(
              'BISHE Auto Detailing Commercial',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              'Bishoftu Station Commercial Reel • 4K Experience',
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
            ),
          ],
        ),
      ],
    ),
  );
}
