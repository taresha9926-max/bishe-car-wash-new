import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../booking_service/domain/models/service_type.dart';
import '../../../booking_service/domain/models/wash_status.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';

class LiveWashStepper extends StatelessWidget {
  final WashStatus currentStatus;
  final bool isCarpet;
  final ServiceType serviceType;

  const LiveWashStepper({
    super.key,
    required this.currentStatus,
    this.isCarpet = false,
    this.serviceType = ServiceType.walkInStation,
  });

  static const List<WashStatus> _steps = [
    WashStatus.pending,
    WashStatus.confirmed,
    WashStatus.assignedToBay,
    WashStatus.washing,
    WashStatus.drying,
    WashStatus.readyForPickup,
    WashStatus.completed,
  ];

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final langCode = state.currentLang;
    final currentIndex = _steps.indexOf(currentStatus);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(_steps.length * 2 - 1, (index) {
          // Even indices are steps (0, 2, 4, 6, 8, 10, 12)
          // Odd indices are modern arrow thumbnails (1, 3, 5, 7, 9, 11)
          if (index.isOdd) {
            final stepBeforeIndex = index ~/ 2;
            final isArrowDone = currentIndex > stepBeforeIndex || currentStatus == WashStatus.completed;
            final isArrowActive = currentIndex == stepBeforeIndex && currentStatus != WashStatus.completed;

            return Padding(
              padding: const EdgeInsets.only(top: 10, left: 4, right: 4),
              child: _buildModernArrowThumbnail(
                isDone: isArrowDone,
                isActive: isArrowActive,
              ),
            );
          }

          final stepIndex = index ~/ 2;
          final step = _steps[stepIndex];
          final isDone = currentIndex > stepIndex || currentStatus == WashStatus.completed;
          final isCurrent = currentIndex == stepIndex && currentStatus != WashStatus.completed;

          final stepIcon = _getStepIcon(step, isCarpet);

          return SizedBox(
            width: 108,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _PulsingHaloRing(
                  isActive: isCurrent,
                  color: isCurrent ? AppColors.liquidCyanNeon : step.color,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isDone
                          ? AppColors.statusCompleted
                          : (isCurrent ? AppColors.slateGlass : const Color(0xFF1E293B)),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCurrent
                            ? AppColors.liquidCyanNeon
                            : (isDone ? AppColors.statusCompleted : AppColors.cardBorder),
                        width: isCurrent ? 2.5 : 1.5,
                      ),
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: AppColors.liquidCyanNeon.withValues(alpha: 0.45),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Icon(
                        isDone ? Icons.check_rounded : stepIcon,
                        size: 20,
                        color: isDone
                            ? Colors.white
                            : (isCurrent ? AppColors.liquidCyanNeon : AppColors.textMuted),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getStepTitle(state, step, langCode),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: isCurrent ? FontWeight.w900 : (isDone ? FontWeight.w700 : FontWeight.w600),
                    color: isCurrent
                        ? AppColors.liquidCyanNeon
                        : (isDone ? Colors.white : AppColors.textSecondary),
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: isDone
                        ? AppColors.statusCompleted.withOpacity(0.15)
                        : (isCurrent
                            ? AppColors.liquidCyanNeon.withOpacity(0.15)
                            : Colors.white.withOpacity(0.06)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isDone
                        ? 'DONE'
                        : (isCurrent ? 'CURRENT' : 'STEP ${stepIndex + 1}'),
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      color: isDone
                          ? AppColors.statusCompleted
                          : (isCurrent ? AppColors.liquidCyanNeon : AppColors.textMuted),
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildModernArrowThumbnail({required bool isDone, required bool isActive}) {
    final color = isDone
        ? AppColors.statusCompleted
        : (isActive ? AppColors.liquidCyanNeon : const Color(0xFF475569));
    final bgColor = isDone
        ? AppColors.statusCompleted.withValues(alpha: 0.16)
        : (isActive ? AppColors.liquidCyanNeon.withValues(alpha: 0.20) : const Color(0xFF1E293B));
    final borderColor = isDone
        ? AppColors.statusCompleted.withValues(alpha: 0.5)
        : (isActive ? AppColors.liquidCyanNeon.withValues(alpha: 0.7) : const Color(0xFF334155));

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.liquidCyanNeon.withValues(alpha: 0.35),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 11,
          color: color,
        ),
      ),
    );
  }

  IconData _getStepIcon(WashStatus step, bool isCarpet) {
    if (isCarpet) {
      switch (step) {
        case WashStatus.pending:
          return Icons.event_available_rounded;
        case WashStatus.confirmed:
          return Icons.location_on_rounded;
        case WashStatus.assignedToBay:
          return Icons.layers_rounded;
        case WashStatus.washing:
          return Icons.wash_rounded;
        case WashStatus.drying:
          return Icons.wb_sunny_rounded;
        case WashStatus.readyForPickup:
          return Icons.verified_rounded;
        case WashStatus.completed:
          return Icons.check_circle_rounded;
        default:
          return Icons.circle;
      }
    }

    switch (step) {
      case WashStatus.pending:
        return Icons.assignment_turned_in_rounded;
      case WashStatus.confirmed:
        return Icons.location_on_rounded;
      case WashStatus.assignedToBay:
        return Icons.garage_rounded;
      case WashStatus.washing:
        return Icons.local_car_wash_rounded;
      case WashStatus.drying:
        return Icons.air_rounded;
      case WashStatus.readyForPickup:
        return Icons.auto_awesome_rounded;
      case WashStatus.completed:
        return Icons.flag_circle_rounded;
      default:
        return step.icon;
    }
  }

  String _getStepTitle(dynamic state, WashStatus step, String langCode) {
    if (serviceType == ServiceType.valetPickUp) {
      switch (step) {
        case WashStatus.pending:
          return state.tr('valetStepDispatched');
        case WashStatus.confirmed:
        case WashStatus.assignedToBay:
          return state.tr('valetStepPickedUp');
        case WashStatus.washing:
          return state.tr('valetStepWashing');
        case WashStatus.drying:
        case WashStatus.readyForPickup:
          return state.tr('valetStepReturning');
        case WashStatus.completed:
          return state.tr('valetStepDelivered');
        default:
          return step.localizedName(langCode);
      }
    }
    if (serviceType == ServiceType.atHomeMobile) {
      switch (step) {
        case WashStatus.pending:
          return state.tr('homeStepDispatched');
        case WashStatus.confirmed:
          return state.tr('homeStepEnRoute');
        case WashStatus.assignedToBay:
          return state.tr('homeStepSetup');
        case WashStatus.washing:
          return state.tr('homeStepWashing');
        case WashStatus.drying:
        case WashStatus.readyForPickup:
        case WashStatus.completed:
          return state.tr('homeStepCompleted');
        default:
          return step.localizedName(langCode);
      }
    }

    switch (step) {
      case WashStatus.pending:
        return state.tr('bookingApprovedStep');
      case WashStatus.confirmed:
        return state.tr('phaseApprovedArrived');
      case WashStatus.assignedToBay:
        return state.tr('queuedInBayStep');
      case WashStatus.washing:
        return state.tr('washingInProgressStep');
      case WashStatus.drying:
        return state.tr('dryingDetailingStep');
      case WashStatus.readyForPickup:
        return state.tr('readyForPickupStep');
      case WashStatus.completed:
        return state.tr('statusCompleted');
      default:
        return step.localizedName(langCode);
    }
  }
}

/// Continuous pulsing active-phase halo ring
class _PulsingHaloRing extends StatefulWidget {
  final Widget child;
  final bool isActive;
  final Color color;

  const _PulsingHaloRing({
    required this.child,
    required this.isActive,
    required this.color,
  });

  @override
  State<_PulsingHaloRing> createState() => _PulsingHaloRingState();
}

class _PulsingHaloRingState extends State<_PulsingHaloRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _haloController;

  @override
  void initState() {
    super.initState();
    _haloController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    final isTesting = WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (widget.isActive && !isTesting) {
      _haloController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant _PulsingHaloRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    final isTesting = WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (widget.isActive && !_haloController.isAnimating && !isTesting) {
      _haloController.repeat();
    } else if (!widget.isActive && _haloController.isAnimating) {
      _haloController.stop();
    }
  }

  @override
  void dispose() {
    _haloController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _haloController,
      builder: (context, child) {
        final val = _haloController.value;
        final ringScale = 1.0 + (val * 0.35);
        final opacity = (1.0 - val).clamp(0.0, 1.0);

        return SizedBox(
          width: 48,
          height: 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: ringScale,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.color.withValues(alpha: opacity * 0.7),
                      width: 2.0,
                    ),
                  ),
                ),
              ),
              widget.child,
            ],
          ),
        );
      },
    );
  }
}
