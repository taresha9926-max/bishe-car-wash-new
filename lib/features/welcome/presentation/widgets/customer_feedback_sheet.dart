import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';
import '../../domain/models/customer_feedback.dart';

/// Modal bottom sheet allowing customers to submit 1-4 star feedback & opinions
/// and browse Admin-approved feedback ("Show Customers Suggestions") expanded by default.
class CustomerFeedbackSheet extends StatefulWidget {
  const CustomerFeedbackSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CustomerFeedbackSheet(),
    );
  }

  /// Renders [stars] filled gold stars (out of 4) concisely.
  static Widget buildStarRow(int stars, {double size = 16}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        stars.clamp(1, 4),
        (_) => Icon(Icons.star_rounded, size: size, color: const Color(0xFFF59E0B)),
      ),
    );
  }

  @override
  State<CustomerFeedbackSheet> createState() => _CustomerFeedbackSheetState();
}

class _CustomerFeedbackSheetState extends State<CustomerFeedbackSheet> {
  int? _selectedStars;
  final _nameController = TextEditingController();
  final _opinionController = TextEditingController();
  bool _isSubmitting = false;
  bool _suggestionsExpanded = true; // Expanded by default per user spec
  String? _statusMessage;
  bool _statusIsError = false;

  @override
  void dispose() {
    _nameController.dispose();
    _opinionController.dispose();
    super.dispose();
  }

  Future<void> _submit(BuildContext context) async {
    final state = AppStateProvider.read(context);
    if (_selectedStars == null) {
      setState(() {
        _statusMessage = state.tr('selectStarRatingFirst');
        _statusIsError = true;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _statusMessage = null;
    });

    final errorKey = await state.submitCustomerFeedback(
      stars: _selectedStars!,
      comment: _opinionController.text,
      customerName: _nameController.text,
    );

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      if (errorKey != null) {
        _statusMessage = state.tr(errorKey);
        _statusIsError = true;
      } else {
        _selectedStars = null;
        _nameController.clear();
        _opinionController.clear();
        _statusMessage = state.tr('feedbackSentForApproval');
        _statusIsError = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final approved = state.approvedCustomerFeedback;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
        maxWidth: 640,
      ),
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle + Header
          Container(
            padding: const EdgeInsets.fromLTRB(18, 10, 12, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
            ),
            child: Column(
              children: [
                Container(
                  width: 38,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withOpacity(0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.star_rounded, color: Color(0xFFD97706), size: 22),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        state.tr('customerFeedbackHeader'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Scrollable Body: Submit Form + Approved List
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Satisfaction & Opinion Submission Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.tr('rateExperienceQuestion'),
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // 4 Satisfaction Levels (1..4 Stars)
                        ...CustomerFeedback.validRatings.map((rating) {
                          final isSelected = _selectedStars == rating;
                          final labelKey = CustomerFeedback.ratingLabelKeys[rating]!;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 7),
                            child: InkWell(
                              onTap: () => setState(() => _selectedStars = rating),
                              borderRadius: BorderRadius.circular(11),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFF59E0B).withOpacity(0.10)
                                      : AppColors.surfaceVariant.withOpacity(0.55),
                                  borderRadius: BorderRadius.circular(11),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFFF59E0B) : AppColors.cardBorder,
                                    width: isSelected ? 1.6 : 1.0,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CustomerFeedbackSheet.buildStarRow(rating, size: 18),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        state.tr(labelKey),
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                          color: isSelected ? const Color(0xFF92400E) : AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                      size: 18,
                                      color: isSelected ? const Color(0xFFD97706) : AppColors.textMuted,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 6),

                        // Optional Name
                        TextField(
                          controller: _nameController,
                          maxLength: 50,
                          decoration: InputDecoration(
                            labelText: state.tr('feedbackNameOptional'),
                            prefixIcon: const Icon(Icons.person_outline_rounded, size: 18),
                            counterText: '',
                            isDense: true,
                            filled: true,
                            fillColor: AppColors.surfaceVariant.withOpacity(0.4),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Optional Personal Opinion
                        TextField(
                          controller: _opinionController,
                          maxLines: 3,
                          maxLength: 300,
                          decoration: InputDecoration(
                            labelText: state.tr('feedbackOpinionHint'),
                            alignLabelWithHint: true,
                            filled: true,
                            fillColor: AppColors.surfaceVariant.withOpacity(0.4),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),

                        if (_statusMessage != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                            decoration: BoxDecoration(
                              color: _statusIsError ? Colors.red.shade50 : Colors.green.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _statusIsError ? Colors.red.shade300 : Colors.green.shade300,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _statusIsError ? Icons.error_outline : Icons.check_circle_outline,
                                  size: 16,
                                  color: _statusIsError ? Colors.red.shade700 : Colors.green.shade700,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _statusMessage!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: _statusIsError ? Colors.red.shade800 : Colors.green.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton.icon(
                            onPressed: _isSubmitting ? null : () => _submit(context),
                            icon: const Icon(Icons.send_rounded, size: 17),
                            label: Text(
                              state.tr('sendFeedback'),
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 2. Approved Public List: "Show Customers Suggestions" (Expanded by Default)
                  InkWell(
                    onTap: () => setState(() => _suggestionsExpanded = !_suggestionsExpanded),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.forum_outlined, size: 18, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${state.tr('showCustomersSuggestions')} (${approved.length})',
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (approved.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              margin: const EdgeInsets.only(right: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B).withOpacity(0.14),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star_rounded, size: 13, color: Color(0xFFD97706)),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${state.averageApprovedRating.toStringAsFixed(1)}/4',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF92400E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Icon(
                            _suggestionsExpanded ? Icons.expand_less : Icons.expand_more,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (_suggestionsExpanded) ...[
                    if (approved.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Text(
                          state.tr('noApprovedFeedbackYet'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                        ),
                      )
                    else
                      ...approved.map((item) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomerFeedbackSheet.buildStarRow(item.stars, size: 15),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF59E0B).withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        state.tr(item.labelKey),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF92400E),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (item.comment.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    item.comment,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      color: AppColors.textPrimary,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item.customerName.isNotEmpty
                                          ? item.customerName
                                          : state.tr('anonymousCustomer'),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      DateFormatter.formatDate(item.createdAt),
                                      style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
