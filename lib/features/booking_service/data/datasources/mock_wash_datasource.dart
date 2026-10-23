import 'package:bishe_car_wash/features/admin/domain/models/commission_log.dart';
import 'package:bishe_car_wash/features/admin/domain/models/staff_member.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/bay_station.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/service_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_booking.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_package.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_status.dart';

class MockWashDataSource {
  static List<WashPackage> getInitialPackages() {
    return [
      const WashPackage(
        id: 'pkg-express',
        name: 'Express Foam Wash',
        description: 'High-pressure water rinse, active snow foam soak, tire shine & hand dry.',
        durationMinutes: 25,
        pricingByCarType: {
          CarType.automobile: 300.0,
          CarType.minibus: 450.0,
          CarType.truck: 600.0,
        },
        features: [
          'High Pressure Pre-wash',
          'Touchless Snow Foam',
          'Rims & Tire Gloss',
          'Microfiber Hand Dry',
        ],
      ),
      const WashPackage(
        id: 'pkg-standard',
        name: 'Standard Clean & Vacuum',
        description: 'Complete exterior body wash plus deep interior vacuum, dashboard wipe & glass cleaning.',
        durationMinutes: 45,
        pricingByCarType: {
          CarType.automobile: 500.0,
          CarType.minibus: 750.0,
          CarType.truck: 950.0,
        },
        features: [
          'Full Exterior Foam Wash',
          'Interior Floor & Seat Vacuum',
          'Dashboard & Console Dressing',
          'Door Jambs & Windows Clean',
          'Fresh Air Freshener',
        ],
      ),
      const WashPackage(
        id: 'pkg-executive',
        name: 'Executive Detailing & Wax',
        description: 'Showroom finish with clay treatment, machine paste wax, leather balm & underbody wash.',
        durationMinutes: 80,
        pricingByCarType: {
          CarType.automobile: 1100.0,
          CarType.minibus: 1550.0,
          CarType.truck: 1950.0,
        },
        features: [
          'Premium Ceramic Foam',
          'Engine Bay Degreasing',
          'Underbody Mud Flush',
          'Leather Seat Deep Clean & Balm',
          'High Gloss Synthetic Wax Shield',
        ],
      ),
      const WashPackage(
        id: 'pkg-engine-chassis',
        name: 'Chassis & Engine Flush',
        description: 'Targeted high-pressure undercarriage rust prevention wash & safe steam engine bay degrease.',
        durationMinutes: 40,
        pricingByCarType: {
          CarType.automobile: 450.0,
          CarType.minibus: 650.0,
          CarType.truck: 850.0,
        },
        features: [
          'Chassis Ramp High Pressure Blast',
          'Road Tar & Salt Removal',
          'Engine Degrease & Dressing',
          'Anti-Corrosion Underspray',
        ],
      ),
    ];
  }

  static List<StaffMember> getInitialStaff() {
    return [
      const StaffMember(
        id: 'stf-01',
        name: 'Abebe Chala',
        phone: '+251 91 123 4567',
        role: StaffRole.washer,
        baseSalaryMonthlyETB: 5000.0,
        commissionRate: 0.15,
        isAvailable: false,
        completedWashesCount: 14,
        totalCommissionEarnedETB: 1125.0,
      ),
      const StaffMember(
        id: 'stf-02',
        name: 'Kedir Tolosa',
        phone: '+251 92 345 6789',
        role: StaffRole.washer,
        baseSalaryMonthlyETB: 4500.0,
        commissionRate: 0.15,
        isAvailable: true,
        completedWashesCount: 11,
        totalCommissionEarnedETB: 880.0,
      ),
      const StaffMember(
        id: 'stf-03',
        name: 'Tigist Mengistu',
        phone: '+251 93 456 7890',
        role: StaffRole.leadDetailer,
        baseSalaryMonthlyETB: 5800.0,
        commissionRate: 0.18,
        isAvailable: true,
        completedWashesCount: 18,
        totalCommissionEarnedETB: 2340.0,
      ),
      const StaffMember(
        id: 'stf-04',
        name: 'Gemechu Desta',
        phone: '+251 94 567 8901',
        role: StaffRole.washer,
        baseSalaryMonthlyETB: 5200.0,
        commissionRate: 0.20,
        isAvailable: false,
        completedWashesCount: 9,
        totalCommissionEarnedETB: 1260.0,
      ),
      const StaffMember(
        id: 'stf-05',
        name: 'Hana Bekele',
        phone: '+251 91 987 6543',
        role: StaffRole.cashier,
        baseSalaryMonthlyETB: 6000.0,
        commissionRate: 0.0,
        isAvailable: true,
        completedWashesCount: 0,
        totalCommissionEarnedETB: 0.0,
      ),
    ];
  }

  static List<StationBay> getInitialBays() {
    return [
      StationBay(
        type: BayType.bay1,
        status: BayStatus.occupied,
        activeBookingId: 'BSH-101',
        activeLicensePlate: 'ET-3-B48210',
        assignedWasherName: 'Abebe Chala',
        startedAt: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      const StationBay(
        type: BayType.bay2,
        status: BayStatus.vacant,
      ),
      StationBay(
        type: BayType.mobileVan,
        status: BayStatus.occupied,
        activeBookingId: 'BSH-102',
        activeLicensePlate: 'ET-1-A90234',
        assignedWasherName: 'Gemechu Desta',
        startedAt: DateTime.now().subtract(const Duration(minutes: 35)),
      ),
    ];
  }

  static List<WashBooking> getInitialBookings(List<WashPackage> packages) {
    final standardPkg = packages[1]; // Standard Clean
    final expressPkg = packages[0];  // Express
    final executivePkg = packages[2];// Executive

    return [
      WashBooking(
        id: 'BSH-101',
        customerName: 'Dawit Yohannes',
        customerPhone: '+251 91 222 3344',
        serviceType: ServiceType.walkInStation,
        carType: CarType.automobile,
        licensePlate: 'ET-3-B48210',
        package: standardPkg,
        status: WashStatus.washing,
        assignedBay: BayType.bay1,
        assignedWasherId: 'stf-01',
        assignedWasherName: 'Abebe Chala',
        payment: const PaymentInfo(
          isPaid: true,
          method: PaymentMethod.telebirr,
          amount: 500.0,
          transactionRef: 'TB-98321045',
        ),
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      WashBooking(
        id: 'BSH-102',
        customerName: 'Saba Tadesse',
        customerPhone: '+251 92 777 8899',
        serviceType: ServiceType.atHomeMobile,
        deliveryLocation: 'Kuriftu Resort Villa 12, Bishoftu',
        carType: CarType.truck,
        licensePlate: 'ET-1-A90234',
        package: executivePkg,
        status: WashStatus.drying,
        assignedBay: BayType.mobileVan,
        assignedWasherId: 'stf-04',
        assignedWasherName: 'Gemechu Desta',
        payment: const PaymentInfo(
          isPaid: false,
          method: PaymentMethod.cash,
          amount: 1950.0,
        ),
        createdAt: DateTime.now().subtract(const Duration(minutes: 50)),
      ),
      WashBooking(
        id: 'BSH-103',
        customerName: 'Biruk Bekele',
        customerPhone: '+251 93 111 4455',
        serviceType: ServiceType.walkInStation,
        carType: CarType.minibus,
        licensePlate: 'ET-3-M54321',
        package: expressPkg,
        status: WashStatus.pending,
        payment: const PaymentInfo(
          isPaid: false,
          method: PaymentMethod.cbeBirr,
          amount: 450.0,
        ),
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
      WashBooking(
        id: 'BSH-100',
        customerName: 'Rahel Girma',
        customerPhone: '+251 91 666 5544',
        serviceType: ServiceType.walkInStation,
        carType: CarType.automobile,
        licensePlate: 'ET-3-A11223',
        package: expressPkg,
        status: WashStatus.completed,
        assignedBay: BayType.bay2,
        assignedWasherId: 'stf-02',
        assignedWasherName: 'Kedir Tolosa',
        payment: const PaymentInfo(
          isPaid: true,
          method: PaymentMethod.cash,
          amount: 300.0,
          paidAt: null,
        ),
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        completedAt: DateTime.now().subtract(const Duration(hours: 1)),
        commissionLogged: true,
      ),
    ];
  }

  static List<CommissionLog> getInitialCommissionLogs() {
    return [
      CommissionLog(
        id: 'COM-001',
        bookingId: 'BSH-100',
        washerId: 'stf-02',
        washerName: 'Kedir Tolosa',
        carPlate: 'ET-3-A11223',
        carType: CarType.automobile,
        servicePackageName: 'Express Foam Wash',
        totalWashPriceETB: 300.0,
        commissionRate: 0.15,
        commissionEarnedETB: 45.0,
        completedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      CommissionLog(
        id: 'COM-000',
        bookingId: 'BSH-099',
        washerId: 'stf-03',
        washerName: 'Tigist Mengistu',
        carPlate: 'ET-2-C99881',
        carType: CarType.truck,
        servicePackageName: 'Executive Detailing & Wax',
        totalWashPriceETB: 1950.0,
        commissionRate: 0.18,
        commissionEarnedETB: 351.0,
        completedAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      CommissionLog(
        id: 'COM-000b',
        bookingId: 'BSH-098',
        washerId: 'stf-01',
        washerName: 'Abebe Chala',
        carPlate: 'ET-3-M77889',
        carType: CarType.minibus,
        servicePackageName: 'Standard Clean & Vacuum',
        totalWashPriceETB: 750.0,
        commissionRate: 0.15,
        commissionEarnedETB: 112.5,
        completedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ];
  }
}
