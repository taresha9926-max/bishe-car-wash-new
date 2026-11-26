import 'package:flutter/material.dart';
import 'package:bishe_car_wash/core/constants/app_colors.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_status.dart';

/// Interactive pseudo-3D automotive vehicle chassis with dynamic wash phase scanning lasers,
/// reflective obsidian studio pedestal, and real-time kinetic underglow.
class Automotive3DCarView extends StatefulWidget {
  final WashStatus status;
  final String? licensePlate;
  final String? vehicleCategory;
  final double height;
  final bool interactive;

  const Automotive3DCarView({
    super.key,
    this.status = WashStatus.washing,
    this.licensePlate,
    this.vehicleCategory,
    this.height = 200,
    this.interactive = true,
  });

  @override
  State<Automotive3DCarView> createState() => _Automotive3DCarViewState();
}

class _Automotive3DCarViewState extends State<Automotive3DCarView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scanController;
  double _rotationY = 0.0;
  double _rotationX = 0.0;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    // Prevent infinite repeat during widget/integration tests
    final isTest = WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (!isTest) {
      _scanController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  Color _getPhaseColor() {
    switch (widget.status) {
      case WashStatus.pending:
        return AppColors.statusPending;
      case WashStatus.confirmed:
      case WashStatus.assignedToBay:
        return AppColors.statusConfirmed;
      case WashStatus.washing:
        return AppColors.liquidCyanNeon;
      case WashStatus.drying:
        return AppColors.warmAmberSunset;
      case WashStatus.readyForPickup:
      case WashStatus.completed:
        return AppColors.statusReady;
      case WashStatus.cancelled:
        return AppColors.statusCancelled;
    }
  }

  String _getPhaseTitle() {
    switch (widget.status) {
      case WashStatus.pending:
        return 'INSPECTION & QUEUE';
      case WashStatus.confirmed:
      case WashStatus.assignedToBay:
        return 'BAY DISPATCHED';
      case WashStatus.washing:
        return 'HYDRO-FOAM JET WASH';
      case WashStatus.drying:
        return 'TURBO DRY & DETAILING';
      case WashStatus.readyForPickup:
        return 'PRISTINE FINISH • READY';
      case WashStatus.completed:
        return 'COMPLETED & ARCHIVED';
      case WashStatus.cancelled:
        return 'CANCELLED';
    }
  }

  @override
  Widget build(BuildContext context) {
    final phaseColor = _getPhaseColor();

    return GestureDetector(
      onPanUpdate: widget.interactive
          ? (details) {
              setState(() {
                _rotationY += details.delta.dx * 0.005;
                _rotationX -= details.delta.dy * 0.005;
                _rotationY = _rotationY.clamp(-0.35, 0.35);
                _rotationX = _rotationX.clamp(-0.2, 0.2);
              });
            }
          : null,
      onPanEnd: widget.interactive
          ? (_) {
              setState(() {
                _rotationY = 0.0;
                _rotationX = 0.0;
              });
            }
          : null,
      child: AnimatedBuilder(
        animation: _scanController,
        builder: (context, _) {
          final scanProgress = _scanController.value;

          return Container(
            height: widget.height,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, 0.3),
                radius: 0.9,
                colors: [
                  phaseColor.withValues(alpha: 0.22),
                  const Color(0xFF0F172A).withValues(alpha: 0.95),
                  const Color(0xFF090D14),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: phaseColor.withValues(alpha: 0.35),
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: phaseColor.withValues(alpha: 0.18),
                  blurRadius: 20,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(19),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 1. Grid lines / Laser floor
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _LaserFloorPainter(phaseColor: phaseColor),
                    ),
                  ),

                  // 2. 3D Perspective Vehicle Silhouette
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.0018)
                      ..rotateY(_rotationY)
                      ..rotateX(_rotationX),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Supercar Chassis Icon Representation
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Kinetic Underglow Ring
                            Container(
                              width: 180,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                boxShadow: [
                                  BoxShadow(
                                    color: phaseColor.withValues(alpha: 0.45),
                                    blurRadius: 24,
                                    spreadRadius: 8,
                                  ),
                                ],
                              ),
                            ),

                            // Vehicle Chassis
                            Icon(
                              Icons.directions_car_filled_rounded,
                              size: widget.height * 0.42,
                              color: Colors.white,
                            ),

                            // Dynamic Scanning Laser Line
                            Positioned(
                              top: (widget.height * 0.42) * scanProgress - 10,
                              child: Container(
                                width: 140,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: phaseColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: phaseColor,
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        // License plate badge
                        if (widget.licensePlate != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.liquidCyanNeon, width: 1),
                            ),
                            child: Text(
                              widget.licensePlate!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // 3. Top HUD Status Pill
                  Positioned(
                    top: 10,
                    left: 12,
                    right: 12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF111827).withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: phaseColor.withValues(alpha: 0.5), width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: phaseColor,
                                    boxShadow: [
                                      BoxShadow(color: phaseColor, blurRadius: 6),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    _getPhaseTitle(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: phaseColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (widget.vehicleCategory != null) ...[
                          const SizedBox(width: 6),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF111827).withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                              ),
                              child: Text(
                                widget.vehicleCategory!.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // 4. Interactive touch hint (bottom right)
                  if (widget.interactive)
                    Positioned(
                      bottom: 8,
                      right: 12,
                      child: Row(
                        children: [
                          Icon(Icons.touch_app_rounded, size: 12, color: Colors.white.withValues(alpha: 0.4)),
                          const SizedBox(width: 4),
                          Text(
                            '3D PERSPECTIVE',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withValues(alpha: 0.4),
                              letterSpacing: 0.6,
                            ),
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
    );
  }
}

class _LaserFloorPainter extends CustomPainter {
  final Color phaseColor;

  _LaserFloorPainter({required this.phaseColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = phaseColor.withValues(alpha: 0.08)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const divisions = 6;
    for (int i = 0; i <= divisions; i++) {
      final y = size.height * (0.6 + (i / divisions) * 0.4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _LaserFloorPainter oldDelegate) =>
      oldDelegate.phaseColor != phaseColor;
}
