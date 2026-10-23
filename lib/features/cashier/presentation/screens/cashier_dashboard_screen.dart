import 'package:flutter/material.dart';
import 'package:bishe_car_wash/core/constants/app_colors.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/bay_station.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/service_tier_option.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_booking.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_status.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';

class CashierDashboardScreen extends StatefulWidget {
  const CashierDashboardScreen({super.key});

  @override
  State<CashierDashboardScreen> createState() => _CashierDashboardScreenState();
}

class _CashierDashboardScreenState extends State<CashierDashboardScreen> {
  // Direct Vehicle Entry Modal / Form
  void _openDirectEntryDialog(BuildContext context) {
    final notifier = AppStateProvider.of(context);
    final plateCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    BookingOrigin origin = BookingOrigin.walkIn;
    ServiceTierOption selectedTier = ServiceTierOption.allOptions.first;
    BayType targetBay = BayType.bay1;
    List<String> selectedWashers = ['Abebe', 'Chala']; // Enforce exactly 2 washers
    PaymentMethod paymentMethod = PaymentMethod.cash;

    final washersList = ['Abebe', 'Chala', 'Tolosa', 'Gemechu'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.app_registration_rounded, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(notifier.tr('registerVehicle')),
              ],
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 480,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Origin Toggle
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: Text(notifier.tr('walkIn')),
                            selected: origin == BookingOrigin.walkIn,
                            onSelected: (_) => setDialogState(() => origin = BookingOrigin.walkIn),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: Text(notifier.tr('phoneCall')),
                            selected: origin == BookingOrigin.phoneCall,
                            onSelected: (_) => setDialogState(() => origin = BookingOrigin.phoneCall),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Plate & Phone
                    TextField(
                      controller: plateCtrl,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        labelText: notifier.tr('licensePlate'),
                        prefixIcon: const Icon(Icons.badge_outlined),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: notifier.tr('phoneNumber'),
                        prefixIcon: const Icon(Icons.phone_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tier Selection
                    Text(notifier.tr('selectServiceTier'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<ServiceTierOption>(
                      value: selectedTier,
                      isExpanded: true,
                      decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                      items: ServiceTierOption.allOptions.map((opt) {
                        return DropdownMenuItem(value: opt, child: Text(opt.label, style: const TextStyle(fontSize: 13)));
                      }).toList(),
                      onChanged: (opt) {
                        if (opt != null) {
                          setDialogState(() {
                            selectedTier = opt;
                            if (opt.serviceType.name == 'mobile') {
                              targetBay = BayType.mobileVan;
                            }
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    // Bay Target Allocation
                    const Text('Bay Target Allocation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _bayChip(BayType.bay1, 'Bay 1', targetBay, (b) => setDialogState(() => targetBay = b)),
                        const SizedBox(width: 8),
                        _bayChip(BayType.bay2, 'Bay 2', targetBay, (b) => setDialogState(() => targetBay = b)),
                        const SizedBox(width: 8),
                        _bayChip(BayType.mobileVan, 'Mobile Van', targetBay, (b) => setDialogState(() => targetBay = b)),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Assigned Washers (Enforce exactly 2 out of 4)
                    Text(
                      '${notifier.tr('assignWashers')} (${selectedWashers.length}/2 selected):',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: selectedWashers.length == 2 ? AppColors.textPrimary : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: washersList.map((washer) {
                        final isSelected = selectedWashers.contains(washer);
                        return FilterChip(
                          label: Text(washer),
                          selected: isSelected,
                          onSelected: (selected) {
                            setDialogState(() {
                              if (selected) {
                                if (selectedWashers.length < 2) selectedWashers.add(washer);
                              } else {
                                selectedWashers.remove(washer);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Payment method
                    Text(notifier.tr('paymentMethod'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _paymentChip(PaymentMethod.cash, 'Cash', paymentMethod, (m) => setDialogState(() => paymentMethod = m)),
                        const SizedBox(width: 6),
                        _paymentChip(PaymentMethod.telebirr, 'Telebirr', paymentMethod, (m) => setDialogState(() => paymentMethod = m)),
                        const SizedBox(width: 6),
                        _paymentChip(PaymentMethod.cbeBirr, 'CBE Birr', paymentMethod, (m) => setDialogState(() => paymentMethod = m)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text(notifier.tr('cancel'))),
              ElevatedButton(
                onPressed: selectedWashers.length == 2 && plateCtrl.text.isNotEmpty && phoneCtrl.text.isNotEmpty
                    ? () async {
                        final packages = notifier.packages;
                        final package = packages.isNotEmpty ? packages.first : notifier.packages[0];

                        final newBooking = WashBooking(
                          id: 'BSH-${DateTime.now().millisecondsSinceEpoch % 100000}',
                          customerName: 'Gate (${plateCtrl.text.trim().toUpperCase()})',
                          customerPhone: phoneCtrl.text.trim(),
                          serviceType: selectedTier.serviceType,
                          carType: selectedTier.carType,
                          licensePlate: plateCtrl.text.trim().toUpperCase(),
                          package: package,
                          status: WashStatus.washing,
                          assignedBay: targetBay,
                          assignedWasherNames: List.from(selectedWashers),
                          origin: origin,
                          payment: PaymentInfo(
                            isPaid: true,
                            method: paymentMethod,
                            amount: selectedTier.defaultPrice,
                          ),
                          createdAt: DateTime.now(),
                        );

                        await notifier.createBooking(newBooking);
                        await notifier.assignBayAndWashers(
                          bookingId: newBooking.id,
                          bay: targetBay,
                          washerNames: selectedWashers,
                        );

                        if (context.mounted) Navigator.pop(ctx);
                      }
                    : null,
                child: const Text('Save & Assign'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _bayChip(BayType type, String label, BayType selected, Function(BayType) onSelect) {
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: selected == type,
      onSelected: (_) => onSelect(type),
    );
  }

  Widget _paymentChip(PaymentMethod method, String label, PaymentMethod selected, Function(PaymentMethod) onSelect) {
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: selected == method,
      onSelected: (_) => onSelect(method),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifier = AppStateProvider.of(context);
    final bays = notifier.bays;
    final allBookings = notifier.bookings;

    final activeQueue = allBookings
        .where((b) =>
            b.status == WashStatus.pending ||
            b.status == WashStatus.confirmed ||
            b.status == WashStatus.assignedToBay ||
            b.status == WashStatus.washing ||
            b.status == WashStatus.drying ||
            b.status == WashStatus.readyForPickup)
        .toList();

    final phoneQueue = activeQueue.where((b) => b.origin == BookingOrigin.phoneCall).toList();
    final completedToday = allBookings.where((b) => b.status == WashStatus.completed).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header + Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                notifier.tr('cashierDashboard'),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_circle_outline_rounded),
                label: Text(notifier.tr('registerVehicle')),
                onPressed: () => _openDirectEntryDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 1. Live Bay Status Bar (Bay 1, Bay 2, Mobile Van)
          Text(notifier.tr('activeBays'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildBayCard(context, BayType.bay1, notifier.tr('bay1'), bays)),
              const SizedBox(width: 10),
              Expanded(child: _buildBayCard(context, BayType.bay2, notifier.tr('bay2'), bays)),
              const SizedBox(width: 10),
              Expanded(child: _buildBayCard(context, BayType.mobileVan, notifier.tr('mobileVan'), bays)),
            ],
          ),
          const SizedBox(height: 24),

          // 2. Phone Call Reservation Section
          if (phoneQueue.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.phone_in_talk_rounded, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Text(notifier.tr('phoneQueue'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...phoneQueue.map((b) => _buildQueueTile(context, b)),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // 3. Active Queue & Station Management
          Text(
            'Active Station Queue (${activeQueue.length})',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          if (activeQueue.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'No vehicles currently in queue or washing.',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              ),
            )
          else
            ...activeQueue.map((b) => _buildQueueTile(context, b)),

          const SizedBox(height: 24),

          // 4. Completed Today Log
          Text(
            '${notifier.tr('completedToday')} (${completedToday.length})',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ...completedToday.take(5).map((b) => _buildCompletedTile(context, b)),
        ],
      ),
    );
  }

  Widget _buildBayCard(BuildContext context, BayType type, String title, List<StationBay> bays) {
    final bay = bays.firstWhere((b) => b.type == type, orElse: () => StationBay(type: type));
    final isOccupied = bay.isOccupied;

    Color statusColor;
    String statusText;
    if (!isOccupied) {
      statusColor = AppColors.statusReady;
      statusText = 'Available';
    } else {
      statusColor = AppColors.statusWashing;
      statusText = 'Washing';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isOccupied ? 'Plate: ${bay.activeLicensePlate ?? "Unknown"}' : 'Ready for next car',
              style: TextStyle(
                fontSize: 13,
                fontWeight: isOccupied ? FontWeight.bold : FontWeight.normal,
                color: isOccupied ? AppColors.textPrimary : AppColors.textMuted,
              ),
            ),
            if (isOccupied && bay.assignedWasherName != null) ...[
              const SizedBox(height: 4),
              Text(
                'Washers: ${bay.assignedWasherName}',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQueueTile(BuildContext context, WashBooking b) {
    final notifier = AppStateProvider.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Status Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: b.status.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.local_car_wash_rounded, color: b.status.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(b.licensePlate, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(width: 8),
                      if (b.origin == BookingOrigin.phoneCall)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Phone Call', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${b.carType.displayName} • ${b.package.name} • ${b.totalPrice.toStringAsFixed(0)} ETB (${b.payment.method.displayName})',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  if (b.assignedWasherNames.isNotEmpty)
                    Text(
                      'Washers: ${b.assignedWasherNames.join(', ')}',
                      style: const TextStyle(fontSize: 11, color: AppColors.primary),
                    ),
                ],
              ),
            ),
            // Advance Status Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                backgroundColor: b.status.color,
              ),
              onPressed: () {
                _advanceBookingStatus(context, b);
              },
              child: Text(_nextActionText(b.status), style: const TextStyle(fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedTile(BuildContext context, WashBooking b) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      color: Colors.grey.shade50,
      child: ListTile(
        leading: const Icon(Icons.check_circle_rounded, color: Colors.green),
        title: Text('${b.licensePlate} (${b.carType.displayName})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(
          'Washers: ${b.assignedWasherNames.join(' & ')} • ${b.totalPrice.toStringAsFixed(0)} ETB',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: const Text('Completed', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }

  String _nextActionText(WashStatus status) {
    switch (status) {
      case WashStatus.pending:
      case WashStatus.confirmed:
        return 'Assign Bay';
      case WashStatus.assignedToBay:
      case WashStatus.washing:
        return 'Set Drying';
      case WashStatus.drying:
        return 'Set Ready';
      case WashStatus.readyForPickup:
        return 'Complete & SMS';
      default:
        return 'Done';
    }
  }

  void _advanceBookingStatus(BuildContext context, WashBooking b) async {
    final notifier = AppStateProvider.of(context);
    switch (b.status) {
      case WashStatus.pending:
      case WashStatus.confirmed:
        // Automatically assign first vacant bay and first 2 washers if unassigned
        await notifier.assignBayAndWashers(
          bookingId: b.id,
          bay: BayType.bay1,
          washerNames: ['Abebe', 'Chala'],
        );
        break;
      case WashStatus.assignedToBay:
      case WashStatus.washing:
        await notifier.updateWashStatus(b.id, WashStatus.drying);
        break;
      case WashStatus.drying:
        await notifier.updateWashStatus(b.id, WashStatus.readyForPickup);
        break;
      case WashStatus.readyForPickup:
        await notifier.updateWashStatus(b.id, WashStatus.completed);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vehicle ${b.licensePlate} completed! Customer pickup SMS queued & commission split.'),
            backgroundColor: Colors.green,
          ),
        );
        break;
      default:
        break;
    }
  }
}
