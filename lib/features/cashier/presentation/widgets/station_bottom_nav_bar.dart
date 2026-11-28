import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../booking_service/presentation/state/app_state_notifier.dart';

/// Shared 4-item Bottom App Bar for Cashier (Day Shift) and Operational Manager (Night Shift).
/// Eliminates redundant top navigation: Queue / Service View, Money / Closing, Daily Washer Pool, Wash History.
class StationBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final bool isCarpet;
  final int activeQueueCount;
  final double drawerOrCustodyCash;
  final bool isManager;
  final dynamic state;

  const StationBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.isCarpet,
    required this.activeQueueCount,
    required this.drawerOrCustodyCash,
    required this.isManager,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final deskDiv = state.stationDeskDivision as StationDeskDivision;
    final IconData primaryIcon;
    final Color primaryColor;
    final String primaryBadge;

    switch (deskDiv) {
      case StationDeskDivision.carWash:
        primaryIcon = Icons.directions_car_filled_rounded;
        primaryColor = AppColors.primary;
        primaryBadge = '$activeQueueCount';
        break;
      case StationDeskDivision.carpetWash:
        primaryIcon = Icons.texture_rounded;
        primaryColor = const Color(0xFF7C3AED);
        primaryBadge = '$activeQueueCount';
        break;
      case StationDeskDivision.shower:
        primaryIcon = Icons.shower_rounded;
        primaryColor = const Color(0xFF0EA5E9);
        primaryBadge = '${state.todayShowerUserCount}';
        break;
      case StationDeskDivision.retail:
        primaryIcon = Icons.shopping_bag_rounded;
        primaryColor = const Color(0xFFD97706);
        primaryBadge = '${state.todayRetailSalesCount}';
        break;
    }

    final items = [
      _NavItemData(
        key: const ValueKey('station_bottom_tab_0'),
        icon: primaryIcon,
        label: state.tr('cashierTabQueue') as String,
        badge: primaryBadge,
        activeColor: primaryColor,
      ),
      _NavItemData(
        key: const ValueKey('station_bottom_tab_1'),
        icon: Icons.account_balance_wallet_rounded,
        label: isManager
            ? state.tr('managerTabHandoverClose') as String
            : state.tr('cashierTabMoney') as String,
        badge: CurrencyFormatter.formatShort(drawerOrCustodyCash),
        activeColor: const Color(0xFF0EA5E9),
      ),
      _NavItemData(
        key: const ValueKey('station_bottom_tab_2'),
        icon: Icons.groups_rounded,
        label: state.tr('bottomTabPool') as String,
        activeColor: const Color(0xFF10B981),
      ),
      _NavItemData(
        key: const ValueKey('station_bottom_tab_3'),
        icon: Icons.history_rounded,
        label: state.tr('cashierTabHistory') as String,
        activeColor: const Color(0xFFF59E0B),
      ),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(top: BorderSide(color: AppColors.cardBorder, width: 1.2)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final selected = selectedIndex == i;
              return Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    key: item.key,
                    onTap: () => onTap(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected ? item.activeColor.withValues(alpha: 0.14) : Colors.transparent,
                        border: Border(
                          top: BorderSide(
                            color: selected ? item.activeColor : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(
                                item.icon,
                                size: 21,
                                color: selected ? item.activeColor : AppColors.textMuted,
                              ),
                              if (item.badge != null)
                                Positioned(
                                  right: -22,
                                  top: -5,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: selected ? item.activeColor : const Color(0xFF1E293B),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: selected ? item.activeColor : AppColors.cardBorder,
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Text(
                                      item.badge!,
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: selected ? Colors.white : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              item.label,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                                color: selected ? Colors.white : AppColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final Key key;
  final IconData icon;
  final String label;
  final String? badge;
  final Color activeColor;

  const _NavItemData({
    required this.key,
    required this.icon,
    required this.label,
    required this.activeColor,
    this.badge,
  });
}
