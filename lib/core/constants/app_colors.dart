import 'package:flutter/material.dart';

/// App color palette reflecting BISHE Car Wash's aquatic, modern branding
/// located near the picturesque crater lakes of Bishoftu, Oromia.
class AppColors {
  AppColors._();

  // Primary Brand Colors
  static const Color primary = Color(0xFF007791); // Deep Ocean Cyan
  static const Color primaryDark = Color(0xFF004D61);
  static const Color primaryLight = Color(0xFF339FB8);
  static const Color secondary = Color(0xFF0284C7); // Sky Blue
  static const Color accent = Color(0xFF00B4D8); // Water Splash Accent

  // Oromia Lush Accent
  static const Color oromiaGreen = Color(0xFF15803D);
  static const Color oromiaGold = Color(0xFFD97706);

  // Bay & Station Specific Colors
  static const Color bay1Color = Color(0xFF2563EB); // Royal Blue
  static const Color bay2Color = Color(0xFF0D9488); // Deep Teal
  static const Color mobileVanColor = Color(0xFFEA580C); // Energetic Orange

  // Payment Provider Accents
  static const Color telebirrBlue = Color(0xFF0284C7);
  static const Color cbeBirrPurple = Color(0xFF701A75);
  static const Color cashGreen = Color(0xFF16A34A);

  // Status Colors
  static const Color statusPending = Color(0xFFEAB308); // Amber
  static const Color statusConfirmed = Color(0xFF3B82F6); // Blue
  static const Color statusWashing = Color(0xFF06B6D4); // Cyan
  static const Color statusDrying = Color(0xFF8B5CF6); // Purple
  static const Color statusReady = Color(0xFF10B981); // Emerald Green
  static const Color statusCompleted = Color(0xFF059669); // Forest Green
  static const Color statusCancelled = Color(0xFFEF4444); // Red

  // Neutral Colors & Surfaces
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color cardBorder = Color(0xFFE2E8F0);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textLight = Colors.white;

  // Dark Theme Neutral Surfaces
  static const Color darkBackground = Color(0xFF0B1320);
  static const Color darkSurface = Color(0xFF142136);
  static const Color darkSurfaceVariant = Color(0xFF1E2F4D);
  static const Color darkBorder = Color(0xFF2D4263);
}
