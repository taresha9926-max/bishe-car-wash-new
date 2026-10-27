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
  String? _pinnedGpsCoordinates;
  bool _isPinningGps = false;

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
        title: Text(state.tr('bookWashTitle')),
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
              Text(
                state.tr('selectServiceMode'),
                style: const TextStyle(
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
              Text(
                state.tr('servicePackages'),
                style: const TextStyle(
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
                                pkg.localizedName(state.currentLang),
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${pkg.durationMinutes} mins • ${pkg.localizedDescription(state.currentLang)}',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (isSelected && pkg.features.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                ...pkg.localizedFeatures(state.currentLang).map((f) => Padding(
                                  padding: const EdgeInsets.only(bottom: 2),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.check_circle_outline, size: 12, color: AppColors.primary),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          f,
                                          style: const TextStyle(fontSize: 10.5, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                              ],
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
              Text(
                state.tr('customerRole'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _nameController,
                label: state.tr('customerName'),
                hint: 'e.g. Girma Tadesse',
                prefixIcon: Icons.person_outline,
                validator: (val) => val == null || val.trim().isEmpty ? state.tr('enterName') : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _phoneController,
                label: state.tr('customerPhone'),
                hint: '+251 91 234 5678',
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_android,
                validator: (val) => val == null || val.length < 9 ? state.tr('enterValidPhone') : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _plateController,
                label: state.tr('licensePlate'),
                hint: 'e.g. 3-B78945 ET',
                prefixIcon: Icons.tag,
                validator: (val) => val == null || val.trim().isEmpty ? state.tr('enterPlate') : null,
              ),
              const SizedBox(height: 12),

              // Address field if At-Home Mobile Van
              if (_selectedServiceType == ServiceType.atHomeMobile) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.mobileVanColor.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.mobileVanColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: AppColors.mobileVanColor, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            state.tr('locationArea'),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedBishoftuArea,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        items: AppConstants.bishoftuAreas.map((area) {
                          return DropdownMenuItem(value: area, child: Text(area));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedBishoftuArea = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _addressController,
                        label: 'Street / Landmark',
                        hint: 'e.g. Near Asham Africa Resort, House 420',
                        prefixIcon: Icons.home,
                        validator: (val) {
                          if (_selectedServiceType == ServiceType.atHomeMobile && (val == null || val.trim().isEmpty)) {
                            return 'Please provide street / residence landmark in Bishoftu';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: _pinnedGpsCoordinates != null ? AppColors.statusCompleted : AppColors.primary,
                            ),
                            backgroundColor: _pinnedGpsCoordinates != null
                                ? AppColors.statusCompleted.withOpacity(0.08)
                                : Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: _isPinningGps
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Icon(
                                  _pinnedGpsCoordinates != null ? Icons.check_circle : Icons.my_location,
                                  color: _pinnedGpsCoordinates != null ? AppColors.statusCompleted : AppColors.primary,
                                  size: 18,
                                ),
                          label: Text(
                            _pinnedGpsCoordinates != null
                                ? '${state.tr("gpsLocationPinned")}: $_pinnedGpsCoordinates'
                                : state.tr('useGpsLocation'),
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: _pinnedGpsCoordinates != null ? AppColors.statusCompleted : AppColors.primary,
                            ),
                          ),
                          onPressed: _pinGpsLocation,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // 5. Payment Selection
              Text(
                state.tr('paymentMethod'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              _buildPaymentSelector(state),
              const SizedBox(height: 20),

              // Booking Order Summary Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedPackage?.localizedName(state.currentLang) ?? '',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        Text(
                          CurrencyFormatter.format(currentPrice),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white24, height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${state.tr("total")}:',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        Text(
                          CurrencyFormatter.format(currentPrice),
                          style: const TextStyle(color: AppColors.oromiaGold, fontWeight: FontWeight.w900, fontSize: 20),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              CustomButton(
                text: state.tr('bookNow'),
                isLoading: _isSubmitting,
                onPressed: _handleBookingSubmit,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentSelector(dynamic state) {
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
                    method.localizedName(state.currentLang),
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

  Future<void> _handleBookingSubmit() async {
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
        gpsCoordinates: _pinnedGpsCoordinates,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.statusCompleted,
            content: Text('${state.tr("bookingSuccess")} (#${booking.id})'),
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

  Future<void> _pinGpsLocation() async {
    setState(() => _isPinningGps = true);
    // Simulate high-precision Bishoftu GPS coordinate acquisition
    await Future.delayed(const Duration(milliseconds: 500));
    final randomOffset = (DateTime.now().millisecond % 50) / 10000.0;
    final lat = (8.7523 + randomOffset).toStringAsFixed(4);
    final lng = (38.9785 + randomOffset).toStringAsFixed(4);
    if (mounted) {
      setState(() {
        _pinnedGpsCoordinates = '$lat, $lng';
        _isPinningGps = false;
      });
    }
  }
}
