import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

/// Shared 5-tab Bottom App Bar for Station Desks (Cashier Day Shift &
/// Operational Manager Night Shift) providing one-tap access to Queue, Money,
/// Daily Washer Pool, Shower, and Wash History in both Car and Carpet modes.
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
    final accent = isCarpet ? const Color(0xFFA78BFA) : AppColors.liquidCyanNeon;

    final items = <_StationNavItem>[
      _StationNavItem(
        index: 0,
        icon: Icons.directions_car_filled_rounded,
        label: state.tr('cashierTabQueue') as String,
        tooltip: state.tr('cashierTabQueue') as String,
        badgeCount: activeQueueCount,
      ),
      _StationNavItem(
        index: 1,
        icon: Icons.account_balance_wallet_rounded,
        label: isManager
            ? state.tr('managerTabHandoverClose') as String
            : state.tr('cashierTabMoney') as String,
        tooltip: isManager
            ? state.tr('managerTabHandoverClose') as String
            : state.tr('cashierTabMoney') as String,
        amountChip: CurrencyFormatter.formatShort(drawerOrCustodyCash),
      ),
      _StationNavItem(
        index: 2,
        icon: Icons.groups_rounded,
        label: state.tr('bottomTabPool') as String,
        tooltip: state.tr('dailyWasherCommissionPool') as String,
      ),
      _StationNavItem(
        index: 3,
        icon: Icons.shower_rounded,
        label: state.tr('bottomTabShower') as String,
        tooltip: state.tr('bottomTabShower') as String,
      ),
      _StationNavItem(
        index: 4,
        icon: Icons.history_rounded,
        label: state.tr('cashierTabHistory') as String,
        tooltip: state.tr('cashierTabHistory') as String,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A1628),
        border: Border(
          top: BorderSide(
            color: accent.withValues(alpha: 0.28),
            width: 1.2,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Row(
            children: items.map((item) {
              final isSelected = item.index == selectedIndex;
              return Expanded(
                child: Tooltip(
                  message: item.tooltip,
                  child: InkWell(
                    key: ValueKey('station_bottom_tab_${item.index}'),
                    onTap: () => onTap(item.index),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? accent.withValues(alpha: 0.16)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(color: accent.withValues(alpha: 0.45), width: 1)
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(
                                item.icon,
                                size: 20,
                                color: isSelected ? accent : AppColors.textSecondary,
                              ),
                              if (item.badgeCount != null && item.badgeCount! > 0)
                                Positioned(
                                  top: -5,
                                  right: -10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: accent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${item.badgeCount}',
                                      style: const TextStyle(
                                        color: Color(0xFF060E1A),
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w900,
                                        height: 1.0,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.label,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 9.8,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                              height: 1.08,
                            ),
                          ),
                          if (item.amountChip != null) ...[
                            const SizedBox(height: 1),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                item.amountChip!,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected ? accent : AppColors.cashGreen,
                                  height: 1.0,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _StationNavItem {
  final int index;
  final IconData icon;
  final String label;
  final String tooltip;
  final int? badgeCount;
  final String? amountChip;

  const _StationNavItem({
    required this.index,
    required this.icon,
    required this.label,
    required this.tooltip,
    this.badgeCount,
    this.amountChip,
  });
}
