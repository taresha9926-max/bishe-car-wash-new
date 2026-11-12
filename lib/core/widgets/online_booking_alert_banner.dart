import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../utils/currency_formatter.dart';
import '../utils/sound_notifier.dart';
import '../../features/booking_service/presentation/state/app_state_provider.dart';

/// Polls for new online bookings while mounted on Cashier/Manager dashboards,
/// plays an audible alert beep on arrival, and shows an actionable banner.
class OnlineBookingAlertBanner extends StatefulWidget {
  const OnlineBookingAlertBanner({super.key});

  @override
  State<OnlineBookingAlertBanner> createState() => _OnlineBookingAlertBannerState();
}

class _OnlineBookingAlertBannerState extends State<OnlineBookingAlertBanner> {
  Timer? _pollTimer;
  int _lastSeenEpoch = -1;

  @override
  void initState() {
    super.initState();
    _pollTimer = Timer.periodic(const Duration(seconds: 12), (_) {
      if (!mounted) return;
      AppStateProvider.read(context).pollNewOnlineBookings();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = AppStateProvider.of(context);
    final currentEpoch = state.onlineBookingAlertEpoch;
    if (_lastSeenEpoch == -1) {
      _lastSeenEpoch = currentEpoch;
    } else if (currentEpoch > _lastSeenEpoch) {
      _lastSeenEpoch = currentEpoch;
      playOnlineBookingBeep();
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final alerts = state.pendingOnlineAlerts;
    if (alerts.isEmpty) return const SizedBox.shrink();

    final latest = alerts.first;
    final countBadge = alerts.length > 1 ? ' (${alerts.length})' : '';
    final details = '${latest.customerName} • ${latest.licensePlate} • '
        '${latest.serviceType.localizedName(state.currentLang, isCarpet: latest.isCarpet)} • '
        '${CurrencyFormatter.format(latest.totalPrice)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D9488).withValues(alpha: 0.28),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${state.tr("newOnlineBookingAlertTitle")}$countBadge',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  details,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryDark,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => AppStateProvider.read(context).acknowledgeOnlineAlerts(),
            child: Text(
              state.tr('acknowledgeAlert'),
              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
