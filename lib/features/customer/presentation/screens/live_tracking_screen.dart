import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../booking_service/domain/models/wash_booking.dart';
import '../../../booking_service/domain/models/wash_status.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';
import '../widgets/live_wash_stepper.dart';

class LiveTrackingScreen extends StatefulWidget {
  final String? bookingId;

  const LiveTrackingScreen({
    super.key,
    this.bookingId,
  });

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _queriedBookingId;
  bool _showSearchHeader = false;

  @override
  void initState() {
    super.initState();
    _queriedBookingId = widget.bookingId;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(dynamic state) {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    final found = state.findBookingByPhoneOrPlate(query);
    if (found != null) {
      setState(() {
        _queriedBookingId = found.id;
        _showSearchHeader = false;
      });
      state.setActiveTrackingBooking(found.id);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primaryDark,
          content: Text(state.tr('noActiveWashFound')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final activeId = _queriedBookingId ?? state.activeTrackingBookingId;
    WashBooking? booking;
    if (activeId != null) {
      try {
        booking = state.bookings.firstWhere((b) => b.id == activeId);
      } catch (_) {}
    }

    if (booking == null) {
      return Scaffold(
        appBar: AppBar(title: Text(state.tr('liveTrackingTitle'))),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.radar_rounded, size: 48, color: AppColors.primary),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.tr('trackMyCar'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    state.tr('trackVehiclePrompt'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _searchController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: state.tr('plateOrPhoneHint'),
                      prefixIcon: const Icon(Icons.directions_car_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onSubmitted: (_) => _performSearch(state),
                  ),
                  const SizedBox(height: 14),
                  CustomButton(
                    text: state.tr('trackNow'),
                    icon: Icons.search,
                    onPressed: () => _performSearch(state),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(state.tr('back')),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${state.tr("liveTrackingTitle")} • ${booking.licensePlate}'),
        actions: [
          IconButton(
            icon: Icon(_showSearchHeader ? Icons.close : Icons.search_rounded),
            tooltip: state.tr('trackAnother'),
            onPressed: () {
              setState(() => _showSearchHeader = !_showSearchHeader);
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => state.loadData(),
            tooltip: state.tr('refresh'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_showSearchHeader) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          hintText: state.tr('plateOrPhoneHint'),
                          hintStyle: const TextStyle(fontSize: 12),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onSubmitted: (_) => _performSearch(state),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _performSearch(state),
                      child: Text(state.tr('trackNow'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
            // Status Header Card
            _buildStatusHeaderCard(context, state, booking),
            const SizedBox(height: 16),

            // Vehicle & Bay Assignment Card
            _buildVehicleDetailsCard(context, state, booking),
            const SizedBox(height: 20),

            // Visual Live Progress Stepper
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.timeline, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        state.tr('activeWashTitle'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${booking.licensePlate} • ${booking.package.localizedName(state.currentLang)}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  LiveWashStepper(currentStatus: booking.status),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Payment & Bill Summary
            _buildPaymentCard(context, state, booking),
            const SizedBox(height: 20),

            // Facility Contact Assistance
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.support_agent_rounded, size: 28, color: AppColors.primary),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bishoftu Station Desk: +251 91 123 4567',
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'Open daily 7:00 AM - 8:00 PM',
                          style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.phone, color: AppColors.primary),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeaderCard(BuildContext context, dynamic state, WashBooking booking) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            booking.status.color.withOpacity(0.9),
            booking.status.color,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: booking.status.color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'BOOKING #${booking.id}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(booking.status.icon, size: 14, color: booking.status.color),
                    const SizedBox(width: 4),
                    Text(
                      booking.status.localizedName(state.currentLang),
                      style: TextStyle(
                        color: booking.status.color,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            booking.status.localizedName(state.currentLang),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${booking.licensePlate} • ${booking.package.localizedName(state.currentLang)}',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white70,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleDetailsCard(BuildContext context, dynamic state, WashBooking booking) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(booking.carType.icon, size: 28, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.licensePlate,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${booking.carType.localizedName(state.currentLang)} • ${booking.package.localizedName(state.currentLang)}',
                      style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildDetailSubItem(
                  icon: Icons.garage_rounded,
                  label: state.tr('bay'),
                  value: booking.assignedBay != null
                      ? booking.assignedBay!.localizedName(state.currentLang)
                      : state.tr('pending'),
                  color: booking.assignedBay != null ? booking.assignedBay!.color : AppColors.textMuted,
                ),
              ),
              Container(width: 1, height: 38, color: AppColors.cardBorder),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: _buildDetailSubItem(
                    icon: Icons.badge_outlined,
                    label: state.tr('washer'),
                    value: booking.assignedWasherName ?? state.tr('assignedTeam'),
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          if (booking.deliveryLocation != null) ...[
            const Divider(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, size: 16, color: AppColors.mobileVanColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${state.tr("locationArea")}: ${booking.deliveryLocation}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailSubItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.textMuted),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color),
        ),
      ],
    );
  }

  Widget _buildPaymentCard(BuildContext context, dynamic state, WashBooking booking) {
    final payment = booking.payment;
    final isPaid = payment.isPaid;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                state.tr('paymentMethod'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              StatusBadge(
                label: isPaid ? 'PAID' : 'PENDING',
                color: isPaid ? AppColors.statusReady : AppColors.statusPending,
                icon: isPaid ? Icons.check_circle : Icons.pending,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                booking.package.localizedName(state.currentLang),
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              Text(
                CurrencyFormatter.format(booking.totalPrice),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                state.tr('paymentMethod'),
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              Row(
                children: [
                  Icon(payment.method.icon, size: 14, color: payment.method.color),
                  const SizedBox(width: 4),
                  Text(
                    payment.method.localizedName(state.currentLang),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: payment.method.color,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (payment.transactionRef != null) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(state.tr('transactionRef'), style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                Text(
                  payment.transactionRef!,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
