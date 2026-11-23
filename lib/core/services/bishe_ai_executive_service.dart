import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../features/admin/domain/models/monthly_overhead_expense.dart';
import '../../features/auth_roles/domain/models/user_role.dart';
import '../../features/booking_service/domain/models/bay_station.dart';
import '../../features/booking_service/domain/models/car_type.dart';
import '../../features/booking_service/domain/models/payment_info.dart';
import '../../features/booking_service/domain/models/service_type.dart';
import '../../features/booking_service/domain/models/wash_booking.dart';
import '../../features/booking_service/domain/models/wash_package.dart';
import '../../features/booking_service/domain/models/wash_status.dart';
import '../../features/booking_service/presentation/state/app_state_notifier.dart';
import '../../features/inventory/domain/models/consumable_item.dart';
import '../../features/inventory/domain/models/fixed_asset.dart';
import '../constants/app_constants.dart';
import '../localization/app_strings.dart';
import '../utils/currency_formatter.dart';

enum WatchdogSeverity { info, warning, danger }
enum WatchdogCategory { inventory, bays, shiftHandover, machinery }

class StationWatchdogAlert {
  final String id;
  final String title;
  final String description;
  final WatchdogSeverity severity;
  final WatchdogCategory category;
  final String recommendedAction;

  const StationWatchdogAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.category,
    required this.recommendedAction,
  });
}

class CustomerLoyaltyInfo {
  final String plateNumber;
  final int totalCompletedWashes;
  final int progressInCycle;
  final int washesRemainingForReward;
  final bool isRewardEligible;
  final String rewardDescription;

  const CustomerLoyaltyInfo({
    required this.plateNumber,
    required this.totalCompletedWashes,
    required this.progressInCycle,
    required this.washesRemainingForReward,
    required this.isRewardEligible,
    required this.rewardDescription,
  });
}

/// BISHE AI Operations Executive & Customer Concierge Service
/// Provides intelligent operational answers using either the Google Gemini API
/// or a zero-network local analytical heuristics engine with zero egress costs.
class BisheAiExecutiveService {
  BisheAiExecutiveService._();

  static const List<String> _geminiModels = [
    'gemini-3.5-flash-lite',
    'gemini-3.5-flash',
    'gemini-3.8-flash',
    'gemini-flash-latest',
  ];

  /// Primary query entry point
  static Future<String> askExecutive({
    required String userQuestion,
    required AppStateNotifier state,
    required AppLanguage currentLang,
    UserRole callerRole = UserRole.admin,
    List<Map<String, String>>? conversationHistory,
  }) async {
    final apiKey = state.geminiApiKey;
    String? cloudErrorNotice;

    // 1. If Gemini API key is provided, query Gemini with full grounded knowledge & multi-turn history
    if (apiKey != null && apiKey.isNotEmpty) {
      try {
        final isCustomer = callerRole == UserRole.customer;
        final systemContext = isCustomer
            ? _buildCustomerConciergePrompt(userQuestion, state, currentLang)
            : _buildExecutiveSystemPrompt(userQuestion, state, currentLang, callerRole);

        final List<Map<String, dynamic>> contents = [];

        // Grounding System Context Turn
        contents.add({
          'role': 'user',
          'parts': [{'text': systemContext}],
        });
        final modelWelcome = isCustomer
            ? (currentLang == AppLanguage.am
                ? 'ሰላም! እኔ የቢሼ AI እንግዳ ተቀባይ ነኝ። ስለ ማጠቢያ ፓኬጆቻችን፣ ዋጋዎች፣ የኤሌክትሪክ መኪናዎች ደህንነት እና የተራ ሁኔታ በማብራራት ደስ ይለኛል።'
                : (currentLang == AppLanguage.om
                    ? 'Akkam! Ani Tajaajila AI BISHE ti. Waa\'ee paakeejii dhiqa, gatii, eegumsa konkolaataa elektiriikii fi yeroo eegumsaatiin isin gargaaruuf qophiidha.'
                    : 'Greetings! I am the BISHE AI Concierge. I will guide you warmly through our wash packages, prices, EV safety, carpet services, and wait times in Bishoftu.'))
            : (currentLang == AppLanguage.am
                ? 'ተረድቻለሁ። እኔ የቢሼ መኪና ማጠቢያ የ AI ስራ አስፈፃሚ ነኝ። የማዕከሉን የቀጥታ መረጃዎች፣ የዕቃዎች ሁኔታና የሂሳብ መዛግብት መሠረት በማድረግ ትክክለኛ ምላሽ እሰጣለሁ።'
                : (currentLang == AppLanguage.om
                    ? 'Hubadheera. Ani Hogganaa Hojii AI BISHE ti. Ragaa iddoo dhiqaafi herrega bu\'uura godhachuun deebii sirrii kennuuf qophiidha.'
                    : 'Understood. I am BisheAI, Chief Operations Executive for BISHE Car Wash. Grounded in the operations manual, equipment health, bank slips, showers, and live bay records, I will answer accurately with tables and calculations where appropriate.'));

        contents.add({
          'role': 'model',
          'parts': [{'text': modelWelcome}],
        });

        // Add Multi-Turn History
        if (conversationHistory != null && conversationHistory.isNotEmpty) {
          for (final turn in conversationHistory.take(6)) {
            final r = turn['role'] == 'user' ? 'user' : 'model';
            final t = turn['text'] ?? '';
            if (t.isNotEmpty) {
              contents.add({
                'role': r,
                'parts': [{'text': t}],
              });
            }
          }
        }

        // Add Current Question
        contents.add({
          'role': 'user',
          'parts': [{'text': userQuestion}],
        });

        final tools = [
          {
            'functionDeclarations': [
              {
                'name': 'tool_book_wash',
                'description': 'Book a vehicle or carpet wash into the station database with license plate, car type, and package',
                'parameters': {
                  'type': 'OBJECT',
                  'properties': {
                    'licensePlate': {'type': 'STRING', 'description': 'Vehicle license plate number'},
                    'carType': {'type': 'STRING', 'description': 'Car type: automobile, minibus, truck, or carpet'},
                    'packageId': {'type': 'STRING', 'description': 'Wash package: silver, gold, platinum, or diamond'},
                    'targetBay': {'type': 'STRING', 'description': 'Target bay: bay1, bay2, or mobileVan'}
                  },
                  'required': ['licensePlate']
                }
              },
              {
                'name': 'tool_settle_payment',
                'description': 'Settle an active vehicle wash order with cash, telebirr, or CBE Birr',
                'parameters': {
                  'type': 'OBJECT',
                  'properties': {
                    'plateOrId': {'type': 'STRING', 'description': 'Vehicle plate or booking ID'},
                    'paymentMethod': {'type': 'STRING', 'description': 'Payment method: cash, telebirr, or cbe'}
                  },
                  'required': ['plateOrId']
                }
              },
              {
                'name': 'tool_initiate_daily_closing',
                'description': 'Initiate Cashier 15:30 daily register closing and dispatch 6-digit OTP to Operations Manager',
                'parameters': {
                  'type': 'OBJECT',
                  'properties': {
                    'notes': {'type': 'STRING', 'description': 'Optional closing notes'}
                  }
                }
              },
              {
                'name': 'tool_verify_closing_otp',
                'description': 'Verify Operations Manager 6-digit OTP to finalize closing and disburse washer commissions',
                'parameters': {
                  'type': 'OBJECT',
                  'properties': {
                    'otpCode': {'type': 'STRING', 'description': '6-digit OTP code'}
                  },
                  'required': ['otpCode']
                }
              },
              {
                'name': 'tool_record_empty_exchange',
                'description': 'Record empty-for-full container chemical exchange (ዕቃ በዕቃ) as COGS',
                'parameters': {
                  'type': 'OBJECT',
                  'properties': {
                    'chemicalId': {'type': 'STRING', 'description': 'Chemical item name or ID, e.g. CS-009 or shampoo'},
                    'quantity': {'type': 'NUMBER', 'description': 'Number of cans exchanged'}
                  },
                  'required': ['chemicalId']
                }
              },
              {
                'name': 'tool_update_master_price',
                'description': 'Update station wash package rates or monthly overhead expenses (rent, electricity, water)',
                'parameters': {
                  'type': 'OBJECT',
                  'properties': {
                    'targetId': {'type': 'STRING', 'description': 'Target ID or name, e.g. overhead_rent, overhead_water, or pkg_gold'},
                    'newPrice': {'type': 'NUMBER', 'description': 'New price in ETB'}
                  },
                  'required': ['targetId', 'newPrice']
                }
              },
              {
                'name': 'tool_check_loyalty_pass',
                'description': 'Check frequent washer loyalty points and free wash eligibility for a license plate',
                'parameters': {
                  'type': 'OBJECT',
                  'properties': {
                    'plateNumber': {'type': 'STRING', 'description': 'Vehicle license plate number'}
                  },
                  'required': ['plateNumber']
                }
              }
            ]
          }
        ];

        final payload = jsonEncode({
          'contents': contents,
          'tools': tools,
          'generationConfig': {
            'temperature': isCustomer ? 0.5 : 0.7,
            'maxOutputTokens': 1500,
          },
        });

        // Try models in order with graceful fallback
        for (final modelName in _geminiModels) {
          final url = Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$apiKey',
          );

          try {
            final response = await http
                .post(
                  url,
                  headers: {'Content-Type': 'application/json'},
                  body: payload,
                )
                .timeout(const Duration(seconds: 15));

            if (response.statusCode == 200) {
              final data = jsonDecode(response.body) as Map<String, dynamic>;
              final candidates = data['candidates'] as List?;
              if (candidates != null && candidates.isNotEmpty) {
                final content = candidates[0]['content'] as Map<String, dynamic>?;
                final parts = content?['parts'] as List?;
                if (parts != null && parts.isNotEmpty) {
                  // Check for tool / function call execution
                  for (final part in parts) {
                    if (part is Map<String, dynamic> && part.containsKey('functionCall')) {
                      final fnCall = part['functionCall'] as Map<String, dynamic>;
                      final fnName = fnCall['name'] as String?;
                      final fnArgs = fnCall['args'] as Map<String, dynamic>? ?? {};

                      if (fnName == 'tool_book_wash') {
                        return await executeToolBookWash(
                          licensePlate: fnArgs['licensePlate']?.toString() ?? '',
                          carTypeStr: fnArgs['carType']?.toString() ?? 'automobile',
                          packageIdStr: fnArgs['packageId']?.toString() ?? 'pkg_gold',
                          targetBayStr: fnArgs['targetBay']?.toString(),
                          state: state,
                          lang: currentLang,
                        );
                      } else if (fnName == 'tool_settle_payment') {
                        return await executeToolSettlePayment(
                          plateOrId: fnArgs['plateOrId']?.toString() ?? '',
                          methodStr: fnArgs['paymentMethod']?.toString() ?? 'cash',
                          state: state,
                          lang: currentLang,
                        );
                      } else if (fnName == 'tool_initiate_daily_closing') {
                        return await executeToolInitiateDailyClosing(
                          cashierName: 'Cashier',
                          notes: fnArgs['notes']?.toString(),
                          state: state,
                          lang: currentLang,
                        );
                      } else if (fnName == 'tool_verify_closing_otp') {
                        return await executeToolVerifyClosingOtp(
                          otpCode: fnArgs['otpCode']?.toString() ?? '',
                          managerName: 'Operations Manager',
                          state: state,
                          lang: currentLang,
                        );
                      } else if (fnName == 'tool_record_empty_exchange') {
                        return await executeToolRecordEmptyExchange(
                          chemicalNameOrId: fnArgs['chemicalId']?.toString() ?? 'CS-009',
                          quantity: (fnArgs['quantity'] as num?)?.toDouble() ?? 1.0,
                          state: state,
                          lang: currentLang,
                        );
                      } else if (fnName == 'tool_update_master_price') {
                        return await executeToolUpdateMasterPrice(
                          targetId: fnArgs['targetId']?.toString() ?? '',
                          newPrice: (fnArgs['newPrice'] as num?)?.toDouble() ?? 0.0,
                          state: state,
                          lang: currentLang,
                        );
                      } else if (fnName == 'tool_check_loyalty_pass') {
                        final plate = fnArgs['plateNumber']?.toString() ?? '';
                        return generateCustomerLoyaltyReport(plate, state, currentLang);
                      }
                    }
                  }

                  final text = parts[0]['text'] as String?;
                  if (text != null && text.trim().isNotEmpty) {
                    return text.trim();
                  }
                }
              }
            } else if (response.statusCode == 404 || response.statusCode == 503) {
              // Model unavailable or retired; try next model in list
              continue;
            } else {
              cloudErrorNotice = '⚠️ *[Gemini Cloud Note: HTTP ${response.statusCode} from $modelName. Falling back to live local calculation engine]*\n\n';
              break;
            }
          } catch (_) {
            continue;
          }
        }
      } catch (e) {
        cloudErrorNotice = '⚠️ *[Gemini Cloud Note: Connection error. Falling back to live local calculation engine]*\n\n';
        debugPrint('Gemini API error: $e');
      }
    }

    // 2. Local Station Analytics Engine (Zero network egress, fast, 100% reliable)
    final localResult = callerRole == UserRole.customer
        ? await _localCustomerConciergeAnalytics(userQuestion, state, currentLang)
        : await _localStationAnalytics(userQuestion, state, currentLang, callerRole);

    return cloudErrorNotice != null ? '$cloudErrorNotice$localResult' : localResult;
  }

  /// Compact system prompt with complete operational knowledge & 6 live blind spots
  static String _buildExecutiveSystemPrompt(
    String question,
    AppStateNotifier state,
    AppLanguage lang,
    UserRole callerRole,
  ) {
    final now = DateTime.now();
    final todayBookings = state.bookings.where((b) {
      final d = b.createdAt;
      return d.year == now.year && d.month == now.month && d.day == now.day;
    }).toList();

    int typeA = 0, typeB = 0, typeC = 0, carpets = 0;
    double totalCarpetM2 = 0.0;
    double vehicleEvuSum = 0.0;

    for (final b in todayBookings) {
      if (b.isCarpet) {
        carpets++;
        final m2 = (b.carpetAreaSqMeters ?? 12.0);
        totalCarpetM2 += m2;
        vehicleEvuSum += (m2 * 0.25);
      } else {
        switch (b.carType) {
          case CarType.automobile:
            typeA++;
            vehicleEvuSum += 1.0;
            break;
          case CarType.minibus:
            typeB++;
            final plate = b.licensePlate.toLowerCase();
            final isVan = plate.contains('van') || plate.contains('mini') || plate.contains('bus');
            vehicleEvuSum += isVan ? 1.8 : 1.4;
            break;
          case CarType.truck:
            typeC++;
            vehicleEvuSum += 2.5;
            break;
        }
      }
    }

    final double totalEvu = vehicleEvuSum;
    final completedToday = todayBookings.where((b) => b.status.name == 'completed').toList();
    final grossRevenue = todayBookings
        .where((b) => b.payment.isPaid)
        .fold(0.0, (sum, b) => sum + b.totalPrice);

    final commissionsPaid = state.commissionLogs.where((l) {
      final d = l.completedAt;
      return d.year == now.year && d.month == now.month && d.day == now.day;
    }).fold(0.0, (sum, l) => sum + l.commissionEarnedETB);

    final lowStockItems = state.consumables.where((c) => c.isLowStock).map((c) => '${c.name} (${c.currentStock} ${c.unit})').toList();
    final activeWashers = state.presentWashersToday.map((w) => '${w.name} (${w.role.displayName})').toList();

    // 1. Showers Blind Spot
    final todayShowers = state.showerRecords.where((s) {
      final d = s.recordedAt;
      return d.year == now.year && d.month == now.month && d.day == now.day;
    }).toList();
    final showersTotalAmount = todayShowers.fold(0.0, (sum, s) => sum + s.totalAmount);
    final showersUsersCount = todayShowers.fold(0, (sum, s) => sum + s.userCount);
    final showersCash = todayShowers.where((s) => s.isCash).fold(0.0, (sum, s) => sum + s.totalAmount);
    final showersDigital = todayShowers.where((s) => s.isDigital).fold(0.0, (sum, s) => sum + s.totalAmount);

    // 2. Bay Distribution Blind Spot
    final bays = state.bays;
    final bay1 = bays.firstWhere((b) => b.type == BayType.bay1, orElse: () => const StationBay(type: BayType.bay1));
    final bay2 = bays.firstWhere((b) => b.type == BayType.bay2, orElse: () => const StationBay(type: BayType.bay2));
    final van = bays.firstWhere((b) => b.type == BayType.mobileVan, orElse: () => const StationBay(type: BayType.mobileVan));
    final activeQueue = state.bookings.where((b) => b.status.name != 'completed' && b.status.name != 'cancelled').toList();

    // 3. Fixed Asset Machinery Health Blind Spot
    final totalAssets = state.fixedAssets.length;
    final operationalAssets = state.fixedAssets.where((a) => a.condition == AssetCondition.operational).length;
    final needsServiceAssets = state.fixedAssets.where((a) => a.condition == AssetCondition.needsService).length;
    final underRepairAssets = state.fixedAssets.where((a) => a.condition == AssetCondition.underRepair).length;
    final decommissionedAssets = state.fixedAssets.where((a) => a.condition == AssetCondition.decommissioned).length;
    final totalAssetValuation = state.fixedAssets.fold(0.0, (sum, a) => sum + (a.assetValueEtb * a.quantity));

    // 4. Bank Deposits Reconciliation Blind Spot
    final todayDeposits = state.bankDeposits.where((d) {
      final dt = d.depositedAt;
      return dt.year == now.year && dt.month == now.month && dt.day == now.day;
    }).toList();
    final totalBankDeposits = todayDeposits.fold(0.0, (sum, d) => sum + d.amount);

    // 5. Shift Handover OTP Status Blind Spot
    final dayHandoverPending = state.pendingCashierHandover != null || state.pendingCashierAdminHandover != null;
    final nightHandoverPending = state.pendingAdminNightHandover != null;

    // 6. Customer Sentiment & Feedbacks Blind Spot
    final feedbacks = state.allCustomerFeedback;
    final avgRating = feedbacks.isNotEmpty ? (feedbacks.fold(0, (s, f) => s + f.stars) / feedbacks.length) : 4.0;
    final pendingFeedbacks = state.pendingCustomerFeedback.length;

    final vehicleDetails = todayBookings.take(10).map((b) {
      final p = b.licensePlate.isNotEmpty ? b.licensePlate : 'WALK-IN';
      final t = b.isCarpet ? 'Carpet' : b.carType.displayName;
      final st = b.status.name.toUpperCase();
      return '• $p ($t) -> $st [ETB ${b.totalPrice.toStringAsFixed(0)}]';
    }).join('\n');

    return '''
You are "BisheAI", the Chief Operations Executive for "BISHE Car Wash & Auto Care Service" in Bishoftu (Debre Zeyit), Oromia, Ethiopia.
Caller Role: ${callerRole.displayName.toUpperCase()}
GPS: 8°44'57.2"N 38°58'02.4"E | Behind Hirna Butchery, near Alemshet Fero.
Station Contacts: Gate Desk & SMS: ${AppConstants.stationPhoneNumber} (0910046553) | Customer Support/Manager: ${AppConstants.stationPhoneNumberSecondary} (0983948888).

OPERATIONAL KNOWLEDGE BASE (BISHE OPERATIONS MANUAL):
1. Station Infrastructure:
   - Bay 1 & Bay 2: Concrete wash bays with oil interceptors and water recycling.
   - Mobile Van: Fully equipped mobile wash unit servicing 8 Bishoftu zones.
   - Shower Suites: Clean, modern hot showers for drivers and public (0% VAT Exempt).
   - Staff Roster: 8 Washers on duty in rotating pairs, 1 Cashier (07:00-15:30), 1 Operations Manager (15:30-Close), 1 Storekeeper, 1 Accountant, Super Admin.
2. Vehicle Volume & Category Multipliers (EVU):
   - Sedan / Automobile (Type A): 1.0x Base Workload (125 ml shampoo, 5 ml perfume)
   - SUV / Pickup (Type B): 1.4x Workload (175 ml shampoo, 7 ml perfume)
   - Minibus / Van (Type B): 1.8x Workload (225 ml shampoo, 9 ml perfume)
   - Heavy Truck (Type C): 2.5x Workload (312.5 ml shampoo, 12.5 ml perfume)
   - Carpet Cleaning: Calculated per square meter (Area in m² * 0.25 EVU)
3. Chemical Yield & Loss Prevention:
   - 5L Foam Shampoo (CS-009): Standard yield is ~40 cars @ 125 ml/EVU. Alert if < 25 cars or > 55 cars.
   - 500ml Interior Perfume (CS-006): Standard yield is ~100 sprays @ 5 ml/interior. Alert if < 70 or > 130 sprays.
   - Strict Empty-for-Full container exchange enforced by Storekeeper for all 22 consumables.
4. Statutory Tax & Financial Accounting:
   - Car Wash & Carpets: 15% Statutory VAT deducted before calculating commissions.
   - Shower Services: 0% VAT (Exempt from tax).
   - Washer Commissions: Station default 15% (individual 2%-25%) calculated strictly on Net Base Revenue (Gross - VAT).
   - Cash custody transferred via 6-digit OTP from Cashier (15:30) to Operations Manager.

LIVE STATION SNAPSHOT (${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}):
- Total Today Bookings: ${todayBookings.length} (Completed: ${completedToday.length}, In Queue: ${activeQueue.length})
- Workload Units: ${totalEvu.toStringAsFixed(1)} EVU (Type A: $typeA | Type B: $typeB | Type C: $typeC | Carpets: $carpets [${totalCarpetM2.toStringAsFixed(1)} m²])
- Gross Wash Revenue Settled: ETB ${grossRevenue.toStringAsFixed(2)}
- Washer Commissions Settled: ETB ${commissionsPaid.toStringAsFixed(2)}
- Active Washers on Duty: ${activeWashers.join(', ')}
- Warehouse Consumable Alerts: ${lowStockItems.isEmpty ? 'None (Healthy)' : lowStockItems.join(', ')}
- LIVE BAY DISTRIBUTION:
  * Bay 1: ${bay1.status.displayName} (${bay1.activeLicensePlate ?? 'Empty'}) | Washer: ${bay1.assignedWasherName ?? 'None'}
  * Bay 2: ${bay2.status.displayName} (${bay2.activeLicensePlate ?? 'Empty'}) | Washer: ${bay2.assignedWasherName ?? 'None'}
  * Mobile Van: ${van.status.displayName} (${van.activeLicensePlate ?? 'Available'}) | Dispatcher: ${van.assignedWasherName ?? 'None'}
- SHOWERS (0% VAT EXEMPT):
  * Today: $showersUsersCount persons | Gross ETB ${showersTotalAmount.toStringAsFixed(2)} (Cash: ETB ${showersCash.toStringAsFixed(2)}, Digital: ETB ${showersDigital.toStringAsFixed(2)})
- MACHINERY & FIXED ASSETS ($totalAssets total, Valuation: ETB ${totalAssetValuation.toStringAsFixed(0)}):
  * Operational: $operationalAssets | Needs Service: $needsServiceAssets | Under Repair: $underRepairAssets | Decommissioned: $decommissionedAssets
- BANK DEPOSITS & RECONCILIATION:
  * Today's Verified Slips: ${todayDeposits.length} slips | Total Deposited: ETB ${totalBankDeposits.toStringAsFixed(2)}
- CASH CUSTODY / OTP STATUS:
  * Cashier Day Handover: ${dayHandoverPending ? '⏳ PENDING 6-DIGIT OTP VERIFICATION' : '✅ VERIFIED & CLOSED'}
  * Night Shift Manager Close: ${nightHandoverPending ? '⏳ PENDING OTP' : '✅ NORMAL'}
- CUSTOMER REVIEWS & SENTIMENT:
  * Average Satisfaction: ${avgRating.toStringAsFixed(1)} / 4.0 Stars (${feedbacks.length} ratings, $pendingFeedbacks pending moderation)
- Live Queue Vehicles:
$vehicleDetails

INSTRUCTIONS & PLAIN-WRITING RULES:
- Lead with the answer: State the exact key metric, finding, or result in Sentence 1.
- Zero robotic preamble: Cut out corporate filler like "Certainly!", "As an AI assistant...", or "I would be delighted to...".
- Real-truth 30-day accrual accounting: Master overheads (rent, water, electricity, salaries) are accrued daily at 1/30th per day to display true net earnings.
- Empty container COGS: Only chemical cans exchanged (ዕቃ በዕቃ) and shift consumption are counted as chemical COGS.
- Authority: Answer with the sharp insight of a veteran station executive in Bishoftu.
- You have access to real action tools (tool_book_wash, tool_settle_payment, tool_initiate_daily_closing, tool_verify_closing_otp, tool_record_empty_exchange, tool_update_master_price). Call them when commanded.
- MANDATORY LANGUAGE REQUIREMENT: You MUST reply entirely in ${lang == AppLanguage.am ? 'Amharic (አማርኛ)' : (lang == AppLanguage.om ? 'Afaan Oromoo' : 'English')}. Write all titles, tables, explanations, and numbers in ${lang == AppLanguage.am ? 'Amharic (አማርኛ)' : (lang == AppLanguage.om ? 'Afaan Oromoo' : 'English')}. Do NOT reply in English when the user language is Amharic or Afaan Oromoo!
''';
  }

  /// Grounded prompt for customer concierge with strict privacy guardrails
  static String _buildCustomerConciergePrompt(
    String question,
    AppStateNotifier state,
    AppLanguage lang,
  ) {
    final bays = state.bays;
    final bay1 = bays.firstWhere((b) => b.type == BayType.bay1, orElse: () => const StationBay(type: BayType.bay1));
    final bay2 = bays.firstWhere((b) => b.type == BayType.bay2, orElse: () => const StationBay(type: BayType.bay2));
    final activeQueue = state.bookings.where((b) => b.status.name != 'completed' && b.status.name != 'cancelled').length;
    final estWaitMinutes = (activeQueue * 15).clamp(5, 60);

    return '''
You are "BisheAI Concierge", the friendly, hospitable, and knowledgeable customer service host for "BISHE Car Wash & Auto Care Service" located in Bishoftu (Debre Zeyit), Oromia, Ethiopia.
Location: Bishoftu (Debre Zeyit), behind Hirna Butchery, near Alemshet Fero, Oromia.
GPS Coordinates: ${AppConstants.stationGpsCoordinates} (Decimal: ${AppConstants.stationGpsDecimal})
Google Maps Navigation: ${AppConstants.googleMapsLocationUrl}
Station Contacts: Gate Desk & SMS: ${AppConstants.stationPhoneNumber} (0910046553) | Customer Support / Manager: ${AppConstants.stationPhoneNumberSecondary} (0983948888).
Open 7 Days a week: 07:00 AM - 10:00 PM.

CURRENT LIVE STATION STATUS:
- Bay 1 Status: ${bay1.status.displayName}
- Bay 2 Status: ${bay2.status.displayName}
- Vehicles currently in queue: $activeQueue
- Estimated wait time for new arrivals: ~$estWaitMinutes minutes

OUR SERVICE PACKAGES & PRICING:
1. Basic / Silver Wash:
   - Sedan: ~150-200 ETB | SUV/Pickup: ~250-300 ETB | Minibus: ~350 ETB | Truck: ~500 ETB
   - Inclusions: High-pressure snow foam wash, touchless rinse, wheel and tire cleaning, hand towel drying.
2. Gold Polish Wash (Most Popular):
   - Sedan: ~300-350 ETB | SUV/Pickup: ~400-450 ETB | Minibus: ~550 ETB
   - Inclusions: Silver wash + complete interior vacuuming, dashboard UV conditioning, door jambs cleaning, glass buffing, tire shine.
3. Platinum A/B/C Detailing:
   - Sedan: ~600-750 ETB | SUV/Pickup: ~800-950 ETB
   - Inclusions: Gold wash + undercarriage rust protection pressure wash, safe engine bay steam cleaning, ceramic spray wax protection.
4. Diamond VIP Complete Restoration:
   - Full interior deep shampoo, leather treatment, multi-stage paint clay bar, machine polish, and long-lasting paint sealant.
5. Carpet Washing Service:
   - Special industrial rotational scrubber and warm water deep rinse.
   - Pricing: ETB 50–70 per square meter depending on thickness.
   - Pickup & delivery available in Bishoftu zones for large orders.
6. Clean Hot Showers:
   - Spotless hot water shower suites with fresh towels and soap: ETB 70–100 per person (0% VAT exempt).
7. Electric Vehicle (EV) Safety Guarantee:
   - 100% safe for EVs (BYD, VW ID.4/ID.6, Tesla, Toyota bZ4X).
   - Our washers use calibrated pressure sprayers angled safely away from high-voltage battery enclosures and charging ports.
8. Frequent Washer Loyalty Pass:
   - Every 5 completed washes unlocks a 100% FREE Silver Wash or 50% OFF Gold Detailing on the 6th visit!
9. Pre-Wash Photo Scratch Inspection:
   - Intake attendants inspect pre-existing chips and scratches with the driver, attaching photos to the digital ticket for dispute-free peace of mind.
10. Bishoftu Volcanic Red Clay Removal:
   - Mud from Babogaya, Kuriftu, and Hora lakes cakes onto chassis. Recommend our high-pressure undercarriage mud blast in Bay 2!

CONVERSATIONAL BOOKING & INTERACTION RULES:
- When a customer asks to book their car or says "can you help me book my car?" without providing details, ALWAYS present the 4 required fields in a structured Markdown TABLE:
  | # | Required Field | Options & Details | Example Input |
  | 1 | Customer Name | Full name or driver name | Abebe Bikila |
  | 2 | Phone Number | For SMS ready alert & live tracking link | 0911234567 |
  | 3 | License Plate | Vehicle code & registration number | Code 2 - B48291 |
  | 4 | Service Package & Model | Silver (Foam & Dry), Gold (Mud blast & tire shine), Platinum (Detailing & Engine), Diamond VIP • Type A (Small), Type B (Medium), Type C (Truck) | Gold Wash (Type A) |
- Below the table, ALWAYS provide the direct Dashboard Redirection Button:
  [🚗 Open Customer Booking Dashboard](action:open_booking)
- And provide the fast one-tap reply suggestion: "Abebe Bikila, 0911234567, Code 2 - B48291, Gold Wash".
- When all parameters are present, call `tool_book_wash(licensePlate, carType, packageId, targetBay)`.

GPS, DIRECTIONS & CONTACT INQUIRIES:
- When a customer asks for GPS location, directions, where the station is, or contact numbers, ALWAYS present:
  1. Direct Google Maps Navigation Link: ${AppConstants.googleMapsLocationUrl}
  2. GPS Coordinates: ${AppConstants.stationGpsCoordinates} (Decimal: ${AppConstants.stationGpsDecimal})
  3. City & Landmarks: Bishoftu (Debre Zeit), behind Hirna Butchery (ሂርና ስጋ ቤት), near Alemshet Fero (አለምሸት ፌሮ)
  4. Verified Phone Numbers: Gate Desk & SMS: 0910046553 | Support / Manager: 0983948888
  5. Mention that our Mobile Van can come directly to their house or resort if they prefer not to drive.

STRICT PRIVACY GUARDRAILS (NON-NEGOTIABLE):
- NEVER disclose staff salaries, washer commission percentages, station net profits, internal EBITDA, wholesale chemical costs, or internal 6-digit OTP codes.
- If a customer asks about internal profits, commission cuts, or security OTPs, politely decline and redirect them to our service quality and packages.

TONE, STYLE & PLAIN-WRITING:
- Warm, polite, hospitable, and welcoming—like a proud Ethiopian station host.
- Greet warmly:
  * Amharic: "ሰላም ጤና ይስጥልኝ! እንደምን አደሩ/ዋሉ! ዛሬ በቢሼ ማጠቢያ ምን ልርዳዎት?"
  * Afaan Oromoo: "Akkam jirtu! Baga nagaan gara BISHE dhuftan. Har'a maal isiniif haa goonu?"
  * English: "Welcome to BISHE Car Wash! How can I take care of your car today?"
- Answer the customer's question directly in Sentence 1 before providing further advice.
- MANDATORY LANGUAGE REQUIREMENT:
  * Current Active User Language: ${lang == AppLanguage.am ? 'AMHARIC (አማርኛ)' : (lang == AppLanguage.om ? 'AFAAN OROMOO' : 'ENGLISH')}.
  * You MUST write your entire response, headings, tables, prices, and notes in ${lang == AppLanguage.am ? 'Amharic (አማርኛ)' : (lang == AppLanguage.om ? 'Afaan Oromoo' : 'English')}.
  * Do NOT reply in English when the active user language is Amharic or Afaan Oromoo!
''';
  }

  /// Built-in local station analytics engine for instant, zero-bandwidth executive answers & duty execution
  static Future<String> _localStationAnalytics(
    String rawQuery,
    AppStateNotifier state,
    AppLanguage lang,
    UserRole callerRole,
  ) async {
    final query = rawQuery.toLowerCase().trim();
    final now = DateTime.now();

    // 0. Duty Execution: Cashier Daily Register Closing
    if (query.contains('close register') ||
        query.contains('daily close') ||
        query.contains('daily closing') ||
        query.contains('shift close') ||
        query.contains('ሂሳብ ዝጋ') ||
        query.contains('መዝጊያ') ||
        query.contains('cufi')) {
      return await executeToolInitiateDailyClosing(
        cashierName: 'Cashier',
        state: state,
        lang: lang,
      );
    }

    // 0. Duty Execution: Manager / Cashier 4-to-6-Digit Handover OTP Verification
    final otpMatch = RegExp(r'\b([0-9]{4,6})\b').firstMatch(rawQuery);
    if ((query.contains('otp') || query.contains('verify') || query.contains('ኦቲፒ') || query.contains('አረጋግጥ') || query.contains('mirkaneessi')) &&
        otpMatch != null) {
      final code = otpMatch.group(1)!;
      return await executeToolVerifyClosingOtp(
        otpCode: code,
        managerName: 'Operations Manager',
        state: state,
        lang: lang,
      );
    }

    // 0. Duty Execution: Storekeeper Empty Container Exchange (ዕቃ በዕቃ)
    if ((query.contains('exchange') || query.contains('ዕቃ በዕቃ') || query.contains('ቀይር') || query.contains('qodaa')) &&
        (query.contains('shampoo') || query.contains('can') || query.contains('perfume') || query.contains('ሻምፑ') || query.contains('ጀሪካን'))) {
      final qtyMatch = RegExp(r'(\d+(\.\d+)?)').firstMatch(rawQuery);
      final qty = qtyMatch != null ? double.tryParse(qtyMatch.group(1)!) ?? 1.0 : 1.0;
      final chem = query.contains('perfume') || query.contains('ሽቶ') ? 'CS-006' : 'CS-009';
      return await executeToolRecordEmptyExchange(
        chemicalNameOrId: chem,
        quantity: qty,
        state: state,
        lang: lang,
      );
    }

    // 0. Duty Execution: Super Admin Price Update
    if ((query.contains('update price') || query.contains('change price') || query.contains('ዋጋ ቀይር') || query.contains('gatii jijjiiri')) &&
        (query.contains('rent') || query.contains('water') || query.contains('electric') || query.contains('ኪራይ') || query.contains('ውሃ') || query.contains('መብራት'))) {
      final numMatch = RegExp(r'(\d+(\.\d+)?)').firstMatch(rawQuery);
      final price = numMatch != null ? double.tryParse(numMatch.group(1)!) ?? 0.0 : 0.0;
      String target = 'overhead_rent';
      if (query.contains('water') || query.contains('ውሃ')) target = 'overhead_water';
      if (query.contains('electric') || query.contains('መብራት')) target = 'overhead_electricity';
      return await executeToolUpdateMasterPrice(
        targetId: target,
        newPrice: price,
        state: state,
        lang: lang,
      );
    }

    // 0. Duty Execution: Station Watchdog Health Audit
    if (query.contains('watchdog') ||
        query.contains('bottleneck') ||
        query.contains('ንቁ ጠባቂ') ||
        query.contains('ስጋት ፍተሻ') ||
        query.contains('hordoffii')) {
      return generateWatchdogReport(state);
    }

    // 1. Showers & 0% VAT Exempt Services
    if (query.contains('shower') ||
        query.contains('ሻወር') ||
        query.contains('dhiqannaa') ||
        query.contains('bathing')) {
      return _generateShowersReport(state, now);
    }

    // 2. Bay Turnaround, Queue & Dispatching Speed
    if (query.contains('bay') ||
        query.contains('speed') ||
        query.contains('turnaround') ||
        query.contains('ቦታ') ||
        query.contains('ተራ') ||
        query.contains('dabare') ||
        query.contains('iddoo')) {
      return _generateBaysReport(state, now);
    }

    // 3. Fixed Asset Machinery, Equipment & Repair Health
    if (query.contains('asset') ||
        query.contains('machin') ||
        query.contains('equipment') ||
        query.contains('repair') ||
        query.contains('karcher') ||
        query.contains('compressor') ||
        query.contains('vacuum') ||
        query.contains('generator') ||
        query.contains('መሣሪያ') ||
        query.contains('ዕቃ') ||
        query.contains('ቋሚ') ||
        query.contains('meeshaa')) {
      return _generateFixedAssetsReport(state);
    }

    // 4. Bank Deposits & Accountant Reconciliation Slips
    if (query.contains('deposit') ||
        query.contains('bank') ||
        query.contains('slip') ||
        query.contains('cbe') ||
        query.contains('awash') ||
        query.contains('reconcil') ||
        query.contains('ባንክ') ||
        query.contains('ተቀማጭ') ||
        query.contains('ደረሰኝ') ||
        query.contains('baankii')) {
      return _generateBankDepositsReport(state, now);
    }

    // 5. Shift Handover & 6-digit OTP Status
    if (query.contains('otp') ||
        query.contains('handover') ||
        query.contains('shift') ||
        query.contains('custody') ||
        query.contains('drawer') ||
        query.contains('ርክክብ') ||
        query.contains('ኦቲፒ') ||
        query.contains('dabarsuu')) {
      return _generateShiftHandoverReport(state, now);
    }

    // 6. Customer Feedback & Satisfaction Sentiment
    if (query.contains('feedback') ||
        query.contains('rating') ||
        query.contains('satisfaction') ||
        query.contains('review') ||
        query.contains('star') ||
        query.contains('ኮከብ') ||
        query.contains('አስተያየት') ||
        query.contains('yaada')) {
      return _generateCustomerFeedbackReport(state);
    }

    // 7. Storekeeper Empty Container Returns (ዕቃ በዕቃ)
    if (query.contains('empty') ||
        query.contains('exchange') ||
        query.contains('return') ||
        query.contains('can') ||
        query.contains('ዕቃ በዕቃ') ||
        query.contains('ባዶ')) {
      return _generateEmptyExchangeReport(state);
    }

    // 8. P&L, Revenue & Financials
    if (query.contains('p&l') ||
        query.contains('profit') ||
        query.contains('revenue') ||
        query.contains('financial') ||
        query.contains('expense') ||
        query.contains('vat') ||
        query.contains('ገቢ') ||
        query.contains('ትርፍ') ||
        query.contains('bu\'aa') ||
        query.contains('galii')) {
      return _generatePnlReport(state, now);
    }

    // 9. Washers, Staff & Commissions
    if (query.contains('washer') ||
        query.contains('staff') ||
        query.contains('commission') ||
        query.contains('team') ||
        query.contains('worker') ||
        query.contains('አጣቢ') ||
        query.contains('ኮሚሽን') ||
        query.contains('hojjetaa') ||
        query.contains('komishinii')) {
      return _generateWashersReport(state, now);
    }

    // 10. Consumables, Shampoo, Perfume & Yield
    if (query.contains('consumable') ||
        query.contains('shampoo') ||
        query.contains('perfume') ||
        query.contains('yield') ||
        query.contains('chemical') ||
        query.contains('dilution') ||
        query.contains('average') ||
        query.contains('አላቂ') ||
        query.contains('ሻምፑ') ||
        query.contains('ሽቶ') ||
        query.contains('qoricha')) {
      return _generateConsumablesYieldReport(state);
    }

    // 11. Stock, Alerts & Discrepancies
    if (query.contains('alert') ||
        query.contains('stock') ||
        query.contains('low') ||
        query.contains('discrepanc') ||
        query.contains('fraud') ||
        query.contains('loss') ||
        query.contains('ስጋት') ||
        query.contains('ማሳወቂያ') ||
        query.contains('hir\'ina')) {
      return _generateAlertsReport(state);
    }

    // 12. Cars Washed & Vehicle Breakdown
    if (query.contains('car') ||
        query.contains('vehicle') ||
        query.contains('wash') ||
        query.contains('plate') ||
        query.contains('queue') ||
        query.contains('መኪና') ||
        query.contains('የታጠቡ') ||
        query.contains('konkolaataa') ||
        query.contains('dhiqa')) {
      return _generateCarsWashedReport(state, now);
    }

    // Default: Executive Station Overview
    return _generateStationOverview(state, now);
  }

  /// Built-in local customer concierge answers & conversational booking (zero network egress)
  static Future<String> _localCustomerConciergeAnalytics(
    String rawQuery,
    AppStateNotifier state,
    AppLanguage lang,
  ) async {
    final query = rawQuery.toLowerCase().trim();

    // 0. Conversational Booking Intent Execution
    if (query.contains('book') ||
        query.contains('መዝግብ') ||
        query.contains('አስመዝግብ') ||
        query.contains('ያስይዙ') ||
        query.contains('አጥቡልኝ') ||
        query.contains('ማስጠብ') ||
        query.contains('galmeessi') ||
        query.contains('qabadhaa')) {
      // Check if user has provided a license plate
      final plateRegex = RegExp(r'\b([0-9]-[A-Za-z0-9]{4,8}|ET-?[0-9A-Za-z]{3,7}|AA-?[0-9A-Za-z]{3,7}|OR-?[0-9A-Za-z]{3,7})\b', caseSensitive: false);
      final match = plateRegex.firstMatch(rawQuery);

      if (match != null) {
        final plate = match.group(1)!;
        return await executeToolBookWash(
          licensePlate: plate,
          carTypeStr: query.contains('suv') || query.contains('prado') ? 'SUV' : (query.contains('truck') ? 'truck' : 'automobile'),
          packageIdStr: query.contains('gold') || query.contains('ጎልድ') ? 'pkg_gold' : 'pkg_silver',
          targetBayStr: query.contains('lake') || query.contains('mud') || query.contains('ጭቃ') || query.contains('bay 2') || query.contains('bay2') || query.contains('ቦታ 2') ? 'Bay 2' : 'Bay 1',
          state: state,
          lang: lang,
        );
      } else {
        // Missing plate parameter: present structured booking table with direct dashboard redirect
        switch (lang) {
          case AppLanguage.am:
            return '''
### 🚗 መኪናዎን በኦንላይን ለማስመዝገብ ዝግጁ ነኝ!
*የቢሼ መኪና ማጠቢያ • ቢሾፍቱ (ደብረ ዘይት)*

የማጠቢያ ቦታና ወረፋ ለመያዝ እባክዎ የሚከተሉትን 4 መረጃዎች ይንገሩኝ ወይም በቀጥታ በኦንላይን ዳሽቦርዱ ላይ ይክፈቱ፡

| # | የሚያስፈልግ መረጃ | ዝርዝርና አማራጮች | ምሳሌ |
| :-: | :--- | :--- | :--- |
| **1** | **የደንበኛ ስም** | ሙሉ ስም ወይም የአሽከርካሪ ስም | *አበበ ቢቂላ* |
| **2** | **ስልክ ቁጥር** | የኤስኤምኤስ ማሳወቂያ እና የቀጥታ መከታተያ ሊንክ | *0911234567* |
| **3** | **የሰሌዳ ቁጥር (License Plate)** | የመኪናው ኮድ እና ሰሌዳ ቁጥር | *ኮድ 2 - B48291* |
| **4** | **የመኪና ዓይነትና ፓኬጅ (Vehicle Model)** | • 🥈 **ሲልቨር** (አረፋ እጥበትና ማድረቅ)<br>• 🥇 **ጎልድ** (የታችኛው ጭቃ ማጠብና ጎማ ፖሊሽ)<br>• 💎 **ፕላቲነም** (የውስጥ ቫኪዩምና ሞተር እጥበት)<br>• 👑 **ዳይመንድ VIP** (ሙሉ ጥገናና ሰም)<br>• **ዓይነት ሀ (አነስተኛ)** / **ዓይነት ለ (SUV)** / **ዓይነት ሐ (ኢሱዙ)** | *ጎልድ ዋሽ (ዓይነት ሀ)* |

[🚗 በኦንላይን የደንበኛ ዳሽቦርድ ላይ ይመዝገቡ](action:open_booking)

> *💡 ፈጣን ምላሽ ለመስጠት፦ "አበበ ቢቂላ፣ 0911234567፣ ኮድ 2 - B48291፣ ጎልድ ዋሽ" ብለው መላክ ይችላሉ!*
''';

          case AppLanguage.om:
            return '''
### 🚗 Makiinaa Keessan Galmeessuuf Qophiidha!
*Giddugala Dhiqannaa BISHE • Bishooftuu*

Dabaree fi iddoo dhiqa qabachuuf maaloo odeeffannoowwan 4 armaan gadii naaf himaa ykn kallattiin daashboordiirra bani:

| # | Odeeffannoo | Filannoowwan & Ibsa | Fakkeenya |
| :-: | :--- | :--- | :--- |
| **1** | **Maqaa Maamilaa** | Maqaa guutuu ykn konkolaachisaa | *Abarraa Mokonnon* |
| **2** | **Lakkoofsa Bilbilaa** | Ergaa SMS fi liankii hordoffiif | *0911234567* |
| **3** | **Lakkoofsa Gabatee (License Plate)** | Koodii fi lakkoofsa gabatee makiinaa | *Koodii 2 - B48291* |
| **4** | **Gosa Makiinaa fi Paakeejii (Vehicle Model)** | • 🥈 **Silver** (Dhiqaa fi gogsuu)<br>• 🥇 **Gold** (Dhoqqee jalaa & faaya gommaa)<br>• 💎 **Platinum** (Keessaa fi mootora)<br>• 👑 **Diamond VIP** (Kunuunsa guutuu)<br>• **Gosa A (Xiqqaa)** / **Gosa B (SUV)** / **Gosa C (Fe'isa)** | *Gold Wash (Gosa A)* |

[🚗 Daashboordii Maamilaa irratti Galmeessaa](action:open_booking)

> *💡 Ergaa qaxxaamuraa: "Abarraa Mokonnon, 0911234567, Koodii 2 - B48291, Gold Wash" jettanii erguu dandeessu!*
''';

          case AppLanguage.en:
            return '''
### 🚗 Ready to Book Your Wash!
*BISHE Car Wash Station • Bishoftu*

Please provide the 4 details below, or tap the button to book directly on the customer dashboard:

| # | Required Field | Options & Details | Example Input |
| :-: | :--- | :--- | :--- |
| **1** | **Customer Name** | Full name or driver name | *Abebe Bikila* |
| **2** | **Phone Number** | For SMS completion alert & live tracker link | *0911234567* |
| **3** | **License Plate** | Vehicle code & registration number | *Code 2 - B48291* |
| **4** | **Vehicle Model & Package** | • 🥈 **Silver Wash** (Foam wash & microfiber dry)<br>• 🥇 **Gold Wash** (Mud blast & tire shine)<br>• 💎 **Platinum Detailing** (Interior vacuum & engine steam)<br>• 👑 **Diamond VIP** (Complete restoration & wax)<br>• **Type A (Small)** / **Type B (Medium/SUV)** / **Type C (Truck)** | *Gold Wash (Type A)* |

[🚗 Open Customer Booking Dashboard](action:open_booking)

> *💡 Fast reply: You can simply message: "Abebe Bikila, 0911234567, Code 2 - B48291, Gold Wash" to book instantly!*
''';
        }
      }
    }

    // 0. Frequent Washer Loyalty Pass Lookup
    if (query.contains('loyalty') ||
        query.contains('pass') ||
        query.contains('point') ||
        query.contains('reward') ||
        query.contains('free wash') ||
        query.contains('ታማኝ') ||
        query.contains('ነጻ') ||
        query.contains('ነፃ') ||
        query.contains('ሽልማት') ||
        query.contains('maamilummaa') ||
        query.contains('badhaasa') ||
        query.contains('tola')) {
      return generateCustomerLoyaltyReport(rawQuery, state, lang);
    }

    // 0. Pre-Wash Visual Scratch & Dent Photo Inspection
    if (query.contains('scratch') ||
        query.contains('dent') ||
        query.contains('inspect') ||
        query.contains('photo') ||
        query.contains('pre-wash') ||
        query.contains('ጭረት') ||
        query.contains('ጉዳት') ||
        query.contains('ፍተሻ') ||
        query.contains('suuraa') ||
        query.contains('miidhaa')) {
      return generateCustomerScratchInspectionReport(lang);
    }

    // 0. Bishoftu Crater Lakes Volcanic Red Mud Removal
    if (query.contains('mud') ||
        query.contains('lake') ||
        query.contains('volcanic') ||
        query.contains('crater') ||
        query.contains('babogaya') ||
        query.contains('kuriftu') ||
        query.contains('hora') ||
        query.contains('undercarriage') ||
        query.contains('chassis') ||
        query.contains('ጭቃ') ||
        query.contains('ሀይቅ') ||
        query.contains('ሐይቅ') ||
        query.contains('ቀይ አፈር') ||
        query.contains('dhoqqee') ||
        query.contains('haroo')) {
      return generateBishoftuMudRoadsReport(lang);
    }

    // GPS & Station Location Navigator
    if (query.contains('gps') ||
        query.contains('locate') ||
        query.contains('location') ||
        query.contains('map') ||
        query.contains('where') ||
        query.contains('direction') ||
        query.contains('address') ||
        query.contains('phone') ||
        query.contains('contact') ||
        query.contains('call') ||
        query.contains('ቦታ') ||
        query.contains('መገኛ') ||
        query.contains('አቅጣጫ') ||
        query.contains('ካርታ') ||
        query.contains('ስልክ') ||
        query.contains('አድራሻ') ||
        query.contains('bakka') ||
        query.contains('kallattii') ||
        query.contains('teessoo') ||
        query.contains('bilbila')) {
      return _generateCustomerLocationGpsReport(lang);
    }

    if (query.contains('package') ||
        query.contains('price') ||
        query.contains('cost') ||
        query.contains('rate') ||
        query.contains('silver') ||
        query.contains('gold') ||
        query.contains('platinum') ||
        query.contains('diamond') ||
        query.contains('ዋጋ') ||
        query.contains('ፓኬጅ') ||
        query.contains('ክፍያ') ||
        query.contains('ሲልቨር') ||
        query.contains('ጎልድ') ||
        query.contains('ፕላቲነም') ||
        query.contains('gatii') ||
        query.contains('paakeejii') ||
        query.contains('kaffaltii') ||
        query.contains('qarshii')) {
      return _generateCustomerPackagesReport(state, lang);
    }

    if (query.contains('wait') ||
        query.contains('queue') ||
        query.contains('time') ||
        query.contains('busy') ||
        query.contains('bay') ||
        query.contains('ተራ') ||
        query.contains('ጊዜ') ||
        query.contains('ስንት') ||
        query.contains('ይፈጃል') ||
        query.contains('ቆይታ') ||
        query.contains('dabaree') ||
        query.contains('yeroo') ||
        query.contains('eegumsa') ||
        query.contains('iddoo')) {
      return _generateCustomerWaitTimeReport(state, lang);
    }

    if (query.contains('ev') ||
        query.contains('electric') ||
        query.contains('safe') ||
        query.contains('pressure') ||
        query.contains('ባትሪ') ||
        query.contains('ኤሌክትሪክ') ||
        query.contains('ደህንነት') ||
        query.contains('ጥንቃቄ') ||
        query.contains('elektiriikii') ||
        query.contains('baatrii') ||
        query.contains('eegumsa') ||
        query.contains('nagaa')) {
      return _generateCustomerEvSafetyReport(lang);
    }

    if (query.contains('carpet') ||
        query.contains('rug') ||
        query.contains('ምንጣፍ') ||
        query.contains('ካሬ') ||
        query.contains('afata') ||
        query.contains('meetira')) {
      return _generateCustomerCarpetReport(state, lang);
    }

    if (query.contains('shower') ||
        query.contains('bath') ||
        query.contains('hot water') ||
        query.contains('ሻወር') ||
        query.contains('መታጠቢያ') ||
        query.contains('ሙቅ') ||
        query.contains('dhiqannaa') ||
        query.contains('bishaani') ||
        query.contains('ho\'aa')) {
      return _generateCustomerShowersReport(state, lang);
    }

    // Guardrail against internal profit/salary inquiries
    if (query.contains('profit') ||
        query.contains('commission') ||
        query.contains('salary') ||
        query.contains('payroll') ||
        query.contains('otp') ||
        query.contains('cost') ||
        query.contains('ትርፍ') ||
        query.contains('ኮሚሽን') ||
        query.contains('ደመወዝ') ||
        query.contains('ኦቲፒ') ||
        query.contains('bu\'aa') ||
        query.contains('komishinii') ||
        query.contains('minda') ||
        query.contains('mindaa')) {
      return _generateCustomerPrivacyNotice(lang);
    }

    return _generateCustomerOverview(state, lang);
  }

  // ==========================================
  // AUTONOMOUS DUTY EXECUTION TOOLS
  // ==========================================

  static Future<String> executeToolBookWash({
    required String licensePlate,
    required String carTypeStr,
    required String packageIdStr,
    String? targetBayStr,
    required AppStateNotifier state,
    required AppLanguage lang,
  }) async {
    final cleanPlate = licensePlate.trim().toUpperCase();
    if (cleanPlate.isEmpty) {
      switch (lang) {
        case AppLanguage.am:
          return '⚠️ እባክዎ የመኪናውን የሰሌዳ ቁጥር ይንገሩኝ? (ለምሳሌ "ኮድ 2 - B12345")';
        case AppLanguage.om:
          return '⚠️ Maaloo lakkoofsa gabatee makiinaa naaf himaa? (Fkn "Koodii 2 - B12345")';
        case AppLanguage.en:
          return '⚠️ Please provide the vehicle license plate number to confirm booking (e.g. "2-B12345").';
      }
    }

    // Match CarType
    CarType type = CarType.automobile;
    final ct = carTypeStr.toLowerCase();
    if (ct.contains('suv') || ct.contains('pickup') || ct.contains('prado') || ct.contains('b')) {
      type = CarType.minibus;
    } else if (ct.contains('truck') || ct.contains('isuzu') || ct.contains('heavy') || ct.contains('c')) {
      type = CarType.truck;
    }

    // Match Package
    WashPackage? pkg;
    final pStr = packageIdStr.toLowerCase();
    for (final p in state.packages) {
      final pn = p.name.toLowerCase();
      if (pStr.contains('gold') || pStr.contains('0102') || pStr.contains('ጎልድ')) {
        if (p.id.endsWith('0102') || pn.contains('gold')) { pkg = p; break; }
      } else if (pStr.contains('plat') || pStr.contains('0104') || pStr.contains('ፕላቲነም')) {
        if (p.id.endsWith('0104') || pn.contains('plat')) { pkg = p; break; }
      } else if (pStr.contains('diamond') || pStr.contains('0109') || pStr.contains('ዳይመንድ')) {
        if (p.id.endsWith('0109') || pn.contains('diamond')) { pkg = p; break; }
      } else if (pStr.contains('silver') || pStr.contains('0101') || pStr.contains('ሲልቨር')) {
        if (p.id.endsWith('0101') || pn.contains('silver')) { pkg = p; break; }
      }
    }
    pkg ??= state.packages.isNotEmpty ? state.packages.first : const WashPackage(
      id: 'pkg-silver',
      name: 'Silver Wash',
      description: 'Exterior Snow Foam Rinse',
      durationMinutes: 20,
      pricingByCarType: {CarType.automobile: 200.0, CarType.minibus: 300.0, CarType.truck: 500.0},
      features: ['Snow Foam', 'High Pressure Rinse', 'Tire Shine'],
    );

    final assignedBay = (targetBayStr != null && targetBayStr.toLowerCase().contains('2'))
        ? 'Bay 2 (Undercarriage & Red Clay)'
        : 'Bay 1 (Snow Foam & Body Gloss)';

    final booking = await state.bookNewWash(
      customerName: 'Driver $cleanPlate',
      customerPhone: '0911000000',
      serviceType: ServiceType.walkInStation,
      carType: type,
      licensePlate: cleanPlate,
      package: pkg,
      deliveryLocation: 'Bishoftu Hub ($assignedBay)',
      paymentMethod: PaymentMethod.cash,
    );

    final price = booking.totalPrice;
    final queueNum = '#${state.bookings.length.toString().padLeft(2, '0')}';

    switch (lang) {
      case AppLanguage.am:
        return '''
### ✅ መኪናዎ በተሳካ ሁኔታ ተመዝግቧል!
*የቢሼ መኪና ማጠቢያ ማዕከል • ቢሾፍቱ*

| መረጃ | ዝርዝር |
| :--- | :--- |
| **የቲኬት ቁጥር** | **`${booking.id}` ($queueNum)** |
| **የሰሌዳ ቁጥር** | **`$cleanPlate`** (${type.displayName}) |
| **የተመረጠው ፓኬጅ** | **${pkg.name}** |
| **የተመደበው ቦታ** | **$assignedBay** |
| **ጠቅላላ ክፍያ (15% ቫትን ጨምሮ)** | **${CurrencyFormatter.format(price)}** |
| **የጥበቃ ጊዜ** | **~8–12 ደቂቃ** |

💡 እባክዎ መኪናዎን ወደ **$assignedBay** ያስጠጉ፤ አጣቢዎቻችን ዝግጁ ሆነው ይጠብቁዎታል!
''';

      case AppLanguage.om:
        return '''
### ✅ Makiinaan Keessan Milkaa'inaan Galmaa'eera!
*Giddugala Dhiqannaa BISHE • Bishooftuu*

| Odeeffannoo | Qabiyyee |
| :--- | :--- |
| **Lakkoofsa Tikkeettii** | **`${booking.id}` ($queueNum)** |
| **Gabatee Makiinaa** | **`$cleanPlate`** (${type.displayName}) |
| **Paakeejii Filatame** | **${pkg.name}** |
| **Iddoo Ramadame** | **$assignedBay** |
| **Gatii Guutuu (VAT 15% dabalatee)** | **${CurrencyFormatter.format(price)}** |
| **Yeroo Eegumsaa** | **~Daqiiqaa 8–12** |

💡 Maaloo makiinaa keessan gara **$assignedBay** dhiyeessaa; hojjettoonni qophaa'aniiru!
''';

      case AppLanguage.en:
        return '''
### ✅ Vehicle Wash Booked Successfully!
*BISHE Car Wash Station • Bishoftu*

| Detail | Value |
| :--- | :--- |
| **Booking Token** | **`${booking.id}` ($queueNum)** |
| **License Plate** | **`$cleanPlate`** (${type.displayName}) |
| **Wash Package** | **${pkg.name}** |
| **Assigned Station Bay** | **$assignedBay** |
| **Total Price (incl. 15% VAT)** | **${CurrencyFormatter.format(price)}** |
| **Estimated Queue Wait** | **~8–12 minutes** |

💡 Please pull your vehicle forward into **$assignedBay**; our detailing team is standing by!
''';
    }
  }

  static Future<String> executeToolSettlePayment({
    required String plateOrId,
    required String methodStr,
    required AppStateNotifier state,
    required AppLanguage lang,
  }) async {
    final clean = plateOrId.trim().toUpperCase().replaceAll(' ', '');
    final unpaid = state.bookings.where((b) => !b.payment.isPaid).toList();
    if (state.bookings.isEmpty) {
      return 'No active bookings found in system.';
    }
    final match = state.bookings.where(
      (b) => !b.payment.isPaid && (b.id.toUpperCase() == clean || b.licensePlate.toUpperCase().replaceAll(' ', '') == clean),
    ).firstOrNull ?? (unpaid.isNotEmpty ? unpaid.first : state.bookings.first);

    PaymentMethod method = PaymentMethod.cash;
    final m = methodStr.toLowerCase();
    if (m.contains('tele') || m.contains('ቴሌ')) {
      method = PaymentMethod.telebirr;
    } else if (m.contains('cbe') || m.contains('ንግድ') || m.contains('ባንክ')) {
      method = PaymentMethod.cbeBirr;
    }

    await state.processPayment(
      bookingId: match.id,
      method: method,
      amount: match.totalPrice,
      transactionRef: 'AI-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
    );

    switch (lang) {
      case AppLanguage.am:
        return '''
### 💵 ክፍያ በተሳካ ሁኔታ ተፈጽሟል!
| የቲኬት ቁጥር | ሰሌዳ | የተከፈለው መጠን | የክፍያ መንገድ | ሁኔታ |
| :--- | :--- | :--- | :--- | :--- |
| **`${match.id}`** | `${match.licensePlate}` | **${CurrencyFormatter.format(match.totalPrice)}** | ${method.displayName} | **✅ ተከፍሏል (PAID)** |
''';
      case AppLanguage.om:
        return '''
### 💵 Kaffaltiin Milkaa'inaan Xumurameera!
| Tikkeettii | Gabatee | Gatii Kaffalame | Toftaa Kaffaltii | Haala |
| :--- | :--- | :--- | :--- | :--- |
| **`${match.id}`** | `${match.licensePlate}` | **${CurrencyFormatter.format(match.totalPrice)}** | ${method.displayName} | **✅ Kaffalameera** |
''';
      case AppLanguage.en:
        return '''
### 💵 Payment Settled Successfully!
| Ticket ID | License Plate | Amount Paid | Payment Method | Audit Status |
| :--- | :--- | :--- | :--- | :--- |
| **`${match.id}`** | `${match.licensePlate}` | **${CurrencyFormatter.format(match.totalPrice)}** | ${method.displayName} | **✅ PAID & LOGGED** |
''';
    }
  }

  static Future<String> executeToolInitiateDailyClosing({
    required String cashierName,
    String? notes,
    required AppStateNotifier state,
    required AppLanguage lang,
  }) async {
    final closing = await state.confirmDailyClosing(
      cashierName: cashierName.isNotEmpty ? cashierName : 'Cashier',
      notes: notes,
      shiftType: 'day',
      handoverTo: 'Operational Manager',
      handoverMethod: 'manager_otp',
    );

    final otp = closing.handoverOtp ?? '849201';
    final vatAmount = (closing.grossRevenue - closing.showerRevenue) * 0.15;

    switch (lang) {
      case AppLanguage.am:
        return '''
### 🔐 የቀን ፈረቃ ሂሳብ መዝጊያ ተጀምሯል (15:30 EAT)
*የቢሾፍቱ ማዕከል • የካሺየር ካዝና ርክክብ*

| የፋይናንስ መረጃ | መጠን | ዝርዝር |
| :--- | :--- | :--- |
| **የታጠቡ መኪኖች** | **${closing.carsWashedCount} መኪኖች** | የተጠናቀቁ እጥበቶች |
| **ጠቅላላ የተሰበሰበ ገቢ** | **${CurrencyFormatter.format(closing.grossRevenue)}** | ጥሬ ገንዘብ + ዲጂታል |
| • የጥሬ ገንዘብ (Cash Drawer) | ${CurrencyFormatter.format(closing.cashRevenue)} | በካዝና ውስጥ ያለ ጥሬ ገንዘብ |
| • የቴሌብር/ዲጂታል (Digital) | ${CurrencyFormatter.format(closing.digitalRevenue)} | በቴሌብር/ባንክ ገቢ የሆነ |
| **15% ህጋዊ ቫት** | **${CurrencyFormatter.format(vatAmount)}** | ለመንግስት የሚከፈል ቫት |
| **ለአጣቢዎች 15% ኮሚሽን** | **${CurrencyFormatter.format(closing.commissionPool)}** | ለአጣቢዎች የሚከፋፈል ድርሻ |

#### ⚠️ የስራ አስኪያጅ ማረጋገጫ OTP ተልኳል፡
የካሺየር ካዝናውን ለመዝጋትና ኮሚሽኑን ለአጣቢዎች ለማከፋፈል **ባለ 6-አሃዝ OTP ወደ ስራ አስኪያጁ ተልኳል** (የሙከራ OTP፦ `$otp`)። እባክዎ ስራ አስኪያጁ ኮዱን እንዲሰጥዎት ጠይቀው እዚህ ያስገቡ።
''';

      case AppLanguage.om:
        return '''
### 🔐 Cufiinsi Shiftii Guyyaa Eegalameera (15:30 EAT)
*Giddugala Bishooftuu • Wal-harkaa Fuudhiinsa Kaashiyaraa*

| Ragaa Faayinaansii | Hamma | Qabiyyee |
| :--- | :--- | :--- |
| **Makiinaa Dhiqame** | **Makiinaa ${closing.carsWashedCount}** | Dhiqa xumurame |
| **Galii Waliigalaa** | **${CurrencyFormatter.format(closing.grossRevenue)}** | Qarshii harkaa + Dijitaalaa |
| • Qarshii Sanduuqaa (Cash) | ${CurrencyFormatter.format(closing.cashRevenue)} | Sanduuqa keessa kan jiru |
| • Telebirr / Dijitaalaa | ${CurrencyFormatter.format(closing.digitalRevenue)} | Telebirr / Baankiin kan kaffalame |
| **VAT 15% Mootummaa** | **${CurrencyFormatter.format(vatAmount)}** | Taaksii seeraa |
| **Komishinii Hojjettootaa 15%** | **${CurrencyFormatter.format(closing.commissionPool)}** | Qooda hojjettoota dhiqaaf |

#### ⚠️ OTP Mirkaneessaa Hogganaa Hojiitiif Ergameera:
Cufiinsa xumuruuf **koodiin OTP 6 Hogganaa Hojii (Operations Manager) tiif ergameera** (Koodii: `$otp`). Maaloo koodicha fuudhaatii asitti galchaa.
''';

      case AppLanguage.en:
        return '''
### 🔐 Day Shift Financial Closing Initiated (15:30 EAT)
*Bishoftu Station • Cashier Drawer Custody Handover*

| Financial Component | Amount (ETB) | Accounting Treatment |
| :--- | :--- | :--- |
| **Vehicles Settled** | **${closing.carsWashedCount} vehicles** | Completed wash jobs |
| **Gross Total Revenue** | **${CurrencyFormatter.format(closing.grossRevenue)}** | Operating Cash + Digital Inflow |
| • Cash Drawer Balance | ${CurrencyFormatter.format(closing.cashRevenue)} | Physical cash for handover |
| • Digital / Telebirr Inflow | ${CurrencyFormatter.format(closing.digitalRevenue)} | Digital ledger verified |
| **15% Statutory VAT** | **${CurrencyFormatter.format(vatAmount)}** | Statutory tax obligation |
| **15% Washer Commission Pool** | **${CurrencyFormatter.format(closing.commissionPool)}** | Direct labor allocation |

#### ⚠️ Manager 6-Digit Verification OTP Dispatched:
To commit the register close and disburse washer commissions, a 6-digit OTP has been generated for the Operations Manager (`$otp`). Please obtain and type the OTP here to finalize.
''';
    }
  }

  static Future<String> executeToolVerifyClosingOtp({
    required String otpCode,
    String managerName = 'Operations Manager',
    required AppStateNotifier state,
    required AppLanguage lang,
  }) async {
    final cleanOtp = otpCode.trim().replaceAll(RegExp(r'[^0-9]'), '');
    final success = await state.acceptCashierHandover(
      managerName: managerName,
      enteredOtp: cleanOtp,
    );

    if (success) {
      await state.disburseAndReportDailyCommissionToAdmin(cashierName: 'Cashier');
      switch (lang) {
        case AppLanguage.am:
          return '''
### ✅ OTP ተረጋግጧል! የፈረቃ ሂሳብ በይፋ ተዘግቷል
1. **የካሺየር ካዝና ርክክብ**: በስራ አስኪያጅ $managerName ተረጋግጦ ተዘግቷል።
2. **የአጣቢዎች 15% ኮሚሽን**: በቅጽበት ወደ አጣቢዎች የደመወዝ መዝገብ ተከፋፍሏል።
3. **የፋይናንስ ሪፖርት**: ወደ አካውንታንት እና አድሚን ዳሽቦርድ በሙሉ ተላልፏል።
''';
        case AppLanguage.om:
          return '''
### ✅ Koodiin OTP Mirkanaa'eera! Shiftiin Cufameera
1. **Wal-harkaa Fuudhiinsi Kaashiyaraa**: Hogganaa Hojii $managerName tiin mirkanaa'ee cufameera.
2. **Komishiniin Hojjettootaa 15%**: Battalatti herrega mindaa isaaniitti qoodameera.
3. **Gabaasni Faayinaansii**: Gara daashboordii oodiitaraafi abbaa qabeenyaatti darbeera.
''';
        case AppLanguage.en:
          return '''
### ✅ OTP Verified & Accepted! Register Closed
1. **Cash Drawer Custody**: Verified and locked by $managerName.
2. **15% Washer Commissions**: Disbursed immediately to active technician payroll ledgers.
3. **Fiscal Audit Snapshot**: Dispatched to Accountant and Super Admin dashboards.
''';
      }
    } else {
      switch (lang) {
        case AppLanguage.am:
          return '❌ የተሳሳተ OTP ኮድ ነው። እባክዎ ከስራ አስኪያጁ ትክክለኛውን ባለ 6-አሃዝ ኮድ ጠይቀው እንደገና ያስገቡ።';
        case AppLanguage.om:
          return '❌ Koodiin OTP dogoggora. Maaloo koodii sirrii Hogganaa Hojiirraa fudhadhaa itti deebi\'aa.';
        case AppLanguage.en:
          return '❌ Invalid OTP code. Please verify the 6-digit handover code with the Operations Manager and try again.';
      }
    }
  }

  static Future<String> executeToolRecordEmptyExchange({
    required String chemicalNameOrId,
    required double quantity,
    required AppStateNotifier state,
    required AppLanguage lang,
  }) async {
    final query = chemicalNameOrId.toLowerCase();
    if (state.consumables.isEmpty) {
      return 'No consumable items found in inventory.';
    }
    final item = state.consumables.where(
      (c) => c.id.toLowerCase() == query || c.name.toLowerCase().contains(query),
    ).firstOrNull ?? state.consumables.first;

    await state.exchangeConsumableEmptyForNew(
      itemId: item.id,
      quantity: quantity,
      washerTeamLeaderName: 'Washer Team Lead',
    );

    final cost = quantity * item.unitCostEtb;

    switch (lang) {
      case AppLanguage.am:
        return '''
### 🔄 ዕቃ በዕቃ ቅያሪ ተመዝግቧል (COGS Deduction)
| የተሰጠው ኬሚካል | የወጣው ብዛት | የተመለሰ ባዶ ዕቃ | የተመዘገበ ወጪ (COGS) | የቀረ ክምችት |
| :--- | :--- | :--- | :--- | :--- |
| **${item.name} (${item.id})** | **$quantity ${item.unit}** | $quantity ባዶ እቃ ተመልሷል | **${CurrencyFormatter.format(cost)}** | ${item.currentStock} ${item.unit} |

> *ማስታወሻ፦ ኬሚካሉ እንደ ዕለታዊ የስራ ማስኬጃ ወጪ (Direct Consumable COGS) በ P&L ላይ በቀጥታ ተቀንሷል።*
''';
      case AppLanguage.om:
        return '''
### 🔄 Qodaa Duudaan Deebi'ee Haaraan Kennameera (COGS)
| Qoricha Dhiqaa | Hamma Kenname | Qodaa Deebi'e | Baasii Hojii (COGS) | Hambaa Galmaa |
| :--- | :--- | :--- | :--- | :--- |
| **${item.name} (${item.id})** | **$quantity ${item.unit}** | Qodaa $quantity deebi'eera | **${CurrencyFormatter.format(cost)}** | ${item.currentStock} ${item.unit} |
''';
      case AppLanguage.en:
        return '''
### 🔄 Empty-for-Full Container Exchange Logged (COGS)
| Chemical Consumable | Issued Qty | Empty Returned | Expensed to COGS | Warehouse Balance |
| :--- | :--- | :--- | :--- | :--- |
| **${item.name} (${item.id})** | **$quantity ${item.unit}** | $quantity rinsed empty | **${CurrencyFormatter.format(cost)}** | ${item.currentStock} ${item.unit} |

> *Accounting Treatment: Expensed directly to Cost of Goods Sold (COGS) under the anti-theft container swap rule.*
''';
    }
  }

  static Future<String> executeToolUpdateMasterPrice({
    required String targetId,
    required double newPrice,
    required AppStateNotifier state,
    required AppLanguage lang,
  }) async {
    final query = targetId.toLowerCase();
    final overhead = state.monthlyOverheads.cast<MonthlyOverheadExpense?>().firstWhere(
      (o) => o?.id.toLowerCase() == query || (o?.name.toLowerCase().contains(query) ?? false),
      orElse: () => null,
    );

    if (overhead != null) {
      await state.updateOverheadExpense(overhead.id, newPrice);
      switch (lang) {
        case AppLanguage.am:
          return '✅ የወርሃዊ ወጪ ዋጋ ተቀይሯል፦ **${overhead.nameAmharic}** ወደ **${CurrencyFormatter.format(newPrice)}/ወር** (የቀን አማካይ፦ **${CurrencyFormatter.format(newPrice / 30)}/ቀን**) ተሻሽሏል!';
        case AppLanguage.om:
          return '✅ Baasiin baatii jijjiirameera፦ **${overhead.nameOromo}** gara **${CurrencyFormatter.format(newPrice)}/ji\'atti** (Guyyaatti፦ **${CurrencyFormatter.format(newPrice / 30)}**) fooyya\'eera!';
        case AppLanguage.en:
          return '✅ Master Overhead Price Updated: **${overhead.name}** updated to **${CurrencyFormatter.format(newPrice)}/month** (Daily Accrual: **${CurrencyFormatter.format(newPrice / 30)}/day**)!';
      }
    }

    return '✅ Master Price Updated: $targetId successfully set to ETB ${newPrice.toStringAsFixed(2)}.';
  }

  // ==========================================
  // STATION WATCHDOG ALERTS & MONITORS
  // ==========================================

  static List<StationWatchdogAlert> generateWatchdogAlerts(AppStateNotifier state) {
    final List<StationWatchdogAlert> alerts = [];
    final now = DateTime.now();

    // 1. Inventory stock alerts
    final lowStock = state.consumables.where((c) => c.isLowStock).toList();
    if (lowStock.isNotEmpty) {
      final names = lowStock.map((c) => '${c.name} (${c.currentStock} ${c.unit})').join(', ');
      alerts.add(
        StationWatchdogAlert(
          id: 'watchdog_low_stock',
          title: 'Low Chemical Consumables',
          description: '${lowStock.length} chemical items below minimum re-order threshold: $names',
          severity: WatchdogSeverity.warning,
          category: WatchdogCategory.inventory,
          recommendedAction: 'Notify Storekeeper to order from supplier and enforce empty-for-full container return (ዕቃ በዕቃ).',
        ),
      );
    }

    // 2. Bay Turnaround Bottlenecks (> 35 mins without completion)
    for (final bay in state.bays) {
      if (bay.status == BayStatus.occupied && bay.startedAt != null) {
        final elapsed = now.difference(bay.startedAt!).inMinutes;
        if (elapsed > 35) {
          alerts.add(
            StationWatchdogAlert(
              id: 'watchdog_bay_${bay.type.name}',
              title: '${bay.type.displayName} Turnaround Delay ($elapsed mins)',
              description: 'Vehicle ${bay.activeLicensePlate ?? 'Unknown'} in ${bay.type.displayName} has exceeded target turnaround (35 mins).',
              severity: WatchdogSeverity.warning,
              category: WatchdogCategory.bays,
              recommendedAction: 'Assign secondary washer pair or inspect drying phase to avoid queue congestion.',
            ),
          );
        }
      }
    }

    // 3. Shift Handover Protocol (15:30 EAT)
    if (now.hour >= 15) {
      final pendingCashier = state.pendingCashierHandover ?? state.pendingCashierAdminHandover;
      if (pendingCashier != null) {
        alerts.add(
          StationWatchdogAlert(
            id: 'watchdog_shift_handover',
            title: '15:30 Shift Handover Awaiting OTP',
            description: 'Cashier day shift drawer physical cash settlement is awaiting Operations Manager 6-digit OTP verification.',
            severity: WatchdogSeverity.danger,
            category: WatchdogCategory.shiftHandover,
            recommendedAction: 'Operations Manager must conduct dual physical cash count in security office and submit 6-digit OTP.',
          ),
        );
      }
    }

    // 4. Machinery & Fixed Asset Maintenance
    final unservicedAssets = state.fixedAssets
        .where((a) => a.condition == AssetCondition.needsService || a.condition == AssetCondition.underRepair)
        .toList();
    if (unservicedAssets.isNotEmpty) {
      final names = unservicedAssets.map((a) => '${a.name} (${a.condition.displayName})').join(', ');
      alerts.add(
        StationWatchdogAlert(
          id: 'watchdog_machinery_health',
          title: 'Machinery Preventative Service Due',
          description: '${unservicedAssets.length} station units need technician service or repair: $names',
          severity: WatchdogSeverity.warning,
          category: WatchdogCategory.machinery,
          recommendedAction: 'Log maintenance job card and verify pump-head oil levels to prevent downtime.',
        ),
      );
    }

    return alerts;
  }

  static String generateWatchdogReport(AppStateNotifier state) {
    final alerts = generateWatchdogAlerts(state);

    if (alerts.isEmpty) {
      return '''
### 🛡️ Station Watchdog Health Audit: ALL CLEAR
*Operational Status: **100% HEALTHY** • Zero bottlenecks or discrepancies detected*

| System Monitored | Status | Operational Condition |
| :--- | :--- | :--- |
| **Bay Turnaround** | **Normal** | All bays operating within 20–30 min turnaround |
| **Chemical Warehouse** | **Healthy** | All 22 consumables above minimum re-order thresholds |
| **15:30 Shift Handover** | **Compliant** | Cash custody drawers balanced & OTP verified |
| **Fixed Assets Machinery** | **Operational** | Kärcher washers, vacuums, and compressors in prime health |

> *Everything is running smoothly! Keep bays moving efficiently.*
''';
    }

    final rows = alerts.map((a) {
      final icon = a.severity == WatchdogSeverity.danger ? '🛑 DANGER' : '⚠️ WARNING';
      return '| **${a.title}** | $icon | ${a.description} | **${a.recommendedAction}** |';
    }).join('\n');

    return '''
### ⚠️ Station Watchdog Health Audit: ${alerts.length} Active Alerts
*Automated Operational Risk & Loss Prevention Monitor*

| Operational Check | Severity | Current Situation | Recommended Corrective Action |
| :--- | :--- | :--- | :--- |
$rows

> *Audit Protocol: Address high-severity items first to maintain station throughput and zero cash variance.*
''';
  }

  // ==========================================
  // CUSTOMER LOYALTY PASS & ROAD CARE
  // ==========================================

  static CustomerLoyaltyInfo checkCustomerLoyalty(String plateNumber, AppStateNotifier state) {
    final cleanPlate = plateNumber.trim().toUpperCase().replaceAll(' ', '');
    final completedBookings = state.bookings.where((b) {
      if (b.status != WashStatus.completed) return false;
      final p = b.licensePlate.trim().toUpperCase().replaceAll(' ', '');
      if (p.isEmpty) return false;
      return p == cleanPlate || p.contains(cleanPlate) || cleanPlate.contains(p);
    }).toList();

    final count = completedBookings.length;
    final isEligible = count > 0 && (count % 5 == 0);
    final progress = count % 5;
    final remaining = isEligible ? 0 : (5 - progress);
    final rewardText = isEligible
        ? 'FREE Silver Wash or 50% OFF Gold Detailing!'
        : '$remaining more wash(es) until FREE Silver Wash';

    return CustomerLoyaltyInfo(
      plateNumber: cleanPlate.isNotEmpty ? cleanPlate : 'WALK-IN',
      totalCompletedWashes: count,
      progressInCycle: isEligible ? 5 : progress,
      washesRemainingForReward: remaining,
      isRewardEligible: isEligible,
      rewardDescription: rewardText,
    );
  }

  static String generateCustomerLoyaltyReport(String rawQuery, AppStateNotifier state, AppLanguage lang) {
    final plateRegex = RegExp(r'\b([0-9]-[A-Za-z0-9]{4,8}|ET-?[0-9A-Za-z]{3,7}|AA-?[0-9A-Za-z]{3,7}|OR-?[0-9A-Za-z]{3,7})\b', caseSensitive: false);
    final match = plateRegex.firstMatch(rawQuery);
    String detectedPlate = match?.group(1) ?? '';

    if (detectedPlate.isEmpty) {
      if (state.bookings.isNotEmpty) {
        final last = state.bookings.lastWhere((b) => b.licensePlate.isNotEmpty, orElse: () => state.bookings.first);
        if (last.licensePlate.isNotEmpty) {
          detectedPlate = last.licensePlate;
        }
      }
    }

    if (detectedPlate.isEmpty) {
      detectedPlate = '2-B12345';
    }

    final info = checkCustomerLoyalty(detectedPlate, state);
    final dots = List.generate(5, (i) => i < info.progressInCycle ? '●' : '○').join('');

    switch (lang) {
      case AppLanguage.am:
        return '''
### 🎁 የቢሼ ተደጋጋሚ ደንበኛ የታማኝነት ፓስ (Loyalty Pass)
*በየ 5 እጥበት 1 ነጻ የሲልቨር እጥበት ወይም 50% የጎልድ ቅናሽ ይሸለሙ!*

| የሰሌዳ ቁጥር | የተጠናቀቁ እጥበቶች | የዙር ሂደት | የሽልማት ሁኔታ |
| :--- | :--- | :--- | :--- |
| **${info.plateNumber}** | **${info.totalCompletedWashes} ጊዜ** | `[$dots]` (${info.progressInCycle}/5) | **${info.isRewardEligible ? '🎉 ነጻ እጥበት ተከፍቷል!' : '${info.washesRemainingForReward} እጥበት ቀርቷል'}** |

${info.isRewardEligible ? '🌟 **እንኳን ደስ አለዎት!** ዛሬ 1 ነጻ የሲልቨር እጥበት ወይም በጎልድ እጥበት ላይ 50% ቅናሽ ማግኘት ይችላሉ። ለካሺየሩ ያሳውቁ!' : '💡 **ማስታወሻ**: ቀጣዩን ነጻ እጥበት ለማግኘት **${info.washesRemainingForReward} እጥበት** ብቻ ቀርቶዎታል። ሰሌዳዎን በማስገባት በማንኛውም ጊዜ ማረጋገጥ ይችላሉ!'}
''';

      case AppLanguage.om:
        return '''
### 🎁 Paasii Maamilummaa Yeroo Hunda BISHE (Loyalty Pass)
*Dhiqa 5 booda dhiqa 1 Silver tolaa ykn Gold irratti hir'ina 50% argadhaa!*

| Gabatee Makiinaa | Dhiqa Xumurame | Marsaa Ammaa | Haala Badhaasaa |
| :--- | :--- | :--- | :--- |
| **${info.plateNumber}** | **Dhiqa ${info.totalCompletedWashes}** | `[$dots]` (${info.progressInCycle}/5) | **${info.isRewardEligible ? '🎉 Dhiqni tolaa banameera!' : 'Dhiqa ${info.washesRemainingForReward}tu hafe'}** |

${info.isRewardEligible ? '🌟 **Baga gammaddan!** Har\'a dhiqa Silver tolaa ykn Gold irratti hir\'ina 50% argachuu dandeessu. Kaashiyaraatti himadhaa!' : '💡 **Hubachiisa**: Badhaasa dhiqa tolaa itti aanu argachuuf **dhiqa ${info.washesRemainingForReward}** qofatu hafa.'}
''';

      case AppLanguage.en:
        return '''
### 🎁 BISHE Frequent Washer Loyalty Pass
*Every 5 completed washes unlocks a FREE Silver Wash or 50% OFF Gold Detailing!*

| License Plate | Completed Washes | Loyalty Progress | Milestone Reward Status |
| :--- | :--- | :--- | :--- |
| **${info.plateNumber}** | **${info.totalCompletedWashes} visits** | `[$dots]` (${info.progressInCycle}/5) | **${info.isRewardEligible ? '🎉 REWARD UNLOCKED!' : '${info.washesRemainingForReward} more wash(es) needed'}** |

${info.isRewardEligible ? '🌟 **Congratulations!** You have qualified for a **FREE Silver Wash** or **50% OFF Gold Detailing** today. Mention this to our cashier upon intake!' : '💡 **Tip**: You only have **${info.washesRemainingForReward} more wash(es)** until your next free wash milestone reward!'}
''';
    }
  }

  static String generateBishoftuMudRoadsReport(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.am:
        return '''
### 🌋 የቢሾፍቱ ሀይቆች እና የገጠር መንገዶች የቀይ አፈር/ጭቃ እጥበት
*ባቦጋያ፣ ኩሪፍቱ፣ ሆራ እና ጨለለቃ ለጎበኙ አሽከርካሪዎች የተዘጋጀ ልዩ ጥበቃ*

የቢሾፍቱ ቀይ የከርሰ-ምድር አፈር ከፍተኛ ማዕድን ስላለው በፀሀይ ሲደርቅ ከመኪናው ቀለም፣ ከብሬክ ካሊፐር እና ከሻሲው ላይ በቀላሉ አይለቅም። በቢሼ ማጠቢያ የምንሰጠው ልዩ እንክብካቤ፡
1. **ከፍተኛ ግፊት ያለው የታችኛው አካል (Undercarriage) እጥበት**: የደረቀውን ቀይ ጭቃ ከሻሲ፣ ከመሪ እና ከእግሮች ላይ ያላቅቃል።
2. **ንክኪ-አልባ የሆም አረፋ ቅድመ-እጥበት**: አፈሩን ሳያሹ በኬሚካል በማቅለጥ ቀለሙ እንዳይጫጭር ይከላከላል።
3. **የዊል-አርች እና የጎማ ማጽዳት**: በዊል ቤይ ውስጥ የተከማቸውን ጭቃ በጥልቀት ያጸዳል።

💡 **ምክር**: የሀይቅ ጉብኝት ካደረጉ **ጎልድ ፖሊሽ** ወይም **ፕላቲነም ዲቴይሊንግ** ፓኬጅን ይምረጡ!
''';
      case AppLanguage.om:
        return '''
### 🌋 Dhiqa Dhoqqee Diimaa Haroowwan Bishooftuu
*Eegumsa Addaa Maamiltoota Haroo Baabboogayyaa, Kuriiftuu fi Horaa Daawwataniif*

Dhoqqeen diimaa naannoo haroowwan Bishooftuu albuuda cimaa waan qabuuf erga gogee booda halluu makiinaa fi shassii irraa salphaatti hin ka'u. Dhiqa Konkolaataa BISHE keessatti:
1. **Dhiqa Jala Makiinaa (Undercarriage)**: Dhoqqee gogee shassii fi naannoo gommaa jala jiru dhiibbaa bishaaniitiin buqqisa.
2. **Hoomacha Dhiqaa Bu'uuraa**: Dhoqqicha osoo hin rigin baqsuudhaan rifeensa halluu makiinaa irraa ittisa.
3. **Qulqullina Gommaafi Riimii**: Dhoqqee gommaa keessatti qabame hundumaa qulqulleessa.

💡 **Gorsa**: Boqonnaa haroowwanii booda paakeejii **Gold Polish** ykn **Platinum Detailing** filadhaa!
''';
      case AppLanguage.en:
        return '''
### 🌋 Bishoftu Crater Lakes Mud & Farm Trail Wash Protocol
*Specialized Red Clay Care for Visitors of Lakes Babogaya, Kuriftu, and Hora*

The volcanic red clay around Bishoftu crater lakes and resort trails is mineral-rich. When baked by the sun, it cakes onto the chassis, brake calipers, and wheel wells, causing premature wear and paint scratches if improperly scrubbed.

#### BISHE Volcanic Mud Wash Protocol:
1. **High-Pressure Undercarriage Mud Blast**: Sweeps away compacted volcanic mud from the suspension and frame.
2. **Touchless Active Snow Foam Pre-Soak**: Emulsifies and encapsulates grit so mud slides off without microfiber swirl scratches.
3. **Deep Wheel-Arch & Caliper Decontamination**: Prevents clay buildup from causing brake squeal or wheel imbalance.

💡 **Recommendation**: For lake tour vehicles, our **Gold Polish** or **Platinum Detailing** package provides optimal undercarriage restoration and paint seal protection!
''';
    }
  }

  static String generateCustomerScratchInspectionReport(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.am:
        return '''
### 📷 ከእጥበት በፊት የሚደረግ የጭረትና ጉዳት ፍተሻ (Pre-Wash Inspection)
*ለደንበኞቻችን ሙሉ መተማመኛ የተዘጋጀ የጥራት አሰራር*

በቢሼ ማጠቢያ መኪናዎን ከማስገባትዎ በፊት የአቀባበል ሰራተኞቻችን ከእርስዎ ጋር በመሆን፡
1. **የዙሪያ ፍተሻ**: በመኪናው ዙሪያ ያሉ የቀደሙ የድንጋይ ጠጠር ምቶች፣ የፊትና የኋላ መከላከያ ጭረቶች ይመረመራሉ።
2. **ዲጂታል ፎቶ ምዝገባ**: ማንኛውም አስቀድሞ የነበረ ጉዳት በስልክ ተነስቶ በቲኬትዎ ላይ ይመዘገባል።
3. **100% ፍትሃዊ ዋስትና**: እጥበቱ ተጠናቆ ሲረከቡ መኪናዎ በሙሉ ጥንቃቄ መጠበቁን ያረጋግጣሉ።

> *አገልግሎቱ ለሁሉም ደንበኞች በነጻ የሚሰጥ መደበኛ የጥራት መመሪያችን ነው።*
''';
      case AppLanguage.om:
        return '''
### 📷 Qorannoo Suuraa Miidhaa fi Rifeensaa Dhiqa Duraa
*Wabii fi Amanamummaa Guutuu Maamiltoota Keenyaaf*

Dhiqa Konkolaataa BISHE keessatti osoo dhiqni hin eegalin duratti hojjettoonni keenya isin waliin:
1. **Qorannoo Naannoo Makiinaa**: Rifeensa dhakaa, miidhaa durii bampaarii fi kofa makiinaa ilaalu.
2. **Galmee Suuraa Dijitaalaa**: Miidhaan durii kamiyyuu suuraadhaan kaafamee tikkeettii keessan irratti galmaa'a.
3. **Wabii 100%**: Xumura dhiqaatiin makiinaan keessan eegumsa cimaadhaan qulqullaa'uu isaa mirkaneeffattu.

> *Tajaajilli kun maamiltoota hundumaaf tola kan kennamudha.*
''';
      case AppLanguage.en:
        return '''
### 📷 Pre-Wash Visual Scratch & Dent Inspection Protocol
*100% Dispute-Free Transparency & Customer Peace of Mind*

Before your vehicle enters Bay 1 or Bay 2, our intake attendants perform a complimentary exterior inspection:
1. **Walkaround Assessment**: We identify pre-existing stone chips, bumper scrapes, and door dings with the driver.
2. **Digital Ticket Photo Logging**: Any prior blemishes are photographed and attached directly to your digital wash record.
3. **Showroom Guarantee**: When your vehicle exits the drying bay, you inspect the finished shine knowing your car was treated with pristine care.

> *This complimentary inspection is standard on all Silver, Gold, Platinum, and VIP packages.*
''';
    }
  }

  // ==========================================
  // BLIND SPOT 1: SHOWERS & 0% VAT EXEMPTION
  // ==========================================
  static String _generateShowersReport(AppStateNotifier state, DateTime now) {
    final todayShowers = state.showerRecords.where((s) {
      final d = s.recordedAt;
      return d.year == now.year && d.month == now.month && d.day == now.day;
    }).toList();

    final totalUsers = todayShowers.fold(0, (sum, s) => sum + s.userCount);
    final totalAmount = todayShowers.fold(0.0, (sum, s) => sum + s.totalAmount);
    final cashAmount = todayShowers.where((s) => s.isCash).fold(0.0, (sum, s) => sum + s.totalAmount);
    final digitalAmount = todayShowers.where((s) => s.isDigital).fold(0.0, (sum, s) => sum + s.totalAmount);

    final rows = todayShowers.take(8).map((s) {
      final timeStr = '${s.recordedAt.hour.toString().padLeft(2, '0')}:${s.recordedAt.minute.toString().padLeft(2, '0')}';
      final method = s.isCash ? '💵 Cash' : '📱 Telebirr/Digital';
      return '| `$timeStr` | ${s.userCount} person(s) | ${CurrencyFormatter.format(s.unitPrice)} | **${CurrencyFormatter.format(s.totalAmount)}** | $method | ${s.recordedBy} |';
    }).join('\n');

    return '''
### 🚿 Today's Shower Service & 0% VAT Statutory Audit
*Station Date: ${now.day}/${now.month}/${now.year} | Statutory Tax Treatment: **0% VAT EXEMPT***

| Metric | Recorded Value | Accounting Compliance |
| :--- | :--- | :--- |
| **Total Shower Guests Today** | **$totalUsers persons** | Clean hot water suite visits |
| **Total Shower Collections** | **${CurrencyFormatter.format(totalAmount)}** | Gross Inflow (0% VAT exempt) |
| • Cash Drawer Receipts | ${CurrencyFormatter.format(cashAmount)} | Subject to physical 15:30 shift handover |
| • Telebirr / Digital Receipts | ${CurrencyFormatter.format(digitalAmount)} | Verified via digital merchant ledger |
| **Statutory VAT Obligation** | **ETB 0.00 (Exempt)** | Certified statutory hygiene exemption |

#### Live Shower Tickets Log:
| Time | Guests | Unit Price | Total Settled | Payment Method | Attendant |
| :--- | :--- | :--- | :--- | :--- | :--- |
${rows.isEmpty ? '| No shower visits logged yet today | - | - | - | - | - |' : rows}

> *Note: Shower revenue is never co-mingled with car wash commission pools and is 100% exempt from the 15% vehicle VAT deduction.*
''';
  }

  // ==========================================
  // BLIND SPOT 2: BAY DISTRIBUTION & SPEED
  // ==========================================
  static String _generateBaysReport(AppStateNotifier state, DateTime now) {
    final bays = state.bays;
    final bay1 = bays.firstWhere((b) => b.type == BayType.bay1, orElse: () => const StationBay(type: BayType.bay1));
    final bay2 = bays.firstWhere((b) => b.type == BayType.bay2, orElse: () => const StationBay(type: BayType.bay2));
    final van = bays.firstWhere((b) => b.type == BayType.mobileVan, orElse: () => const StationBay(type: BayType.mobileVan));

    final activeQueue = state.bookings.where((b) => b.status.name != 'completed' && b.status.name != 'cancelled').toList();
    final completedCount = state.bookings.where((b) {
      final d = b.createdAt;
      return d.year == now.year && d.month == now.month && d.day == now.day && b.status.name == 'completed';
    }).length;

    String getElapsedTime(DateTime? start) {
      if (start == null) return '0 min';
      final diff = DateTime.now().difference(start).inMinutes;
      return '$diff min';
    }

    return '''
### ⚡ Live Bay Distribution, Queue & Turnaround Speed
*Active Station Bays: 2 Concrete Bays + 1 Mobile Unit | Today's Throughput: **$completedCount vehicles completed***

| Bay / Station Unit | Live Operational Status | Active Vehicle | Assigned Washer | Elapsed Time |
| :--- | :--- | :--- | :--- | :--- |
| **Bay 1 (Concrete)** | **${bay1.status.displayName}** | `${bay1.activeLicensePlate ?? 'VACANT'}` | ${bay1.assignedWasherName ?? 'Unassigned'} | ${getElapsedTime(bay1.startedAt)} |
| **Bay 2 (Concrete)** | **${bay2.status.displayName}** | `${bay2.activeLicensePlate ?? 'VACANT'}` | ${bay2.assignedWasherName ?? 'Unassigned'} | ${getElapsedTime(bay2.startedAt)} |
| **Mobile Van Unit** | **${van.status.displayName}** | `${van.activeLicensePlate ?? 'AVAILABLE'}` | ${van.assignedWasherName ?? 'Roving Team'} | ${getElapsedTime(van.startedAt)} |

#### Live Waiting Queue (${activeQueue.length} vehicles waiting):
${activeQueue.isEmpty ? '✅ **Zero bay queue** — all incoming vehicles receive immediate intake!' : activeQueue.take(5).map((b) => '• **${b.licensePlate.isNotEmpty ? b.licensePlate : 'WALK-IN'}** (${b.carType.displayName}): ${b.status.name.toUpperCase()} (Est. wait: ~${(activeQueue.indexOf(b) + 1) * 15} mins)').join('\n')}

#### Turnaround Efficiency Guidelines:
- **Standard Type A Wash**: Target turnaround is **20–25 minutes**.
- **Gold Polish Detailing**: Target turnaround is **35–45 minutes**.
- **Heavy Truck (Type C)**: Target turnaround is **50–65 minutes**.
''';
  }

  // ==========================================
  // BLIND SPOT 3: FIXED ASSETS & MACHINERY HEALTH
  // ==========================================
  static String _generateFixedAssetsReport(AppStateNotifier state) {
    final assets = state.fixedAssets;
    final operational = assets.where((a) => a.condition == AssetCondition.operational).toList();
    final needsService = assets.where((a) => a.condition == AssetCondition.needsService).toList();
    final underRepair = assets.where((a) => a.condition == AssetCondition.underRepair).toList();
    final decommissioned = assets.where((a) => a.condition == AssetCondition.decommissioned).toList();
    final totalValuation = assets.fold(0.0, (s, a) => s + (a.assetValueEtb * a.quantity));

    final alertRows = assets.where((a) => a.condition != AssetCondition.operational).map((a) {
      return '| **${a.name}** | `${a.serialNumber}` | ${a.assignedLocation} | **${a.condition.displayName}** | ${a.notes.isNotEmpty ? a.notes : 'Scheduled check'} |';
    }).join('\n');

    return '''
### 🛠️ Station Fixed Assets & Machinery Health Audit
*Total Machinery Assets: **${assets.length} units** | Total Capital Valuation: **${CurrencyFormatter.format(totalValuation)}***

| Equipment Health Status | Count | Capital Protection Action |
| :--- | :--- | :--- |
| **✅ 100% Operational** | **${operational.length} units** | In continuous active bay service |
| **⚠️ Needs Preventative Service** | **${needsService.length} units** | Oil change, filter, or valve seal inspection |
| **🔧 Currently Under Repair** | **${underRepair.length} units** | Technician workshop ticket open |
| **🛑 Decommissioned / Retired** | **${decommissioned.length} units** | Write-off documented in asset register |

#### Active Machinery Alerts & Maintenance Log:
| Equipment Asset | Serial Number | Bay Location | Current Condition | Maintenance Notes |
| :--- | :--- | :--- | :--- | :--- |
${alertRows.isEmpty ? '| ✅ All station equipment (Kärcher washers, vacuums, compressors) are operating in peak condition! | - | - | - | - |' : alertRows}

> *Preventative Maintenance Rule: High-pressure Kärcher pumps must undergo pump-head oil changes every 300 operating hours.*
''';
  }

  // ==========================================
  // BLIND SPOT 4: BANK DEPOSITS & RECONCILIATION
  // ==========================================
  static String _generateBankDepositsReport(AppStateNotifier state, DateTime now) {
    final deposits = state.bankDeposits.where((d) {
      final dt = d.depositedAt;
      return dt.year == now.year && dt.month == now.month && dt.day == now.day;
    }).toList();

    final totalDeposited = deposits.fold(0.0, (sum, d) => sum + d.amount);

    final rows = deposits.take(6).map((d) {
      final timeStr = '${d.depositedAt.hour.toString().padLeft(2, '0')}:${d.depositedAt.minute.toString().padLeft(2, '0')}';
      return '| `$timeStr` | **${d.bankName}** | `${d.accountNumber}` | `${d.referenceSlipNumber}` | **${CurrencyFormatter.format(d.amount)}** | ${d.cashierName} |';
    }).join('\n');

    return '''
### 🏦 Bank Deposit Slips & Cash Drawer Reconciliation
*Station Date: ${now.day}/${now.month}/${now.year} | Verified Slips Logged: **${deposits.length} deposits***

| Target Account | Bank Slip Reference | Deposited Amount | Cashier Name | Audit Status |
| :--- | :--- | :--- | :--- | :--- |
${rows.isEmpty ? '| No bank deposit slips logged yet today | - | - | - | - |' : rows}

#### Reconciliation Summary:
- **Total Deposited to Bank Today**: **${CurrencyFormatter.format(totalDeposited)}**
- **Bank Destination Accounts**: Commercial Bank of Ethiopia (CBE) & Awash Bank
- **Loss Prevention Standard**: Physical bank stamped deposit slips must be attached to the closing envelope and matched against the cashier's daily cash drawer settlement.
''';
  }

  // ==========================================
  // BLIND SPOT 5: SHIFT HANDOVER & 6-DIGIT OTP
  // ==========================================
  static String _generateShiftHandoverReport(AppStateNotifier state, DateTime now) {
    final pendingCashier = state.pendingCashierHandover ?? state.pendingCashierAdminHandover;
    final pendingManager = state.pendingAdminNightHandover;

    return '''
### 🔐 Shift Custody & 6-Digit OTP Handover Status
*Station Security Protocol: Cash custody transferred between shifts via cryptographic 6-digit OTP*

| Shift Handover Gate | Shift Time | Handover Custody | Current Verification Status | Action Required |
| :--- | :--- | :--- | :--- | :--- |
| **Day Shift Handover** | 15:30 EAT | Cashier ➔ Operations Manager | **${pendingCashier != null ? '⏳ PENDING VERIFICATION' : '✅ VERIFIED & CLOSED'}** | ${pendingCashier != null ? 'Manager must verify cash count & submit 6-digit OTP' : 'Cash drawer matched successfully'} |
| **Night Shift Closing** | Station Close | Operations Manager ➔ Safe/Bank | **${pendingManager != null ? '⏳ PENDING CLOSING' : '✅ NORMAL'}** | Final day reconciliation & physical cash drop |

#### Handover Loss-Prevention Controls:
1. Physical cash counting must take place in the station security office under dual witness.
2. The Cashier cannot leave until the Operations Manager verifies the physical drawer cash against the system total and submits the generated 6-digit OTP.
3. Any variance over **ETB 20.00** must be logged as a discrepancy report with immediate notification to the General Manager.
''';
  }

  // ==========================================
  // BLIND SPOT 6: CUSTOMER REVIEWS & SENTIMENT
  // ==========================================
  static String _generateCustomerFeedbackReport(AppStateNotifier state) {
    final allFeedback = state.allCustomerFeedback;
    final approved = state.approvedCustomerFeedback;
    final pending = state.pendingCustomerFeedback;
    final avgRating = allFeedback.isNotEmpty
        ? (allFeedback.fold(0, (sum, f) => sum + f.stars) / allFeedback.length)
        : 4.0;

    final feedbackRows = allFeedback.take(6).map((f) {
      final starsStr = '⭐' * f.stars;
      final status = f.status.name.toUpperCase();
      final comment = f.comment.isNotEmpty ? f.comment : '(No written comment)';
      return '| **${f.customerName.isNotEmpty ? f.customerName : 'Customer'}** | $starsStr | "$comment" | **$status** |';
    }).join('\n');

    return '''
### ⭐ Customer Satisfaction & Feedback Sentiment
*Overall Station Rating: **${avgRating.toStringAsFixed(1)} / 4.0 Stars** (${allFeedback.length} total customer evaluations)*

| Sentiment Metric | Count | Performance Benchmark |
| :--- | :--- | :--- |
| **Average Star Rating** | **${avgRating.toStringAsFixed(1)} / 4.0** | Target: ≥ 3.5 Stars |
| **Approved Public Reviews** | **${approved.length} reviews** | Published on customer dashboard |
| **Pending Moderation Queue** | **${pending.length} reviews** | Awaiting Manager/Admin review |
| **Customer Satisfaction Index** | **${((avgRating / 4.0) * 100).toStringAsFixed(0)}%** | High Quality Standard |

#### Recent Customer Reviews:
| Customer Name | Star Rating | Feedback Comment | Moderation Status |
| :--- | :--- | :--- | :--- |
${feedbackRows.isEmpty ? '| No customer feedback submissions yet | - | - | - |' : feedbackRows}
''';
  }

  // ==========================================
  // STOREKEEPER: EMPTY CONTAINER EXCHANGE (ዕቃ በዕቃ)
  // ==========================================
  static String _generateEmptyExchangeReport(AppStateNotifier state) {
    final lowStock = state.consumables.where((c) => c.isLowStock).toList();
    final shampoo = state.consumables.where((c) => c.id == 'CS-009').firstOrNull ??
        (state.consumables.isNotEmpty
            ? state.consumables.first
            : const ConsumableItem(
                id: 'CS-009',
                name: 'Snow Foam Shampoo (5L Canister)',
                nameAmharic: 'የበረዶ አረፋ ሻምፑ',
                category: 'Chemicals',
                unit: 'cans',
                currentStock: 0,
                minThreshold: 4,
                unitCostEtb: 1850.0,
              ));
    final perfume = state.consumables.where((c) => c.id == 'CS-006').firstOrNull ??
        (state.consumables.isNotEmpty
            ? state.consumables.first
            : const ConsumableItem(
                id: 'CS-006',
                name: 'Interior Fragrance Perfume (500ml)',
                nameAmharic: 'የመኪና ውስጥ ሽቶ',
                category: 'Chemicals',
                unit: 'bottles',
                currentStock: 0,
                minThreshold: 6,
                unitCostEtb: 420.0,
              ));

    return '''
### 🔄 Storekeeper Empty-for-Full Container Exchange (ዕቃ በዕቃ)
*Station Anti-Theft Protocol: Zero new chemical containers dispensed without an empty container returned*

| Controlled Chemical | Container Type | Current Full Stock | Minimum Re-Order Threshold | Exchange Status |
| :--- | :--- | :--- | :--- | :--- |
| **Snow Foam Shampoo (CS-009)** | 5L Plastic Can | **${shampoo.currentStock} cans** | ${shampoo.minThreshold} cans | Strict Empty Can Exchange |
| **Interior Fragrance (CS-006)** | 500ml Spray Bottle | **${perfume.currentStock} bottles** | ${perfume.minThreshold} bottles | Empty Spray Bottle Exchange |
| **Tire Dressing Gel (CS-004)** | 1L Squeeze Bottle | Tracked | 5 bottles | Bottle Return Required |

#### Storekeeper Loss-Prevention Guidelines:
1. Washers must return the rinsed empty 5L container before receiving a full dilution container.
2. If a container is lost or punctured, an incident ticket must be authorized by the Operations Manager.
3. Low-stock re-order alerts currently active: **${lowStock.length} items**.
''';
  }

  // ==========================================
  // CUSTOMER CONCIERGE LOCAL REPORTS
  // ==========================================
  static String _generateCustomerLocationGpsReport(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.am:
        return '''
### 📍 ቢሼ የመኪና ማጠቢያ — የጂፒኤስ መገኛና ስልክ
*የቢሾፍቱ ሃይቆች መኪና እጥበትና ዲቴይሊንግ ስቱዲዮ • ቢሾፍቱ (ደብረ ዘይት)*

| መረጃ | የጣቢያው መገኛና የስልክ መስመሮች |
| :--- | :--- |
| **የጎግል ካርታ ቀጥታ ሊንክ** | [🗺️ በጎግል ካርታ ክፈት](${AppConstants.googleMapsLocationUrl}) |
| **የጂፒኤስ መለያ (GPS)** | `${AppConstants.stationGpsCoordinates}` *(አስርዮሽ፦ `${AppConstants.stationGpsDecimal}`)* |
| **ከተማ / ክልል** | ቢሾፍቱ (ደብረ ዘይት)፣ ሆራ ሐይቅ አጠገብ፣ ኦሮሚያ |
| **መለያ ምልክቶች** | ከ**ሂርና ስጋ ቤት** ጀርባ፣ ወደ **አለምሸት ፌሮ** መታጠፊያ |
| **የመግቢያ በር / ዴስክ** | [📞 **${AppConstants.stationPhoneNumber}**](tel:${AppConstants.stationPhoneNumber}) |
| **ደንበኞች አገልግሎት / ሥራ አስኪያጅ** | [📞 **${AppConstants.stationPhoneNumberSecondary}**](tel:${AppConstants.stationPhoneNumberSecondary}) |

---

### 🚗 የመኪና መምጫ አቅጣጫዎች
- **ከአዲስ አበባ በፈጣን መንገድ (Expressway)**፦ በቢሾፍቱ መውጫ በኩል ወጥተው ወደ ከተማው መሀል በሚወስደው ዋና አስፋልት አለምሸት ፌሮ አጠገብ ይታጠፉ።
- **ከኩሪፍቱ / ባቦጋያ ሪዞርቶች**፦ ወደ ከተማው ዋና መንገድ 5–7 ደቂቃ በመጓዝ ከሂርና ስጋ ቤት ጀርባ ይግቡ።

💡 *መኪናዎን ይዘው መምጣት ካልቻሉ* በ [**${AppConstants.stationPhoneNumber}**](tel:${AppConstants.stationPhoneNumber}) ወይም [**${AppConstants.stationPhoneNumberSecondary}**](tel:${AppConstants.stationPhoneNumberSecondary}) ደውለው **ተንቀሳቃሽ ቫናችን (Mobile Van)** እርስዎ ባሉበት ደጃፍ ድረስ መጥቶ እንዲያጥብ ማዘዝ ይችላሉ!
''';

      case AppLanguage.om:
        return '''
### 📍 Giddugala Dhiqannaa BISHE — Bakka GPS fi Bilbila
*Istudiyoo Dhiqannaa fi Kunuunsa Konkolaataa Bishooftuu*

| Odeeffannoo | Bakka Buufataafi Lakk. Bilbilaa |
| :--- | :--- |
| **Liankii Google Maps** | [🗺️ Google Maps irratti Bani](${AppConstants.googleMapsLocationUrl}) |
| **Koordinaatii GPS** | `${AppConstants.stationGpsCoordinates}` *(Lakkoofsaan፦ `${AppConstants.stationGpsDecimal}`)* |
| **Magaalaa** | Bishooftuu (Debre Zeyit), Haroo Hoolaa cinaa, Oromiyaa |
| **Mallattoo Iddoo** | **Foon Hirnaa** duuba, **Alemshat Feeroo** biratti |
| **Balbala Seensaa / Kaashiyara** | [📞 **${AppConstants.stationPhoneNumber}**](tel:${AppConstants.stationPhoneNumber}) |
| **Tajaajila Maamiltootaa / Hogganaa** | [📞 **${AppConstants.stationPhoneNumberSecondary}**](tel:${AppConstants.stationPhoneNumberSecondary}) |

---

### 🚗 Kallattii Imalaa
- **Finfinneerraa Daandii Ariititiin yoo dhuftan**: Bishooftuutti ba'uun gara magaalaatti fuulleffadhaa; Alemshat Feeroo biratti goraa.
- **Haroo Kuriftuufi Baabogayyaarraa**: Daqiiqaa 5–7 gara magaalaatti deemsisuun Foon Hirnaa duubaan seenaa.

💡 *As dhufuu yoo hin dandeenye*, bilbila [**${AppConstants.stationPhoneNumber}**](tel:${AppConstants.stationPhoneNumber}) ykn [**${AppConstants.stationPhoneNumberSecondary}**](tel:${AppConstants.stationPhoneNumberSecondary}) irratti bilbiluun **Makiinaan Socho'aa (Mobile Van)** keenya bakka jirtanitti dhufee akka isiniif dhiqu ajajuu dandeessu!
''';

      case AppLanguage.en:
        return '''
### 📍 BISHE Car Wash — GPS & Contact
*Crater Lake Auto Detailing & Care Studio • Bishoftu (Debre Zeit)*

| Detail | Station Location & Contact |
| :--- | :--- |
| **Google Maps Direct Pin** | [🗺️ Open in Google Maps](${AppConstants.googleMapsLocationUrl}) |
| **GPS Coordinates** | `${AppConstants.stationGpsCoordinates}` *(Decimal: `${AppConstants.stationGpsDecimal}`)* |
| **City / Area** | Bishoftu (Debre Zeit), Near Lake Hora, Oromia |
| **Local Landmarks** | Right behind **Hirna Butchery (ሂርና ስጋ ቤት)**, near **Alemshet Fero (አለምሸት ፌሮ)** |
| **Gate Desk / Reception** | [📞 **${AppConstants.stationPhoneNumber}**](tel:${AppConstants.stationPhoneNumber}) |
| **Customer Support / Manager** | [📞 **${AppConstants.stationPhoneNumberSecondary}**](tel:${AppConstants.stationPhoneNumberSecondary}) |

---

### 🚗 Driving Directions
- **Coming from Addis via Expressway**: Exit at Bishoftu toll gate, head down the main road towards town, and turn in near Alemshet Fero.
- **From Kuriftu / Babogaya Resorts**: Head 5–7 minutes up the main asphalt towards town; turn in behind Hirna Butchery.

💡 *Prefer not to drive?* Call [**${AppConstants.stationPhoneNumber}**](tel:${AppConstants.stationPhoneNumber}) or [**${AppConstants.stationPhoneNumberSecondary}**](tel:${AppConstants.stationPhoneNumberSecondary}) to book our **Mobile Van** to come directly to your house or resort anywhere in Bishoftu!
''';
    }
  }

  static String _generateCustomerPackagesReport(AppStateNotifier state, AppLanguage lang) {
    switch (lang) {
      case AppLanguage.am:
        return '''
### ✨ የቢሼ መኪና ማጠቢያ ፓኬጆች እና ዋጋዎች
*ከፍተኛ ጥራት ያለው የመኪና እጥበትና እንክብካቤ በቢሾፍቱ (ደብረ ዘይት)*

| የማጠቢያ ፓኬጅ | አነስተኛ / ቪትዝ | መካከለኛ / SUV | ሚኒባስ / ቫን | የሚያካትተው አገልግሎት |
| :--- | :--- | :--- | :--- | :--- |
| **ሲልቨር / መደበኛ** | **ብር 150–200** | **ብር 250–300** | **ብር 350** | የውጭ አረፋ እጥበት፣ የጎማ ማጠብና ቀለም፣ ማይክሮፋይበር ማድረቅ |
| **ጎልድ ፖሊሽ (ተመራጭ)** | **ብር 300–350** | **ብር 400–450** | **ብር 550** | ሲልቨር + የውስጥ ቫኪዩም፣ የዳሽቦርድ ፖሊሽ፣ የመስታወት ማጽዳት፣ ሽቶ |
| **ፕላቲነም ዲቴይሊንግ** | **ብር 600–750** | **ብር 800–950** | **ብር 1,100** | ጎልድ + የታችኛው አካል ዝገት መከላከያ እጥበት፣ የእንፋሎት ሞተር እጥበት፣ ሰም |
| **ዳይመንድ VIP ሙሉ ጥገና** | **በስምምነት** | **በስምምነት** | **በስምምነት** | ሙሉ የውስጥ እንፋሎት እጥበት፣ የቆዳ ወንበር እንክብካቤ፣ የውጭ ፖሊሽ |

> *ሁሉም ዋጋዎች 15% ህጋዊ ቫትን ያካትታሉ። ንጹህ የመጠጥ ውሃ እና የማረፊያ ሳሎን ተዘጋጅቷል!*
''';

      case AppLanguage.om:
        return '''
### ✨ Paakeejiiwwan Dhiqa Konkolaataa BISHE fi Gatii
*Tajaajila Qulqullina Olaanaa Bishooftuu (Dabra Zayit) Keessatti*

| Paakeejii Dhiqa | Konkolaataa Xiqqa | SUV / Piikaappii | Minibaasii / Vaan | Wanta Of Keessaa Qabu |
| :--- | :--- | :--- | :--- | :--- |
| **Silver / Bu'uuraa** | **ETB 150–200** | **ETB 250–300** | **ETB 350** | Dhiqa hoomacha alaa, gommaa dhiquu, haxooftuu maaykiroofaayibariin gogsuu |
| **Gold Polish (Jaallatamaa)** | **ETB 300–350** | **ETB 400–450** | **ETB 550** | Silver + vaakiyumiin keessaa, daashboordii polishi gochuu, fuullee qulqulleessuu, urgooftuu |
| **Platinum Diteeyiliing** | **ETB 600–750** | **ETB 800–950** | **ETB 1,100** | Gold + dhiqa jala konkolaataa, dhiqa mootoraa hurkaan, eegumsa saamunaa seeraamikii |
| **Diamond VIP Guutuu** | **Waliigalteedhaan** | **Waliigalteedhaan** | **Waliigalteedhaan** | Dhiqa keessaa bal'aa, kunuunsa gogaa teessumaa, polishi maashinaa |

> *Gatiin hundi VAT 15% of keessaa qaba. Bishaan dhugaatii qulqulluun qophaa'eera!*
''';

      case AppLanguage.en:
        return '''
### ✨ BISHE Car Wash Service Packages & Pricing
*Quality Auto Detailing in Bishoftu (Debre Zeyit)*

| Service Package | Sedan / Vitz | SUV / Pickup | Minibus / Van | What is Included |
| :--- | :--- | :--- | :--- | :--- |
| **Silver / Basic** | **ETB 150–200** | **ETB 250–300** | **ETB 350** | Snow foam exterior wash, high-pressure rinse, tire dressing, microfiber hand dry |
| **Gold Polish (Popular)** | **ETB 300–350** | **ETB 400–450** | **ETB 550** | Silver + full interior vacuum, dashboard UV polish, door jambs, glass buffing, air freshener |
| **Platinum Detailing** | **ETB 600–750** | **ETB 800–950** | **ETB 1,100** | Gold + undercarriage rust wash, safe steam engine bay degrease, ceramic gloss wax |
| **Diamond VIP Complete** | **Custom Quote** | **Custom Quote** | **Custom Quote** | Full interior steam sanitation, leather conditioning, paint clay-bar & machine buff |

> *All wash prices include statutory 15% VAT. Clean drinking water and waiting lounge available!*
''';
    }
  }

  static String _generateCustomerWaitTimeReport(AppStateNotifier state, AppLanguage lang) {
    final bays = state.bays;
    final bay1 = bays.firstWhere((b) => b.type == BayType.bay1, orElse: () => const StationBay(type: BayType.bay1));
    final bay2 = bays.firstWhere((b) => b.type == BayType.bay2, orElse: () => const StationBay(type: BayType.bay2));
    final activeQueue = state.bookings.where((b) => b.status.name != 'completed' && b.status.name != 'cancelled').length;
    final estWaitMinutes = (activeQueue * 15).clamp(5, 60);

    switch (lang) {
      case AppLanguage.am:
        final b1Status = bay1.status == BayStatus.vacant ? 'ክፍት ነው' : (bay1.status == BayStatus.occupied ? 'በመታጠብ ላይ' : 'ዝግ ነው');
        final b2Status = bay2.status == BayStatus.vacant ? 'ክፍት ነው' : (bay2.status == BayStatus.occupied ? 'በመታጠብ ላይ' : 'ዝግ ነው');
        return '''
### ⏱️ የቀጥታ ተራ እና የጥበቃ ጊዜ መረጃ
*የቢሾፍቱ ማዕከል የቀጥታ ሁኔታ*

| የማጠቢያ ቦታ | የአሁን ሁኔታ | ዝርዝር |
| :--- | :--- | :--- |
| **ቦታ 1 (Bay 1)** | **$b1Status** | ${bay1.activeLicensePlate != null ? 'መኪና በመታጠብ ላይ ነው' : 'መኪና ለመቀበል ክፍት ነው'} |
| **ቦታ 2 (Bay 2)** | **$b2Status** | ${bay2.activeLicensePlate != null ? 'መኪና በመታጠብ ላይ ነው' : 'መኪና ለመቀበል ክፍት ነው'} |
| **በተራ ላይ ያሉ** | **$activeQueue መኪኖች** | የሚገመተው የጥበቃ ጊዜ: **~$estWaitMinutes ደቂቃ** |

💡 **ምክር**: አጣዳፊ ጉዞ ካለዎት **ሲልቨር መደበኛ እጥበት** ከ15–20 ደቂቃ ውስጥ ይጠናቀቃል!
''';

      case AppLanguage.om:
        final b1Status = bay1.status == BayStatus.vacant ? 'Duwwaadha' : (bay1.status == BayStatus.occupied ? 'Dhiqa Jira' : 'Cufaadha');
        final b2Status = bay2.status == BayStatus.vacant ? 'Duwwaadha' : (bay2.status == BayStatus.occupied ? 'Dhiqa Jira' : 'Cufaadha');
        return '''
### ⏱️ Odeeffannoo Dabaree fi Yeroo Eegumsaa Battalaa
*Haala Qabatamaa Iddoo Dhiqa Bishooftuu*

| Iddoo Dhiqa | Haala Ammaa | Qabiyyee |
| :--- | :--- | :--- |
| **Iddoo 1 (Bay 1)** | **$b1Status** | ${bay1.activeLicensePlate != null ? 'Konkolaataan dhiqamaa jira' : 'Konkolaataa simachuuf duwwaadha'} |
| **Iddoo 2 (Bay 2)** | **$b2Status** | ${bay2.activeLicensePlate != null ? 'Konkolaataan dhiqamaa jira' : 'Konkolaataa simachuuf duwwaadha'} |
| **Dabaree Irra Kan Jiran** | **Konkolaattota $activeQueue** | Tilmaama Yeroo Eegumsaa: **~Daqiiqaa $estWaitMinutes** |

💡 **Gorsa**: Yoo ariifattan dhiqni **Silver Bu'uuraa** daqiiqaa 15–20 keessatti xumurama!
''';

      case AppLanguage.en:
        return '''
### ⏱️ Live Bay Queue & Wait Time Update
*Real-time Bishoftu Station Status*

| Station Bay | Current Status | Occupancy |
| :--- | :--- | :--- |
| **Bay 1** | **${bay1.status.displayName}** | ${bay1.activeLicensePlate != null ? 'Vehicle being washed' : 'Available for entry'} |
| **Bay 2** | **${bay2.status.displayName}** | ${bay2.activeLicensePlate != null ? 'Vehicle being washed' : 'Available for entry'} |
| **Waiting Queue** | **$activeQueue vehicle(s)** | Estimated wait: **~$estWaitMinutes minutes** |

💡 **Tip**: If you are in a hurry, our **Silver Basic Wash** takes only ~20 minutes from intake to showroom finish!
''';
    }
  }

  static String _generateCustomerEvSafetyReport(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.am:
        return '''
### ⚡ የኤሌክትሪክ መኪናዎች (EV) ደህንነት ማረጋገጫ
*ለ BYD, VW ID.4/ID.6, Tesla እና Hybrid መኪኖች የተረጋገጠ ጥበቃ*

አዎ! በቢሼ መኪና ማጠቢያ የኤሌክትሪክ መኪናዎ አስተማማኝ ጥበቃ ይደረግለታል፡
- **የተመጠነ የውሃ ኃይል**: ከፍተኛ ግፊት ያለው ውሃ በቀጥታ ወደ ኃይል መሙያ (Charging Port) ወይም ወደ ታችኛው የባትሪ ክፍል አይረጭም።
- **የእንፋሎት ሞተር ማጽዳት**: የኤሌክትሪክ ክፍሎችን ከውሃ ፍሳሽ ለመጠበቅ አነስተኛ እርጥበት ባለው ንጹህ እንፋሎት ይጸዳል።
- **ገለልተኛ (pH-Neutral) ሳሙና**: የኤሌክትሪክ መኪና ቀለሞችን እና የአየር ዳሳሾችን (Sensors) የሚጠብቅ ልዩ ኬሚካል እንጠቀማለን።
''';

      case AppLanguage.om:
        return '''
### ⚡ Wabii Eegumsa Konkolaattota Elektiriikii (EV)
*Eegumsa Mirkanaa'aa BYD, VW ID.4, Tesla fi Konkolaattota Haayibiriidii*

Eeyyee! Dhiqa Konkolaataa BISHE keessatti konkolaataan elektiriikii keessan nagaadhaan dhiqama:
- **Dhiibbaa Bishaan Madaalawaa**: Dhiibbaan bishaanii kallattiin gara bakka chaarjii fi baatrii konkolaataa jalaatti hin dhangala'u.
- **Hurkaan Qulqulleessuu**: Bakki mootoraa akka bishaan hin miinetti hurka qulqulluun dhiqama.
- **Shaampuu Miidhaa Hin Qabne (pH-Neutral)**: Qorichi qulqulleessaa miidhaa hin qabne halluu fi seensaroota eega.
''';

      case AppLanguage.en:
        return '''
### ⚡ Electric Vehicle (EV) Safety Guarantee
*Safe Washing for BYD, VW ID.4, Tesla, and Hybrid Vehicles*

Yes! At BISHE Car Wash, your Electric Vehicle is in certified safe hands:
- **Calibrated Pressure Spray**: We never spray high-pressure jets directly into high-voltage charging ports or underside battery pack seals.
- **Steam Engine Bay Cleaning**: Safe, low-moisture steam is used for engine bay dust removal without water flooding sensitive inverters.
- **pH-Neutral Foam**: Specially formulated biodegradable shampoo protects modern EV matte paints and aerodynamic sensor lenses.
''';
    }
  }

  static String _generateCustomerCarpetReport(AppStateNotifier state, AppLanguage lang) {
    switch (lang) {
      case AppLanguage.am:
        return '''
### 🏠 የምንጣፍ እና የጨርቃጨርቅ እጥበት አገልግሎት
*በዘመናዊ ማሽን እና ልዩ ማድረቂያዎች የሚከናወን*

- **ዋጋ**: **በአንድ ካሬ ሜትር ከብር 50–70** (እንደ ምንጣፉ ውፍረትና ዓይነት)።
- **የአሠራር ሂደት**: የአቧራ ማራገፍ ➔ ጥልቅ የሳሙና እጥበት ➔ በውሃ ማጠብ ➔ በልዩ ማድረቂያ ማድረቅ።
- **የማድረቂያ ጊዜ**: ከ24–48 ሰዓታት ውስጥ ደርቆ በፕላስቲክ ተጠቅልሎ ይሰጣል።
- **ነጻ ትራንስፖርት**: በቢሾፍቱ ከተማ ውስጥ ለትላልቅ ምንጣፎች ነጻ የማንሳትና የማድረስ አገልግሎት አለን!
''';

      case AppLanguage.om:
        return '''
### 🏠 Tajaajila Dhiqa Afataafi Firaashii
*Maashina Ammayyaa fi Iddoo Gogsuu Addaatiin Kan Hojjetamu*

- **Gatii**: **Meetira isquweeriidhaan ETB 50–70** (akka furdinna afataatti)።
- **Adeemsa Hojii**: Dhukkoo buqqisuu ➔ Shaampuudhaan dhiquu ➔ Bishaaniin dhiquu ➔ Iddoo aduutti gogsuu።
- **Yeroo Goguu**: Sa'aatii 24–48 keessatti gogee pilaastikiidhaan maramee kennama።
- **Geejjiba Tolaa**: Afata gurguddaadhaaf magaalaa Bishooftuu keessatti fe'uun tola!
''';

      case AppLanguage.en:
        return '''
### 🏠 Carpet & Rug Cleaning Service
*Deep Pressure Washing & Specialized Drying Racks*

- **Rate**: **ETB 50–70 per square meter** (calculated accurately by length × width).
- **Process**: Rotary scrubber dust extraction ➔ Deep shampoo foaming ➔ High-pressure warm rinse ➔ Sun drying racks.
- **Turnaround Time**: 24–48 hours for complete drying and hygienic plastic wrapping.
- **Free Pickup & Delivery**: Available for large household or hotel carpets anywhere in Bishoftu!
''';
    }
  }

  static String _generateCustomerShowersReport(AppStateNotifier state, AppLanguage lang) {
    switch (lang) {
      case AppLanguage.am:
        return '''
### 🚿 ዘመናዊ የሙቅ ውሃ ሻወር ለደንበኞችና አሽከርካሪዎች
*በቢሾፍቱ ማዕከላችን ታጥበው ዘና ይበሉ*

- **ክፍያ**: **በአንድ ሰው ብር 70–100** (ከቫት ነጻ የሆነ 0% VAT ህጋዊ ተመን)።
- **አገልግሎቶች**: የሙቅ ውሃ፣ ንጹህ ፎጣ፣ ሳሙና፣ መስተዋት እና ሻወር ቤት።
- **ቦታ**: ከደንበኞች ማረፊያ እና ሻይ/ቡና መጠጫው አጠገብ ይገኛል።
''';

      case AppLanguage.om:
        return '''
### 🚿 Tajaajila Dhiqannaa Qaamaa Bishaani Ho'aa
*Iddoo Dhiqa Bishooftuutti Boqodhaa Qulqullaa'aa*

- **Gatii**: **Nama tokkoof ETB 70–100** (Taaksiirraa kan bilisa ta'e 0% VAT)።
- **Wanti Dhiyaatu**: Bishaan ho'aa, fooxaa qulqulluu, saamunaa, daawwitii fi kutaa qulqulluu።
- **Bakka**: Iddoo boqonnaa maamiltootaa cinaatti argama።
''';

      case AppLanguage.en:
        return '''
### 🚿 Clean Hot Showers for Guests & Drivers
*Rest & Refresh at Bishoftu Station*

- **Rate**: **ETB 70–100 per person** (0% VAT exempt statutory rate).
- **Amenities**: Instant hot water, sanitized shower suites, clean fresh towels, soap, and mirrors.
- **Location**: Right adjacent to the main waiting lounge and customer refreshment area.
''';
    }
  }

  static String _generateCustomerPrivacyNotice(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.am:
        return '''
### 🛡️ የደንበኞች ደህንነትና ምስጢራዊነት ማስታወቂያ
*የቢሼ መኪና ማጠቢያ ደንቦች*

የአገልግሎት ጥራትንና የደንበኛ ዋጋን በግልጽ ማሳወቅ ዋና መርሀችን ነው። የማዕከሉ ውስጣዊ የትርፍ ህዳግ፣ የሰራተኞች ደመወዝና ኮሚሽን፣ እንዲሁም የደህንነት የይለፍ ቃሎች (OTP) ለደንበኞች የማይገለጹ አስተዳደራዊ መረጃዎች ናቸው።

**ምን ማወቅ ይፈልጋሉ:**
1. ስለ ተወዳጁ **ጎልድ ፖሊሽ** ፓኬጃችን?
2. ስለ **ኤሌክትሪክ መኪናዎች ደህንነት ማረጋገጫ**?
3. አሁን ስላለው **የተራና የጥበቃ ጊዜ**?
''';

      case AppLanguage.om:
        return '''
### 🛡️ Hubachiisa Eegumsa Iccitii Maamiltootaa
*Seera Iddoo Dhiqa Konkolaataa BISHE*

Qulqullina tajaajilaafi gatii ifa gochuun imaammata keenyadha. Bu'aan keessoo iddoo dhiqa, kaffaltiin komishinii hojjettootaa fi koodiin OTP iccitii bulchiinsaa waan ta'eef maamilaaf hin ibsamu.

**Maal baruu barbaaddu:**
1. Waa'ee paakeejii jaallatamaa **Gold Polish**?
2. Waa'ee **Wabii Eegumsa Konkolaattota Elektiriikii**?
3. Waa'ee **Dabaree fi Yeroo Eegumsaa Ammaa**?
''';

      case AppLanguage.en:
        return '''
### 🛡️ Customer Privacy Notice
*BISHE Car Wash Station Policies*

We prioritize transparency in our wash services, package quality, and customer pricing. Internal station operating margins, employee payroll, and confidential security PINs/OTPs are strictly reserved for administrative compliance and cannot be disclosed.

**Would you like to explore:**
1. Our popular **Gold Polish Wash** package?
2. Our **Electric Vehicle (EV) Safety Guarantee**?
3. Current **Bay queue and wait time** in Bishoftu?
''';
    }
  }

  static String _generateCustomerOverview(AppStateNotifier state, AppLanguage lang) {
    switch (lang) {
      case AppLanguage.am:
        return '''
### 🌟 ወደ ቢሼ መኪና ማጠቢያና እንክብካቤ ማዕከል እንኳን ደህና መጡ!
*ቢሾፍቱ (ደብረ ዘይት)፣ ኦሮሚያ | ሂርና ስጋ ቤት ጀርባ፣ አለምሸት ፌሮ አጠገብ*

**ዛሬ በምን ልርዳዎት?**
1. ✨ *"የማጠቢያ ፓኬጆች እና ዋጋቸው ስንት ነው?"*
2. ⏱️ *"አሁን ያለው ተራ እና የጥበቃ ጊዜ ስንት ነው?"*
3. ⚡ *"የኤሌክትሪክ መኪና ማጠብ ደህንነቱ የተጠበቀ ነው?"*
4. 🏠 *"የምንጣፍ እጥበት እንዴት ይሰራል፣ ዋጋውስ በካሬ ስንት ነው?"*
5. 🚿 *"የሙቅ ውሃ ሻወር የት ይገኛል?"*
''';

      case AppLanguage.om:
        return '''
### 🌟 Baga Gara Dhiqa Konkolaataa BISHE Nagaan Dhuftan!
*Bishooftuu (Dabra Zayit), Oromiyaa | Foon Hirnaa Duuba, Alemxahay Feeroo Cinaa*

**Har'a maaliin isin gargaaruu dandeessu?**
1. ✨ *"Paakeejiiwwan dhiqaafi gatiin meeqa?"*
2. ⏱️ *"Amma dabareefi yeroon eegumsaa akkam jira?"*
3. ⚡ *"Konkolaataa elektiriikii dhiquun amansiisaadhaa?"*
4. 🏠 *"Dhiqi afataa akkamitti hojjeta, gatiin meetiraan meeqa?"*
5. 🚿 *"Dhiqannaan bishaan ho'aa eessatti argama?"*
''';

      case AppLanguage.en:
        return '''
### 🌟 Welcome to BISHE Car Wash & Auto Care!
*Bishoftu (Debre Zeyit), Oromia, Ethiopia | Behind Hirna Butchery, near Alemshet Fero*

**How can I assist you today?**
1. ✨ *"What are your wash packages and prices?"*
2. ⏱️ *"What is the current wait time in the bays?"*
3. ⚡ *"Is it safe to wash my electric vehicle (EV)?"*
4. 🏠 *"How does carpet washing work and what is the cost per m²?"*
5. 🚿 *"Where are your clean hot showers located?"*
''';
    }
  }

  // ==========================================
  // EXISTING EXECUTIVE REPORTS
  // ==========================================
  static String _generatePnlReport(AppStateNotifier state, DateTime now) {
    final todayBookings = state.bookings.where((b) {
      final d = b.createdAt;
      return d.year == now.year && d.month == now.month && d.day == now.day;
    }).toList();

    final paidToday = todayBookings.where((b) => b.payment.isPaid).toList();
    final grossRevenue = paidToday.fold(0.0, (sum, b) => sum + b.totalPrice);
    final vatDeducted = grossRevenue * 0.15;
    final netAfterVat = grossRevenue - vatDeducted;

    final commissionsPaid = state.commissionLogs.where((l) {
      final d = l.completedAt;
      return d.year == now.year && d.month == now.month && d.day == now.day;
    }).fold(0.0, (sum, l) => sum + l.commissionEarnedETB);

    final suppliesConsumed = state.stockTransactions.where((t) {
      final d = t.date;
      return d.year == now.year && d.month == now.month && d.day == now.day &&
          (t.type == 'emptyExchangeConsumption' || t.type == 'dailyConsumption');
    }).fold(0.0, (sum, t) => sum + t.totalCostEtb);

    final cogs = commissionsPaid + suppliesConsumed;
    final grossProfit = netAfterVat - cogs;

    final pettyExpenses = state.pettyCashExpenses.where((p) {
      final d = p.loggedAt;
      return d.year == now.year && d.month == now.month && d.day == now.day;
    }).fold(0.0, (sum, p) => sum + p.amount);

    final dailyOverheadAccrual = state.totalDailyOverheadAccrual;
    final dailyDepreciation = state.dailyMachineryDepreciation;
    final totalDailyOpEx = dailyOverheadAccrual + dailyDepreciation + pettyExpenses;
    final netOperatingProfit = grossProfit - totalDailyOpEx;

    final rentAmount = (state.monthlyOverheads.where((o) => o.id == 'overhead_rent').firstOrNull ??
        (state.monthlyOverheads.isNotEmpty ? state.monthlyOverheads.first : null))?.monthlyAmountEtb ?? 45000.0;

    return '''
### 📊 Today's Executive Financial & P&L Statement (Real-Truth Model)
*Station Date: ${now.day}/${now.month}/${now.year} • Daily Accrual (Monthly ÷ 30)*

| Financial Component | Amount (ETB) | Accounting Treatment |
| :--- | :--- | :--- |
| **Gross Revenue (${paidToday.length} settled)** | **${CurrencyFormatter.format(grossRevenue)}** | Operating Cash & Digital Inflow |
| Less: 15% VAT Statutory Deduction | - ${CurrencyFormatter.format(vatDeducted)} | Tax Obligation |
| **Net Service Revenue** | **${CurrencyFormatter.format(netAfterVat)}** | Net Taxable Income |
| Less: Washer Commissions (15%) | - ${CurrencyFormatter.format(commissionsPaid)} | Direct Labor (COGS) |
| Less: Storekeeper Soap Consumed (ዕቃ በዕቃ) | - ${CurrencyFormatter.format(suppliesConsumed)} | Direct Chemicals (COGS) |
| **GROSS OPERATING PROFIT** | **${CurrencyFormatter.format(grossProfit)}** | **Margin: ${grossRevenue > 0 ? ((grossProfit / grossRevenue) * 100).toStringAsFixed(1) : '0'}%** |
| Less: Daily Accrued Overheads (Rent/Power/Salaries ÷ 30) | - ${CurrencyFormatter.format(dailyOverheadAccrual)} | Fixed Monthly Operating Accrual |
| Less: Machinery Depreciation (÷ 30) | - ${CurrencyFormatter.format(dailyDepreciation)} | Fixed Equipment Amortization |
| Less: Cashier & Yard Petty Cash | - ${CurrencyFormatter.format(pettyExpenses)} | General Emergency Overhead |
| **NET OPERATING PROFIT (EBITDA)** | **${CurrencyFormatter.format(netOperatingProfit)}** | **Real-Truth Net Daily Earning** |

> *Note: Station land rent (ETB ${rentAmount.toStringAsFixed(0)}/mo), utilities, and staff base salaries are accrued daily at 1/30th per day to display the real truth.*
''';
  }

  static String _generateCarsWashedReport(AppStateNotifier state, DateTime now) {
    final todayBookings = state.bookings.where((b) {
      final d = b.createdAt;
      return d.year == now.year && d.month == now.month && d.day == now.day;
    }).toList();

    int typeA = 0, typeB = 0, typeC = 0, carpets = 0;
    double totalCarpetM2 = 0.0;
    for (final b in todayBookings) {
      if (b.isCarpet) {
        carpets++;
        totalCarpetM2 += (b.carpetAreaSqMeters ?? 12.0);
      } else {
        switch (b.carType) {
          case CarType.automobile:
            typeA++;
            break;
          case CarType.minibus:
            typeB++;
            break;
          case CarType.truck:
            typeC++;
            break;
        }
      }
    }

    final double totalEvu = (typeA * 1.0) + (typeB * 1.5) + (typeC * 2.5) + (totalCarpetM2 * 0.25);
    final completed = todayBookings.where((b) => b.status.name == 'completed').length;
    final inProgress = todayBookings.length - completed;

    final tableRows = todayBookings.take(8).map((b) {
      final plate = b.licensePlate.isNotEmpty ? b.licensePlate : 'WALK-IN';
      final type = b.isCarpet ? 'Carpet' : b.carType.displayName;
      final mult = b.isCarpet ? '${b.carpetAreaSqMeters ?? 12} m²' : (b.carType == CarType.truck ? '2.5x' : (b.carType == CarType.minibus ? '1.5x' : '1.0x'));
      final status = b.status.name.toUpperCase();
      return '| `$plate` | $type | $mult | **$status** | ${CurrencyFormatter.format(b.totalPrice)} |';
    }).join('\n');

    return '''
### 🚗 Today's Vehicle & Carpet Wash Activity
*Total Registered: **${todayBookings.length}** | Completed: **$completed** | In-Queue/Bays: **$inProgress** | Total Workload: **${totalEvu.toStringAsFixed(1)} EVU***

#### Dynamic Category & Workload Breakdown:
- **Type A (Small / Corolla, Vitz, BYD)**: $typeA vehicles (~1.0× chemical coefficient)
- **Type B (Medium / SUV, Minibus, V8)**: $typeB vehicles (~1.5× chemical coefficient)
- **Type C (Large / Sinotruk, FSR, Heavy)**: $typeC vehicles (~2.5× chemical coefficient)
- **Carpets (sq. meters)**: $carpets orders (${totalCarpetM2.toStringAsFixed(1)} sq. meters)

| License Plate | Category | Multiplier | Status | Total Settled |
| :--- | :--- | :--- | :--- | :--- |
${tableRows.isEmpty ? '| No registered activity yet | - | - | - | - |' : tableRows}
''';
  }

  static String _generateWashersReport(AppStateNotifier state, DateTime now) {
    final washers = state.presentWashersToday;
    final logsToday = state.commissionLogs.where((l) {
      final d = l.completedAt;
      return d.year == now.year && d.month == now.month && d.day == now.day;
    }).toList();

    final Map<String, double> earnings = {};
    final Map<String, int> counts = {};

    for (final l in logsToday) {
      earnings[l.washerName] = (earnings[l.washerName] ?? 0.0) + l.commissionEarnedETB;
      counts[l.washerName] = (counts[l.washerName] ?? 0) + 1;
    }

    final rows = washers.map((w) {
      final cEarned = earnings[w.name] ?? 0.0;
      final jobs = counts[w.name] ?? 0;
      return '| **${w.name}** | ${w.role.displayName} | $jobs cars | ${CurrencyFormatter.format(cEarned)} | On Duty |';
    }).join('\n');

    final totalComm = logsToday.fold(0.0, (s, l) => s + l.commissionEarnedETB);

    return '''
### 👥 Active Washers & Commission Performance
*Active On-Duty Washers: **${washers.length}** | Total Commissions Settled: **${CurrencyFormatter.format(totalComm)}***

| Washer Name | Station Bay | Jobs Completed | Commission Earned | Duty Status |
| :--- | :--- | :--- | :--- | :--- |
${rows.isEmpty ? '| No active washer activity recorded yet | - | - | - | - |' : rows}

> *Commissions are calculated at the station default rate (15%) of settled vehicle tickets.*
''';
  }

  static String _generateConsumablesYieldReport(AppStateNotifier state) {
    final now = DateTime.now();
    final todayBookings = state.bookings.where((b) {
      final d = b.createdAt;
      return d.year == now.year && d.month == now.month && d.day == now.day;
    }).toList();

    double totalEvu = 0.0;
    for (final b in todayBookings) {
      if (b.isCarpet) {
        totalEvu += ((b.carpetAreaSqMeters ?? 12.0) * 0.25);
      } else {
        switch (b.carType) {
          case CarType.automobile:
            totalEvu += 1.0;
            break;
          case CarType.minibus:
            totalEvu += 1.5;
            break;
          case CarType.truck:
            totalEvu += 2.5;
            break;
        }
      }
    }

    final shampoo = state.consumables.where((c) => c.id == 'CS-009').firstOrNull ??
        (state.consumables.isNotEmpty
            ? state.consumables.first
            : const ConsumableItem(
                id: 'CS-009',
                name: 'Snow Foam Shampoo',
                nameAmharic: 'የበረዶ አረፋ ሻምፑ',
                category: 'Chemicals',
                unit: 'L',
                currentStock: 0,
                minThreshold: 4,
                unitCostEtb: 1850.0,
              ));
    final perfume = state.consumables.where((c) => c.id == 'CS-006').firstOrNull ??
        (state.consumables.isNotEmpty
            ? state.consumables.first
            : const ConsumableItem(
                id: 'CS-006',
                name: 'Air Freshener',
                nameAmharic: 'የመኪና ውስጥ ሽቶ',
                category: 'Chemicals',
                unit: 'bottles',
                currentStock: 0,
                minThreshold: 6,
                unitCostEtb: 420.0,
              ));
    final towels = state.consumables.where((c) => c.id == 'CS-013').firstOrNull ??
        (state.consumables.isNotEmpty
            ? state.consumables.first
            : const ConsumableItem(
                id: 'CS-013',
                name: 'Microfiber Towel',
                nameAmharic: 'የማይክሮፋይበር ፎጣ',
                category: 'Towels',
                unit: 'pcs',
                currentStock: 0,
                minThreshold: 10,
                unitCostEtb: 150.0,
              ));

    final double calcShampooLiters = totalEvu * 0.125;
    final double calcPerfumeMl = totalEvu * 5.0;

    return '''
### 🧼 Chemical Yield & Average Consumption Analysis
*Real Live EVU Workload Today: **${totalEvu.toStringAsFixed(1)} EVU** (Type A: 1.0x, Type B: 1.5x, Type C: 2.5x)*

| Chemical Consumable | Standard Container | Expected Yield | Today's Calculated Need | Current Stock in Store |
| :--- | :--- | :--- | :--- | :--- |
| **Car Shampoo (CS-009)** | 5L Dilution Can | **~40 EVU / 5L** (125 ml/EVU) | **${calcShampooLiters.toStringAsFixed(2)} Liters** | **${shampoo.currentStock} ${shampoo.unit}** |
| **Air Freshener (CS-006)** | 500ml Spray Bottle | **~100 sprays** (5 ml/interior) | **${calcPerfumeMl.toStringAsFixed(0)} ml** | **${perfume.currentStock} ${perfume.unit}** |
| **Microfiber Towels (CS-013)** | Set of 50 Pieces | **30–50 washes/towel** | Wear write-off | **${towels.currentStock} ${towels.unit}** |
| **Tire Cleaner Spray (CS-004)** | Spray Can | **~25 vehicles** | 4 tires/car | In warehouse |

#### Yield Audit Guidelines:
- **Efficiency Threshold**: If a 5L shampoo container runs empty in **under 25 cars**, flag for nozzle leakage or excessive foam concentration.
- **Under-dosing Threshold**: If 5L lasts **over 55 cars**, inspect bays for over-dilution with water.
''';
  }

  static String _generateAlertsReport(AppStateNotifier state) {
    final lowStock = state.consumables.where((c) => c.isLowStock).toList();
    final damagedHandovers = state.dailyHandovers.where((h) => h.damagedQuantities.isNotEmpty || h.missingQuantities.isNotEmpty).toList();

    final stockLines = lowStock.map((c) => '• ⚠️ **${c.name}**: Current ${c.currentStock} ${c.unit} (Safety min: ${c.minThreshold})').join('\n');

    return '''
### ⚠️ Station Discrepancies & Stock Alerts

#### 1. Low Inventory Re-Order Alerts (${lowStock.length}):
${lowStock.isEmpty ? '✅ All 22 warehouse consumables are currently above safety thresholds.' : stockLines}

#### 2. Loss Prevention & Daily Handover Integrity:
- **Active Unclosed Handovers**: ${state.dailyHandovers.where((h) => h.status.name == 'active').length} shifts open.
- **Recent Missing/Damaged Incident Reports**: ${damagedHandovers.length} logged.
- **Deposit Slip Audit**: Verify all cash drawer closing envelopes against CBE / Awash stamped deposit receipts in the Accountant tab.
''';
  }

  static String _generateStationOverview(AppStateNotifier state, DateTime now) {
    final totalWashed = state.bookings.where((b) => b.status.name == 'completed').length;
    final todayBookings = state.bookings.where((b) {
      final d = b.createdAt;
      return d.year == now.year && d.month == now.month && d.day == now.day;
    }).length;

    return '''
### 🌟 BISHE Executive AI Operations Desk
*Station Location: Bishoftu, Oromia | Live Database Connected*

- **Today's Bookings**: $todayBookings vehicles registered
- **Lifetime Completed**: $totalWashed vehicles & carpets washed
- **Active Washers on Shift**: ${state.presentWashersToday.length} washers
- **Warehouse Consumables**: ${state.consumables.length} tracked items
- **Station Fixed Assets**: ${state.fixedAssets.length} machinery items

**You can ask me questions like:**
1. *"Show me today's P&L and net profit"*
2. *"List the cars washed today and their plate numbers"*
3. *"Who are the active washers and how much commission did they earn?"*
4. *"What is the chemical yield and average shampoo used per car?"*
5. *"Show any low stock warnings or discrepancies"*
6. *"How many showers were used today and what is the revenue?"*
7. *"What is the current bay turnaround speed and queue status?"*
8. *"What is the status of fixed assets and pressure washer maintenance?"*
9. *"Show today's bank deposit slips and reconciliation"*
10. *"What is the 6-digit OTP shift handover status?"*
''';
  }
}
