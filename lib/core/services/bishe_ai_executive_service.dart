import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../features/booking_service/domain/models/car_type.dart';
import '../../features/booking_service/presentation/state/app_state_notifier.dart';
import '../localization/app_strings.dart';
import '../utils/currency_formatter.dart';

/// BISHE AI Operations Executive Service
/// Provides intelligent operational answers using either the Google Gemini API
/// or a zero-network local analytical heuristics engine.
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
    List<Map<String, String>>? conversationHistory,
  }) async {
    final apiKey = state.geminiApiKey;
    String? cloudErrorNotice;

    // 1. If Gemini API key is provided, query Gemini with full grounded knowledge & multi-turn history
    if (apiKey != null && apiKey.isNotEmpty) {
      try {
        final systemContext = _buildGeminiSystemPrompt(userQuestion, state, currentLang);
        final List<Map<String, dynamic>> contents = [];

        // Grounding System Context Turn
        contents.add({
          'role': 'user',
          'parts': [{'text': systemContext}],
        });
        contents.add({
          'role': 'model',
          'parts': [{'text': 'Understood. I am BisheAI, Chief Operations Executive for BISHE Car Wash. Grounded in the operations manual and live station records, I will answer accurately with tables and calculations where appropriate.'}],
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
            'temperature': 0.7,
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
    final localResult = _localStationAnalytics(userQuestion, state, currentLang);
    return cloudErrorNotice != null ? '$cloudErrorNotice$localResult' : localResult;
  }

  /// Compact system prompt with aggregated business snapshot (< 1.5 KB)
  static String _buildGeminiSystemPrompt(
    String question,
    AppStateNotifier state,
    AppLanguage lang,
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
            // Differentiate SUV/Pickup (1.4x) from Minibus/Van (1.8x)
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

    final vehicleDetails = todayBookings.take(10).map((b) {
      final p = b.licensePlate.isNotEmpty ? b.licensePlate : 'WALK-IN';
      final t = b.isCarpet ? 'Carpet' : b.carType.displayName;
      final st = b.status.name.toUpperCase();
      return '• $p ($t) -> $st [ETB ${b.totalPrice.toStringAsFixed(0)}]';
    }).join('\n');

    return '''
You are "BisheAI", the Chief Operations Executive for "BISHE Car Wash & Auto Care Service" located in Bishoftu (Debre Zeyit), Oromia, Ethiopia.
GPS: 8°44'57.2"N 38°58'02.4"E | Location: Behind Hirna Butchery, near Alemshet Fero.

OPERATIONAL KNOWLEDGE BASE (BISHE OPERATIONS MANUAL):
1. Infrastructure: 2 Physical Bays (Bay 1 & Bay 2), 1 Mobile Van (serving 8 Bishoftu zones), 8 Washers on duty in rotating pairs.
2. Vehicle Volume & Category Multipliers (EVU):
   - Sedan / Automobile (Type A): 1.0x Base Workload (125 ml shampoo, 5 ml perfume)
   - SUV / Pickup (Type B): 1.4x Workload (175 ml shampoo, 7 ml perfume)
   - Minibus / Van (Type B): 1.8x Workload (225 ml shampoo, 9 ml perfume)
   - Heavy Truck (Type C): 2.5x Workload (312.5 ml shampoo, 12.5 ml perfume)
   - Carpet Cleaning: Calculated per square meter (Area in m² * 0.25 EVU)
3. Chemical Yield Benchmarks & Thresholds:
   - 5L Foam Shampoo (CS-009): Standard yield is ~40 cars @ 125 ml/EVU. Trigger alert if < 25 cars (waste/leak) or > 55 cars (under-dilution).
   - 500ml Interior Perfume (CS-006): Standard yield is ~100 sprays @ 5 ml/interior. Trigger alert if < 70 or > 130 sprays.
   - Empty-for-Full chemical exchange strictly enforced by Storekeeper for all 22 consumables (CS-001 to CS-014).
4. Statutory Tax & P&L Math:
   - Car Wash & Carpets: 15% Statutory VAT.
   - Shower Services: 0% VAT (Exempt).
   - Washer Commissions: Default 15% (individual rates 2%-25%) calculated strictly on Net Base Revenue (Gross - VAT).
   - Cash custody transferred via 6-digit OTP from Cashier (07:00-15:30) to Operations Manager.

LIVE STATION DATABASE SNAPSHOT (${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}):
- Total Today Bookings: ${todayBookings.length} (Completed: ${completedToday.length})
- Workload Breakdown: Type A: $typeA | Type B: $typeB | Type C: $typeC | Carpets: $carpets (${totalCarpetM2.toStringAsFixed(1)} m²)
- Total Workload Units: ${totalEvu.toStringAsFixed(1)} EVU
- Gross Revenue Settled: ETB ${grossRevenue.toStringAsFixed(2)}
- Washer Commissions Settled: ETB ${commissionsPaid.toStringAsFixed(2)}
- Active Washers on Duty: ${activeWashers.join(', ')}
- Low Stock Warehouse Alerts: ${lowStockItems.isEmpty ? 'None (Healthy)' : lowStockItems.join(', ')}
- Live Queue Entries:
$vehicleDetails

INSTRUCTIONS:
- Answer with analytical depth, clarity, and authority. Point out revenue leaks, chemical variances, or anomalies if any.
- If asked for a table or list, format as a clean Markdown table.
- If asked in Amharic or Afaan Oromoo, reply in that language. Otherwise reply in English.
''';
  }

  /// Built-in local station analytics engine for instant, zero-bandwidth answers
  static String _localStationAnalytics(
    String rawQuery,
    AppStateNotifier state,
    AppLanguage lang,
  ) {
    final query = rawQuery.toLowerCase().trim();
    final now = DateTime.now();

    // 1. P&L, Revenue & Financials
    if (query.contains('p&l') ||
        query.contains('profit') ||
        query.contains('revenue') ||
        query.contains('financial') ||
        query.contains('expense') ||
        query.contains('ገቢ') ||
        query.contains('ትርፍ') ||
        query.contains('bu\'aa') ||
        query.contains('galii')) {
      return _generatePnlReport(state, now);
    }

    // 2. Washers, Staff & Commissions (Evaluated before generic 'wash')
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

    // 3. Consumables, Shampoo, Perfume & Yield
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

    // 4. Stock, Alerts & Discrepancies
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

    // 5. Cars Washed & Vehicle Breakdown
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

**You can ask me questions like:**
1. *"Show me today's P&L and net profit"*
2. *"List the cars washed today and their plate numbers"*
3. *"Who are the active washers and how much commission did they earn?"*
4. *"What is the chemical yield and average shampoo used per car?"*
5. *"Show any low stock warnings or discrepancies"*
''';
  }
}
