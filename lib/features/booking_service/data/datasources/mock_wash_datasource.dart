import 'package:bishe_car_wash/features/admin/domain/models/commission_log.dart';
import 'package:bishe_car_wash/features/admin/domain/models/staff_credential.dart';
import 'package:bishe_car_wash/features/admin/domain/models/staff_member.dart';
import 'package:bishe_car_wash/features/auth_roles/domain/models/user_role.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/bay_station.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/service_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_booking.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_package.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_status.dart';

class MockWashDataSource {
  static List<StaffCredential> getInitialCredentials() {
    return [
      const StaffCredential(
        id: 'cred-admin',
        username: 'admin',
        pin: '1234',
        role: UserRole.admin,
        fullName: 'Bishe Super Admin',
        isActive: true,
      ),
      const StaffCredential(
        id: 'cred-cashier',
        username: 'cashier',
        pin: '0000',
        role: UserRole.cashier,
        fullName: 'Station Gate Cashier',
        isActive: true,
      ),
    ];
  }

  static List<WashPackage> getInitialPackages() {
    return [
      const WashPackage(
        id: 'pkg-silver',
        name: 'Basic / Silver Package',
        description: 'Basic wash for exterior body and glass clean.',
        durationMinutes: 25,
        pricingByCarType: {
          CarType.automobile: 500.0,
          CarType.minibus: 700.0,
        },
        features: [
          'High Pressure Pre-wash',
          'Touchless Body Wash',
          'Rims & Tire Clean',
          'Microfiber Hand Dry',
        ],
      ),
      const WashPackage(
        id: 'pkg-gold',
        name: 'Gold Package (Polish)',
        description: 'Basic wash plus premium protective body polish.',
        durationMinutes: 40,
        pricingByCarType: {
          CarType.automobile: 1500.0,
          CarType.minibus: 2100.0,
        },
        features: [
          'Basic Exterior Wash',
          'High Gloss Body Polish',
          'Tire Gloss & Protection',
          'Door Jambs & Glass Wipe',
        ],
      ),
      const WashPackage(
        id: 'pkg-plat-interior',
        name: 'Platinum Interior Detailing',
        description: 'Seat & floor carpet removed & washing + roof deep cleaning + dashboard detailing.',
        durationMinutes: 75,
        pricingByCarType: {
          CarType.automobile: 5000.0,
          CarType.minibus: 8000.0,
        },
        features: [
          'Seats & Floor Carpet Removed & Washed',
          'Deep Roof Lining Clean',
          'Dashboard & AC Vents Detailing',
          'Leather / Fabric Conditioning',
        ],
      ),
      const WashPackage(
        id: 'pkg-plat-ext-a',
        name: 'Platinum Exterior - A',
        description: 'Body Polish + Water Spot removal and gloss treatment.',
        durationMinutes: 60,
        pricingByCarType: {
          CarType.automobile: 5600.0,
          CarType.minibus: 9000.0,
        },
        features: [
          'Hand Wash & Clay Bar Treatment',
          'Machine Body Polish',
          'Hard Water Spot Removal',
          'Hydrophobic Paint Sealant',
        ],
      ),
      const WashPackage(
        id: 'pkg-plat-ext-b',
        name: 'Platinum Exterior - B',
        description: 'Body + Water Spot + Tire Detailing & rim protection.',
        durationMinutes: 70,
        pricingByCarType: {
          CarType.automobile: 6000.0,
          CarType.minibus: 9500.0,
        },
        features: [
          'All Platinum Exterior A Services',
          'Deep Tire & Wheel Well Detailing',
          'Ceramic Rim Gloss Coat',
          'Exterior Plastic & Trim Dressing',
        ],
      ),
      const WashPackage(
        id: 'pkg-plat-ext-c',
        name: 'Platinum Exterior - C',
        description: 'Body + Water Spot + Tire Detailing + Headlight restoration.',
        durationMinutes: 85,
        pricingByCarType: {
          CarType.automobile: 8000.0,
          CarType.minibus: 12500.0,
        },
        features: [
          'All Platinum Exterior B Services',
          'Headlight Wet Sanding & UV Restoration',
          'Chrome & Metal Brightening',
          'Long-lasting Protective Sealant',
        ],
      ),
      const WashPackage(
        id: 'pkg-diamond-a',
        name: 'Diamond Package A',
        description: 'Interior Full Detailing & Body Polish + Water Spot treatment.',
        durationMinutes: 110,
        pricingByCarType: {
          CarType.automobile: 10600.0,
          CarType.minibus: 17000.0,
        },
        features: [
          'Full Interior Carpet & Seat Detailing',
          'Body High Gloss Machine Polish',
          'Mineral Water Spot Removal',
          'Cabin Steam Sanitization',
        ],
      ),
      const WashPackage(
        id: 'pkg-diamond-b',
        name: 'Diamond Package B',
        description: 'Interior Full Detailing & Body + Water Spot + Tire Detailing.',
        durationMinutes: 120,
        pricingByCarType: {
          CarType.automobile: 11000.0,
          CarType.minibus: 17500.0,
        },
        features: [
          'All Diamond Package A Services',
          'Full Wheel Arch & Tire Detailing',
          'Engine Compartment Dressing',
          'Leather Balm & Dashboard UV Shield',
        ],
      ),
      const WashPackage(
        id: 'pkg-diamond-full',
        name: 'Diamond Full Package',
        description: 'Ultimate Interior Detailing + Exterior Comprehensive detailing suite.',
        durationMinutes: 150,
        pricingByCarType: {
          CarType.automobile: 13000.0,
          CarType.minibus: 20500.0,
        },
        features: [
          'Complete Platinum Interior Detailing',
          'Complete Platinum Exterior C Suite',
          'Headlight Restoration & Ceramic Spray',
          'Air Conditioning Deodorization',
        ],
      ),
      const WashPackage(
        id: 'pkg-engine-chem',
        name: 'Engine Chemical Cleaning',
        description: 'Basic / Silver package wash + professional engine chemical degrease.',
        durationMinutes: 45,
        pricingByCarType: {
          CarType.automobile: 1700.0,
          CarType.minibus: 2400.0,
        },
        features: [
          'Basic / Silver Exterior Body Wash',
          'Safe Chemical Engine Degreasing',
          'High Pressure Dirt Rinse',
          'Silicone Engine Hose Conditioning',
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
        role: StaffRole.leadDetailer,
        baseSalaryMonthlyETB: 5800.0,
        commissionRate: 0.15,
        isAvailable: true,
        completedWashesCount: 22,
        totalCommissionEarnedETB: 2450.0,
        skillSeniorityLevel: 4,
      ),
      const StaffMember(
        id: 'stf-02',
        name: 'Kedir Tolosa',
        phone: '+251 92 345 6789',
        role: StaffRole.washer,
        baseSalaryMonthlyETB: 5000.0,
        commissionRate: 0.15,
        isAvailable: true,
        completedWashesCount: 19,
        totalCommissionEarnedETB: 1950.0,
        skillSeniorityLevel: 3,
      ),
      const StaffMember(
        id: 'stf-03',
        name: 'Tigist Mengistu',
        phone: '+251 93 456 7890',
        role: StaffRole.leadDetailer,
        baseSalaryMonthlyETB: 5800.0,
        commissionRate: 0.15,
        isAvailable: true,
        completedWashesCount: 21,
        totalCommissionEarnedETB: 2200.0,
        skillSeniorityLevel: 4,
      ),
      const StaffMember(
        id: 'stf-04',
        name: 'Gemechu Desta',
        phone: '+251 94 567 8901',
        role: StaffRole.washer,
        baseSalaryMonthlyETB: 4800.0,
        commissionRate: 0.15,
        isAvailable: true,
        completedWashesCount: 17,
        totalCommissionEarnedETB: 1750.0,
        skillSeniorityLevel: 3,
      ),
      const StaffMember(
        id: 'stf-05',
        name: 'Dawit Haile',
        phone: '+251 95 678 9012',
        role: StaffRole.washer,
        baseSalaryMonthlyETB: 4600.0,
        commissionRate: 0.15,
        isAvailable: true,
        completedWashesCount: 15,
        totalCommissionEarnedETB: 1550.0,
        skillSeniorityLevel: 2,
      ),
      const StaffMember(
        id: 'stf-06',
        name: 'Chala Lemma',
        phone: '+251 96 789 0123',
        role: StaffRole.washer,
        baseSalaryMonthlyETB: 4600.0,
        commissionRate: 0.15,
        isAvailable: true,
        completedWashesCount: 14,
        totalCommissionEarnedETB: 1400.0,
        skillSeniorityLevel: 2,
      ),
      const StaffMember(
        id: 'stf-07',
        name: 'Biniam Tesfaye',
        phone: '+251 97 890 1234',
        role: StaffRole.washer,
        baseSalaryMonthlyETB: 4200.0,
        commissionRate: 0.15,
        isAvailable: true,
        completedWashesCount: 12,
        totalCommissionEarnedETB: 1200.0,
        skillSeniorityLevel: 1,
      ),
      const StaffMember(
        id: 'stf-08',
        name: 'Robel Girma',
        phone: '+251 98 901 2345',
        role: StaffRole.washer,
        baseSalaryMonthlyETB: 4200.0,
        commissionRate: 0.15,
        isAvailable: true,
        completedWashesCount: 11,
        totalCommissionEarnedETB: 1100.0,
        skillSeniorityLevel: 1,
      ),
      const StaffMember(
        id: 'stf-09',
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
        carType: CarType.minibus,
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
        carType: CarType.minibus,
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
