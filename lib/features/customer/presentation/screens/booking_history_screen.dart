import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/auto_care_assets.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';
import 'live_tracking_screen.dart';

class BookingHistoryScreen extends StatefulWidget {
  final bool? initialCarpetFilter;

  const BookingHistoryScreen({super.key, this.initialCarpetFilter});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  late bool _isCarpetTab;

  @override
  void initState() {
    super.initState();
    _isCarpetTab = widget.initialCarpetFilter ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final allBookings = state.bookings;
    final filteredBookings = allBookings.where((b) => b.isCarpet == _isCarpetTab).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(state.tr('historyTitle')),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          // Segmented Tabs: [ 🚗 My Car Washes ] | [ 🧼 My Carpet Cleanings ]
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _isCarpetTab = false),
                      borderRadius: BorderRadius.circular(9),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: !_isCarpetTab ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(9),
                          boxShadow: !_isCarpetTab
                              ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 4)]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.directions_car_rounded, size: 16, color: !_isCarpetTab ? Colors.white : AppColors.textSecondary),
                            const SizedBox(width: 6),
                            Text(
                              state.tr('myCarWashes'),
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: !_isCarpetTab ? Colors.white : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _isCarpetTab = true),
                      borderRadius: BorderRadius.circular(9),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: _isCarpetTab ? const Color(0xFF7C3AED) : Colors.transparent,
                          borderRadius: BorderRadius.circular(9),
                          boxShadow: _isCarpetTab
                              ? [BoxShadow(color: const Color(0xFF7C3AED).withOpacity(0.3), blurRadius: 4)]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.texture_rounded, size: 16, color: _isCarpetTab ? Colors.white : AppColors.textSecondary),
                            const SizedBox(width: 6),
                            Text(
                              state.tr('myCarpetCleanings'),
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: _isCarpetTab ? Colors.white : AppColors.textSecondary,
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

          // Orders List
          Expanded(
            child: filteredBookings.isEmpty
                ? Center(
                    child: Text(
                      _isCarpetTab ? state.tr('noCarpetsFound') : state.tr('noVehiclesFound'),
                      style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    itemCount: filteredBookings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final booking = filteredBookings[index];
                      final isCarpet = booking.isCarpet;

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LiveTrackingScreen(bookingId: booking.id),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AutoCareAssets.buildPhotoThumbnail(
                                imageUrl: isCarpet
                                    ? (booking.carpetType == 'type_b' ? AutoCareAssets.carpetTypeBUrl : AutoCareAssets.carpetTypeAUrl)
                                    : AutoCareAssets.getPackageImage(booking.package),
                                width: 52,
                                height: 52,
                                borderRadius: 12,
                                fallbackIcon: isCarpet ? Icons.texture_rounded : Icons.directions_car_rounded,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              booking.licensePlate,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: isCarpet ? const Color(0xFF7C3AED).withOpacity(0.12) : AppColors.surfaceVariant,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                isCarpet
                                                    ? (booking.carpetType == 'type_b' ? state.tr('carpetTypeB') : state.tr('carpetTypeA'))
                                                    : booking.carType.localizedName(state.currentLang),
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: isCarpet ? const Color(0xFF7C3AED) : AppColors.textSecondary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        StatusBadge(
                                          label: booking.status.localizedName(state.currentLang),
                                          color: booking.status.color,
                                          isSmall: true,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      isCarpet
                                          ? '${booking.carpetDimensions != null && booking.carpetDimensions!.isNotEmpty ? '${booking.carpetDimensions} m² • ' : ''}${booking.serviceType.localizedName(state.currentLang, isCarpet: true)}'
                                          : booking.package.localizedName(state.currentLang),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          DateFormatter.formatDate(booking.createdAt),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                        Text(
                                          CurrencyFormatter.format(booking.totalPrice),
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.primaryDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
