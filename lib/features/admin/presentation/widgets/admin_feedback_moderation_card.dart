import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';
import '../../../welcome/domain/models/customer_feedback.dart';
import '../../../welcome/presentation/widgets/customer_feedback_sheet.dart';

/// Admin card for filtering spam/scammers by approving or ignoring customer feedback.
class AdminFeedbackModerationCard extends StatefulWidget {
  const AdminFeedbackModerationCard({super.key});

  @override
  State<AdminFeedbackModerationCard> createState() => _AdminFeedbackModerationCardState();
}

class _AdminFeedbackModerationCardState extends State<AdminFeedbackModerationCard> {
  FeedbackStatus _activeTab = FeedbackStatus.pending;

  static const Map<FeedbackStatus, String> _tabLabelKeys = {
    FeedbackStatus.pending: 'pendingReviewLabel',
    FeedbackStatus.approved: 'approvedLabel',
    FeedbackStatus.ignored: 'ignoredLabel',
  };

  List<CustomerFeedback> _itemsFor(dynamic state, FeedbackStatus status) {
    switch (status) {
      case FeedbackStatus.pending:
        return state.pendingCustomerFeedback as List<CustomerFeedback>;
      case FeedbackStatus.approved:
        return state.approvedCustomerFeedback as List<CustomerFeedback>;
      case FeedbackStatus.ignored:
        return state.ignoredCustomerFeedback as List<CustomerFeedback>;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final pendingCount = (state.pendingCustomerFeedback as List).length;
    final items = _itemsFor(state, _activeTab);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: pendingCount > 0 ? const Color(0xFFF59E0B) : AppColors.cardBorder,
          width: pendingCount > 0 ? 1.6 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.rate_review_rounded, color: Color(0xFFD97706), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.tr('adminFeedbackModeration'),
                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    Text(
                      state.tr('adminFeedbackModerationSub'),
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              if (pendingCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD97706),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$pendingCount',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Status Filter Tabs
          Row(
            children: FeedbackStatus.values.map((status) {
              final selected = _activeTab == status;
              final count = _itemsFor(state, status).length;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: status != FeedbackStatus.values.last ? 6 : 0),
                  child: InkWell(
                    onTap: () => setState(() => _activeTab = status),
                    borderRadius: BorderRadius.circular(9),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : AppColors.surfaceVariant.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${state.tr(_tabLabelKeys[status]!)} ($count)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: selected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),

          if (items.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                state.tr('feedbackModerationEmpty'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            )
          else
            ...items.map((item) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CustomerFeedbackSheet.buildStarRow(item.stars, size: 15),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              state.tr(item.labelKey),
                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            ),
                          ),
                          Text(
                            DateFormatter.formatDateTime(item.createdAt),
                            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.customerName.isNotEmpty ? item.customerName : state.tr('anonymousCustomer'),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                      ),
                      if (item.comment.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.comment,
                          style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (item.status == FeedbackStatus.pending) ...[
                            TextButton(
                              onPressed: () => state.moderateCustomerFeedback(item.id, FeedbackStatus.ignored),
                              child: Text(
                                state.tr('ignoreFeedback'),
                                style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700, fontSize: 12),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ] else ...[
                            TextButton(
                              onPressed: () => state.deleteCustomerFeedback(item.id),
                              child: Text(
                                state.tr('removeFeedback'),
                                style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700, fontSize: 12),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          if (item.status != FeedbackStatus.approved)
                            ElevatedButton(
                              onPressed: () => state.moderateCustomerFeedback(item.id, FeedbackStatus.approved),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.statusCompleted,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text(
                                state.tr('approveFeedback'),
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }
}
