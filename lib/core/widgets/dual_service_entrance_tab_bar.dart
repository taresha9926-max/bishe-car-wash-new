import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../../features/booking_service/presentation/state/app_state_notifier.dart';
import '../../features/booking_service/presentation/state/app_state_provider.dart';

/// Top 4-Card Service Switcher for Cashier (Day Shift) and Operational Manager (Night Shift):
/// [Car Washing Service] [Carpet Washing Service] [Shower Service] [Retail Item Sales].
/// Tapping any card switches the active station desk exclusively to that service.
class DualServiceEntranceTabBar extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onServiceSelected;

  const DualServiceEntranceTabBar({
    super.key,
    this.padding,
    this.onServiceSelected,
  });

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final active = state.stationDeskDivision;

    final cards = [
      _ServiceCardConfig(
        key: const ValueKey('desk_service_card_car'),
        division: StationDeskDivision.carWash,
        label: state.tr('carWashingService'),
        icon: Icons.directions_car_filled_rounded,
        accent: AppColors.primary,
        badgeCount: state.bookings
            .where((b) => !b.isCarpet && b.status.name != 'cancelled' && !(b.status.name == 'completed' && b.payment.isPaid) && !(b.status.name == 'readyForPickup' && b.payment.isPaid))
            .length,
      ),
      _ServiceCardConfig(
        key: const ValueKey('desk_service_card_carpet'),
        division: StationDeskDivision.carpetWash,
        label: state.tr('carpetWashingService'),
        icon: Icons.texture_rounded,
        accent: const Color(0xFF7C3AED),
        badgeCount: state.bookings
            .where((b) => b.isCarpet && b.status.name != 'cancelled' && !(b.status.name == 'completed' && b.payment.isPaid) && !(b.status.name == 'readyForPickup' && b.payment.isPaid))
            .length,
      ),
      _ServiceCardConfig(
        key: const ValueKey('desk_service_card_shower'),
        division: StationDeskDivision.shower,
        label: state.tr('stationShowerService'),
        icon: Icons.shower_rounded,
        accent: const Color(0xFF0EA5E9),
        badgeCount: state.todayShowerUserCount,
      ),
      _ServiceCardConfig(
        key: const ValueKey('desk_service_card_retail'),
        division: StationDeskDivision.retail,
        label: state.tr('retailSalesTitle'),
        icon: Icons.shopping_bag_rounded,
        accent: const Color(0xFFD97706),
        badgeCount: state.todayRetailSalesCount,
      ),
    ];

    Widget buildCard(_ServiceCardConfig cfg) {
      final isSelected = active == cfg.division;
      return Material(
        color: Colors.transparent,
        child: InkWell(
          key: cfg.key,
          onTap: () {
            state.selectStationDeskDivision(cfg.division);
            onServiceSelected?.call();
          },
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        cfg.accent.withValues(alpha: 0.28),
                        cfg.accent.withValues(alpha: 0.14),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isSelected ? null : const Color(0xFF111827),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? cfg.accent : AppColors.cardBorder,
                width: isSelected ? 1.6 : 1.0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: cfg.accent.withValues(alpha: 0.22),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: cfg.accent.withValues(alpha: isSelected ? 0.25 : 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(cfg.icon, size: 17, color: isSelected ? Colors.white : cfg.accent),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    cfg.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      height: 1.15,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
                if (cfg.badgeCount > 0) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected ? cfg.accent : cfg.accent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${cfg.badgeCount}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: isSelected ? Colors.white : cfg.accent,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 680) {
            return Row(
              children: [
                for (int i = 0; i < cards.length; i++) ...[
                  Expanded(child: buildCard(cards[i])),
                  if (i < cards.length - 1) const SizedBox(width: 8),
                ],
              ],
            );
          }
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: buildCard(cards[0])),
                  const SizedBox(width: 8),
                  Expanded(child: buildCard(cards[1])),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: buildCard(cards[2])),
                  const SizedBox(width: 8),
                  Expanded(child: buildCard(cards[3])),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ServiceCardConfig {
  final Key key;
  final StationDeskDivision division;
  final String label;
  final IconData icon;
  final Color accent;
  final int badgeCount;

  const _ServiceCardConfig({
    required this.key,
    required this.division,
    required this.label,
    required this.icon,
    required this.accent,
    required this.badgeCount,
  });
}
