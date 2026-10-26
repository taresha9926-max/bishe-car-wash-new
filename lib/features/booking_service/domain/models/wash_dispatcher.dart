import 'dart:math';
import 'bay_station.dart';
import 'wash_booking.dart';
import 'wash_status.dart';

/// Deep dispatch module encapsulating station concurrency, queue wait-time
/// estimation, and wash lifecycle state machine transitions.
class WashDispatcher {
  /// Calculates estimated start time for a newly queued vehicle at the 2 physical bays.
  static int estimateStationWaitMinutes({
    required int availableBaysCount,
    required List<WashBooking> queue,
    DateTime? now,
  }) {
    if (availableBaysCount > 0 && queue.isEmpty) {
      return 0; // Immediate entry
    }
    if (queue.isEmpty) {
      return 0;
    }

    final currentTime = now ?? DateTime.now();
    int totalRemainingMinutes = 0;
    for (final b in queue) {
      final elapsed = currentTime.difference(b.createdAt).inMinutes;
      final pkgDuration = b.package.durationMinutes > 0 ? b.package.durationMinutes : 25;
      final remaining = max(5, pkgDuration - elapsed);
      totalRemainingMinutes += remaining;
    }

    // Two physical bays service vehicles concurrently in parallel
    final effectiveWait = (totalRemainingMinutes / 2).ceil();
    return max(5, effectiveWait);
  }

  /// Calculates estimated start time for a mobile doorstep service order.
  static int estimateMobileVanWaitMinutes({
    required bool isVanAvailable,
    required List<WashBooking> queue,
    DateTime? now,
  }) {
    if (isVanAvailable && queue.isEmpty) {
      return 0;
    }
    if (queue.isEmpty) {
      return 0;
    }

    final currentTime = now ?? DateTime.now();
    int totalMinutes = 0;
    for (final b in queue) {
      final elapsed = currentTime.difference(b.createdAt).inMinutes;
      final pkgDuration = b.package.durationMinutes > 0 ? b.package.durationMinutes : 40;
      final remaining = max(10, pkgDuration - elapsed);
      totalMinutes += remaining;
    }

    return max(15, totalMinutes);
  }

  /// Evaluates next wash lifecycle transition.
  static WashStatus? nextStatus(WashStatus current) {
    switch (current) {
      case WashStatus.pending:
      case WashStatus.confirmed:
      case WashStatus.assignedToBay:
        return WashStatus.washing;
      case WashStatus.washing:
        return WashStatus.drying;
      case WashStatus.drying:
        return WashStatus.readyForPickup;
      case WashStatus.readyForPickup:
        return WashStatus.completed;
      case WashStatus.completed:
      case WashStatus.cancelled:
        return null;
    }
  }

  /// Correlates a station bay to its active booking.
  static WashBooking? findBookingForBay(StationBay bay, List<WashBooking> bookings) {
    if (bay.activeBookingId == null) return null;
    try {
      return bookings.firstWhere((b) => b.id == bay.activeBookingId);
    } catch (_) {
      return null;
    }
  }

  /// Returns current wash status for a station bay.
  static WashStatus? getBayWashStatus(StationBay bay, List<WashBooking> bookings) {
    return findBookingForBay(bay, bookings)?.status;
  }
}
