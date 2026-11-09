import 'package:flutter_test/flutter_test.dart';
import 'package:bishe_car_wash/core/localization/app_strings.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_wash_service_item.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_booking.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/service_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_package.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';

void main() {
  group('Car Wash Master Table Trilingual (EN, AM, OM) Verification', () {
    final items = CarWashServiceItem.getInitialServiceItems();

    test('All initial services have exact Master Table Amharic and Afaan Oromoo translations', () {
      final bodyWash = items.firstWhere((i) => i.id == 'srv_body_wash');
      expect(bodyWash.localizedName(AppLanguage.en), 'Body Hand Wash with Shampoo & Fiber Towel');
      expect(bodyWash.localizedName(AppLanguage.am), 'የመኪና አካል በሻምፖ እና በፋይበር ፎጣ እጥበት');
      expect(bodyWash.localizedName(AppLanguage.om), 'Dhiqannaa qaama konkolaataa shaamപ്പോ fi fooxaa faayiberiitiin');

      final tireClean = items.firstWhere((i) => i.id == 'srv_tire_clean');
      expect(tireClean.localizedName(AppLanguage.en), 'Tire Cleaning & Tire Black Finish');
      expect(tireClean.localizedName(AppLanguage.am), 'የጎማ እጥበት እና ማጥቆሪያ ቅባት');
      expect(tireClean.localizedName(AppLanguage.om), 'Qulqullina gommaa fi kuula guraachessituu gommaa');

      final windowPolish = items.firstWhere((i) => i.id == 'srv_window_polish');
      expect(windowPolish.localizedName(AppLanguage.en), 'Window Polish & Cleaning');
      expect(windowPolish.localizedName(AppLanguage.am), 'የመስኮት መስታወት ማጽዳት');
      expect(windowPolish.localizedName(AppLanguage.om), 'Daawwitii foddaa konkolaataa qulqulleessuu');

      final machinePolish = items.firstWhere((i) => i.id == 'srv_machine_polish');
      expect(machinePolish.localizedName(AppLanguage.en), 'Machine Body Polish');
      expect(machinePolish.localizedName(AppLanguage.am), 'በማሽን የሚደረግ የሰውነት ፖሊሽ');
      expect(machinePolish.localizedName(AppLanguage.om), 'Poolishii qaamaa maashiniin hojjetamu');

      final scratchRemoval = items.firstWhere((i) => i.id == 'srv_scratch_removal');
      expect(scratchRemoval.localizedName(AppLanguage.en), 'Scratch / Minor Scratch Removal');
      expect(scratchRemoval.localizedName(AppLanguage.am), 'የጭረት እና ጥቃቅን ስንጥቆች ማስለቀቅ');
      expect(scratchRemoval.localizedName(AppLanguage.om), 'Ciccitaa fi madaa xixiqqoo halluu balleessuu');

      final waterSpot = items.firstWhere((i) => i.id == 'srv_water_spot');
      expect(waterSpot.localizedName(AppLanguage.en), 'Water Spot Chemical Removal');
      expect(waterSpot.localizedName(AppLanguage.am), 'የውሃ እና የጨው ድርቀት ምልክቶችን ማስለቀቅ');
      expect(waterSpot.localizedName(AppLanguage.om), 'Mallattoo bishaanii fi ashaboo goge qorichaan balleessuu');

      final intVacuum = items.firstWhere((i) => i.id == 'srv_int_vacuum');
      expect(intVacuum.localizedName(AppLanguage.en), 'Interior Vacuum: Floor & Seat Cleaning');
      expect(intVacuum.localizedName(AppLanguage.am), 'የውስጥ ክፍል ቫኪዩም (የወለል እና የወንበር አቧራ ማጽዳት)');
      expect(intVacuum.localizedName(AppLanguage.om), 'Vaakiyuumii keessaa (dhukkee lafaa fi teessumaa qulqulleessuu)');

      final seatsOut = items.firstWhere((i) => i.id == 'srv_seats_out');
      expect(seatsOut.localizedName(AppLanguage.en), 'Seat & Floor Carpet Removed & Washed');
      expect(seatsOut.localizedName(AppLanguage.am), 'ወንበሮችና የወለል ምንጣፎች ወጥተው የሚታጠቡበት');
      expect(seatsOut.localizedName(AppLanguage.om), 'Teessumootaa fi afata lafaa baasanii dhiquu');

      final roofCleaning = items.firstWhere((i) => i.id == 'srv_roof_cleaning');
      expect(roofCleaning.localizedName(AppLanguage.en), 'Roof Headliner Deep Cleaning');
      expect(roofCleaning.localizedName(AppLanguage.am), 'የኮርኒስ/የጣራ ጨርቅ ጥልቅ እጥበት');
      expect(roofCleaning.localizedName(AppLanguage.om), 'Huccuu korniisa/baaxii keessaa gadi-fageenyaan dhiquu');

      final dashDetailing = items.firstWhere((i) => i.id == 'srv_dashboard_detailing');
      expect(dashDetailing.localizedName(AppLanguage.en), 'Dashboard Detailing: Cream & Airfresh');
      expect(dashDetailing.localizedName(AppLanguage.am), 'የዳሽቦርድ ማስዋብ (ክሬም እና ሽቶ ማስተካከል)');
      expect(dashDetailing.localizedName(AppLanguage.om), 'Daashboordii miidheksuu (kiriimii fi shittoo sirreessuu)');

      final doorPanel = items.firstWhere((i) => i.id == 'srv_door_panel');
      expect(doorPanel.localizedName(AppLanguage.en), 'Door Panel Deep Cleaning');
      expect(doorPanel.localizedName(AppLanguage.am), 'የበር ውስጣዊ ገጽታዎች ጥልቅ ጽዳት እና ማስዋብ');
      expect(doorPanel.localizedName(AppLanguage.om), 'Qaama keessoo balbalaa gadi-fageenyaan qulqulleessuu fi miidheksuu');

      final engineShampoo = items.firstWhere((i) => i.id == 'srv_engine_shampoo');
      expect(engineShampoo.localizedName(AppLanguage.en), 'Engine Cleaning: Shampoo');
      expect(engineShampoo.localizedName(AppLanguage.am), 'የሞተር እጥበት (በሻምፖ)');
      expect(engineShampoo.localizedName(AppLanguage.om), 'Mootora shaamപ്പോdhaan dhiquu');

      final engineChemical = items.firstWhere((i) => i.id == 'srv_engine_chemical');
      expect(engineChemical.localizedName(AppLanguage.en), 'Engine Bay Chemical Degreasing: Deep Clean, Rinse & Dry');
      expect(engineChemical.localizedName(AppLanguage.am), 'የሞተር ክፍል በኬሚካል ቅባት ማስለቀቅ (ጥልቅ ጽዳት፣ ማጠብ እና ማድረቅ)');
      expect(engineChemical.localizedName(AppLanguage.om), 'Moora mootoraa kemikaalaan cooma qulqulleessuu (dhiquu, dhiqachuu fi gogsuu)');

      final headlight = items.firstWhere((i) => i.id == 'srv_headlight_restoration');
      expect(headlight.localizedName(AppLanguage.en), 'Headlight Restoration');
      expect(headlight.localizedName(AppLanguage.am), 'የደበዘዘ (የወየበ) የግንባር መብራት መስታወት ወደ ኦሪጂናል መመለስ');
      expect(headlight.localizedName(AppLanguage.om), 'Daawwitii ifaa fuulduraa kan dhiitama/bifa gate gara oriijinaalaatti deebisuu');
    });

    test('Master Table categories translate accurately across EN, AM, OM', () {
      expect(AppStrings.translateCategoryName('exterior', AppLanguage.en), 'Exterior & Hand Wash');
      expect(AppStrings.translateCategoryName('exterior', AppLanguage.am), 'የውጭ አካል እና የእጅ እጥበት');
      expect(AppStrings.translateCategoryName('exterior', AppLanguage.om), 'Dhiqannaa Qaama Alaa fi Harka');

      expect(AppStrings.translateCategoryName('polish', AppLanguage.en), 'Body Polish & Paint Correction');
      expect(AppStrings.translateCategoryName('polish', AppLanguage.am), 'የመኪና አካል ፖሊሽ እና የቀለም ጭረት ጥገና');
      expect(AppStrings.translateCategoryName('polish', AppLanguage.om), 'Poolishii Qaama Konkolaataa fi Bakkoltee Halluu Sirreessuu');

      expect(AppStrings.translateCategoryName('interior', AppLanguage.en), 'Interior Restoration & Detailing');
      expect(AppStrings.translateCategoryName('interior', AppLanguage.am), 'የውስጥ ክፍል ፅዳት እና ዲቴይሊንግ');
      expect(AppStrings.translateCategoryName('interior', AppLanguage.om), 'Qulqullina Keessaa fi Miidhagina Guutuu');

      expect(AppStrings.translateCategoryName('engine', AppLanguage.en), 'Engine & Specialty Detailing');
      expect(AppStrings.translateCategoryName('engine', AppLanguage.am), 'የሞተር እና የሞተር የተለያዩ ክፍሎች ጥልቅ ፅዳት');
      expect(AppStrings.translateCategoryName('engine', AppLanguage.om), 'Qulqullina Gadi-fageenyaa Mootoraa fi Kutaa Addaa');
    });

    test('WashBooking.localizedServiceDisplayName maps service names to active language', () {
      final booking = WashBooking(
        id: 'wb_test_1',
        customerName: 'Abebe Bikila',
        customerPhone: '0911223344',
        serviceType: ServiceType.walkInStation,
        carType: CarType.automobile,
        licensePlate: 'AA-2-12345',
        package: const WashPackage(
          id: 'pkg_custom',
          name: 'Custom Package',
          description: '',
          durationMinutes: 45,
          pricingByCarType: {CarType.automobile: 500},
          features: [],
        ),
        payment: const PaymentInfo(amount: 500.0, method: PaymentMethod.cash, isPaid: false),
        createdAt: DateTime.now(),
        selectedServices: [
          'Body Hand Wash with Shampoo & Fiber Towel',
          'Tire Cleaning & Tire Black Finish',
        ],
      );

      // In Amharic
      final amharicDisplay = booking.localizedServiceDisplayName(AppLanguage.am);
      expect(amharicDisplay, contains('የመኪና አካል በሻምፖ እና በፋይበር ፎጣ እጥበት'));
      expect(amharicDisplay, contains('የጎማ እጥበት እና ማጥቆሪያ ቅባት'));

      // In Afaan Oromoo
      final oromoDisplay = booking.localizedServiceDisplayName(AppLanguage.om);
      expect(oromoDisplay, contains('Dhiqannaa qaama konkolaataa shaamപ്പോ fi fooxaa faayiberiitiin'));
      expect(oromoDisplay, contains('Qulqullina gommaa fi kuula guraachessituu gommaa'));
    });
  });
}
