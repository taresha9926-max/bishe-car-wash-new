import 'package:flutter/material.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/service_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_booking.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_package.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_status.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';
import 'prototype_live_ticket_view.dart';

/// Model 3: Express Kiosk / Speed Intake (<15s booking).
/// Apple Style 3: Highland Sand & Action Amber (#D97706) on Warm Canvas (#FAF8F5).
class Prototype3ExpressKioskView extends StatefulWidget {
  final ValueChanged<WashBooking>? onBookingComplete;
  final VoidCallback onOpenLounge;

  const Prototype3ExpressKioskView({
    super.key,
    this.onBookingComplete,
    required this.onOpenLounge,
  });

  @override
  State<Prototype3ExpressKioskView> createState() => _Prototype3ExpressKioskViewState();
}

class _Prototype3ExpressKioskViewState extends State<Prototype3ExpressKioskView> {
  CarType _selectedCarType = CarType.automobile;
  WashPackage? _selectedPackage;
  final _plateController = TextEditingController(text: 'B99887');
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
      id: 'proto-kiosk-${DateTime.now().millisecondsSinceEpoch}',
      customerName: 'Express Driver',
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

    // Apple Style 3 Tokens: Highland Sand & Amber
    const sandCanvas = Color(0xFFFBF9F6);
    const sandCardBg = Colors.white;
    const sandInk = Color(0xFF1C1917); // Stone 900
    const sandMuted = Color(0xFF78716C); // Stone 500
    const sandHairline = Color(0xFFE7E2DA);
    const sandActionAmber = Color(0xFFD97706); // Apple Watch Ultra Amber
    const sandTileBg = Color(0xFFF5F2EB);

    return Container(
      color: sandCanvas,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Container(
              decoration: BoxDecoration(
                color: sandCardBg,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: sandHairline),
              ),
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    state.tr('expressWashIntakeTitle'),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.4,
                      color: sandInk,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.tr('expressWashIntakeSub'),
                    style: const TextStyle(color: sandMuted, fontSize: 13, height: 1.3),
                  ),
                  const SizedBox(height: 20),

                  // 2x2 Responsive Vehicle Grid (childAspectRatio 2.2 for generous breathing room)
                  Text(
                    state.tr('selectVehicle'),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: sandMuted),
                  ),
                  const SizedBox(height: 8),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 2.2, // Generous height to prevent multiline overflow in OM/AM
                    children: CarType.values.map((type) {
                      final isSel = type == _selectedCarType;
                      return InkWell(
                        onTap: () => setState(() => _selectedCarType = type),
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSel ? const Color(0xFFFFFBEB) : sandTileBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSel ? sandActionAmber : sandHairline,
                              width: isSel ? 1.8 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                type.icon,
                                size: 22,
                                color: isSel ? sandActionAmber : sandMuted,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  type.localizedName(lang),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: isSel ? FontWeight.w600 : FontWeight.w500,
                                    color: sandInk,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Chunky Tactile Package Cards
                  Text(
                    state.tr('selectPackage'),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: sandMuted),
                  ),
                  const SizedBox(height: 8),
                  ...packages.map((pkg) {
                    final isSel = pkg.id == (activePkg?.id);
                    final price = pkg.pricingByCarType[_selectedCarType] ?? 0.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () => setState(() => _selectedPackage = pkg),
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          constraints: const BoxConstraints(minHeight: 52),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSel ? const Color(0xFFFFFBEB) : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSel ? sandActionAmber : sandHairline,
                              width: isSel ? 1.8 : 1.0,
                            ),
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
                                        fontSize: 15,
                                        fontWeight: isSel ? FontWeight.w600 : FontWeight.w500,
                                        color: sandInk,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      pkg.localizedDescription(lang),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: sandMuted, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${price.toStringAsFixed(0)} ETB',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isSel ? sandActionAmber : sandInk,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 18),

                  // Quick Details (Responsive Layout for Plate & Phone)
                  LayoutBuilder(
                    builder: (context, inputConstraints) {
                      final stackInputs = inputConstraints.maxWidth < 360;
                      final plateInput = TextField(
                        key: const Key('kiosk_plate_input'),
                        controller: _plateController,
                        style: const TextStyle(fontWeight: FontWeight.w600, color: sandInk),
                        decoration: InputDecoration(
                          labelText: state.tr('licensePlate'),
                          labelStyle: const TextStyle(color: sandMuted, fontSize: 13),
                          filled: true,
                          fillColor: sandTileBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: sandHairline),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: sandHairline),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: sandActionAmber, width: 1.5),
                          ),
                          prefixIcon: const Icon(Icons.pin_rounded, color: sandMuted, size: 20),
                          isDense: true,
                        ),
                      );

                      final phoneInput = TextField(
                        key: const Key('kiosk_phone_input'),
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(fontWeight: FontWeight.w600, color: sandInk),
                        decoration: InputDecoration(
                          labelText: state.tr('customerPhone'),
                          labelStyle: const TextStyle(color: sandMuted, fontSize: 13),
                          filled: true,
                          fillColor: sandTileBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: sandHairline),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: sandHairline),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: sandActionAmber, width: 1.5),
                          ),
                          prefixIcon: const Icon(Icons.phone_rounded, color: sandMuted, size: 20),
                          isDense: true,
                        ),
                      );

                      if (stackInputs) {
                        return Column(
                          children: [
                            plateInput,
                            const SizedBox(height: 10),
                            phoneInput,
                          ],
                        );
                      } else {
                        return Row(
                          children: [
                            Expanded(child: plateInput),
                            const SizedBox(width: 10),
                            Expanded(child: phoneInput),
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 22),

                  // Full-width 56dp Apple Action Amber Pill CTA
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: sandActionAmber,
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                        elevation: 0,
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.flash_on_rounded, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              state.tr('instantBookAndDriveInBtn'),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${calculatedPrice.toStringAsFixed(0)} ETB)',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
