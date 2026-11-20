import 'package:flutter_test/flutter_test.dart';
import 'package:bishe_car_wash/features/booking_service/data/repositories/wash_repository_impl.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/bay_station.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_notifier.dart';
import 'package:bishe_car_wash/features/cashier/domain/models/bank_incoming_transaction.dart';
import 'package:bishe_car_wash/features/cashier/domain/models/sentinel_config.dart';

void main() {
  group('Digital Payment Cross-Referencing & Bishe Sentinel Tests', () {
    late AppStateNotifier state;

    setUp(() async {
      final repo = WashRepositoryImpl();
      state = AppStateNotifier(repository: repo);
      await state.loadData();
    });

    test('BankIncomingTransaction model correctly parses and checks status', () {
      final txn = BankIncomingTransaction(
        id: 'txn-1',
        provider: 'telebirr',
        refNo: 'DKK0G3C37O',
        amount: 50.0,
        payerName: 'Rakeb Kassahun',
        payerPhone: '0919****1239',
        rawSms: 'received ETB 50.00 from Rakeb Kassahun... transaction number is DKK0G3C37O',
        matchStatus: 'unmatched',
        receivedAt: DateTime.now(),
      );

      expect(txn.isTelebirr, isTrue);
      expect(txn.isCbe, isFalse);
      expect(txn.isUnmatched, isTrue);
      expect(txn.isMatched, isFalse);
    });

    test('SentinelConfig model correctly identifies online and mode state', () {
      final onlineConfig = SentinelConfig(
        batteryLevel: 85,
        status: 'online',
        lastHeartbeat: DateTime.now().subtract(const Duration(minutes: 2)),
        securityMode: 'flexible',
      );
      expect(onlineConfig.isOnline, isTrue);
      expect(onlineConfig.isFlexible, isTrue);
      expect(onlineConfig.isStrict, isFalse);

      final offlineConfig = SentinelConfig(
        batteryLevel: 10,
        status: 'offline',
        lastHeartbeat: DateTime.now().subtract(const Duration(minutes: 30)),
        securityMode: 'strict',
      );
      expect(offlineConfig.isOnline, isFalse);
      expect(offlineConfig.isStrict, isTrue);
    });

    test('Split Payment correctly divides revenue between Cash drawer and Digital accounts', () async {
      await state.registerWalkIn(
        licensePlate: 'AA-SPLIT-99',
        customerName: 'Dawit Tsige',
        customerPhone: '0912345678',
        package: state.packages.first,
        carType: CarType.automobile,
        assignedBay: BayType.bay1,
        paymentMethod: PaymentMethod.telebirr,
      );

      final booking = state.bookings.firstWhere((b) => b.licensePlate == 'AA-SPLIT-99');
      final total = booking.totalPrice; // typically 450 or 500

      // Split 200 Cash + remainder in Telebirr
      final cashPortion = 200.0;
      final digitalPortion = total - cashPortion;

      await state.processPayment(
        bookingId: booking.id,
        method: PaymentMethod.telebirr,
        amount: total,
        transactionRef: 'DKK99SPLIT1',
        splitCashAmount: cashPortion,
        splitDigitalAmount: digitalPortion,
      );

      final updated = state.bookings.firstWhere((b) => b.id == booking.id);
      expect(updated.payment.isPaid, isTrue);
      expect(updated.payment.isSplit, isTrue);
      expect(updated.payment.splitCashAmount, equals(200.0));
      expect(updated.payment.splitDigitalAmount, equals(digitalPortion));

      // Check drawer contains the cash portion exactly
      expect(state.cashierDrawerBalanceETB, equals(200.0));
      // Digital revenue contains the digital portion
      expect(state.totalDigitalRevenueETB, equals(digitalPortion));
    });

    test('Pre-arrived bank SMS auto-matches when cashier enters matching ref', () async {
      // 1. Sentinel ingests Telebirr SMS from 127
      const telebirrSms =
          'Dear Tariku You have received ETB 500.00 from Senait Tadesse(2519****4455) on 20/11/2026 15:30:00. Your transaction number is DKKMATCH88. Your current E-Money balance is ETB 10,000.00. Thank you for using telebirr Ethio telecom';

      await state.ingestBankSms(
        rawSms: telebirrSms,
        provider: 'telebirr',
      );

      // Verify SMS exists in state
      expect(state.bankIncomingTransactions.any((t) => t.refNo == 'DKKMATCH88'), isTrue);

      // 2. Customer car arrives and is registered
      await state.registerWalkIn(
        licensePlate: 'OR-MATCH-01',
        customerName: 'Senait Tadesse',
        customerPhone: '0919445500',
        package: state.packages.first,
        carType: CarType.automobile,
        assignedBay: BayType.bay2,
        paymentMethod: PaymentMethod.telebirr,
      );

      final booking = state.bookings.firstWhere((b) => b.licensePlate == 'OR-MATCH-01');

      // 3. Cashier processes payment entering the matching ref 'DKKMATCH88'
      await state.processPayment(
        bookingId: booking.id,
        method: PaymentMethod.telebirr,
        amount: booking.totalPrice,
        transactionRef: 'DKKMATCH88',
        receiptScreenshot: 'assets/images/mock_receipt.jpg',
      );

      final paidBooking = state.bookings.firstWhere((b) => b.id == booking.id);
      // It must be automatically verified!
      expect(paidBooking.payment.isBankVerified, isTrue);
      expect(paidBooking.payment.isPendingSms, isFalse);
    });

    test('Post-payment arrival of bank SMS matches previously pending booking', () async {
      // 1. Car arrives and pays before SMS arrives (Policy 1: Flexible Mode)
      await state.registerWalkIn(
        licensePlate: 'ET-DELAY-77',
        customerName: 'Kenenisa Bekele',
        customerPhone: '0911778899',
        package: state.packages.first,
        carType: CarType.automobile,
        assignedBay: BayType.bay2,
        paymentMethod: PaymentMethod.cbeBirr,
      );

      final booking = state.bookings.firstWhere((b) => b.licensePlate == 'ET-DELAY-77');

      await state.processPayment(
        bookingId: booking.id,
        method: PaymentMethod.cbeBirr,
        amount: booking.totalPrice,
        transactionRef: 'v2-hfHCxO9eFffMNPj5SyIp',
        receiptScreenshot: 'assets/images/cbe_screenshot.jpg',
        verificationStatus: 'pending_sms',
      );

      var checkBooking = state.bookings.firstWhere((b) => b.id == booking.id);
      expect(checkBooking.payment.isPendingSms, isTrue);
      expect(checkBooking.payment.isBankVerified, isFalse);

      // 2. Three minutes later, bank SMS arrives on Sentinel phone
      const cbeSms =
          'Dear Tariku Gebretsadik Gebresilasie You have received ETB 500.00 from account 1*********8773 (Kenenisa Bekele) to your account 1*********4388. Your current balance is ETB 30,000.00. Thanks for Banking with CBE. https://mbreciept.cbe.com.et/v2-hfHCxO9eFffMNPj5SyIp for feedback: https://forms.gle/kGNGQpG3mQCCk3iD6';

      await state.ingestBankSms(
        rawSms: cbeSms,
        provider: 'cbe',
      );

      // 3. Booking must now be upgraded to verified
      checkBooking = state.bookings.firstWhere((b) => b.id == booking.id);
      expect(checkBooking.payment.isBankVerified, isTrue);
      expect(checkBooking.payment.isPendingSms, isFalse);
    });

    test('Security mode toggle successfully updates Sentinel configuration', () async {
      expect(state.sentinelConfig?.isFlexible, isTrue);

      await state.setSentinelSecurityMode('strict');
      expect(state.sentinelConfig?.isStrict, isTrue);

      await state.setSentinelSecurityMode('flexible');
      expect(state.sentinelConfig?.isFlexible, isTrue);
    });
  });
}
