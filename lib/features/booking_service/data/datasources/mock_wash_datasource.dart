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
        completedWashesCount: 0,
        totalCommissionEarnedETB: 0.0,
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
        completedWashesCount: 0,
        totalCommissionEarnedETB: 0.0,
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
        completedWashesCount: 0,
        totalCommissionEarnedETB: 0.0,
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
        completedWashesCount: 0,
        totalCommissionEarnedETB: 0.0,
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
        completedWashesCount: 0,
        totalCommissionEarnedETB: 0.0,
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
        completedWashesCount: 0,
        totalCommissionEarnedETB: 0.0,
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
        completedWashesCount: 0,
        totalCommissionEarnedETB: 0.0,
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
        completedWashesCount: 0,
        totalCommissionEarnedETB: 0.0,
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
      const StationBay(
        type: BayType.bay1,
        status: BayStatus.vacant,
      ),
      const StationBay(
        type: BayType.bay2,
        status: BayStatus.vacant,
      ),
      const StationBay(
        type: BayType.mobileVan,
        status: BayStatus.vacant,
      ),
    ];
  }

  static List<WashBooking> getInitialBookings(List<WashPackage> packages) {
    return [];
  }

  static List<CommissionLog> getInitialCommissionLogs() {
    return [];
  }
}
