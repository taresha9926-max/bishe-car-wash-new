import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/services/bishe_ai_executive_service.dart';
import '../../../../core/utils/url_launcher_helper.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';

class BisheAiExecutiveSheet extends StatefulWidget {
  const BisheAiExecutiveSheet({super.key});

  /// Static helper to display the AI Executive as a modal sheet
  static void show(BuildContext context) {
    final notifier = AppStateProvider.read(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AppStateProvider(
        notifier: notifier,
        child: const BisheAiExecutiveSheet(),
      ),
    );
  }

  @override
  State<BisheAiExecutiveSheet> createState() => _BisheAiExecutiveSheetState();
}

class _ChatMessage {
  final bool isUser;
  final String text;
  final DateTime timestamp;

  _ChatMessage({
    required this.isUser,
    required this.text,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class _BisheAiExecutiveSheetState extends State<BisheAiExecutiveSheet> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final state = AppStateProvider.read(context);
      _messages.add(
        _ChatMessage(
          isUser: false,
          text: state.tr('aiWelcomeMessage'),
        ),
      );
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSend([String? presetQuery]) async {
    final query = presetQuery ?? _inputController.text.trim();
    if (query.isEmpty || _isLoading) return;

    if (presetQuery == null) {
      _inputController.clear();
    }

    setState(() {
      _messages.add(_ChatMessage(isUser: true, text: query));
      _isLoading = true;
    });
    _scrollToBottom();

    final state = AppStateProvider.read(context);
    final history = _messages
        .take(_messages.length - 1)
        .map((m) => {
              'role': m.isUser ? 'user' : 'model',
              'text': m.text,
            })
        .toList();

    final response = await BisheAiExecutiveService.askExecutive(
      userQuestion: query,
      state: state,
      currentLang: AppLanguage.fromCode(state.currentLang),
      conversationHistory: history,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        _messages.add(_ChatMessage(isUser: false, text: response));
      });
      _scrollToBottom();
    }
  }

  void _showApiKeyDialog() {
    final state = AppStateProvider.read(context);
    final keyCtrl = TextEditingController(text: state.geminiApiKey ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AppStateProvider(
        notifier: state,
        child: AlertDialog(
        backgroundColor: const Color(0xFF111827),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0x3300E5FF), width: 1.2),
        ),
        title: Row(
          children: [
            const Icon(Icons.key_rounded, color: AppColors.liquidCyanNeon, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                state.tr('configureApiKey'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              state.tr('apiKeyNotice'),
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: keyCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'AIzaSy...',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, size: 16),
                  onPressed: () => keyCtrl.clear(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.liquidCyanNeon,
                side: const BorderSide(color: Color(0x5500E5FF)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              icon: const Icon(Icons.open_in_new_rounded, size: 15),
              label: Text(state.tr('getFreeKeyBtn'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              onPressed: () => UrlLauncherHelper.openUrl('https://aistudio.google.com'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(state.tr('cancel'), style: const TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              state.setGeminiApiKey(keyCtrl.text);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(keyCtrl.text.trim().isNotEmpty ? 'Gemini API Key saved.' : 'Key cleared. Using Local Station Analytics.'),
                  backgroundColor: AppColors.statusCompleted,
                ),
              );
            },
            child: Text(state.tr('save')),
          ),
        ],
      ),
    ),
  );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final media = MediaQuery.of(context);
    final isDesktop = media.size.width >= 900;
    final hasKey = state.geminiApiKey != null && state.geminiApiKey!.isNotEmpty;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 620 : double.infinity,
          maxHeight: media.size.height * 0.90,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(24),
              bottom: isDesktop ? const Radius.circular(24) : Radius.zero,
            ),
            border: Border.all(color: AppColors.cardBorder, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 25,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // 1. Header Bar
              _buildHeader(context, state, hasKey),

              // 2. Horizontally scrollable quick-prompt chips
              _buildQuickPromptChips(state),

              const Divider(height: 1, color: Color(0xFF1E293B)),

              // 3. Chat Messages List
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  itemCount: _messages.length,
                  itemBuilder: (ctx, idx) => _buildMessageBubble(_messages[idx]),
                ),
              ),

              // 4. Thinking Loading Indicator
              if (_isLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.liquidCyanNeon),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        state.tr('aiThinking'),
                        style: const TextStyle(fontSize: 11, color: AppColors.liquidCyanNeon, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),

              // 5. Input Bar
              _buildInputBar(state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic state, bool hasKey) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 10),
      decoration: const BoxDecoration(
        color: Color(0xFF111827),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF007791), Color(0xFF00E5FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.liquidCyanNeon.withOpacity(0.3),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Text(
                      state.tr('aiExecutiveTitle'),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (hasKey ? const Color(0xFF10B981) : AppColors.liquidCyanNeon).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: (hasKey ? const Color(0xFF10B981) : AppColors.liquidCyanNeon).withOpacity(0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 6,
                            color: hasKey ? const Color(0xFF10B981) : AppColors.liquidCyanNeon,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            hasKey ? state.tr('aiCloudEngineBadge') : state.tr('aiLocalEngineBadge'),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: hasKey ? const Color(0xFF10B981) : AppColors.liquidCyanNeon,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Text(
                  state.tr('aiExecutiveSub'),
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.key_rounded, size: 20, color: AppColors.liquidCyanNeon),
            tooltip: state.tr('configureApiKey'),
            onPressed: _showApiKeyDialog,
          ),
          IconButton(
            icon: const Icon(Icons.cleaning_services_rounded, size: 18, color: AppColors.textMuted),
            tooltip: state.tr('clearChat'),
            onPressed: () {
              setState(() {
                _messages.clear();
                _messages.add(_ChatMessage(isUser: false, text: state.tr('aiWelcomeMessage')));
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 20, color: Colors.white70),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPromptChips(dynamic state) {
    final chips = [
      {'label': state.tr('aiPromptPnL'), 'query': 'Today\'s P&L and net profit summary'},
      {'label': state.tr('aiPromptCars'), 'query': 'List cars washed today and vehicle types'},
      {'label': state.tr('aiPromptWashers'), 'query': 'Active washers on duty and their commissions'},
      {'label': state.tr('aiPromptYield'), 'query': 'Chemical yield and average shampoo and perfume used per car'},
      {'label': state.tr('aiPromptAlerts'), 'query': 'Check for low inventory stock and station discrepancies'},
    ];

    return Container(
      color: const Color(0xFF0F172A),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: chips.map((chip) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                backgroundColor: const Color(0xFF1E293B),
                side: const BorderSide(color: Color(0x4400E5FF)),
                label: Text(
                  chip['label']!,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                onPressed: () => _handleSend(chip['query']),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage message) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.liquidCyanNeon.withOpacity(0.5)),
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: AppColors.liquidCyanNeon, size: 14),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primaryDark : const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14).copyWith(
                  bottomLeft: !isUser ? Radius.zero : const Radius.circular(14),
                  bottomRight: isUser ? Radius.zero : const Radius.circular(14),
                ),
                border: Border.all(
                  color: isUser ? AppColors.primaryLight.withOpacity(0.4) : const Color(0xFF334155),
                ),
              ),
              child: SelectableText(
                message.text,
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.4,
                  color: isUser ? Colors.white : AppColors.textPrimary,
                  fontFamily: 'NotoSansEthiopic',
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 14),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputBar(dynamic state) {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 8, 12, MediaQuery.of(context).viewInsets.bottom + 10),
      decoration: const BoxDecoration(
        color: Color(0xFF111827),
        border: Border(top: BorderSide(color: Color(0xFF1E293B))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: state.tr('askAiHint'),
                hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Color(0xFF334155)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Color(0xFF334155)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: AppColors.liquidCyanNeon, width: 1.5),
                ),
              ),
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.send_rounded, size: 18),
            onPressed: () => _handleSend(),
          ),
        ],
      ),
    );
  }
}
