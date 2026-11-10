import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';

/// Compact pill reassuring public customers that listed ETB tariffs are negotiable.
class NegotiablePriceBadge extends StatelessWidget {
  final bool onDark;

  const NegotiablePriceBadge({super.key, this.onDark = false});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: onDark
            ? AppColors.statusReady.withOpacity(0.18)
            : AppColors.statusReady.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: onDark
              ? AppColors.statusReady.withOpacity(0.55)
              : AppColors.statusReady.withOpacity(0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.handshake_outlined,
            size: 14,
            color: onDark ? Colors.greenAccent : AppColors.statusCompleted,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              state.tr('pricesAreNegotiable'),
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: onDark ? Colors.greenAccent : AppColors.statusCompleted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
