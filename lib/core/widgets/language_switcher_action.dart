import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../../features/booking_service/presentation/state/app_state_provider.dart';

/// Universal Language Translation Button that renders across all screens,
/// supporting both dark headers (AppRoleHeader) and light headers (AppBar).
class LanguageSwitcherAction extends StatelessWidget {
  final bool isDark;
  final EdgeInsetsGeometry? margin;

  const LanguageSwitcherAction({
    super.key,
    this.isDark = true,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final currentLang = state.currentLang;
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    final bgColor = const Color(0xFF161A26);
    final borderColor = AppColors.cardBorder;
    const textColor = AppColors.textPrimary;
    const iconColor = AppColors.warmGold;

    return Container(
      margin: margin ?? EdgeInsets.symmetric(vertical: isMobile ? 12 : 14, horizontal: 4),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 6 : 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentLang,
          dropdownColor: const Color(0xFF161A26),
          icon: const Icon(Icons.language_rounded, size: 15, color: iconColor),
          items: [
            DropdownMenuItem(
              value: 'EN',
              child: Text('EN', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5, color: textColor)),
            ),
            DropdownMenuItem(
              value: 'OM',
              child: Text('OM', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5, color: textColor)),
            ),
            DropdownMenuItem(
              value: 'AM',
              child: Text('AM', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5, color: textColor)),
            ),
          ],
          onChanged: (lang) {
            if (lang != null && lang != currentLang) {
              state.setLanguage(lang);
            }
          },
        ),
      ),
    );
  }
}
