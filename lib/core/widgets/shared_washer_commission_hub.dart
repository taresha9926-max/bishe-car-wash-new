import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'package:bishe_car_wash/core/utils/currency_formatter.dart';
import 'package:bishe_car_wash/features/admin/domain/models/staff_member.dart';
import 'package:bishe_car_wash/features/cashier/presentation/screens/weekly_commission_report_dialog.dart';

enum WasherHubRole { cashier, accountant, admin }

/// Unified Master Washer Team Roster, Attendance & Commission Hub
/// Shared across Cashier, Accountant, and Admin dashboards with mobile-first
/// expandable architecture and zero clutter.
class SharedWasherCommissionHub extends StatefulWidget {
  final dynamic state;
  final WasherHubRole role;
  final bool isMobile;
  final bool initiallyExpanded;
  final bool respectInitiallyExpanded;

  const SharedWasherCommissionHub({
    super.key,
    required this.state,
    required this.role,
    required this.isMobile,
    this.initiallyExpanded = true,
    this.respectInitiallyExpanded = false,
  });

  @override
  State<SharedWasherCommissionHub> createState() => _SharedWasherCommissionHubState();
}

class _SharedWasherCommissionHubState extends State<SharedWasherCommissionHub>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _animController;
  late Animation<double> _chevronTurns;
  int _selectedWeekOffset = 0;
  bool _adminShowLiveRoster = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = (widget.respectInitiallyExpanded || !widget.isMobile) ? widget.initiallyExpanded : false;
    _animController = AnimationController(
      duration: const Duration(milliseconds: 220),
      vsync: this,
    );
    _chevronTurns = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    if (_isExpanded) {
      _animController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final isMobile = widget.isMobile;
    final washers = (state.availableWashers as List).cast<StaffMember>();
    final pool = state.teamCommissionPoolTodayETB as double;
    final weeklyPool = state.weeklyTotalCommissionPool as double;
    final dividends = state.washerDividendsToday as Map<String, dynamic>;
    final isCashier = widget.role == WasherHubRole.cashier;

    // Week calculation for Accountant / Admin matrix
    final now = DateTime.now().subtract(Duration(days: _selectedWeekOffset * 7));
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final weekDays = List.generate(7, (i) => monday.add(Duration(days: i)));
    final List<String> dayLabels = [
      state.tr('monShort') as String,
      state.tr('tueShort') as String,
      state.tr('wedShort') as String,
      state.tr('thuShort') as String,
      state.tr('friShort') as String,
      state.tr('satShort') as String,
      state.tr('sunShort') as String,
    ];

    final isWeeklyPaid = state.isWeeklyCommissionPaid(_selectedWeekOffset) as bool;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isExpanded
              ? AppColors.oromiaGold.withOpacity(0.55)
              : AppColors.oromiaGold.withOpacity(0.35),
          width: _isExpanded ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.oromiaGold.withOpacity(_isExpanded ? 0.08 : 0.03),
            blurRadius: _isExpanded ? 12 : 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Unified Card Header (Clickable to Expand / Collapse)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _toggleExpanded,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      // Gradient Trophy / Stars Badge
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.oromiaGold, AppColors.oromiaGold.withOpacity(0.8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.oromiaGold.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.stars_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),

                      // Title & Subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isCashier
                                  ? state.tr('dailyWasherCommissionPool')
                                  : (widget.role == WasherHubRole.admin
                                      ? state.tr('adminWasherHubTitle')
                                      : state.tr('weeklyPayrollMatrix')),
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${state.presentWashersCount} of ${state.totalWashersCount} ${state.tr("onDutyWashers")} • 15% Pool',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Pool Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.oromiaGold.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.oromiaGold.withOpacity(0.3)),
                        ),
                        child: Text(
                          CurrencyFormatter.format(isCashier ? pool : weeklyPool),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            color: AppColors.oromiaGold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Rotating Chevron
                      RotationTransition(
                        turns: _chevronTurns,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: _isExpanded
                                ? AppColors.primary.withOpacity(0.1)
                                : AppColors.surfaceVariant,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: _isExpanded ? AppColors.primary : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 2. Action Toolbar (Always accessible on collapsed/expanded or inside header)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (isCashier) ...[
                    // Button to disburse & report daily commission to accountant & admin
                    ElevatedButton.icon(
                      onPressed: (pool > 0 && !state.isDailyCommissionDisbursedToday)
                          ? () => _showDisburseDailyDialog(context, state, pool, state.presentWashersCount)
                          : null,
                      icon: Icon(
                        state.isDailyCommissionDisbursedToday
                            ? Icons.check_circle_rounded
                            : Icons.send_rounded,
                        size: 14,
                      ),
                      label: Text(
                        state.isDailyCommissionDisbursedToday
                            ? state.tr('disbursedToday')
                            : state.tr('disburseAndReportDailyCommission'),
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: state.isDailyCommissionDisbursedToday
                            ? Colors.grey.shade400
                            : AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        elevation: 0,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => WeeklyCommissionReportDialog.show(context),
                      icon: const Icon(Icons.assignment_turned_in_rounded, size: 14),
                      label: Text(
                        state.tr('reportWeeklyCommission'),
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.statusCompleted,
                        side: const BorderSide(color: AppColors.statusCompleted),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.done_all_rounded, size: 14),
                      label: Text(state.tr('markAllPresent'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                      onPressed: () {
                        state.markAllWashersPresent();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.tr('markAllPresent')),
                            backgroundColor: AppColors.statusCompleted,
                          ),
                        );
                      },
                    ),
                  ] else ...[
                    // Button in Accountant/Admin Dashboard to confirm & mark weekly commission paid
                    ElevatedButton.icon(
                      onPressed: (!isWeeklyPaid && weeklyPool > 0)
                          ? () => _showConfirmWeeklyPaidDialog(context, state, weeklyPool, washers.length)
                          : null,
                      icon: Icon(
                        isWeeklyPaid ? Icons.verified_rounded : Icons.payments_rounded,
                        size: 15,
                        color: isWeeklyPaid ? Colors.green.shade800 : Colors.white,
                      ),
                      label: Text(
                        isWeeklyPaid
                            ? state.tr('weeklyCommissionPaidAndConfirmed')
                            : state.tr('confirmWeeklyCommissionPaid'),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 11.5,
                          color: isWeeklyPaid ? Colors.green.shade900 : Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isWeeklyPaid ? Colors.green.shade100 : AppColors.statusCompleted,
                        disabledBackgroundColor: Colors.green.shade100,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        elevation: 0,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // 3. Status Bar: Present / Absent / Total
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      decoration: BoxDecoration(
                        color: AppColors.statusCompleted.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.statusCompleted.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle, color: AppColors.statusCompleted, size: 13),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${state.presentWashersCount} Present',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: AppColors.statusCompleted),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 13),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${state.totalWashersCount - state.presentWashersCount} Absent',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Colors.redAccent),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.groups_rounded, color: AppColors.textSecondary, size: 13),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${state.totalWashersCount} Total',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: AppColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // 4. Animated Expandable Content Body
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity, height: 0),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Divider(height: 1, color: AppColors.cardBorder),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: isCashier
                        ? _buildCashierExpandedContent(context, state, washers, dividends, pool)
                        : (widget.role == WasherHubRole.admin
                            ? _buildAdminExpandedContent(
                                context,
                                state,
                                washers,
                                dividends,
                                pool,
                                weeklyPool,
                                weekDays,
                                dayLabels,
                                isMobile,
                              )
                            : _buildAccountantExpandedContent(
                                context,
                                state,
                                washers,
                                weeklyPool,
                                weekDays,
                                dayLabels,
                                isMobile,
                              )),
                  ),
                ],
              ),
              crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 220),
            ),
          ],
        ),
      ),
    );
  }

  // --- CASHIER EXPANDED VIEW ---
  Widget _buildCashierExpandedContent(
    BuildContext context,
    dynamic state,
    List<StaffMember> washers,
    Map<String, dynamic> dividends,
    double pool,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Absent Washer Protection Notice
        Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.06),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              const Icon(Icons.shield_outlined, size: 14, color: Colors.blue),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  state.tr('absentWashersProtection'),
                  style: const TextStyle(fontSize: 10.5, color: Colors.blueGrey, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),

        // Dividends breakdown list (if any)
        if (dividends.isNotEmpty) ...[
          Text(
            state.tr('assignedCommissionShare'),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          ...dividends.values.map((div) {
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          div.isPresent ? Icons.check_circle_rounded : Icons.cancel_rounded,
                          size: 13,
                          color: div.isPresent ? AppColors.statusCompleted : Colors.red,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            div.washerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: div.isPresent ? FontWeight.w700 : FontWeight.w500,
                              color: div.isPresent ? AppColors.textPrimary : AppColors.textMuted,
                            ),
                          ),
                        ),
                        if (div.customTierName != null && div.customTierName!.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                            child: Text(
                              div.customTierName!,
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
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
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: div.isPresent ? AppColors.oromiaGold : Colors.red,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 10),
        ],

        // 8 Washers Attendance Toggle List
        Text(
          '${state.tr("attendanceDesk")} (${washers.length} Washers)',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 6),
        ...washers.map((w) {
          final isPresent = state.isWasherPresentToday(w.id);

          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isPresent ? AppColors.statusCompleted.withOpacity(0.35) : Colors.red.withOpacity(0.25),
                width: 1.1,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: isPresent ? AppColors.statusCompleted.withOpacity(0.12) : Colors.red.withOpacity(0.12),
                  child: Text(
                    w.name.isNotEmpty ? w.name[0] : 'W',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12.5,
                      color: isPresent ? AppColors.statusCompleted : Colors.red,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              w.name,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textPrimary),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: isPresent ? AppColors.statusCompleted.withOpacity(0.12) : Colors.red.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isPresent ? state.tr('onDutyBadge') : state.tr('absentBadge'),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: isPresent ? AppColors.statusCompleted : Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Base: ${(w.commissionRate * 100).toStringAsFixed(1)}% • Earned: ${isPresent && dividends[w.id] != null ? CurrencyFormatter.format(dividends[w.id]!.earnedETB) : "0 ETB"} • ${w.phone}',
                        style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: isPresent,
                  activeColor: AppColors.statusCompleted,
                  onChanged: (val) {
                    state.setWasherAttendance(w.id, val);
                  },
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // --- ADMIN EXPANDED VIEW (TOGGLE BETWEEN 7-DAY MATRIX & LIVE SHIFT ROSTER) ---
  Widget _buildAdminExpandedContent(
    BuildContext context,
    dynamic state,
    List<StaffMember> washers,
    Map<String, dynamic> dividends,
    double pool,
    double weeklyPool,
    List<DateTime> weekDays,
    List<String> dayLabels,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: Center(
                    child: Text(
                      state.tr('sevenDayMatrix'),
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: !_adminShowLiveRoster ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  selected: !_adminShowLiveRoster,
                  selectedColor: AppColors.primary,
                  onSelected: (val) => setState(() => _adminShowLiveRoster = !val),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  label: Center(
                    child: Text(
                      state.tr('liveRosterAndSwitches'),
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: _adminShowLiveRoster ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  selected: _adminShowLiveRoster,
                  selectedColor: AppColors.primary,
                  onSelected: (val) => setState(() => _adminShowLiveRoster = val),
                ),
              ),
            ],
          ),
        ),
        if (_adminShowLiveRoster)
          _buildCashierExpandedContent(context, state, washers, dividends, pool)
        else
          _buildAccountantExpandedContent(
            context,
            state,
            washers,
            weeklyPool,
            weekDays,
            dayLabels,
            isMobile,
          ),
      ],
    );
  }

  // --- ACCOUNTANT / ADMIN EXPANDED VIEW ---
  Widget _buildAccountantExpandedContent(
    BuildContext context,
    dynamic state,
    List<StaffMember> washers,
    double weeklyPool,
    List<DateTime> weekDays,
    List<String> dayLabels,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Week Switcher Toolbar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.date_range_rounded, size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    _selectedWeekOffset == 0 ? 'Current Week' : '$_selectedWeekOffset Week Ago',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded, size: 20),
                  onPressed: () => setState(() => _selectedWeekOffset++),
                  tooltip: 'Previous Week',
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded, size: 20),
                  onPressed: _selectedWeekOffset > 0 ? () => setState(() => _selectedWeekOffset--) : null,
                  tooltip: 'Next Week',
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Always render 7-Day Matrix in Tabular Mon-Sun form (daily commission ETB or 'A' if absent)
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.surfaceVariant),
              columnSpacing: isMobile ? 10 : 14,
              horizontalMargin: 10,
              columns: [
                const DataColumn(label: Text('Washer', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5))),
                const DataColumn(label: Text('Tier', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5))),
                ...List.generate(
                  7,
                  (i) => DataColumn(
                    label: Text(
                      '${dayLabels[i]}\n${weekDays[i].day}/${weekDays[i].month}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10.5),
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    state.tr('weeklyTotalLabel'),
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5),
                  ),
                ),
              ],
              rows: washers.map((w) {
                final dailyValues = List.generate(7, (dayIdx) {
                  final dayDate = weekDays[dayIdx];
                  final isPresent = state.isWasherPresentOnDate(w.id, dayDate) as bool;
                  final earned = isPresent ? (state.getWasherCommissionForDate(w.id, dayDate) as double) : 0.0;
                  return (isPresent: isPresent, earned: earned);
                });
                final computedWeekSum = dailyValues.fold<double>(0.0, (sum, d) => sum + d.earned);
                final weeklyComm = (_selectedWeekOffset == 0 && computedWeekSum <= 0)
                    ? ((state.weeklyWasherCommissions as Map<String, double>)[w.name] ?? 0.0)
                    : computedWeekSum;

                return DataRow(
                  cells: [
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 11,
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: Text(w.name.isNotEmpty ? w.name[0] : 'W', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          ),
                          const SizedBox(width: 6),
                          Text(w.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11.5)),
                        ],
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(4)),
                        child: Text('T${w.skillSeniorityLevel}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.blue.shade900)),
                      ),
                    ),
                    // 7 Days (Mon-Sun): 'A' if absent, exact daily ETB commission if present
                    ...dailyValues.map((dayInfo) {
                      return DataCell(
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: !dayInfo.isPresent ? Colors.red.shade50 : Colors.green.shade50,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: !dayInfo.isPresent ? Colors.red.shade200 : Colors.green.shade200,
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              !dayInfo.isPresent ? 'A' : CurrencyFormatter.formatShort(dayInfo.earned),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: !dayInfo.isPresent ? Colors.red.shade800 : Colors.green.shade800,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    DataCell(Text(CurrencyFormatter.format(weeklyComm), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5, color: Colors.green))),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  void _showDisburseDailyDialog(BuildContext context, dynamic state, double pool, int washerCount) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.stars_rounded, color: AppColors.oromiaGold, size: 24),
            const SizedBox(width: 8),
            const Text('Disburse & Report Commission', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Text(
          'Confirm distribution of ${CurrencyFormatter.format(pool)} team commission dividends among the $washerCount washer(s) on duty today, and officially report it to the Accountant and Admin?',
          style: const TextStyle(fontSize: 12.5, height: 1.4),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await state.disburseAndReportDailyCommissionToAdmin(
                cashierName: state.activeStaffFullName ?? 'Cashier',
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.tr('dailyCommissionDisbursedReported')),
                  backgroundColor: AppColors.statusCompleted,
                ),
              );
            },
            child: const Text('Confirm & Report', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  void _showConfirmWeeklyPaidDialog(BuildContext context, dynamic state, double pool, int washerCount) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.verified_rounded, color: AppColors.statusCompleted, size: 24),
            const SizedBox(width: 8),
            const Text('Confirm Weekly Payout', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Text(
          'Confirm payout of ${CurrencyFormatter.format(pool)} in total weekly washer commissions across $washerCount washers? This will confirm and lock the weekly payout ledger.',
          style: const TextStyle(fontSize: 12.5, height: 1.4),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusCompleted,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await state.confirmWeeklyCommissionPaid(_selectedWeekOffset);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.tr('weeklyCommissionPaidSuccess')),
                  backgroundColor: AppColors.statusCompleted,
                ),
              );
            },
            child: const Text('Mark Paid & Confirmed', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}
