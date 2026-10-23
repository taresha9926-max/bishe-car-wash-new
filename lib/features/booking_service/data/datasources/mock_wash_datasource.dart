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
        id: 'pkg-standard',
        name: 'Standard Clean',
        description: 'High-pressure wash, snow foam soak, tire cleaning & microfiber dry.',
        durationMinutes: 25,
        pricingByCarType: {
          CarType.automobile: 300.0,
          CarType.minibus: 450.0,
          CarType.truck: 700.0,
        },
        features: [
          'High Pressure Pre-wash',
          'Snow Foam Wash',
          'Tire Gloss',
          'Microfiber Hand Dry',
        ],
      ),
      const WashPackage(
        id: 'pkg-mobile',
        name: 'At-Home Mobile Service',
        description: 'Doorstep car wash across Bishoftu with self-contained water and power.',
        durationMinutes: 35,
        pricingByCarType: {
          CarType.automobile: 500.0,
          CarType.minibus: 700.0,
          CarType.truck: 1050.0,
        },
        features: [
          'At-Your-Door Service in Bishoftu',
          'Onboard Water & Power',
          'Complete Exterior Snow Foam',
          'Tire & Wheel Deep Clean',
        ],
      ),
    ];
  }

  // Exactly 4 washers as specified: Abebe, Chala, Tolosa, Gemechu
  static List<StaffMember> getInitialStaff() {
    return [
      const StaffMember(
        id: 'stf-01',
        name: 'Abebe',
        phone: '+251 91 123 4567',
        role: StaffRole.washer,
        baseSalaryMonthlyETB: 5000.0,
        commissionRate: 0.15,
        isAvailable: true,
        completedWashesCount: 14,
        totalCommissionEarnedETB: 1250.0,
      ),
      const StaffMember(
        id: 'stf-02',
        name: 'Chala',
        phone: '+251 92 234 5678',
        role: StaffRole.washer,
        baseSalaryMonthlyETB: 5000.0,
        commissionRate: 0.15,
        isAvailable: true,
        completedWashesCount: 12,
        totalCommissionEarnedETB: 1100.0,
      ),
      const StaffMember(
        id: 'stf-03',
        name: 'Tolosa',
        phone: '+251 93 345 6789',
        role: StaffRole.washer,
        baseSalaryMonthlyETB: 5000.0,
        commissionRate: 0.15,
        isAvailable: true,
        completedWashesCount: 11,
        totalCommissionEarnedETB: 980.0,
      ),
      const StaffMember(
        id: 'stf-04',
        name: 'Gemechu',
        phone: '+251 94 456 7890',
        role: StaffRole.washer,
        baseSalaryMonthlyETB: 5000.0,
        commissionRate: 0.15,
        isAvailable: true,
        completedWashesCount: 10,
        totalCommissionEarnedETB: 920.0,
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
        assignedWasherName: 'Abebe & Chala',
        startedAt: DateTime.now().subtract(const Duration(minutes: 15)),
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

  static List<WashBooking> getInitialBookings() {
    final packages = getInitialPackages();
    final standardPkg = packages[0];
    final mobilePkg = packages[1];

    return [
      WashBooking(
        id: 'BSH-101',
        customerName: 'Dawit Alemu',
        customerPhone: '+251911445566',
        serviceType: ServiceType.walkInStation,
        carType: CarType.automobile,
        licensePlate: 'ET-3-B48210',
        package: standardPkg,
        status: WashStatus.washing,
        assignedBay: BayType.bay1,
        assignedWasherNames: ['Abebe', 'Chala'],
        origin: BookingOrigin.walkIn,
        payment: const PaymentInfo(
          isPaid: true,
          method: PaymentMethod.telebirr,
          amount: 300.0,
          transactionRef: 'TLB-948271',
        ),
        createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
      ),
      WashBooking(
        id: 'BSH-102',
        customerName: 'Rahel Tadesse',
        customerPhone: '+251922889900',
        serviceType: ServiceType.walkInStation,
        carType: CarType.minibus,
        licensePlate: 'ET-2-A19342',
        package: standardPkg,
        status: WashStatus.pending,
        assignedWasherNames: const [],
        origin: BookingOrigin.onlineCustomer,
        payment: const PaymentInfo(
          isPaid: false,
          method: PaymentMethod.cbeBirr,
          amount: 450.0,
        ),
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
      WashBooking(
        id: 'BSH-103',
        customerName: 'Solomon Kebede',
        customerPhone: '+251933112233',
        serviceType: ServiceType.atHomeMobile,
        deliveryLocation: 'Lake Bishoftu Resort Corridor',
        carType: CarType.truck,
        licensePlate: 'ET-3-C88129',
        package: mobilePkg,
        status: WashStatus.confirmed,
        assignedBay: BayType.mobileVan,
        assignedWasherNames: ['Tolosa', 'Gemechu'],
        origin: BookingOrigin.phoneCall,
        payment: const PaymentInfo(
          isPaid: false,
          method: PaymentMethod.cash,
          amount: 1050.0,
        ),
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ];
  }

  static List<CommissionLog> getInitialCommissions() {
    return [
      CommissionLog(
        id: 'comm-01',
        bookingId: 'BSH-099',
        washerId: 'stf-01',
        washerName: 'Abebe',
        carPlate: 'ET-3-A11223',
        carType: CarType.automobile,
        servicePackageName: 'Walk-in Bay - Type A',
        totalWashPriceETB: 300.0,
        commissionEarnedETB: 22.50, // 15% of 300 / 2
        isSettled: false,
        completedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      CommissionLog(
        id: 'comm-02',
        bookingId: 'BSH-099',
        washerId: 'stf-02',
        washerName: 'Chala',
        carPlate: 'ET-3-A11223',
        carType: CarType.automobile,
        servicePackageName: 'Walk-in Bay - Type A',
        totalWashPriceETB: 300.0,
        commissionEarnedETB: 22.50,
        isSettled: false,
        completedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];
  }
}
