import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../utils/live_gps_helper.dart';
import '../utils/url_launcher_helper.dart';
import '../../features/booking_service/domain/models/service_type.dart';
import 'custom_text_field.dart';

/// Shared exact home/place address + live GPS coordinate locator card used for
/// At-Home Mobile Van & VIP Driver Pick-up/Return bookings across Customer, Cashier & Manager desks.
class ServiceLocationPickerCard extends StatefulWidget {
  final dynamic state;
  final ServiceType serviceType;
  final bool isCarpet;
  final String selectedArea;
  final ValueChanged<String> onAreaChanged;
  final TextEditingController addressController;
  final TextEditingController gpsController;

  const ServiceLocationPickerCard({
    super.key,
    required this.state,
    required this.serviceType,
    required this.isCarpet,
    required this.selectedArea,
    required this.onAreaChanged,
    required this.addressController,
    required this.gpsController,
  });

  @override
  State<ServiceLocationPickerCard> createState() => _ServiceLocationPickerCardState();
}

class _ServiceLocationPickerCardState extends State<ServiceLocationPickerCard> {
  bool _isLocatingGps = false;

  Future<void> _locateLiveGps() async {
    setState(() => _isLocatingGps = true);
    final coords = await LiveGpsHelper.getCurrentCoordinates();
    if (!mounted) return;
    setState(() => _isLocatingGps = false);
    if (coords != null && coords.isNotEmpty) {
      setState(() => widget.gpsController.text = coords);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFD97706),
          content: Text(widget.state.tr('gpsUnavailableMsg')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final hasGps = widget.gpsController.text.trim().isNotEmpty;
    final hasAddress = widget.addressController.text.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.isCarpet
                      ? state.tr('carpetPickUpLocation')
                      : (widget.serviceType == ServiceType.valetPickUp
                          ? state.tr('driverPickUpLocation')
                          : state.tr('locationArea')),
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            isExpanded: true,
            value: AppConstants.bishoftuAreas.contains(widget.selectedArea)
                ? widget.selectedArea
                : AppConstants.bishoftuAreas.first,
            decoration: InputDecoration(
              labelText: state.tr('locationArea'),
              filled: true,
              fillColor: AppColors.surfaceVariant,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            items: AppConstants.bishoftuAreas
                .map((area) => DropdownMenuItem(
                      value: area,
                      child: Text(area, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5)),
                    ))
                .toList(),
            onChanged: (val) {
              if (val != null) widget.onAreaChanged(val);
            },
          ),
          const SizedBox(height: 10),
          CustomTextField(
            controller: widget.addressController,
            label: state.tr('exactHomePlaceLabel'),
            hint: state.tr('exactHomePlaceHint'),
            prefixIcon: Icons.home_work_outlined,
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomTextField(
                  controller: widget.gpsController,
                  label: state.tr('gpsCoordinatesLabel'),
                  hint: '8.75230, 38.97850',
                  prefixIcon: Icons.gps_fixed_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: ElevatedButton.icon(
                  onPressed: _isLocatingGps ? null : _locateLiveGps,
                  icon: _isLocatingGps
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Icon(
                          hasGps ? Icons.check_circle_rounded : Icons.my_location_rounded,
                          size: 16,
                        ),
                  label: Text(
                    _isLocatingGps ? state.tr('liveGpsFetching') : state.tr('liveGpsLocatorBtn'),
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasGps ? AppColors.statusCompleted : AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
          if (hasGps || hasAddress) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  final query = hasGps
                      ? widget.gpsController.text.trim()
                      : '${widget.selectedArea}, ${widget.addressController.text.trim()}, Bishoftu, Ethiopia';
                  UrlLauncherHelper.openUrl(
                    'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}',
                  );
                },
                icon: const Icon(Icons.map_rounded, size: 15),
                label: Text(state.tr('openInMaps'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
