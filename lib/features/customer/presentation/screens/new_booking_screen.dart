import 'package:flutter/material.dart';
import 'package:bishe_car_wash/core/constants/app_colors.dart';
import 'package:bishe_car_wash/core/constants/app_constants.dart';
import 'package:bishe_car_wash/core/utils/currency_formatter.dart';
import 'package:bishe_car_wash/core/widgets/custom_button.dart';
import 'package:bishe_car_wash/core/widgets/custom_text_field.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/service_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_package.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';
import 'package:bishe_car_wash/features/customer/presentation/widgets/car_type_selector.dart';
import 'package:bishe_car_wash/features/customer/presentation/widgets/station_type_card.dart';
import 'package:bishe_car_wash/features/customer/presentation/screens/live_tracking_screen.dart';

class NewBookingScreen extends StatefulWidget {
  final ServiceType? initialServiceType;
  final CarType? initialCarType;
  final WashPackage? initialPackage;

  const NewBookingScreen({
    super.key,
    this.initialServiceType,
    this.initialCarType,
    this.initialPackage,
  });

  @override
  State<NewBookingScreen> createState() => _NewBookingScreenState();
}

class _NewBookingScreenState extends State<NewBookingScreen> {
  final _formKey = GlobalKey<FormState>();

  late ServiceType _selectedServiceType;
  late CarType _selectedCarType;
  WashPackage? _selectedPackage;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.telebirr;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController(text: '+251 9');
  final _plateController = TextEditingController();
  final _addressController = TextEditingController();
  String _selectedBishoftuArea = AppConstants.bishoftuAreas.first;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedServiceType = widget.initialServiceType ?? ServiceType.walkInStation;
    _selectedCarType = widget.initialCarType ?? CarType.automobile;
    _selectedPackage = widget.initialPackage;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _plateController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final packages = state.packages;
    if (_selectedPackage == null && packages.isNotEmpty) {
      _selectedPackage = packages.first;
    }

    final currentPrice = _selectedPackage?.getPriceFor(_selectedCarType) ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Car Wash'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Choose Service Mode (Walk-in Station vs At-Home Mobile)
              const Text(
                '1. Select Service Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              StationTypeCard(
                serviceType: ServiceType.walkInStation,
                isSelected: _selectedServiceType == ServiceType.walkInStation,
                availableCapacity: state.availableBaysCount,
                onTap: () {
                  setState(() {
                    _selectedServiceType = ServiceType.walkInStation;
                  });
                },
              ),
              const SizedBox(height: 10),
              StationTypeCard(
                serviceType: ServiceType.atHomeMobile,
                isSelected: _selectedServiceType == ServiceType.atHomeMobile,
                availableCapacity: state.isMobileVanAvailable ? 1 : 0,
                onTap: () {
                  setState(() {
                    _selectedServiceType = ServiceType.atHomeMobile;
                  });
                },
              ),
              const SizedBox(height: 22),

              // 2. Select Car Type (Automobile, Minibus, Truck)
              const Text(
                '2. Select Car Category',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              CarTypeSelector(
                selectedType: _selectedCarType,
                onSelected: (type) {
                  setState(() {
                    _selectedCarType = type;
                  });
                },
              ),
              const SizedBox(height: 22),

              // 3. Wash Package
              const Text(
                '3. Choose Wash Package',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              ...packages.map((pkg) {
                final isSelected = pkg.id == _selectedPackage?.id;
                final price = pkg.getPriceFor(_selectedCarType);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPackage = pkg;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withOpacity(0.06) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.cardBorder,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Radio<String>(
                          value: pkg.id,
                          groupValue: _selectedPackage?.id,
                          activeColor: AppColors.primary,
                          onChanged: (_) {
                            setState(() {
                              _selectedPackage = pkg;
                            });
                          },
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pkg.name,
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${pkg.durationMinutes} mins • ${pkg.description}',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          CurrencyFormatter.format(price),
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),

              // 4. Vehicle & Customer Details
              const Text(
                '4. Vehicle & Contact Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _nameController,
                label: 'Customer Full Name',
                hint: 'e.g. Girma Tadesse',
                prefixIcon: Icons.person_outline,
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _phoneController,
                label: 'Phone Number (Ethiopian Mobile)',
                hint: '+251 91 234 5678',
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_android,
                validator: (val) => val == null || val.length < 9 ? 'Please enter a valid phone number' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _plateController,
                label: 'License Plate Number',
                hint: 'e.g. ET-3-B48210 or 3-B12345',
                prefixIcon: Icons.badge_outlined,
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter license plate' : null,
              ),
              const SizedBox(height: 12),

              // If At-Home Mobile Service, ask for Bishoftu Area & Address
              if (_selectedServiceType == ServiceType.atHomeMobile) ...[
                const SizedBox(height: 6),
                const Text(
                  'Bishoftu Area / Neighborhood',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedBishoftuArea,
                      items: AppConstants.bishoftuAreas.map((area) {
                        return DropdownMenuItem<String>(
                          value: area,
                          child: Text(area, style: const TextStyle(fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedBishoftuArea = val;
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _addressController,
                  label: 'House / Compound / Street Address',
                  hint: 'e.g. Near Babogaya View Hotel, Compound #4',
                  prefixIcon: Icons.home_outlined,
                  maxLines: 2,
                  validator: (val) {
                    if (_selectedServiceType == ServiceType.atHomeMobile &&
                        (val == null || val.trim().isEmpty)) {
                      return 'Please provide street / residence location';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              // 5. Payment Preference
              const Text(
                '5. Payment Method Preference',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              _buildPaymentSelector(),
              const SizedBox(height: 24),

              // Booking Summary Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Service Type:', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        Text(
                          _selectedServiceType.displayName,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Car Category:', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        Text(
                          _selectedCarType.displayName,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Wash Package:', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        Text(
                          _selectedPackage?.name ?? '',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Service Fee:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          CurrencyFormatter.format(currentPrice),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              CustomButton(
                text: 'Confirm & Book Now',
                icon: Icons.check_circle_outline_rounded,
                isLoading: _isSubmitting,
                onPressed: () => _handleBookingSubmit(context),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentSelector() {
    return Column(
      children: [
        PaymentMethod.telebirr,
        PaymentMethod.cbeBirr,
        PaymentMethod.cash,
      ].map((method) {
        final isSelected = method == _selectedPaymentMethod;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedPaymentMethod = method;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? method.color.withOpacity(0.08) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? method.color : AppColors.cardBorder,
                width: isSelected ? 1.8 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(method.icon, color: method.color, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    method.displayName,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? method.color : AppColors.textPrimary,
                    ),
                  ),
                ),
                Radio<PaymentMethod>(
                  value: method,
                  groupValue: _selectedPaymentMethod,
                  activeColor: method.color,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedPaymentMethod = val;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _handleBookingSubmit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPackage == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final state = AppStateProvider.read(context);

      String? fullAddress;
      if (_selectedServiceType == ServiceType.atHomeMobile) {
        fullAddress = '$_selectedBishoftuArea - ${_addressController.text.trim()}';
      }

      final booking = await state.bookNewWash(
        customerName: _nameController.text.trim(),
        customerPhone: _phoneController.text.trim(),
        serviceType: _selectedServiceType,
        carType: _selectedCarType,
        licensePlate: _plateController.text.trim(),
        package: _selectedPackage!,
        deliveryLocation: fullAddress,
        paymentMethod: _selectedPaymentMethod,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.statusCompleted,
            content: Text('Booking #${booking.id} created successfully!'),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => LiveTrackingScreen(bookingId: booking.id),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text('Failed to create booking: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
