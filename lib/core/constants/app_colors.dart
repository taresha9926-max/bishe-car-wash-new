import 'package:flutter/material.dart';

/// App color palette reflecting BISHE Car Wash's Obsidian & Brushed Gold studio branding
/// located near the picturesque crater lakes of Bishoftu, Oromia.
class AppColors {
  AppColors._();

  // Primary Brand Colors (Obsidian & Brushed Champagne Gold)
  static const Color primary = Color(0xFFD97706); // Deep Amber Gold
  static const Color primaryDark = Color(0xFF92400E); // Rich Bronze Gold (for white-text containers)
  static const Color primaryLight = Color(0xFFFBBF24); // Bright Gold Highlight
  static const Color secondary = Color(0xFFF59E0B); // Warm Brushed Gold
  static const Color accent = Color(0xFFFDE68A); // Champagne Gold Highlight

  // Dedicated Obsidian Gold Studio Tokens
  static const Color obsidianCanvas = Color(0xFF06070B); // Pitch Obsidian
  static const Color obsidianSurface = Color(0xFF10131C); // Smoked Carbon
  static const Color obsidianElevated = Color(0xFF161A26); // Elevated Charcoal
  static const Color champagneGold = Color(0xFFFDE68A);
  static const Color warmGold = Color(0xFFF59E0B);
  static const Color deepAmberGold = Color(0xFFD97706);
  static const Color obsidianGoldText = Color(0xFF140E02);
  static const List<Color> goldGradient = [
    Color(0xFFFDE68A),
    Color(0xFFF59E0B),
    Color(0xFFD97706),
  ];
  static const List<Color> goldButtonGradient = [
    Color(0xFFF59E0B),
    Color(0xFFD97706),
  ];

  // Oromia Lush Accent
  static const Color oromiaGreen = Color(0xFF15803D);
  static const Color oromiaGold = Color(0xFFD97706);

  // Bay & Station Specific Colors
  static const Color bay1Color = Color(0xFFD97706); // Deep Amber Gold
  static const Color bay2Color = Color(0xFFF59E0B); // Warm Gold
  static const Color mobileVanColor = Color(0xFFEA580C); // Energetic Orange

  // Payment Provider Accents
  static const Color telebirrBlue = Color(0xFFF59E0B);
  static const Color cbeBirrPurple = Color(0xFF701A75);
  static const Color cashGreen = Color(0xFF16A34A);

  // Obsidian Gold Studio Surface & Neon Aliases
  static const Color midnightCanvas = Color(0xFF06070B); // Pitch Obsidian
  static const Color slateGlass = Color(0xFF10131C); // Smoked Carbon
  static const Color liquidCyanNeon = Color(0xFFF59E0B); // Warm Brushed Gold
  static const Color warmAmberSunset = Color(0xFFFDE68A); // Champagne Gold

  // Status Colors
  static const Color statusPending = Color(0xFFEAB308); // Amber
  static const Color statusConfirmed = Color(0xFFF59E0B); // Warm Gold
  static const Color statusWashing = Color(0xFFFBBF24); // Bright Gold
  static const Color statusDrying = Color(0xFF8B5CF6); // Purple
  static const Color statusReady = Color(0xFF10B981); // Emerald Green
  static const Color statusCompleted = Color(0xFF059669); // Forest Green
  static const Color statusCancelled = Color(0xFFEF4444); // Red

  // Neutral Colors & Surfaces (Pitch Obsidian & Smoked Carbon)
  static const Color background = Color(0xFF06070B); // Pitch Obsidian canvas
  static const Color surface = Color(0xFF10131C); // Elevated Smoked Carbon
  static const Color surfaceVariant = Color(0xFF161A26); // Elevated container variant
  static const Color cardBorder = Color(0x38F59E0B); // Warm Gold hairline border
  static const Color cardGlassBorder = Color(0x4DFDE68A); // Champagne glass border

  // Text Colors (Warm Ivory & Stone)
  static const Color textPrimary = Color(0xFFFAF7F0); // Warm crisp ivory
  static const Color textSecondary = Color(0xFFA19B8F); // Muted warm slate
  static const Color textMuted = Color(0xFF78716C); // Low-contrast stone hint
  static const Color textLight = Colors.white;

  // Dark Theme Neutral Surfaces
  static const Color darkBackground = Color(0xFF06070B);
  static const Color darkSurface = Color(0xFF10131C);
  static const Color darkSurfaceVariant = Color(0xFF161A26);
  static const Color darkBorder = Color(0xFF2B2418);
}
