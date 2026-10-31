import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/url_launcher_helper.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/models/payment_info.dart';
import '../../domain/models/wash_booking.dart';
import '../../domain/models/wash_status.dart';
import '../state/app_state_provider.dart';

enum HistoryDateFilter {
  today,
  yesterday,
  thisWeek,
  thisMonth,
  customRange;

  String localizedLabel(dynamic state) {
    switch (this) {
      case HistoryDateFilter.today:
        return state.tr('filterToday');
      case HistoryDateFilter.yesterday:
        return state.tr('filterYesterday');
      case HistoryDateFilter.thisWeek:
        return state.tr('filterThisWeek');
      case HistoryDateFilter.thisMonth:
        return state.tr('filterThisMonth');
      case HistoryDateFilter.customRange:
        return state.tr('filterCustomRange');
    }
  }
}

class VehicleHistoryScreen extends StatefulWidget {
  final bool isEmbedded;

  const VehicleHistoryScreen({super.key, this.isEmbedded = false});

  @override
  State<VehicleHistoryScreen> createState() => _VehicleHistoryScreenState();
}

class _VehicleHistoryScreenState extends State<VehicleHistoryScreen> {
  HistoryDateFilter _dateFilter = HistoryDateFilter.today;
  DateTimeRange? _customDateRange;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<WashBooking> _filterBookings(List<WashBooking> allBookings) {
    // History contains bookings that are paid and/or completed
    final paidBookings = allBookings.where((b) => b.payment.isPaid).toList();
    final now = DateTime.now();

    final filteredByDate = paidBookings.where((b) {
      final date = b.createdAt;
      switch (_dateFilter) {
        case HistoryDateFilter.today:
          return date.year == now.year && date.month == now.month && date.day == now.day;
        case HistoryDateFilter.yesterday:
          final y = now.subtract(const Duration(days: 1));
          return date.year == y.year && date.month == y.month && date.day == y.day;
        case HistoryDateFilter.thisWeek:
          final monday = now.subtract(Duration(days: now.weekday - 1));
          final start = DateTime(monday.year, monday.month, monday.day);
          return date.isAfter(start) || date.isAtSameMomentAs(start);
        case HistoryDateFilter.thisMonth:
          return date.year == now.year && date.month == now.month;
        case HistoryDateFilter.customRange:
          if (_customDateRange == null) return true;
          final start = DateTime(_customDateRange!.start.year, _customDateRange!.start.month, _customDateRange!.start.day);
          final end = DateTime(_customDateRange!.end.year, _customDateRange!.end.month, _customDateRange!.end.day, 23, 59, 59);
          return (date.isAfter(start) || date.isAtSameMomentAs(start)) &&
              (date.isBefore(end) || date.isAtSameMomentAs(end));
      }
    }).toList();

    if (_searchQuery.trim().isEmpty) return filteredByDate;

    final q = _searchQuery.trim().toLowerCase();
    return filteredByDate.where((b) {
      return b.licensePlate.toLowerCase().contains(q) ||
          b.customerPhone.toLowerCase().contains(q) ||
          b.customerName.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final historyList = _filterBookings(state.bookings);

    final totalCars = historyList.length;
    final totalRevenue = historyList.fold<double>(0.0, (sum, b) => sum + b.totalPrice);
    final cashTotal = historyList
        .where((b) => b.payment.method == PaymentMethod.cash)
        .fold<double>(0.0, (sum, b) => sum + b.totalPrice);
    final digitalTotal = totalRevenue - cashTotal;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Filter Bar
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: HistoryDateFilter.values.map((filter) {
              final isSelected = filter == _dateFilter;
              String chipLabel = filter.localizedLabel(state);
              if (filter == HistoryDateFilter.customRange && _customDateRange != null) {
                final s = _customDateRange!.start;
                final e = _customDateRange!.end;
                chipLabel = '${s.day}/${s.month} - ${e.day}/${e.month}';
              }

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  avatar: filter == HistoryDateFilter.customRange
                      ? Icon(Icons.date_range_rounded, size: 15, color: isSelected ? Colors.white : AppColors.primary)
                      : null,
                  label: Text(
                    chipLabel,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: Colors.white,
                  showCheckmark: false,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: isSelected ? AppColors.primary : AppColors.cardBorder),
                  ),
                  onSelected: (_) async {
                    if (filter == HistoryDateFilter.customRange) {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2022),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        initialDateRange: _customDateRange ??
                            DateTimeRange(
                              start: DateTime.now().subtract(const Duration(days: 7)),
                              end: DateTime.now(),
                            ),
                      );
                      if (picked != null) {
                        setState(() {
                          _customDateRange = picked;
                          _dateFilter = HistoryDateFilter.customRange;
                        });
                      }
                    } else {
                      setState(() => _dateFilter = filter);
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),

        // KPI Summary Box
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(state.tr('carsWashed'), style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                    const SizedBox(height: 2),
                    Text(
                      '$totalCars',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 32, color: AppColors.cardBorder),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(state.tr('totalRevenue'), style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.formatShort(totalRevenue),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.statusCompleted),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 32, color: AppColors.cardBorder),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(state.tr('cashVsDigital'), style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                    const SizedBox(height: 2),
                    Text(
                      '${CurrencyFormatter.formatShort(cashTotal)} / ${CurrencyFormatter.formatShort(digitalTotal)}',
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Search Bar
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: state.tr('searchPlateOrPhone'),
            prefixIcon: const Icon(Icons.search, size: 20),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
          ),
          onChanged: (val) => setState(() => _searchQuery = val),
        ),
        const SizedBox(height: 10),

        if (state.bookings.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${state.bookings.length} Total Bookings Recorded',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
              TextButton.icon(
                icon: const Icon(Icons.delete_sweep_rounded, size: 16, color: Colors.red),
                label: Text(
                  state.tr('clearAllBookings'),
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.red),
                ),
                onPressed: () => _confirmClearAllBookings(context, state),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],

        // History Records List
        if (historyList.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Center(
              child: Text(
                state.tr('noVehiclesFound'),
                style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: historyList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final b = historyList[index];
              return _buildHistoryCard(context, b, state);
            },
          ),
      ],
    );

    if (widget.isEmbedded) {
      return content;
    }

    final isMobile = ResponsiveLayout.isMobile(context);
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(state.tr('washAndVehicleHistory'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 24 : (isMobile ? 12 : 18),
              vertical: 16,
            ),
            child: content,
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, WashBooking b, dynamic state) {
    final method = b.payment.method;
    final isDigital = method.isDigital;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.statusCompleted.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_rounded, color: AppColors.statusCompleted, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    b.licensePlate,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.textPrimary),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      b.carType.displayName,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
              Text(
                CurrencyFormatter.format(b.totalPrice),
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                b.package.name,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isDigital ? AppColors.telebirrBlue.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${state.tr('statusPaid').toUpperCase()} • ${method.localizedName(state.currentLanguage).toUpperCase()}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isDigital ? AppColors.telebirrBlue : Colors.green.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Customer: ${b.customerName} (${b.customerPhone})',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              Text(
                DateFormatter.formatDate(b.createdAt),
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
          if (b.assignedWasherName != null) ...[
            const SizedBox(height: 4),
            Text(
              'Washer: ${b.assignedWasherName} • Bay: ${b.assignedBay?.displayName ?? "Station"}',
              style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmClearAllBookings(BuildContext context, dynamic state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                state.tr('clearAllBookingsConfirm'),
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
          ],
        ),
        content: Text(
          state.tr('clearAllBookingsDesc'),
          style: const TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(state.tr('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await state.clearAllBookings();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.tr('clearAllBookingsSuccess')),
                    backgroundColor: Colors.green.shade700,
                  ),
                );
              }
            },
            child: Text(state.tr('clearAllBookings')),
          ),
        ],
      ),
    );
  }
}
