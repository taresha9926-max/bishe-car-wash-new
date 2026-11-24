import 'package:flutter/material.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/service_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_booking.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_package.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_status.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';
import 'prototype_live_ticket_view.dart';

/// Model 1: Progressive 3-step linear wizard.
/// Apple Style 1: Studio White & Action Blue (#0071E3) on Canvas Parchment (#F5F5F7).
class Prototype1StepperView extends StatefulWidget {
  final ValueChanged<WashBooking>? onBookingComplete;
  final VoidCallback onOpenLounge;

  const Prototype1StepperView({
    super.key,
    this.onBookingComplete,
    required this.onOpenLounge,
  });

  @override
  State<Prototype1StepperView> createState() => _Prototype1StepperViewState();
}

class _Prototype1StepperViewState extends State<Prototype1StepperView> {
  int _currentStep = 0;
  CarType _selectedCarType = CarType.automobile;
  WashPackage? _selectedPackage;
  final _plateController = TextEditingController(text: 'A12345');
  final _phoneController = TextEditingController(text: '0911223344');
  WashBooking? _submittedBooking;

  @override
  void dispose() {
    _plateController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() async {
    final state = AppStateProvider.read(context);
    final packages = state.packages;
    final pkg = _selectedPackage ?? (packages.isNotEmpty ? packages.first : null);
    if (pkg == null) return;

    final price = pkg.pricingByCarType[_selectedCarType] ?? 250.0;
    final booking = WashBooking(
      id: 'proto-step-${DateTime.now().millisecondsSinceEpoch}',
      customerName: 'Guest Driver',
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
        onReset: () => setState(() {
          _submittedBooking = null;
          _currentStep = 0;
        }),
        onOpenLounge: widget.onOpenLounge,
      );
    }

    final state = AppStateProvider.of(context);
    final lang = state.currentLang;
    final packages = state.packages;

    // Apple Style 1 Tokens: Studio White & Action Blue
    const appleActionBlue = Color(0xFF0071E3);
    const appleInk = Color(0xFF1D1D1F);
    const appleMuted = Color(0xFF86868B);
    const appleHairline = Color(0xFFE5E5EA);

    return Container(
      color: const Color(0xFFF5F5F7), // Apple Canvas Parchment
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Apple-style Capsule Segmented Progress Track
            Row(
              children: List.generate(3, (index) {
                final isActive = index <= _currentStep;
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                    decoration: BoxDecoration(
                      color: isActive ? appleActionBlue : const Color(0xFFD2D2D7),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            if (_currentStep == 0) ...[
              Text(
                state.tr('step1ChooseVehicle'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.4,
                  color: appleInk,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                state.tr('step1ChooseVehicleSub'),
                style: const TextStyle(color: appleMuted, fontSize: 14, height: 1.3),
              ),
              const SizedBox(height: 20),
              ...CarType.values.map((type) {
                final isSelected = type == _selectedCarType;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => setState(() => _selectedCarType = type),
                    borderRadius: BorderRadius.circular(18),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFF0F7FF) : Colors.white,
                        border: Border.all(
                          color: isSelected ? appleActionBlue : appleHairline,
                          width: isSelected ? 1.8 : 1.0,
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            type.icon,
                            size: 28,
                            color: isSelected ? appleActionBlue : appleMuted,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  type.localizedName(lang),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                    color: appleInk,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  type.localizedSubLabel(lang),
                                  style: const TextStyle(color: appleMuted, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle_rounded, color: appleActionBlue, size: 22),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => setState(() => _currentStep = 1),
                style: ElevatedButton.styleFrom(
                  backgroundColor: appleActionBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const StadiumBorder(),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    state.tr('nextChoosePackageBtn'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ] else if (_currentStep == 1) ...[
              Text(
                state.tr('step2ChoosePackage'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.4,
                  color: appleInk,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                state.tr('step2ChoosePackageSub'),
                style: const TextStyle(color: appleMuted, fontSize: 14, height: 1.3),
              ),
              const SizedBox(height: 20),
              ...packages.map((pkg) {
                final isSelected = pkg.id == (_selectedPackage?.id ?? (packages.first.id));
                final price = pkg.pricingByCarType[_selectedCarType] ?? 0.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => setState(() => _selectedPackage = pkg),
                    borderRadius: BorderRadius.circular(18),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFF0F7FF) : Colors.white,
                        border: Border.all(
                          color: isSelected ? appleActionBlue : appleHairline,
                          width: isSelected ? 1.8 : 1.0,
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pkg.localizedName(lang),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                    color: appleInk,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  pkg.localizedDescription(lang),
                                  style: const TextStyle(color: appleMuted, fontSize: 13, height: 1.3),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${price.toStringAsFixed(0)} ETB',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? appleActionBlue : appleInk,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () => setState(() => _currentStep = 0),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: appleInk,
                      side: const BorderSide(color: Color(0xFFD2D2D7)),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 22),
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      state.tr('backBtn'),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => _currentStep = 2),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appleActionBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: const StadiumBorder(),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          state.tr('nextContactDetailsBtn'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Text(
                state.tr('step3ContactDetails'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.4,
                  color: appleInk,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                state.tr('step3ContactDetailsSub'),
                style: const TextStyle(color: appleMuted, fontSize: 14, height: 1.3),
              ),
              const SizedBox(height: 20),
              TextField(
                key: const Key('stepper_plate_input'),
                controller: _plateController,
                style: const TextStyle(color: appleInk, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  labelText: state.tr('licensePlate'),
                  labelStyle: const TextStyle(color: appleMuted),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: appleHairline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: appleHairline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: appleActionBlue, width: 1.5),
                  ),
                  prefixIcon: const Icon(Icons.pin_rounded, color: appleMuted),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                key: const Key('stepper_phone_input'),
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: appleInk, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  labelText: state.tr('customerPhone'),
                  labelStyle: const TextStyle(color: appleMuted),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: appleHairline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: appleHairline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: appleActionBlue, width: 1.5),
                  ),
                  prefixIcon: const Icon(Icons.phone_rounded, color: appleMuted),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () => setState(() => _currentStep = 1),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: appleInk,
                      side: const BorderSide(color: Color(0xFFD2D2D7)),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 22),
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      state.tr('backBtn'),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appleActionBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: const StadiumBorder(),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          state.tr('confirmAndDriveInBtn'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
