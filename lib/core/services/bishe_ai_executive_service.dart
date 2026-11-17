import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../features/auth_roles/domain/models/user_role.dart';
import '../../features/booking_service/domain/models/bay_station.dart';
import '../../features/booking_service/domain/models/car_type.dart';
import '../../features/booking_service/presentation/state/app_state_notifier.dart';
import '../../features/inventory/domain/models/fixed_asset.dart';
import '../localization/app_strings.dart';
import '../utils/currency_formatter.dart';

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
        contents.add({
          'role': 'model',
          'parts': [
            {
              'text': isCustomer
                  ? 'Greetings! I am the BISHE AI Concierge. I will guide you warmly through our wash packages, prices, EV safety, carpet services, and wait times in Bishoftu.'
                  : 'Understood. I am BisheAI, Chief Operations Executive for BISHE Car Wash. Grounded in the operations manual, equipment health, bank slips, showers, and live bay records, I will answer accurately with tables and calculations where appropriate.'
            }
          ],
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

        final payload = jsonEncode({
          'contents': contents,
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
        ? _localCustomerConciergeAnalytics(userQuestion, state, currentLang)
        : _localStationAnalytics(userQuestion, state, currentLang, callerRole);

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

INSTRUCTIONS:
- Answer with executive clarity, specific numbers, and deep station context.
- Format structured data, lists, and comparative statements as clean Markdown tables.
- Tailor the response to the caller's role (${callerRole.displayName}).
- Respond in the user's language (Amharic, Afaan Oromoo, or English).
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
You are "BisheAI Concierge", the friendly, hospitable, and knowledgeable customer service assistant for "BISHE Car Wash & Auto Care Service" located in Bishoftu (Debre Zeyit), Oromia, Ethiopia.
Location: Bishoftu, behind Hirna Butchery, near Alemshet Fero.
Hotline: +251 911 000 000 | Open 7 Days a week: 07:00 AM - 10:00 PM.

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

STRICT PRIVACY GUARDRAILS (NON-NEGOTIABLE):
- NEVER disclose staff salaries, washer commission percentages, station net profits, internal EBITDA, wholesale chemical costs, or internal 6-digit OTP codes.
- If a customer asks about internal profits, commission cuts, or security OTPs, politely decline and redirect them to our service quality and packages.

TONE & STYLE:
- Warm, polite, professional, and welcoming.
- Use clear bullet points and markdown tables for package comparisons or pricing questions.
- Respond in the language used by the customer (English, Afaan Oromoo, or Amharic).
''';
  }

  /// Built-in local station analytics engine for instant, zero-bandwidth executive answers
  static String _localStationAnalytics(
    String rawQuery,
    AppStateNotifier state,
    AppLanguage lang,
    UserRole callerRole,
  ) {
    final query = rawQuery.toLowerCase().trim();
    final now = DateTime.now();

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

  /// Built-in local customer concierge answers (zero network egress)
  static String _localCustomerConciergeAnalytics(
    String rawQuery,
    AppStateNotifier state,
    AppLanguage lang,
  ) {
    final query = rawQuery.toLowerCase().trim();

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
        query.contains('gatii') ||
        query.contains('paakeejii')) {
      return _generateCustomerPackagesReport(state);
    }

    if (query.contains('wait') ||
        query.contains('queue') ||
        query.contains('time') ||
        query.contains('busy') ||
        query.contains('bay') ||
        query.contains('ተራ') ||
        query.contains('ጊዜ') ||
        query.contains('dabaree') ||
        query.contains('yeroo')) {
      return _generateCustomerWaitTimeReport(state);
    }

    if (query.contains('ev') ||
        query.contains('electric') ||
        query.contains('safe') ||
        query.contains('pressure') ||
        query.contains('ባትሪ') ||
        query.contains('ኤሌክትሪክ') ||
        query.contains('ደህንነት') ||
        query.contains('elektiriikii')) {
      return _generateCustomerEvSafetyReport();
    }

    if (query.contains('carpet') ||
        query.contains('rug') ||
        query.contains('ምንጣፍ') ||
        query.contains('afata')) {
      return _generateCustomerCarpetReport(state);
    }

    if (query.contains('shower') ||
        query.contains('bath') ||
        query.contains('hot water') ||
        query.contains('ሻወር') ||
        query.contains('dhiqannaa')) {
      return _generateCustomerShowersReport(state);
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
        query.contains('ደመወዝ')) {
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

    return _generateCustomerOverview(state);
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
    final shampoo = state.consumables.firstWhere((c) => c.id == 'CS-009', orElse: () => state.consumables.first);
    final perfume = state.consumables.firstWhere((c) => c.id == 'CS-006', orElse: () => state.consumables.first);

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
  static String _generateCustomerPackagesReport(AppStateNotifier state) {
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

  static String _generateCustomerWaitTimeReport(AppStateNotifier state) {
    final bays = state.bays;
    final bay1 = bays.firstWhere((b) => b.type == BayType.bay1, orElse: () => const StationBay(type: BayType.bay1));
    final bay2 = bays.firstWhere((b) => b.type == BayType.bay2, orElse: () => const StationBay(type: BayType.bay2));
    final activeQueue = state.bookings.where((b) => b.status.name != 'completed' && b.status.name != 'cancelled').length;
    final estWaitMinutes = (activeQueue * 15).clamp(5, 60);

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

  static String _generateCustomerEvSafetyReport() {
    return '''
### ⚡ Electric Vehicle (EV) Safety Guarantee
*Safe Washing for BYD, VW ID.4, Tesla, and Hybrid Vehicles*

Yes! At BISHE Car Wash, your Electric Vehicle is in certified safe hands:
- **Calibrated Pressure Spray**: We never spray high-pressure jets directly into high-voltage charging ports or underside battery pack seals.
- **Steam Engine Bay Cleaning**: Safe, low-moisture steam is used for engine bay dust removal without water flooding sensitive inverters.
- **pH-Neutral Foam**: Specially formulated biodegradable shampoo protects modern EV matte paints and aerodynamic sensor lenses.
''';
  }

  static String _generateCustomerCarpetReport(AppStateNotifier state) {
    return '''
### 🏠 Carpet & Rug Cleaning Service
*Deep Pressure Washing & Specialized Drying Racks*

- **Rate**: **ETB 50–70 per square meter** (calculated accurately by length × width).
- **Process**: Rotary scrubber dust extraction ➔ Deep shampoo foaming ➔ High-pressure warm rinse ➔ Sun drying racks.
- **Turnaround Time**: 24–48 hours for complete drying and hygienic plastic wrapping.
- **Free Pickup & Delivery**: Available for large household or hotel carpets anywhere in Bishoftu!
''';
  }

  static String _generateCustomerShowersReport(AppStateNotifier state) {
    return '''
### 🚿 Clean Hot Showers for Guests & Drivers
*Rest & Refresh at Bishoftu Station*

- **Rate**: **ETB 70–100 per person** (0% VAT exempt statutory rate).
- **Amenities**: Instant hot water, sanitized shower suites, clean fresh towels, soap, and mirrors.
- **Location**: Right adjacent to the main waiting lounge and customer refreshment area.
''';
  }

  static String _generateCustomerOverview(AppStateNotifier state) {
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

    final netOperatingProfit = grossProfit - pettyExpenses;

    return '''
### 📊 Today's Executive Financial & P&L Statement
*Station Date: ${now.day}/${now.month}/${now.year}*

| Financial Component | Amount (ETB) | Accounting Treatment |
| :--- | :--- | :--- |
| **Gross Revenue (${paidToday.length} settled)** | **${CurrencyFormatter.format(grossRevenue)}** | Operating Cash & Digital Inflow |
| Less: 15% VAT Statutory Deduction | - ${CurrencyFormatter.format(vatDeducted)} | Tax Obligation |
| **Net Service Revenue** | **${CurrencyFormatter.format(netAfterVat)}** | Net Taxable Income |
| Less: Washer Commissions (15%) | - ${CurrencyFormatter.format(commissionsPaid)} | Direct Labor (COGS) |
| Less: Supplies Consumed | - ${CurrencyFormatter.format(suppliesConsumed)} | Direct Chemicals (COGS) |
| **GROSS OPERATING PROFIT** | **${CurrencyFormatter.format(grossProfit)}** | **Margin: ${grossRevenue > 0 ? ((grossProfit / grossRevenue) * 100).toStringAsFixed(1) : '0'}%** |
| Less: Cashier & Yard Petty Cash | - ${CurrencyFormatter.format(pettyExpenses)} | General Operating Overhead |
| **NET OPERATING PROFIT (EBITDA)** | **${CurrencyFormatter.format(netOperatingProfit)}** | **Net Retained Daily Cash** |

> *Note: Fixed station rent and guaranteed monthly base salaries are amortized over the 30-day calendar cycle.*
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

    final shampoo = state.consumables.firstWhere(
      (c) => c.id == 'CS-009',
      orElse: () => state.consumables.first,
    );
    final perfume = state.consumables.firstWhere(
      (c) => c.id == 'CS-006',
      orElse: () => state.consumables.first,
    );
    final towels = state.consumables.firstWhere(
      (c) => c.id == 'CS-013',
      orElse: () => state.consumables.first,
    );

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
