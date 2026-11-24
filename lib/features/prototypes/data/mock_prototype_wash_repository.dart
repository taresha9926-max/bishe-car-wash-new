import 'package:bishe_car_wash/features/booking_service/data/repositories/wash_repository_impl.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/bay_station.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_booking.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_status.dart';
import 'package:bishe_car_wash/features/prototypes/domain/models/prototype_model_type.dart';

/// Hermetic in-memory mock repository for Phase 1 prototype evaluation.
/// Extends [WashRepositoryImpl] to leverage existing seeded collections without
/// writing duplicate boilerplate, and operates with zero network egress (Rule 9 & 10).
class MockPrototypeWashRepository extends WashRepositoryImpl {
  final bool isHermeticSandbox = true;

  final List<WashBooking> _prototypeBookings = [];

  MockPrototypeWashRepository() : super();

  /// Returns simulated station telemetry for Prototype 2.
  StationTelemetrySnapshot getStationTelemetrySnapshot() {
    return const StationTelemetrySnapshot(
      totalBays: 2,
      availableBays: 1,
      activeQueueCount: 2,
      estimatedWaitMinutes: 10,
      activeWashersCount: 4,
    );
  }

  @override
  Future<List<WashBooking>> getBookings() async {
    final base = await super.getBookings();
    return [...base, ..._prototypeBookings];
  }

  @override
  Future<WashBooking> createBooking(WashBooking booking) async {
    // Determine assigned bay or queue ticket
    final assignedBay = booking.assignedBay ?? BayType.bay1;
    final finalized = booking.copyWith(
      id: 'proto-${DateTime.now().millisecondsSinceEpoch}',
      status: WashStatus.assignedToBay,
      assignedBay: assignedBay,
      createdAt: DateTime.now(),
    );
    _prototypeBookings.add(finalized);
    return finalized;
  }
}
