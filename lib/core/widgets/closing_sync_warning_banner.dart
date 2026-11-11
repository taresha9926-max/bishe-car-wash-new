import 'package:flutter/material.dart';
import 'package:bishe_car_wash/core/constants/app_colors.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';

/// Maps a raw closing cloud-sync error to the accurate localized warning text.
String resolveClosingSyncWarningMessage(dynamic state, String syncErr) {
  final isRlsUpdateBlock =
      syncErr.contains('UPDATE blocked by RLS') || syncErr.contains('0 rows updated');
  return state.tr(
    isRlsUpdateBlock ? 'closingCloudSyncRlsWarning' : 'closingCloudSyncNetworkWarning',
  );
}

/// Shows the closing/handover SnackBar, distinguishing cloud sync errors from success.
void showClosingSyncResultSnackBar(
  BuildContext context,
  dynamic state, {
  required String successMessage,
  Color successColor = AppColors.statusCompleted,
}) {
  final syncErr = state.closingCloudSyncError as String?;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        syncErr != null
            ? resolveClosingSyncWarningMessage(state, syncErr)
            : successMessage,
      ),
      backgroundColor: syncErr != null ? const Color(0xFFD97706) : successColor,
      duration: Duration(seconds: syncErr != null ? 7 : 4),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

/// Dismissible warning banner displayed when the latest daily closing failed cloud sync.
class ClosingSyncWarningBanner extends StatelessWidget {
  const ClosingSyncWarningBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final syncErr = state.closingCloudSyncError;
    if (syncErr == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD97706)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFB45309), size: 19),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              resolveClosingSyncWarningMessage(state, syncErr),
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF92400E),
              ),
            ),
          ),
          IconButton(
            onPressed: state.clearClosingCloudSyncError,
            tooltip: state.tr('close'),
            icon: const Icon(Icons.close_rounded, color: Color(0xFF92400E), size: 18),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          ),
        ],
      ),
    );
  }
}
