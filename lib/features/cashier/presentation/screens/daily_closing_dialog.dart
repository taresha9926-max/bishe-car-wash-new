import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/auto_care_assets.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../booking_service/domain/models/payment_info.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';
import '../../../admin/domain/models/daily_financial_closing.dart';
import '../../../auth_roles/domain/models/user_role.dart';

class DailyClosingDialog extends StatefulWidget {
  final bool isManagerClosing;
  const DailyClosingDialog({super.key, this.isManagerClosing = false});

  static Future<void> show(BuildContext context, {bool isManagerClosing = false}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => DailyClosingDialog(isManagerClosing: isManagerClosing),
    );
  }

  @override
  State<DailyClosingDialog> createState() => _DailyClosingDialogState();
}

class _DailyClosingDialogState extends State<DailyClosingDialog> {
  final _cashierNameController = TextEditingController(text: 'Staff On Duty');
  final _notesController = TextEditingController();
  final _bankSlipController = TextEditingController();
  String _handoverMethod = 'manager_otp'; // 'manager_otp' or 'bank_deposit'
  String _selectedAccountKey = 'account_a';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final active = AppStateProvider.read(context).activeStaffFullName;
    if (active != null && active.isNotEmpty) {
      _cashierNameController.text = active;
    } else {
      _cashierNameController.text = widget.isManagerClosing ? 'Dawit Manager' : 'Cashier On Duty';
    }
  }

  @override
  void dispose() {
    _cashierNameController.dispose();
    _notesController.dispose();
    _bankSlipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final gross = state.totalRevenueTodayETB;
    final cash = state.totalCashRevenueETB;
    final digital = state.totalDigitalRevenueETB;
    final comm = state.teamCommissionPoolTodayETB;
    final net = gross - comm;
    final deposited = state.totalCashDepositedTodayETB;
    final petty = state.todayPettyCashExpensesETB;
    final remainingCash = state.undepositedCashTodayETB;
    final dividends = state.washerDividendsToday;
    final isAlreadyClosed = widget.isManagerClosing ? state.isTodayNightShiftClosed : state.isTodayDayShiftClosed;
    final needsCommissionDisbursement = !isAlreadyClosed && state.requiresDailyCommissionDisbursementBeforeClosing;
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 14 : 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        AutoCareAssets.buildPhotoThumbnail(
                          imageUrl: widget.isManagerClosing ? AutoCareAssets.packageTireRimUrl : AutoCareAssets.welcomeHeroUrl,
                          width: 44,
                          height: 44,
                          borderRadius: 12,
                          fallbackIcon: Icons.fact_check_rounded,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.isManagerClosing ? state.tr('nightClosingTitle') : state.tr('dailyClosing'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                              ),
                              Text(
                                isAlreadyClosed
                                    ? 'Shift Already Closed & Confirmed'
                                    : (widget.isManagerClosing
                                        ? 'Night shift closing & total payout to Admin'
                                        : 'Day shift closing & handover to Operational Manager'),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: isAlreadyClosed ? AppColors.statusCompleted : AppColors.textSecondary,
                                  fontWeight: isAlreadyClosed ? FontWeight.w700 : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // KPI Summary Box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    _buildClosingRow(
                      widget.isManagerClosing ? 'Night Shift Gross Revenue:' : 'Daily Gross Revenue:',
                      CurrencyFormatter.format(gross),
                      isBold: true,
                      valueColor: AppColors.primary,
                    ),
                    const Divider(height: 16),
                    _buildClosingRow('  • Vehicle Wash Revenue:', '${CurrencyFormatter.format(state.todayVehicleRevenueETB)} (${state.totalCompletedCarsToday} cars)', valueColor: AppColors.primaryDark),
                    const SizedBox(height: 3),
                    _buildClosingRow('  • Carpet Cleaning Revenue:', '${CurrencyFormatter.format(state.todayCarpetRevenueETB)} (${state.todayCarpetCleanedCount} carpets)', valueColor: const Color(0xFF6366F1)),
                    const SizedBox(height: 3),
                    _buildClosingRow('  • Station Shower Revenue:', '${CurrencyFormatter.format(state.todayShowerRevenueETB)} (${state.todayShowerUserCount} users, 0% comm)', valueColor: const Color(0xFF0284C7)),
                    if (state.todayCustomerTipsETB > 0) ...[
                      const SizedBox(height: 3),
                      _buildClosingRow('  • Customer Tips to Washers:', '+ ${CurrencyFormatter.format(state.todayCustomerTipsETB)} (100% to pool)', valueColor: Colors.amber.shade900),
                    ],
                    const Divider(height: 16),
                    _buildClosingRow('  • Cash Collected at Station:', CurrencyFormatter.format(cash), valueColor: AppColors.cashGreen),
                    const SizedBox(height: 4),
                    _buildClosingRow('  • Digital Channels Total (Telebirr/CBE):', CurrencyFormatter.format(digital), valueColor: AppColors.telebirrBlue),
                    const Divider(height: 16),
                    _buildClosingRow(
                      widget.isManagerClosing ? 'Night Washer Commission (15% Pool):' : 'Day Washer Commission (15% Pool):',
                      '- ${CurrencyFormatter.format(comm)}',
                      isBold: true,
                      valueColor: AppColors.oromiaGold,
                    ),
                    const SizedBox(height: 4),
                    _buildClosingRow('Remaining Station Net Profit:', CurrencyFormatter.format(net), isBold: true, valueColor: AppColors.statusCompleted),
                    const Divider(height: 16),
                    if (widget.isManagerClosing) ...[
                      _buildClosingRow('Carried Cash from Cashier Handover:', CurrencyFormatter.format(state.managerCarriedCashETB), isBold: true, valueColor: Colors.indigo),
                      const SizedBox(height: 4),
                      _buildClosingRow('Night Shift Cash Collected:', CurrencyFormatter.format(state.nightShiftAdditionalCashETB), valueColor: AppColors.cashGreen),
                      const Divider(height: 16),
                      _buildClosingRow('Total Physical Cash Handed to Admin:', CurrencyFormatter.format(remainingCash), isBold: true, valueColor: AppColors.primary),
                    ] else ...[
                      _buildClosingRow('Petty Cash / Emergency Outflow:', CurrencyFormatter.format(petty), valueColor: Colors.deepOrange),
                      const SizedBox(height: 4),
                      _buildClosingRow('Cash Balance to Handover to Manager:', CurrencyFormatter.format(remainingCash), isBold: true, valueColor: remainingCash > 0 ? AppColors.primary : AppColors.textSecondary),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Digital Channels Breakdown
              Text(
                state.tr('moneyReceivedBreakdown'),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              _buildDigitalChannelsGrid(state),
              const SizedBox(height: 16),

              // Washer Commission Distribution
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${state.tr('teamCommissionDistribution')}:',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${state.presentWashersCount} On Duty',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.oromiaGold),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.oromiaGold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 13, color: AppColors.oromiaGold),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        state.tr('washerCommissionReportNote'),
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF92400E)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: dividends.isEmpty
                    ? const Center(
                        child: Text('No active washers on duty.', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      )
                    : Column(
                        children: dividends.values.map((div) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(
                                        div.isPresent ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                        size: 14,
                                        color: div.isPresent ? AppColors.statusCompleted : Colors.red,
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          div.washerName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: div.isPresent ? FontWeight.w700 : FontWeight.w500,
                                            color: div.isPresent ? AppColors.textPrimary : AppColors.textMuted,
                                          ),
                                        ),
                                      ),
                                      if (div.customTierName != null && div.customTierName!.isNotEmpty) ...[
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: AppColors.surfaceVariant,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              div.customTierName!,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  div.isPresent
                                      ? '${div.percentageShare.toStringAsFixed(1)}% • ${CurrencyFormatter.format(div.earnedETB)}'
                                      : 'Absent (0 ETB)',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: div.isPresent ? AppColors.oromiaGold : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),
              const SizedBox(height: 16),

              // Physical Cash Destination Option (Cashier shift only)
              if (!widget.isManagerClosing) ...[
                Text(
                  state.tr('handoverMethod'),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => setState(() => _handoverMethod = 'manager_otp'),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: _handoverMethod == 'manager_otp' ? AppColors.primary.withOpacity(0.08) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _handoverMethod == 'manager_otp' ? AppColors.primary : AppColors.cardBorder,
                        width: _handoverMethod == 'manager_otp' ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _handoverMethod == 'manager_otp' ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                          color: _handoverMethod == 'manager_otp' ? AppColors.primary : AppColors.textMuted,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.tr('handoverToManagerOption'),
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: _handoverMethod == 'manager_otp' ? AppColors.primary : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Generates 4-digit code for Operational Manager to count and verify.',
                                style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => setState(() => _handoverMethod = 'admin_otp'),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: _handoverMethod == 'admin_otp' ? AppColors.primary.withOpacity(0.08) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _handoverMethod == 'admin_otp' ? AppColors.primary : AppColors.cardBorder,
                        width: _handoverMethod == 'admin_otp' ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _handoverMethod == 'admin_otp' ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                          color: _handoverMethod == 'admin_otp' ? AppColors.primary : AppColors.textMuted,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.tr('handoverToAdminOption'),
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: _handoverMethod == 'admin_otp' ? AppColors.primary : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                state.tr('handoverToAdminSub'),
                                style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => setState(() => _handoverMethod = 'bank_deposit'),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: _handoverMethod == 'bank_deposit' ? AppColors.primary.withOpacity(0.08) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _handoverMethod == 'bank_deposit' ? AppColors.primary : AppColors.cardBorder,
                        width: _handoverMethod == 'bank_deposit' ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _handoverMethod == 'bank_deposit' ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                          color: _handoverMethod == 'bank_deposit' ? AppColors.primary : AppColors.textMuted,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.tr('bankDepositOption'),
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: _handoverMethod == 'bank_deposit' ? AppColors.primary : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                state.tr('bankDepositSub'),
                                style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_handoverMethod == 'bank_deposit') ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(() => _selectedAccountKey = 'account_a'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _selectedAccountKey == 'account_a' ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: _selectedAccountKey == 'account_a' ? AppColors.cbeBirrPurple : Colors.transparent,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: const Text('CBE (Account A)', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(() => _selectedAccountKey = 'account_b'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _selectedAccountKey == 'account_b' ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: _selectedAccountKey == 'account_b' ? const Color(0xFFEA580C) : Colors.transparent,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: const Text('Awash (Account B)', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: _bankSlipController,
                          label: 'Deposit Slip Reference / Transaction #',
                          hint: 'e.g. CBE-TX-982187 or Awash-Slip-441',
                          prefixIcon: Icons.receipt_long_rounded,
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
              ],

              // Staff Name & Notes
              CustomTextField(
                controller: _cashierNameController,
                label: widget.isManagerClosing ? 'Closing Manager Name' : 'Closing Cashier Name',
                hint: widget.isManagerClosing ? 'Manager confirming closing' : 'Cashier confirming closing',
                prefixIcon: Icons.badge_rounded,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: _notesController,
                label: 'Daily Closing Remarks / Notes',
                hint: 'e.g. All vehicles washed and accounted for, cash counted.',
                prefixIcon: Icons.edit_note_rounded,
              ),
              const SizedBox(height: 14),

              // Open Vehicles Handover & Online No-Show Auto-Cleanup Summary
              Builder(
                builder: (context) {
                  final openVehicles = state.openArrivedQueueBookings;
                  final unarrivedOnline = state.unarrivedOnlineBookingsToday;
                  final willClearNoShows = widget.isManagerClosing || _handoverMethod != 'manager_otp';
                  if (openVehicles.isEmpty && (!willClearNoShows || unarrivedOnline.isEmpty)) {
                    return const SizedBox(height: 6);
                  }
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (openVehicles.isNotEmpty) ...[
                          Row(
                            children: [
                              const Icon(Icons.directions_car_filled_rounded, size: 17, color: Color(0xFF4338CA)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  (!widget.isManagerClosing && _handoverMethod == 'manager_otp')
                                      ? '${state.tr("handedOverVehiclesTitle")} (${openVehicles.length})'
                                      : '${state.tr("openVehiclesHandoverTitle")} (${openVehicles.length})',
                                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF312E81)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${state.tr("openVehiclesHandoverDesc")} (${openVehicles.map((v) => "${v.licensePlate}${v.isPostponed ? " [POSTPONED]" : ""}${v.payment.isPaid ? " [PAID]" : ""}").take(5).join(", ")})',
                            style: const TextStyle(fontSize: 11.5, color: Color(0xFF3730A3), height: 1.3),
                          ),
                        ],
                        if (willClearNoShows && unarrivedOnline.isNotEmpty) ...[
                          if (openVehicles.isNotEmpty) const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.auto_delete_rounded, size: 16, color: Color(0xFFB45309)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '${unarrivedOnline.length} ${state.tr("autoClearNoShowsNotice")}',
                                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF92400E)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),

              // Strict Prerequisite Gate: Daily Washer Commissions must be disbursed first
              if (needsCommissionDisbursement) ...[
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFD97706), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.lock_clock_rounded, color: Color(0xFFB45309), size: 22),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              state.tr('commissionDisburseRequiredTitle'),
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF92400E),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${state.tr("commissionDisburseRequiredDesc")} (${state.tr("remainingCommissionPool")}: ${CurrencyFormatter.format(state.undisbursedCommissionPoolTodayETB)})',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF78350F), height: 1.35),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isSubmitting
                              ? null
                              : () async {
                                  final staffName = _cashierNameController.text.trim().isNotEmpty
                                      ? _cashierNameController.text.trim()
                                      : (widget.isManagerClosing ? 'Dawit Manager' : 'Cashier');
                                  await state.disburseAndReportDailyCommissionToAdmin(cashierName: staffName);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(state.tr('dailyCommissionDisbursedReported')),
                                        backgroundColor: AppColors.statusCompleted,
                                      ),
                                    );
                                  }
                                },
                          icon: const Icon(Icons.payments_rounded, size: 17),
                          label: Text(
                            state.tr('disburseNowAndUnlockClosing'),
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD97706),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Action Buttons
              if (isAlreadyClosed) ...[
                CustomButton(
                  text: '${state.tr('dailyClosingConfirmed')} (${state.tr('shiftLocked')})',
                  icon: Icons.lock_outline_rounded,
                  backgroundColor: Colors.grey.shade600,
                  isLoading: false,
                  onPressed: null,
                ),
                if (!widget.isManagerClosing) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _handleUnlockShift(context, state),
                      icon: const Icon(Icons.lock_open_rounded, color: AppColors.primary, size: 18),
                      label: Text(
                        (state.pendingCashierHandover != null || state.pendingCashierAdminHandover != null)
                            ? state.tr('unlockAndResumeShift')
                            : state.tr('unlockWithManagerPin'),
                        style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 13),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ] else
                CustomButton(
                  text: needsCommissionDisbursement
                      ? state.tr('commissionDisburseRequiredTitle')
                      : state.tr('confirmDailyClosing'),
                  icon: needsCommissionDisbursement ? Icons.lock_rounded : Icons.check_circle_outline_rounded,
                  backgroundColor: needsCommissionDisbursement ? Colors.grey.shade500 : AppColors.cashGreen,
                  isLoading: _isSubmitting,
                  onPressed: (_isSubmitting || needsCommissionDisbursement) ? null : _handleClosingConfirm,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClosingRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isBold ? 13 : 12,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
              color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isBold ? 13.5 : 12,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDigitalChannelsGrid(dynamic state) {
    final methodRevenue = state.getRevenueByPaymentMethod();
    final methodCounts = state.getTransactionCountByPaymentMethod();

    final channels = [
      (label: PaymentMethod.telebirr.localizedName(state.currentLanguage), amt: methodRevenue[PaymentMethod.telebirr] ?? 0.0, cnt: methodCounts[PaymentMethod.telebirr] ?? 0, color: AppColors.telebirrBlue),
      (label: PaymentMethod.cbeBirr.localizedName(state.currentLanguage), amt: methodRevenue[PaymentMethod.cbeBirr] ?? 0.0, cnt: methodCounts[PaymentMethod.cbeBirr] ?? 0, color: AppColors.cbeBirrPurple),
      (label: PaymentMethod.bankOfAbyssinia.localizedName(state.currentLanguage), amt: methodRevenue[PaymentMethod.bankOfAbyssinia] ?? 0.0, cnt: methodCounts[PaymentMethod.bankOfAbyssinia] ?? 0, color: const Color(0xFFF59E0B)),
      (label: PaymentMethod.awashBank.localizedName(state.currentLanguage), amt: methodRevenue[PaymentMethod.awashBank] ?? 0.0, cnt: methodCounts[PaymentMethod.awashBank] ?? 0, color: const Color(0xFFEA580C)),
      (label: PaymentMethod.dashenBank.localizedName(state.currentLanguage), amt: methodRevenue[PaymentMethod.dashenBank] ?? 0.0, cnt: methodCounts[PaymentMethod.dashenBank] ?? 0, color: const Color(0xFF0284C7)),
      (label: PaymentMethod.otherBankTransfer.localizedName(state.currentLanguage), amt: methodRevenue[PaymentMethod.otherBankTransfer] ?? 0.0, cnt: methodCounts[PaymentMethod.otherBankTransfer] ?? 0, color: Colors.indigo),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: channels.map((c) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: c.amt > 0 ? c.color.withOpacity(0.08) : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: c.amt > 0 ? c.color.withOpacity(0.3) : AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                c.label,
                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: c.amt > 0 ? c.color : AppColors.textSecondary),
              ),
              const SizedBox(height: 2),
              Text(
                '${CurrencyFormatter.formatShort(c.amt)} (${c.cnt})',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: c.amt > 0 ? AppColors.textPrimary : AppColors.textMuted,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Future<void> _handleClosingConfirm() async {
    final state = AppStateProvider.read(context);
    if (state.requiresDailyCommissionDisbursementBeforeClosing) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.tr('commissionDisburseRequiredDesc')),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final staffName = _cashierNameController.text.trim().isNotEmpty
        ? _cashierNameController.text.trim()
        : (widget.isManagerClosing ? 'Dawit Manager' : 'Cashier On Duty');

    setState(() => _isSubmitting = true);

    try {
      String targetRecipient = 'Operational Manager';
      if (widget.isManagerClosing) {
        targetRecipient = 'Admin / Owner';
      } else if (_handoverMethod == 'admin_otp') {
        targetRecipient = 'Admin / Owner';
      } else if (_handoverMethod == 'bank_deposit') {
        targetRecipient = 'Bank Deposit';
      }

      final closing = await state.confirmDailyClosing(
        cashierName: staffName,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        shiftType: widget.isManagerClosing ? 'night' : 'day',
        closedByRole: widget.isManagerClosing ? 'manager' : 'cashier',
        handoverTo: targetRecipient,
        handoverMethod: widget.isManagerClosing ? 'admin_otp' : _handoverMethod,
        bankAccountKey: _selectedAccountKey,
        bankReferenceSlip: _bankSlipController.text.trim().isNotEmpty ? _bankSlipController.text.trim() : null,
      );

      if (mounted) {
        final parentContext = Navigator.of(context).context;
        Navigator.pop(context);
        if (state.closingCloudSyncError != null && parentContext.mounted) {
          ScaffoldMessenger.of(parentContext).showSnackBar(
            SnackBar(
              content: Text(state.tr('closingCloudSyncRlsWarning')),
              backgroundColor: const Color(0xFFD97706),
              duration: const Duration(seconds: 7),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        if (closing.handoverOtp != null && closing.handoverOtp!.isNotEmpty && parentContext.mounted) {
          _showOtpReceiptDialog(parentContext, closing, state);
        } else if (state.closingCloudSyncError == null && parentContext.mounted) {
          ScaffoldMessenger.of(parentContext).showSnackBar(
            SnackBar(
              content: Text(state.tr('bankDepositRecorded')),
              backgroundColor: AppColors.statusReady,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error confirming closing: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _handleUnlockShift(BuildContext context, dynamic state) async {
    final isPending = state.pendingCashierHandover != null || state.pendingCashierAdminHandover != null;
    if (isPending) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.lock_open_rounded, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  state.tr('confirmUnlockShiftTitle'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          content: Text(
            state.tr('confirmUnlockShiftDesc'),
            style: const TextStyle(fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(state.tr('cancel'), style: const TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(state.tr('confirmUnlockAction')),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await state.unlockDayShiftClosing();
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.tr('shiftUnlockedSuccess')),
              backgroundColor: AppColors.statusReady,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } else {
      final unlocked = await _showUnlockShiftPinDialog(context, state);
      if (unlocked == true && context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.tr('shiftUnlockedSuccess')),
            backgroundColor: AppColors.statusReady,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<bool> _showUnlockShiftPinDialog(BuildContext context, dynamic state) async {
    final pinController = TextEditingController();
    String? errorMessage;
    bool isVerifying = false;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.security_rounded, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    state.tr('enterManagerOrAdminPin'),
                    style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.tr('managerOrAdminPinRequired'),
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: pinController,
                  obscureText: true,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    labelText: 'PIN',
                    errorText: errorMessage,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(Icons.pin_rounded),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(state.tr('cancel'), style: const TextStyle(color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                onPressed: isVerifying
                    ? null
                    : () async {
                        final pin = pinController.text.trim();
                        if (pin.isEmpty) return;
                        setDialogState(() {
                          isVerifying = true;
                          errorMessage = null;
                        });

                        final isMgr = await state.authenticateRoleAsync(UserRole.manager, pin);
                        final isAdmin = isMgr ? false : await state.authenticateRoleAsync(UserRole.admin, pin);

                        if (isMgr || isAdmin) {
                          await state.unlockDayShiftClosing();
                          if (ctx.mounted) Navigator.pop(ctx, true);
                        } else {
                          setDialogState(() {
                            isVerifying = false;
                            errorMessage = state.tr('invalidManagerOrAdminPin');
                          });
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: isVerifying
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(state.tr('unlock')),
              ),
            ],
          );
        },
      ),
    );

    pinController.dispose();
    return result ?? false;
  }

  void _showOtpReceiptDialog(BuildContext context, DailyFinancialClosing closing, dynamic state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.pin_rounded, color: AppColors.primary, size: 30),
              ),
              const SizedBox(height: 14),
              Text(
                state.tr('transferOtpCode'),
                style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              Text(
                widget.isManagerClosing || _handoverMethod == 'admin_otp'
                    ? 'Give this 4-digit code to Admin after handing over ${CurrencyFormatter.format(closing.handoverCashAmount)} physical cash.'
                    : 'Give this 4-digit code to Operational Manager after handing over ${CurrencyFormatter.format(closing.handoverCashAmount)} physical cash.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
                ),
                child: Text(
                  closing.handoverOtp ?? '',
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 10,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Physical Handover Cash:', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                    Text(
                      CurrencyFormatter.format(closing.handoverCashAmount),
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: AppColors.cashGreen),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Done',
                icon: Icons.check_circle_rounded,
                backgroundColor: AppColors.primary,
                isLoading: false,
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
