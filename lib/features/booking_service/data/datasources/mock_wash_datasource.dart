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
      const StaffCredential(
        id: 'cred-storekeeper',
        username: 'storekeeper',
        pin: '3344',
        role: UserRole.storekeeper,
        fullName: 'Inventory Storekeeper',
        isActive: true,
      ),
      const StaffCredential(
        id: 'cred-accountant',
        username: 'accountant',
        pin: '5566',
        role: UserRole.accountant,
        fullName: 'Finance Accountant',
        isActive: true,
      ),
    ];
  }

  static List<WashPackage> getInitialPackages() {
    return [
      const WashPackage(
        id: 'a0000000-0000-0000-0000-000000000101',
        name: 'Basic / Silver Package',
        description: 'High pressure pre-wash, touchless snow foam, rims/tire clean & microfiber hand dry.',
        durationMinutes: 25,
        pricingByCarType: {
          CarType.automobile: 500.0,
          CarType.minibus: 700.0,
          CarType.truck: 1200.0,
        },
        features: [
          'High-pressure undercarriage & wheel arch pre-rinse',
          'Touchless snow foam body soak',
          'Hand wash with microfiber mitts',
          'Rims & tire surface cleaning',
          'Spot-free rinse & streak-free microfiber hand dry',
        ],
      ),
      const WashPackage(
        id: 'a0000000-0000-0000-0000-000000000102',
        name: 'Gold Package (Polish)',
        description: 'Basic wash plus machine high-gloss body polish & tire protection shine.',
        durationMinutes: 40,
        pricingByCarType: {
          CarType.automobile: 1500.0,
          CarType.minibus: 2100.0,
          CarType.truck: 2800.0,
        },
        features: [
          'Complete Basic / Silver Wash included',
          'Machine high-gloss body polish application',
          'Long-lasting silicone tire dressing & shine',
          'Exterior glass polish & door jamb wipe-down',
        ],
      ),
      const WashPackage(
        id: 'a0000000-0000-0000-0000-000000000103',
        name: 'Platinum Interior Detailing',
        description: 'Complete cabin restoration: all passenger seats & carpets removed, washed & steam sanitized.',
        durationMinutes: 75,
        pricingByCarType: {
          CarType.automobile: 5000.0,
          CarType.minibus: 8000.0,
          CarType.truck: 10000.0,
        },
        features: [
          'All passenger seats removed for extraction',
          'Floor carpets shampooed & pressure washed',
          'Roof lining high-heat steam sanitization',
          'Dashboard, vents, glove box & console detailing',
          'Air conditioning duct deodorization',
          'Leather conditioning / upholstery UV shield',
        ],
      ),
      const WashPackage(
        id: 'a0000000-0000-0000-0000-000000000104',
        name: 'Platinum Exterior - Level A',
        description: 'Machine body polish plus chemical mineral hard water spot removal.',
        durationMinutes: 60,
        pricingByCarType: {
          CarType.automobile: 5600.0,
          CarType.minibus: 9000.0,
          CarType.truck: 12000.0,
        },
        features: [
          'Full exterior hand wash & clay bar decontamination',
          'Machine paint correction & gloss enhancement',
          'Chemical removal of Bishoftu lake water spots',
          'Hydrophobic paint sealant protection',
        ],
      ),
      const WashPackage(
        id: 'a0000000-0000-0000-0000-000000000105',
        name: 'Platinum Exterior - Level B',
        description: 'Body polish, water spot removal plus deep wheel arch, rim & tire detailing.',
        durationMinutes: 70,
        pricingByCarType: {
          CarType.automobile: 6000.0,
          CarType.minibus: 9500.0,
          CarType.truck: 13000.0,
        },
        features: [
          'All Platinum Exterior Level A services included',
          'Brake dust removal & wheel well acid wash',
          'Ceramic rim protective gloss coating',
          'Exterior plastic trim & bumper restoration',
        ],
      ),
      const WashPackage(
        id: 'a0000000-0000-0000-0000-000000000106',
        name: 'Platinum Exterior - Level C',
        description: 'Complete exterior suite: body polish, water spot, tire detailing & headlight restoration.',
        durationMinutes: 85,
        pricingByCarType: {
          CarType.automobile: 8000.0,
          CarType.minibus: 12500.0,
          CarType.truck: 16000.0,
        },
        features: [
          'All Platinum Exterior Level A & B services included',
          'Dual-stage headlight wet-sanding & UV yellowing removal',
          'Chrome & metal trim brightening polish',
          'Hydrophobic rain-repellent windshield treatment',
        ],
      ),
      const WashPackage(
        id: 'a0000000-0000-0000-0000-000000000107',
        name: 'Diamond Package A',
        description: 'All-in-one bundle: Full Platinum Interior Detailing + Platinum Exterior Level A.',
        durationMinutes: 110,
        pricingByCarType: {
          CarType.automobile: 10600.0,
          CarType.minibus: 17000.0,
          CarType.truck: 22000.0,
        },
        features: [
          'Full Platinum Interior Detailing (seats & carpets out)',
          'Machine body polish & paint correction',
          'Mineral hard water spot removal',
          'Cabin antibacterial steam sanitization',
        ],
      ),
      const WashPackage(
        id: 'a0000000-0000-0000-0000-000000000108',
        name: 'Diamond Package B',
        description: 'All-in-one bundle: Full Platinum Interior Detailing + Platinum Exterior Level B.',
        durationMinutes: 120,
        pricingByCarType: {
          CarType.automobile: 11000.0,
          CarType.minibus: 17500.0,
          CarType.truck: 23000.0,
        },
        features: [
          'Full Platinum Interior Detailing (seats & carpets out)',
          'Machine body polish & water spot removal',
          'Deep wheel arch, rim & tire detailing',
          'Engine compartment dress & UV interior balm',
        ],
      ),
      const WashPackage(
        id: 'a0000000-0000-0000-0000-000000000109',
        name: 'Diamond Full Package',
        description: 'The ultimate showroom detail: Full Platinum Interior + Complete Platinum Exterior Level C.',
        durationMinutes: 150,
        pricingByCarType: {
          CarType.automobile: 13000.0,
          CarType.minibus: 20500.0,
          CarType.truck: 26000.0,
        },
        features: [
          'Complete Platinum Interior Detailing (seats & carpets out)',
          'Complete Platinum Exterior Level C Suite',
          'Dual-stage headlight restoration & ceramic seal',
          'Complete air conditioning deodorization & engine wipe',
        ],
      ),
      const WashPackage(
        id: 'a0000000-0000-0000-0000-000000000110',
        name: 'Engine Chemical Cleaning',
        description: 'Basic / Silver wash + safe chemical engine degreaser, controlled rinse & hose conditioning.',
        durationMinutes: 45,
        pricingByCarType: {
          CarType.automobile: 1700.0,
          CarType.minibus: 2400.0,
          CarType.truck: 3500.0,
        },
        features: [
          'Basic / Silver exterior body wash included',
          'Safe chemical degreaser on engine block & firewall',
          'Low-pressure controlled grime rinse',
          'Silicone hose & rubber component conditioning',
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
