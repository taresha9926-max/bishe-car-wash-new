import 'package:flutter/material.dart';
import 'package:bishe_car_wash/core/constants/app_colors.dart';
import 'package:bishe_car_wash/core/localization/app_strings.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/service_tier_option.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_booking.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_status.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  // Booking Form State
  ServiceTierOption _selectedOption = ServiceTierOption.allOptions.first;
  final TextEditingController _plateController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  PaymentMethod _paymentMethod = PaymentMethod.telebirr;

  // Tracker State
  final TextEditingController _searchPlateController = TextEditingController();
  WashBooking? _trackedBooking;
  bool _hasSearched = false;

  @override
  void dispose() {
    _plateController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _searchPlateController.dispose();
    super.dispose();
  }

  void _submitBooking() async {
    final notifier = AppStateProvider.of(context);
    final plate = _plateController.text.trim();
    final phone = _phoneController.text.trim();

    if (plate.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Plate Number and Phone Number.')),
      );
      return;
    }

    final packages = notifier.packages;
    final package = packages.isNotEmpty ? packages.first : notifier.packages[0];

    final newBooking = WashBooking(
      id: 'BSH-${DateTime.now().millisecondsSinceEpoch % 100000}',
      customerName: 'Customer ($plate)',
      customerPhone: phone,
      serviceType: _selectedOption.serviceType,
      deliveryLocation: _locationController.text.isNotEmpty ? _locationController.text.trim() : null,
      carType: _selectedOption.carType,
      licensePlate: plate.toUpperCase(),
      package: package,
      status: WashStatus.pending,
      origin: BookingOrigin.onlineCustomer,
      payment: PaymentInfo(
        isPaid: false,
        method: _paymentMethod,
        amount: _selectedOption.defaultPrice,
      ),
      createdAt: DateTime.now(),
    );

    await notifier.createBooking(newBooking);

    setState(() {
      _searchPlateController.text = plate.toUpperCase();
      _trackedBooking = newBooking;
      _hasSearched = true;
      _plateController.clear();
      _phoneController.clear();
      _locationController.clear();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(notifier.tr('bookingSuccess')),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  void _searchBooking() {
    final notifier = AppStateProvider.of(context);
    final plate = _searchPlateController.text.trim();
    setState(() {
      _hasSearched = true;
      _trackedBooking = notifier.findBookingByPlate(plate);
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = AppStateProvider.of(context);
    final ahead = notifier.activeQueueCount;
    final waitMinutes = notifier.estimatedWaitMinutes;
    final arrival = notifier.recommendedArrivalTime;
    final arrivalStr =
        '${arrival.hour.toString().padLeft(2, '0')}:${arrival.minute.toString().padLeft(2, '0')}';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Real-Time Queue Insight Badge
              Card(
                color: AppColors.surface,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.speed_rounded, color: AppColors.primary, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notifier.tr('queueInsight'),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                _badgeItem(Icons.directions_car_rounded,
                                    '${notifier.tr('carsAhead')}: $ahead'),
                                _badgeItem(Icons.timer_outlined,
                                    '${notifier.tr('estimatedWait')}: $waitMinutes min'),
                                _badgeItem(Icons.schedule_rounded,
                                    '${notifier.tr('recommendedArrival')}: $arrivalStr'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Booking Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.add_task_rounded, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            notifier.tr('bookWash'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Compact Combined Dropdown
                      Text(
                        notifier.tr('selectServiceTier'),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<ServiceTierOption>(
                            isExpanded: true,
                            value: _selectedOption,
                            items: ServiceTierOption.allOptions.map((opt) {
                              return DropdownMenuItem(
                                value: opt,
                                child: Text(
                                  opt.label,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                ),
                              );
                            }).toList(),
                            onChanged: (opt) {
                              if (opt != null) setState(() => _selectedOption = opt);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // If Mobile Van: Bishoftu Address Input
                      if (_selectedOption.serviceType.name == 'mobile') ...[
                        TextField(
                          controller: _locationController,
                          decoration: InputDecoration(
                            labelText: 'Bishoftu Delivery Area / Landmark',
                            hintText: 'e.g. Lake Bishoftu Resort Corridor',
                            prefixIcon: const Icon(Icons.location_on_outlined),
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // License Plate & Phone Number
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _plateController,
                              textCapitalization: TextCapitalization.characters,
                              decoration: InputDecoration(
                                labelText: notifier.tr('licensePlate'),
                                hintText: '2-AA-A12345',
                                prefixIcon: const Icon(Icons.badge_outlined),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: notifier.tr('phoneNumber'),
                                hintText: '0911223344',
                                prefixIcon: const Icon(Icons.phone_outlined),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Payment Method Selector
                      Text(
                        notifier.tr('paymentMethod'),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _paymentRadio(PaymentMethod.telebirr, 'Telebirr', AppColors.telebirrBlue),
                          const SizedBox(width: 8),
                          _paymentRadio(PaymentMethod.cbeBirr, 'CBE Birr', AppColors.cbeBirrPurple),
                          const SizedBox(width: 8),
                          _paymentRadio(PaymentMethod.cash, 'Cash', AppColors.cashGreen),
                        ],
                      ),
                      const SizedBox(height: 18),

                      ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle_outline_rounded),
                        label: Text(
                          '${notifier.tr('confirmBooking')} (${_selectedOption.defaultPrice.toStringAsFixed(0)} ETB)',
                        ),
                        onPressed: _submitBooking,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Live Status Tracker Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.radar_rounded, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            notifier.tr('trackWash'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchPlateController,
                              textCapitalization: TextCapitalization.characters,
                              decoration: InputDecoration(
                                hintText: notifier.tr('searchPlate'),
                                prefixIcon: const Icon(Icons.search_rounded),
                              ),
                              onSubmitted: (_) => _searchBooking(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: _searchBooking,
                            child: Text(notifier.tr('search')),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Tracker Result
                      if (_trackedBooking != null) ...[
                        _buildTrackerStepper(_trackedBooking!),
                      ] else if (_hasSearched) ...[
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            notifier.tr('noActiveBooking'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badgeItem(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _paymentRadio(PaymentMethod method, String label, Color color) {
    final selected = _paymentMethod == method;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _paymentMethod = method),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.1) : Colors.white,
            border: Border.all(
              color: selected ? color : AppColors.cardBorder,
              width: selected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: selected ? color : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrackerStepper(WashBooking booking) {
    final notifier = AppStateProvider.of(context);
    final stages = [
      notifier.tr('statusQueued'),
      notifier.tr('statusInBay'),
      notifier.tr('statusDrying'),
      notifier.tr('statusCompleted'),
    ];

    int currentStep = 0;
    if (booking.status == WashStatus.pending || booking.status == WashStatus.confirmed) {
      currentStep = 0;
    } else if (booking.status == WashStatus.assignedToBay || booking.status == WashStatus.washing) {
      currentStep = 1;
    } else if (booking.status == WashStatus.drying) {
      currentStep = 2;
    } else if (booking.status == WashStatus.readyForPickup || booking.status == WashStatus.completed) {
      currentStep = 3;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Plate: ${booking.licensePlate}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Chip(
                label: Text(
                  booking.status.displayName,
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                backgroundColor: booking.status.color,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Stepper Circles
          Row(
            children: List.generate(stages.length, (idx) {
              final isPassed = idx <= currentStep;
              final isCurrent = idx == currentStep;
              return Expanded(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: isPassed ? AppColors.primary : Colors.grey.shade300,
                      child: Text(
                        '${idx + 1}',
                        style: TextStyle(
                          color: isPassed ? Colors.white : Colors.black54,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      stages[idx],
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        color: isCurrent ? AppColors.primary : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
