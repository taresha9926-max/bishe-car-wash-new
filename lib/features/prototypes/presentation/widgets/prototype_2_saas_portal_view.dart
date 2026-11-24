import 'package:flutter/material.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/service_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_booking.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_package.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_status.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';
import 'package:bishe_car_wash/features/prototypes/domain/models/prototype_model_type.dart';
import 'prototype_live_ticket_view.dart';

/// Model 2: SaaS dual-card portal.
/// Apple Style 2: Pro Space Titanium (#161617 / #1D1D1F) with Electric Blue (#2997FF).
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

    // Apple Style 2 Tokens: Pro Space Titanium
    const proCanvas = Color(0xFF161617);
    const proCardBg = Color(0xFF1D1D1F);
    const proTileSurface = Color(0xFF272729);
    const proHairline = Color(0xFF333336);
    const proElectricBlue = Color(0xFF2997FF);
    const proTextWhite = Color(0xFFF5F5F7);
    const proMuted = Color(0xFF86868B);

    const telemetry = StationTelemetrySnapshot(
      totalBays: 2,
      availableBays: 1,
      activeQueueCount: 2,
      estimatedWaitMinutes: 10,
      activeWashersCount: 4,
    );

    return Container(
      color: proCanvas,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 720;

          final telemetryCard = Container(
            decoration: BoxDecoration(
              color: proCardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: proHairline),
            ),
            padding: const EdgeInsets.all(22),
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
                          color: proTextWhite,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: proElectricBlue.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: const Text(
                        'Bishoftu Hub',
                        style: TextStyle(
                          color: proElectricBlue,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: _buildTelemetryMetric(
                        label: state.tr('bayAvailability'),
                        value: '${telemetry.availableBays} / ${telemetry.totalBays} Open',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTelemetryMetric(
                        label: state.tr('estWaitTime'),
                        value: '~${telemetry.estimatedWaitMinutes} min',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _buildTelemetryMetric(
                        label: state.tr('activeQueue'),
                        value: '${telemetry.activeQueueCount} in line',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTelemetryMetric(
                        label: state.tr('staffOnDuty'),
                        value: '${telemetry.activeWashersCount} Washers',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );

          final bookingCard = Container(
            decoration: BoxDecoration(
              color: proCardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: proHairline),
            ),
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  state.tr('expressBookingPortal'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                    color: proTextWhite,
                  ),
                ),
                const SizedBox(height: 18),

                // Vehicle Category Chips
                Text(
                  state.tr('vehicleCategory'),
                  style: const TextStyle(fontSize: 13, color: proMuted, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: CarType.values.map((type) {
                    final isSel = type == _selectedCarType;
                    return InkWell(
                      onTap: () => setState(() => _selectedCarType = type),
                      borderRadius: BorderRadius.circular(9999),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSel ? proElectricBlue : proTileSurface,
                          borderRadius: BorderRadius.circular(9999),
                          border: Border.all(
                            color: isSel ? proElectricBlue : proHairline,
                          ),
                        ),
                        child: Text(
                          type.localizedName(lang),
                          style: TextStyle(
                            color: isSel ? Colors.white : proTextWhite,
                            fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),

                // Package Dropdown
                Text(
                  state.tr('servicePackage'),
                  style: const TextStyle(fontSize: 13, color: proMuted, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: proTileSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: proHairline),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<WashPackage>(
                      isExpanded: true,
                      dropdownColor: proCardBg,
                      value: activePkg,
                      items: packages.map((pkg) {
                        return DropdownMenuItem(
                          value: pkg,
                          child: Text(
                            pkg.localizedName(lang),
                            style: const TextStyle(color: proTextWhite, fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (pkg) => setState(() => _selectedPackage = pkg),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Responsive Plate & Phone (Stacks on narrow screens to eliminate out-of-bounds overflow)
                LayoutBuilder(
                  builder: (context, fieldConstraints) {
                    final stackFields = fieldConstraints.maxWidth < 360;
                    final plateField = TextField(
                      key: const Key('portal_plate_input'),
                      controller: _plateController,
                      style: const TextStyle(color: proTextWhite, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        labelText: state.tr('licensePlate'),
                        labelStyle: const TextStyle(color: proMuted, fontSize: 13),
                        filled: true,
                        fillColor: proTileSurface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: proHairline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: proHairline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: proElectricBlue, width: 1.5),
                        ),
                        prefixIcon: const Icon(Icons.pin_rounded, color: proMuted, size: 20),
                        isDense: true,
                      ),
                    );

                    final phoneField = TextField(
                      key: const Key('portal_phone_input'),
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: proTextWhite, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        labelText: state.tr('customerPhone'),
                        labelStyle: const TextStyle(color: proMuted, fontSize: 13),
                        filled: true,
                        fillColor: proTileSurface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: proHairline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: proHairline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: proElectricBlue, width: 1.5),
                        ),
                        prefixIcon: const Icon(Icons.phone_rounded, color: proMuted, size: 20),
                        isDense: true,
                      ),
                    );

                    if (stackFields) {
                      return Column(
                        children: [
                          plateField,
                          const SizedBox(height: 12),
                          phoneField,
                        ],
                      );
                    } else {
                      return Row(
                        children: [
                          Expanded(child: plateField),
                          const SizedBox(width: 12),
                          Expanded(child: phoneField),
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),

                // Calculated Price Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: proTileSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: proHairline),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          state.tr('calculatedTotal'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: proMuted,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${calculatedPrice.toStringAsFixed(0)} ETB',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: proElectricBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: proElectricBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: const StadiumBorder(),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      state.tr('confirmBookingBtn'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
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
            // Mobile View: Booking Card prioritized above the fold
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
      ),
    );
  }

  Widget _buildTelemetryMetric({
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFF5F5F7),
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF86868B),
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
