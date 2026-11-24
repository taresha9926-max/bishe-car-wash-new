import 'package:flutter/material.dart';
import 'package:bishe_car_wash/core/constants/app_colors.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/service_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_booking.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_package.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_status.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';
import 'prototype_live_ticket_view.dart';

/// Model 3: Express Kiosk / Speed Intake (<15s booking).
/// Ultra-compact single card with a 2x2 responsive vehicle grid and
/// 48dp tactile package cards for high-throughput gate operations.
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: const BorderSide(color: AppColors.cardBorder),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          state.tr('expressWashIntakeTitle'),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '< 15 SEC',
                          style: TextStyle(
                            color: Colors.amber.shade900,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 2x2 Responsive Vehicle Grid (Resolving Major 1: No pill clipping in OM/AM)
                  Text(
                    state.tr('selectVehicle'),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 2.8,
                    children: CarType.values.map((type) {
                      final isSel = type == _selectedCarType;
                      return InkWell(
                        onTap: () => setState(() => _selectedCarType = type),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSel ? AppColors.primary.withOpacity(0.08) : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSel ? AppColors.primary : AppColors.cardBorder,
                              width: isSel ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(type.icon, size: 20, color: isSel ? AppColors.primary : Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  type.localizedName(lang),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                                    color: isSel ? AppColors.primary : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Chunky Tactile Package Cards (48dp min targets, resolving Major 1)
                  Text(
                    state.tr('selectPackage'),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  ...packages.map((pkg) {
                    final isSel = pkg.id == (activePkg?.id);
                    final price = pkg.pricingByCarType[_selectedCarType] ?? 0.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () => setState(() => _selectedPackage = pkg),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 48),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSel ? AppColors.primary.withOpacity(0.08) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSel ? AppColors.primary : AppColors.cardBorder,
                              width: isSel ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  pkg.localizedName(lang),
                                  style: TextStyle(
                                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                    color: isSel ? AppColors.primary : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Text(
                                '${price.toStringAsFixed(0)} ETB',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSel ? AppColors.primary : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),

                  // License Plate & Phone
                  TextField(
                    key: const Key('kiosk_plate_input'),
                    controller: _plateController,
                    decoration: InputDecoration(
                      labelText: state.tr('licensePlate'),
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.pin_rounded, size: 20),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    key: const Key('kiosk_phone_input'),
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: state.tr('customerPhone'),
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.phone_rounded, size: 20),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Full-width 56dp CTA
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.flash_on_rounded, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              state.tr('instantBookAndDriveInBtn'),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${calculatedPrice.toStringAsFixed(0)} ETB)',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
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
