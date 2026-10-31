import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/image_picker_helper.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../booking_service/presentation/state/app_state_notifier.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';

class BankDepositDialog extends StatefulWidget {
  const BankDepositDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const BankDepositDialog(),
    );
  }

  @override
  State<BankDepositDialog> createState() => _BankDepositDialogState();
}

class _BankDepositDialogState extends State<BankDepositDialog> {
  String _selectedAccountKey = 'account_a'; // 'account_a' or 'account_b'
  final _amountController = TextEditingController();
  final _slipController = TextEditingController();
  final _notesController = TextEditingController();
  final _cashierNameController = TextEditingController(text: 'Cashier On Duty');

  bool _isSubmitting = false;
  String? _uploadedReceiptName;
  String? _receiptBase64;

  @override
  void dispose() {
    _amountController.dispose();
    _slipController.dispose();
    _notesController.dispose();
    _cashierNameController.dispose();
    super.dispose();
  }

  void _pickReceiptImage() {
    ImagePickerHelper.pickImage(onPicked: (img) {
      setState(() {
        _uploadedReceiptName = img.name;
        _receiptBase64 = img.base64Data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final availableCash = state.undepositedCashTodayETB;
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 14 : 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.account_balance_rounded, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.tr('depositCashToBank'),
                            style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                          Text(
                            state.tr('depositToOwnerAccounts'),
                            style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Available Cash in Drawer Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.cashGreen.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cashGreen.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.point_of_sale_rounded, color: AppColors.cashGreen, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          state.tr('cashAwaitingDeposit'),
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    Text(
                      CurrencyFormatter.format(availableCash),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.cashGreen),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Select Target Account A or B
              Text(
                state.tr('selectTargetBankAccount'),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),

              // Account A
              _buildAccountSelectorCard(
                accountKey: 'account_a',
                title: state.tr('ownerAccountA'),
                accountNumber: AppStateNotifier.ownerAccountANumber,
                bankName: 'Commercial Bank of Ethiopia',
                color: AppColors.cbeBirrPurple,
                icon: Icons.account_balance_rounded,
              ),
              const SizedBox(height: 8),

              // Account B
              _buildAccountSelectorCard(
                accountKey: 'account_b',
                title: state.tr('ownerAccountB'),
                accountNumber: AppStateNotifier.ownerAccountBNumber,
                bankName: 'Awash Bank',
                color: const Color(0xFFEA580C),
                icon: Icons.account_balance_wallet_rounded,
              ),
              const SizedBox(height: 16),

              // Deposit Amount & Quick Fill
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${state.tr('depositAmount')}:',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  if (availableCash > 0)
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(Icons.flash_on_rounded, size: 14, color: AppColors.primary),
                      label: Text(state.tr('depositAllCash'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                      onPressed: () {
                        _amountController.text = availableCash.toStringAsFixed(0);
                      },
                    ),
                ],
              ),
              const SizedBox(height: 6),
              CustomTextField(
                controller: _amountController,
                label: 'Deposit Amount',
                hint: 'e.g. 5000',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icons.attach_money_rounded,
              ),
              const SizedBox(height: 12),

              // Stamped Slip Mandatory Notice
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.shield_rounded, size: 18, color: Colors.amber.shade900),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.tr('depositSlipMandatoryNotice'),
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.amber.shade900),
                      ),
                    ),
                  ],
                ),
              ),

              // Slip / Transaction Ref Number
              CustomTextField(
                controller: _slipController,
                label: '${state.tr('bankSlipNumber')} *',
                hint: 'e.g. CBE-SLIP-984210 or AW-DEP-4491',
                prefixIcon: Icons.receipt_long_rounded,
              ),
              const SizedBox(height: 12),

              // Receipt Screenshot Upload
              Row(
                children: [
                  Text(
                    state.tr('uploadDepositSlip'),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  const Text(' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: _pickReceiptImage,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                  decoration: BoxDecoration(
                    color: _uploadedReceiptName != null ? AppColors.cashGreen.withOpacity(0.06) : Colors.red.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _uploadedReceiptName != null ? AppColors.cashGreen : Colors.red.shade300,
                      width: _uploadedReceiptName != null ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _uploadedReceiptName != null ? Icons.check_circle_rounded : Icons.camera_alt_outlined,
                        color: _uploadedReceiptName != null ? AppColors.cashGreen : Colors.red.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _uploadedReceiptName ?? state.tr('pleaseUploadDepositSlip'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _uploadedReceiptName != null ? AppColors.cashGreen : Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Cashier Name & Notes
              CustomTextField(
                controller: _cashierNameController,
                label: 'Deposited By (Cashier Name)',
                hint: 'Cashier full name',
                prefixIcon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: _notesController,
                label: 'Deposit Remarks (Optional)',
                hint: 'e.g. Deposited before branch closing',
                prefixIcon: Icons.notes_rounded,
              ),
              const SizedBox(height: 20),

              // Submit Button
              CustomButton(
                text: state.tr('confirmBankDeposit'),
                icon: Icons.check_circle_rounded,
                backgroundColor: AppColors.primary,
                isLoading: _isSubmitting,
                onPressed: _isSubmitting ? null : _handleDepositSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountSelectorCard({
    required String accountKey,
    required String title,
    required String accountNumber,
    required String bankName,
    required Color color,
    required IconData icon,
  }) {
    final isSelected = _selectedAccountKey == accountKey;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAccountKey = accountKey;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.cardBorder,
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? color : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Acc #: $accountNumber',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: color, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDepositSubmit() async {
    final state = AppStateProvider.read(context);
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid deposit amount.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final slipRef = _slipController.text.trim();
    if (slipRef.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.tr('depositSlipMandatoryNotice')),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    if (_receiptBase64 == null || _receiptBase64!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.tr('pleaseUploadDepositSlip')),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    final cashierName = _cashierNameController.text.trim().isNotEmpty
        ? _cashierNameController.text.trim()
        : 'Cashier On Duty';

    setState(() => _isSubmitting = true);

    try {
      final state = AppStateProvider.read(context);
      await state.recordBankDeposit(
        amount: amount,
        accountKey: _selectedAccountKey,
        referenceSlipNumber: slipRef,
        receiptScreenshot: _receiptBase64,
        cashierName: cashierName,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deposit of ${CurrencyFormatter.format(amount)} to ${_selectedAccountKey == "account_b" ? "Account B" : "Account A"} recorded successfully!'),
            backgroundColor: AppColors.statusReady,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error recording deposit: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
}
