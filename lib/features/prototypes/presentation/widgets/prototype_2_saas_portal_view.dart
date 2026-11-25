import 'package:flutter/material.dart';
import 'package:bishe_car_wash/core/constants/app_colors.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/service_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_booking.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_package.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_status.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';
import 'package:bishe_car_wash/features/prototypes/domain/models/prototype_model_type.dart';
import 'prototype_live_ticket_view.dart';

/// Model 2: Modern SaaS dual-card portal.
/// Displays Live Station Telemetry alongside an Express Booking card.
class Prototype2SaasPortalView extends StatefulWidget {
  final ValueChanged<WashBooking>? onBookingComplete;
  final VoidCallback onOpenLounge;

  const Prototype2SaasPortalView({
    super.key,
    this.onBookingComplete,
    required this.onOpenLounge,
  });

  @override
  State<Prototype2SaasPortalView> createState() => _Prototype2SaasPortalViewState();
}

class _Prototype2SaasPortalViewState extends State<Prototype2SaasPortalView> {
  CarType _selectedCarType = CarType.automobile;
  WashPackage? _selectedPackage;
  final _plateController = TextEditingController(text: 'ET-9921');
  final _phoneController = TextEditingController(text: '0922334455');
  WashBooking? _submittedBooking;

  @override
  void dispose() {
    _plateController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    final state = AppStateProvider.read(context);
    final packages = state.packages;
    final pkg = _selectedPackage ?? (packages.isNotEmpty ? packages.first : null);
    if (pkg == null) return;

    final price = pkg.pricingByCarType[_selectedCarType] ?? 250.0;
    final booking = WashBooking(
      id: 'proto-portal-${DateTime.now().millisecondsSinceEpoch}',
      customerName: 'Online Driver',
      customerPhone: _phoneController.text.trim(),
      serviceType: ServiceType.walkInStation,
      carType: _selectedCarType,
      licensePlate: _plateController.text.trim().toUpperCase(),
      package: pkg,
      status: WashStatus.assignedToBay,
      payment: PaymentInfo(
        method: PaymentMethod.cash,
        amount: price,
      ),
      createdAt: DateTime.now(),
    );

    setState(() {
      _submittedBooking = booking;
    });

    widget.onBookingComplete?.call(booking);
  }

  @override
  Widget build(BuildContext context) {
    if (_submittedBooking != null) {
      return PrototypeLiveTicketView(
        booking: _submittedBooking!,
        onReset: () => setState(() => _submittedBooking = null),
        onOpenLounge: widget.onOpenLounge,
      );
    }

    final state = AppStateProvider.of(context);
    final lang = state.currentLang;
    final packages = state.packages;
    final activePkg = _selectedPackage ?? (packages.isNotEmpty ? packages.first : null);
    final calculatedPrice = activePkg?.pricingByCarType[_selectedCarType] ?? 0.0;

    const telemetry = StationTelemetrySnapshot(
      totalBays: 2,
      availableBays: 1,
      activeQueueCount: 2,
      estimatedWaitMinutes: 10,
      activeWashersCount: 4,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;

        final telemetryCard = Card(
          elevation: 0,
          color: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        state.tr('liveStationTelemetry'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF34D399)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, size: 8, color: Color(0xFF34D399)),
                          SizedBox(width: 6),
                          Text(
                            'LIVE PULSE',
                            style: TextStyle(
                              color: Color(0xFF34D399),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildTelemetryMetric(
                        label: state.tr('bayAvailability'),
                        value: '${telemetry.availableBays} / ${telemetry.totalBays} Open',
                        icon: Icons.local_car_wash_rounded,
                        color: Colors.tealAccent,
                      ),
                    ),
                    Expanded(
                      child: _buildTelemetryMetric(
                        label: state.tr('estWaitTime'),
                        value: '~${telemetry.estimatedWaitMinutes} mins',
                        icon: Icons.timer_outlined,
                        color: Colors.amberAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTelemetryMetric(
                        label: state.tr('activeQueue'),
                        value: '${telemetry.activeQueueCount} Vehicles',
                        icon: Icons.format_list_numbered_rounded,
                        color: Colors.lightBlueAccent,
                      ),
                    ),
                    Expanded(
                      child: _buildTelemetryMetric(
                        label: state.tr('staffOnDuty'),
                        value: '${telemetry.activeWashersCount} Washers',
                        icon: Icons.people_outline_rounded,
                        color: Colors.purpleAccent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );

        final bookingCard = Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.cardBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  state.tr('expressBookingPortal'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Vehicle Category Chips
                Text(
                  state.tr('vehicleCategory'),
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: CarType.values.map((type) {
                    final isSel = type == _selectedCarType;
                    return ChoiceChip(
                      label: Text(type.localizedName(lang)),
                      selected: isSel,
                      onSelected: (_) => setState(() => _selectedCarType = type),
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSel ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Package Dropdown
                Text(
                  state.tr('servicePackage'),
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<WashPackage>(
                      isExpanded: true,
                      value: activePkg,
                      items: packages.map((pkg) {
                        return DropdownMenuItem(
                          value: pkg,
                          child: Text(pkg.localizedName(lang)),
                        );
                      }).toList(),
                      onChanged: (pkg) => setState(() => _selectedPackage = pkg),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Plate & Phone Fields
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: const Key('portal_plate_input'),
                        controller: _plateController,
                        decoration: InputDecoration(
                          labelText: state.tr('licensePlate'),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        key: const Key('portal_phone_input'),
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: state.tr('customerPhone'),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Dynamic Price Calculation Banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        state.tr('calculatedTotal'),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${calculatedPrice.toStringAsFixed(0)} ETB',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    state.tr('confirmBookingBtn'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );

        if (isWide) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: telemetryCard),
                const SizedBox(width: 20),
                Expanded(flex: 6, child: bookingCard),
              ],
            ),
          );
        } else {
          // Mobile View: Booking Card prioritized above the fold per Nit 6
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                bookingCard,
                const SizedBox(height: 16),
                telemetryCard,
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildTelemetryMetric({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
