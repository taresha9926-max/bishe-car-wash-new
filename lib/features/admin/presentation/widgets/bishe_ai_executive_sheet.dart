import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/services/bishe_ai_executive_service.dart';
import '../../../../core/utils/sound_helper.dart';
import '../../../../core/utils/url_launcher_helper.dart';
import '../../../auth_roles/domain/models/user_role.dart';
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

abstract class _AiBlock {}

class _HeaderBlock extends _AiBlock {
  final int level;
  final String text;
  _HeaderBlock(this.level, this.text);
}

class _KpiStripBlock extends _AiBlock {
  final List<Map<String, String>> items;
  _KpiStripBlock(this.items);
}

class _TableBlock extends _AiBlock {
  final List<String> headers;
  final List<List<String>> rows;
  _TableBlock(this.headers, this.rows);

  String toCsv() {
    final buf = StringBuffer();
    buf.writeln(headers.map((h) => '"${h.replaceAll('**', '').replaceAll('"', '""').trim()}"').join(','));
    for (final row in rows) {
      buf.writeln(row.map((c) => '"${c.replaceAll('**', '').replaceAll('`', '').replaceAll('"', '""').trim()}"').join(','));
    }
    return buf.toString();
  }

  String toPlainText() {
    final buf = StringBuffer();
    buf.writeln(headers.map((h) => h.replaceAll('**', '').trim()).join(' | '));
    for (final row in rows) {
      buf.writeln(row.map((c) => c.replaceAll('**', '').replaceAll('`', '').trim()).join(' | '));
    }
    return buf.toString();
  }
}

class _BulletBlock extends _AiBlock {
  final String text;
  _BulletBlock(this.text);
}

class _CalloutBlock extends _AiBlock {
  final String text;
  _CalloutBlock(this.text);
}

class _ParagraphBlock extends _AiBlock {
  final String text;
  _ParagraphBlock(this.text);
}

class _BisheAiExecutiveSheetState extends State<BisheAiExecutiveSheet> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _initialized = false;
  bool _autoVoiceEnabled = false;
  String? _speakingText;
  bool _isListening = false;
  String? _lastLang;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = AppStateProvider.read(context);
    final currentLang = state.currentLang;
    if (!_initialized) {
      final welcomeText = state.currentRole == UserRole.customer
          ? state.tr('aiCustomerWelcomeMessage')
          : state.tr('aiWelcomeMessage');
      _messages.add(
        _ChatMessage(
          isUser: false,
          text: welcomeText,
        ),
      );
      _initialized = true;
      _lastLang = currentLang;
    } else if (_lastLang != currentLang) {
      _lastLang = currentLang;
      if (_messages.length == 1 && !_messages.first.isUser) {
        _messages[0] = _ChatMessage(
          isUser: false,
          text: state.currentRole == UserRole.customer
              ? state.tr('aiCustomerWelcomeMessage')
              : state.tr('aiWelcomeMessage'),
        );
      }
    }
  }

  @override
  void dispose() {
    SoundHelper.stopSpeaking();
    SoundHelper.stopListening();
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

  void _speakMessage(String text) {
    setState(() {
      _speakingText = text;
    });
    SoundHelper.speak(
      text,
      onDone: () {
        if (mounted) {
          setState(() {
            if (_speakingText == text) _speakingText = null;
          });
        }
      },
      onError: () {
        if (mounted) {
          setState(() {
            if (_speakingText == text) _speakingText = null;
          });
        }
      },
    );
  }

  void _stopSpeaking() {
    SoundHelper.stopSpeaking();
    setState(() {
      _speakingText = null;
    });
  }

  void _toggleListening() {
    if (_isListening) {
      SoundHelper.stopListening();
      setState(() {
        _isListening = false;
      });
    } else {
      setState(() {
        _isListening = true;
      });
      SoundHelper.startListening(
        onResult: (text) {
          if (mounted) {
            setState(() {
              _inputController.text = text;
            });
          }
        },
        onDone: () {
          if (mounted) {
            setState(() {
              _isListening = false;
            });
          }
        },
        onError: () {
          if (mounted) {
            setState(() {
              _isListening = false;
            });
          }
        },
      );
    }
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
      callerRole: state.currentRole,
      conversationHistory: history,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        _messages.add(_ChatMessage(isUser: false, text: response));
      });
      _scrollToBottom();
      SoundHelper.playChime();
      if (_autoVoiceEnabled) {
        _speakMessage(response);
      }
    }
  }

  void _copyToClipboard(String text, String confirmation) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(confirmation),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _exportCsv(String csvContent, String filename, dynamic state) {
    Clipboard.setData(ClipboardData(text: csvContent));
    SoundHelper.exportCsvFile(filename, csvContent);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.tr('aiExportSuccess')),
        backgroundColor: AppColors.statusCompleted,
        duration: const Duration(seconds: 2),
      ),
    );
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
                  itemBuilder: (ctx, idx) => _buildMessageBubble(_messages[idx], state),
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
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: const BoxDecoration(
        color: Color(0xFF111827),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF007791), Color(0xFF00E5FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.liquidCyanNeon.withOpacity(0.3),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.currentRole == UserRole.customer
                      ? state.tr('aiConciergeTitle')
                      : state.tr('aiExecutiveTitle'),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: (hasKey ? const Color(0xFF10B981) : AppColors.liquidCyanNeon).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: (hasKey ? const Color(0xFF10B981) : AppColors.liquidCyanNeon).withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.circle,
                              size: 5,
                              color: hasKey ? const Color(0xFF10B981) : AppColors.liquidCyanNeon,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                hasKey ? state.tr('aiCloudEngineBadge') : state.tr('aiLocalEngineBadge'),
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  color: hasKey ? const Color(0xFF10B981) : AppColors.liquidCyanNeon,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  state.currentRole == UserRole.customer
                      ? state.tr('aiConciergeSub')
                      : state.tr('aiExecutiveSub'),
                  style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 30, height: 30),
            icon: Icon(
              _autoVoiceEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              size: 18,
              color: _autoVoiceEnabled ? AppColors.liquidCyanNeon : AppColors.textMuted,
            ),
            tooltip: state.tr('aiVoiceMode'),
            onPressed: () {
              setState(() {
                _autoVoiceEnabled = !_autoVoiceEnabled;
                if (!_autoVoiceEnabled) {
                  _stopSpeaking();
                }
              });
            },
          ),
          if (state.currentRole != UserRole.customer)
            IconButton(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 30, height: 30),
              icon: const Icon(Icons.key_rounded, size: 18, color: AppColors.liquidCyanNeon),
              tooltip: state.tr('configureApiKey'),
              onPressed: _showApiKeyDialog,
            ),
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 30, height: 30),
            icon: const Icon(Icons.cleaning_services_rounded, size: 16, color: AppColors.textMuted),
            tooltip: state.tr('clearChat'),
            onPressed: () {
              _stopSpeaking();
              final resetText = state.currentRole == UserRole.customer
                  ? state.tr('aiCustomerWelcomeMessage')
                  : state.tr('aiWelcomeMessage');
              setState(() {
                _messages.clear();
                _messages.add(_ChatMessage(isUser: false, text: resetText));
              });
            },
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 30, height: 30),
            icon: const Icon(Icons.close_rounded, size: 18, color: Colors.white70),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPromptChips(dynamic state) {
    final List<Map<String, String>> chips;
    final currentRole = state.currentRole as UserRole;

    switch (currentRole) {
      case UserRole.customer:
        chips = [
          {'label': state.tr('aiPromptCustomerPackages'), 'query': state.tr('aiQueryCustomerPackages')},
          {'label': state.tr('aiPromptCustomerWaitTime'), 'query': state.tr('aiQueryCustomerWaitTime')},
          {'label': state.tr('aiPromptCustomerEvSafety'), 'query': state.tr('aiQueryCustomerEvSafety')},
          {'label': state.tr('aiPromptCustomerCarpet'), 'query': state.tr('aiQueryCustomerCarpet')},
          {'label': state.tr('aiPromptCustomerShower'), 'query': state.tr('aiQueryCustomerShower')},
        ];
        break;
      case UserRole.manager:
        chips = [
          {'label': state.tr('aiPromptBaySpeed'), 'query': state.tr('aiQueryBaySpeed')},
          {'label': state.tr('aiPromptOtpStatus'), 'query': state.tr('aiQueryOtpStatus')},
          {'label': state.tr('aiPromptWasherPairs'), 'query': state.tr('aiQueryWasherPairs')},
          {'label': state.tr('aiPromptShowersCount'), 'query': state.tr('aiQueryShowersCount')},
          {'label': state.tr('aiPromptPnL'), 'query': state.tr('aiQueryPnL')},
        ];
        break;
      case UserRole.cashier:
        chips = [
          {'label': state.tr('aiPromptUnsettled'), 'query': state.tr('aiQueryUnsettled')},
          {'label': state.tr('aiPromptShowersCount'), 'query': state.tr('aiQueryShowersCount')},
          {'label': state.tr('aiPromptCashDrawer'), 'query': state.tr('aiQueryCashDrawer')},
          {'label': state.tr('aiPromptCars'), 'query': state.tr('aiQueryCars')},
        ];
        break;
      case UserRole.storekeeper:
        chips = [
          {'label': state.tr('aiPromptEmptyExchange'), 'query': state.tr('aiQueryEmptyExchange')},
          {'label': state.tr('aiPromptAssetHealth'), 'query': state.tr('aiQueryAssetHealth')},
          {'label': state.tr('aiPromptConsumableReorder'), 'query': state.tr('aiQueryConsumableReorder')},
          {'label': state.tr('aiPromptYield'), 'query': state.tr('aiQueryYield')},
        ];
        break;
      case UserRole.accountant:
        chips = [
          {'label': state.tr('aiPromptPnL'), 'query': state.tr('aiQueryPnL')},
          {'label': state.tr('aiPromptBankReconciliation'), 'query': state.tr('aiQueryBankReconciliation')},
          {'label': state.tr('aiPromptVatSummary'), 'query': state.tr('aiQueryVatSummary')},
          {'label': state.tr('aiPromptWashers'), 'query': state.tr('aiQueryWashers')},
        ];
        break;
      case UserRole.admin:
        chips = [
          {'label': state.tr('aiPromptPnL'), 'query': state.tr('aiQueryPnL')},
          {'label': state.tr('aiPromptCars'), 'query': state.tr('aiQueryCars')},
          {'label': state.tr('aiPromptWashers'), 'query': state.tr('aiQueryWashers')},
          {'label': state.tr('aiPromptYield'), 'query': state.tr('aiQueryYield')},
          {'label': state.tr('aiPromptAssetHealth'), 'query': state.tr('aiQueryAssetHealth')},
          {'label': state.tr('aiPromptAlerts'), 'query': state.tr('aiQueryAlerts')},
        ];
        break;
    }

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

  Widget _buildMessageBubble(_ChatMessage message, dynamic state) {
    final isUser = message.isUser;
    final hasTable = !isUser && message.text.contains('|') && message.text.contains('\n|');

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isUser)
                    SelectableText(
                      message.text,
                      style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.4,
                        color: Colors.white,
                        fontFamily: 'NotoSansEthiopic',
                      ),
                    )
                  else
                    _buildStructuredAiMessage(message.text, state),
                  if (!isUser) ...[
                    const SizedBox(height: 10),
                    const Divider(height: 1, color: Color(0xFF334155)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        // Listen / Stop Audio
                        InkWell(
                          borderRadius: BorderRadius.circular(6),
                          onTap: () {
                            if (_speakingText == message.text) {
                              _stopSpeaking();
                            } else {
                              _speakMessage(message.text);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: (_speakingText == message.text
                                      ? Colors.redAccent
                                      : AppColors.liquidCyanNeon)
                                  .withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: (_speakingText == message.text
                                        ? Colors.redAccent
                                        : AppColors.liquidCyanNeon)
                                    .withOpacity(0.35),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _speakingText == message.text
                                      ? Icons.stop_rounded
                                      : Icons.volume_up_rounded,
                                  size: 13,
                                  color: _speakingText == message.text
                                      ? Colors.redAccent
                                      : AppColors.liquidCyanNeon,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _speakingText == message.text
                                      ? state.tr('aiStopAudio')
                                      : state.tr('aiListen'),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: _speakingText == message.text
                                        ? Colors.redAccent
                                        : AppColors.liquidCyanNeon,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Copy Text
                        InkWell(
                          borderRadius: BorderRadius.circular(6),
                          onTap: () => _copyToClipboard(message.text, state.tr('aiCopiedToast')),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFF334155)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.copy_rounded, size: 11, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  state.tr('aiCopyAll'),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Export CSV if table exists in message
                        if (hasTable)
                          InkWell(
                            borderRadius: BorderRadius.circular(6),
                            onTap: () {
                              final blocks = _parseMarkdownBlocks(message.text);
                              final tables = blocks.whereType<_TableBlock>().toList();
                              if (tables.isNotEmpty) {
                                final csv = tables.map((t) => t.toCsv()).join('\n\n');
                                _exportCsv(csv, 'bishe_export_${DateTime.now().millisecondsSinceEpoch}.csv', state);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.statusCompleted.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.statusCompleted.withOpacity(0.4)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.download_rounded, size: 12, color: AppColors.statusCompleted),
                                  const SizedBox(width: 4),
                                  Text(
                                    state.tr('aiExportCsv'),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.statusCompleted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        // Copy Table if table exists in message
                        if (hasTable)
                          InkWell(
                            borderRadius: BorderRadius.circular(6),
                            onTap: () {
                              final blocks = _parseMarkdownBlocks(message.text);
                              final tables = blocks.whereType<_TableBlock>().toList();
                              if (tables.isNotEmpty) {
                                final txt = tables.map((t) => t.toPlainText()).join('\n\n');
                                _copyToClipboard(txt, state.tr('aiCopiedToast'));
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFF334155)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.table_chart_rounded, size: 12, color: AppColors.liquidCyanNeon),
                                  const SizedBox(width: 4),
                                  Text(
                                    state.tr('aiCopyTable'),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.liquidCyanNeon,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
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

  Widget _buildStructuredAiMessage(String rawText, dynamic state) {
    final blocks = _parseMarkdownBlocks(rawText);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blocks.map((block) {
        if (block is _HeaderBlock) {
          return _buildHeaderBlock(block);
        } else if (block is _KpiStripBlock) {
          return _buildKpiStripBlock(block);
        } else if (block is _TableBlock) {
          return _buildTableBlock(block, state);
        } else if (block is _BulletBlock) {
          return _buildBulletBlock(block);
        } else if (block is _CalloutBlock) {
          return _buildCalloutBlock(block);
        } else if (block is _ParagraphBlock) {
          return _buildParagraphBlock(block);
        }
        return const SizedBox.shrink();
      }).toList(),
    );
  }

  List<_AiBlock> _parseMarkdownBlocks(String rawText) {
    final List<_AiBlock> blocks = [];
    final lines = rawText.split('\n');
    int i = 0;

    while (i < lines.length) {
      final line = lines[i].trim();

      if (line.isEmpty) {
        i++;
        continue;
      }

      // 1. Header 3 or 4
      if (line.startsWith('### ')) {
        blocks.add(_HeaderBlock(3, line.substring(4).trim()));
        i++;
        continue;
      }
      if (line.startsWith('#### ')) {
        blocks.add(_HeaderBlock(4, line.substring(5).trim()));
        i++;
        continue;
      }

      // 2. Callout / Quote (starts with '>' or '⚠️ *[')
      if (line.startsWith('>') || line.startsWith('⚠️ *[')) {
        final calloutText = line.startsWith('>') ? line.substring(1).trim() : line;
        blocks.add(_CalloutBlock(calloutText));
        i++;
        continue;
      }

      // 3. KPI summary line (e.g. *Total Registered: **10** | Completed: **8** ...*)
      if (line.startsWith('*') && line.endsWith('*') && line.contains('|') && !line.contains(':---')) {
        final inner = line.substring(1, line.length - 1).trim();
        final parts = inner.split('|');
        if (parts.length >= 2 && parts.any((p) => p.contains(':'))) {
          final items = <Map<String, String>>[];
          for (final part in parts) {
            final colIdx = part.indexOf(':');
            if (colIdx != -1) {
              final label = part.substring(0, colIdx).replaceAll('**', '').trim();
              final val = part.substring(colIdx + 1).replaceAll('**', '').trim();
              items.add({'label': label, 'value': val});
            } else {
              items.add({'label': '', 'value': part.replaceAll('**', '').trim()});
            }
          }
          blocks.add(_KpiStripBlock(items));
          i++;
          continue;
        }
      }

      // 4. Markdown Table
      if (line.startsWith('|') && line.endsWith('|')) {
        final tableLines = <String>[];
        while (i < lines.length && lines[i].trim().startsWith('|') && lines[i].trim().endsWith('|')) {
          tableLines.add(lines[i].trim());
          i++;
        }

        if (tableLines.length >= 2) {
          final headerLine = tableLines[0];
          final headers = headerLine
              .substring(1, headerLine.length - 1)
              .split('|')
              .map((c) => c.trim())
              .toList();

          final rows = <List<String>>[];
          for (int t = 1; t < tableLines.length; t++) {
            final rLine = tableLines[t];
            // Skip separator line | :--- | :--- |
            if (RegExp(r'^\|[\s\-:]+\|\s*$').hasMatch(rLine)) {
              continue;
            }
            final cells = rLine
                .substring(1, rLine.length - 1)
                .split('|')
                .map((c) => c.trim())
                .toList();

            while (cells.length < headers.length) {
              cells.add('');
            }
            rows.add(cells.take(headers.length).toList());
          }

          blocks.add(_TableBlock(headers, rows));
          continue;
        }
      }

      // 5. Bullet item
      if (line.startsWith('- ') || line.startsWith('* ') || line.startsWith('• ')) {
        final bulletText = line.substring(2).trim();
        blocks.add(_BulletBlock(bulletText));
        i++;
        continue;
      }

      // 6. Default: Paragraph
      blocks.add(_ParagraphBlock(line));
      i++;
    }

    return blocks;
  }

  Widget _buildHeaderBlock(_HeaderBlock block) {
    return Padding(
      padding: EdgeInsets.only(top: block.level == 3 ? 12 : 8, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 3.5,
            height: block.level == 3 ? 16 : 13,
            decoration: BoxDecoration(
              color: block.level == 3 ? AppColors.liquidCyanNeon : AppColors.primaryLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              block.text,
              style: TextStyle(
                fontSize: block.level == 3 ? 13.5 : 12,
                fontWeight: FontWeight.w800,
                color: block.level == 3 ? Colors.white : AppColors.liquidCyanNeon,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiStripBlock(_KpiStripBlock block) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: block.items.map((item) {
            final label = item['label'] ?? '';
            final val = item['value'] ?? '';
            return Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF141E33), Color(0xFF0F172A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0x4400E5FF)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (label.isNotEmpty)
                    Text(
                      label,
                      style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    val,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.liquidCyanNeon),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTableBlock(_TableBlock block, dynamic state) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0B132B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Action Header above the table
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: const BoxDecoration(
              color: Color(0xFF162038),
              borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
              border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
            ),
            child: Row(
              children: [
                const Icon(Icons.table_chart_rounded, size: 13, color: AppColors.liquidCyanNeon),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    state.tr('aiTableHint'),
                    style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted, fontStyle: FontStyle.italic),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                InkWell(
                  onTap: () {
                    final csv = block.toCsv();
                    _exportCsv(csv, 'bishe_report_${DateTime.now().millisecondsSinceEpoch}.csv', state);
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.statusCompleted.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.statusCompleted.withOpacity(0.4)),
                    ),
                    child: const Icon(Icons.download_rounded, size: 13, color: AppColors.statusCompleted),
                  ),
                ),
                const SizedBox(width: 6),
                InkWell(
                  onTap: () {
                    final txt = block.toPlainText();
                    _copyToClipboard(txt, state.tr('aiCopiedToast'));
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: const Icon(Icons.copy_rounded, size: 12, color: AppColors.liquidCyanNeon),
                  ),
                ),
              ],
            ),
          ),
          // Horizontally Scrollable Table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: {
                  for (int i = 0; i < block.headers.length; i++)
                    i: const IntrinsicColumnWidth(),
                },
                children: [
                  // Header row
                  TableRow(
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E293B),
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                    ),
                    children: block.headers.map((h) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      child: Text(
                        h.replaceAll('**', '').trim(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.liquidCyanNeon,
                          letterSpacing: 0.3,
                        ),
                      ),
                    )).toList(),
                  ),
                  // Data rows
                  for (int rIdx = 0; rIdx < block.rows.length; rIdx++)
                    TableRow(
                      decoration: BoxDecoration(
                        color: rIdx % 2 == 1 ? const Color(0xFF131D31) : Colors.transparent,
                        border: const Border(bottom: BorderSide(color: Color(0xFF1E293B), width: 0.8)),
                      ),
                      children: block.rows[rIdx].map((cell) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: _buildCellWidget(cell.trim()),
                      )).toList(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCellWidget(String rawCell) {
    final cell = rawCell.trim();
    final upper = cell.toUpperCase();

    // Monospace code / license plate: `3-B12345` or WALK-IN
    if (cell.startsWith('`') && cell.endsWith('`')) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0x5500E5FF)),
        ),
        child: Text(
          cell.replaceAll('`', ''),
          style: const TextStyle(fontSize: 10.5, fontFamily: 'monospace', fontWeight: FontWeight.bold, color: Colors.white),
        ),
      );
    }

    // Completed / Healthy / Paid / On Duty Tag
    if (upper.contains('COMPLETED') || upper.contains('HEALTHY') || upper.contains('ON DUTY') || upper.contains('PAID')) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0x2210B981),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0x6610B981)),
        ),
        child: Text(
          cell.replaceAll('**', ''),
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF34D399)),
        ),
      );
    }

    // Pending / In Queue / Re-order Tag
    if (upper.contains('PENDING') || upper.contains('IN QUEUE') || upper.contains('RE-ORDER') || upper.contains('OFF DUTY')) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0x22F59E0B),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0x66F59E0B)),
        ),
        child: Text(
          cell.replaceAll('**', ''),
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFFBBF24)),
        ),
      );
    }

    // Type A Tag
    if (upper.contains('TYPE A') || upper.contains('AUTOMOBILE') || upper.contains('SEDAN')) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0x226366F1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0x666366F1)),
        ),
        child: Text(
          cell.replaceAll('**', ''),
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF818CF8)),
        ),
      );
    }

    // Type B Tag
    if (upper.contains('TYPE B') || upper.contains('SUV') || upper.contains('MINIBUS')) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0x220EA5E9),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0x660EA5E9)),
        ),
        child: Text(
          cell.replaceAll('**', ''),
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8)),
        ),
      );
    }

    // Type C Tag
    if (upper.contains('TYPE C') || upper.contains('TRUCK')) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0x22EC4899),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0x66EC4899)),
        ),
        child: Text(
          cell.replaceAll('**', ''),
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFF472B6)),
        ),
      );
    }

    // Default cell text with RichText (supports bold ** and ETB)
    return SelectableText.rich(
      _buildRichSpan(
        cell,
        defaultColor: cell.contains('ETB') ? Colors.white : AppColors.textPrimary,
        fontSize: 11,
      ),
    );
  }

  Widget _buildBulletBlock(_BulletBlock block) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '•',
            style: TextStyle(color: AppColors.liquidCyanNeon, fontSize: 13, height: 1.3),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SelectableText.rich(
              _buildRichSpan(block.text, fontSize: 11.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalloutBlock(_CalloutBlock block) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0x1800E5FF),
        borderRadius: BorderRadius.circular(8),
        border: const Border(left: BorderSide(color: AppColors.liquidCyanNeon, width: 3)),
      ),
      child: SelectableText.rich(
        _buildRichSpan(
          block.text,
          defaultColor: const Color(0xFFE2E8F0),
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildParagraphBlock(_ParagraphBlock block) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: SelectableText.rich(
        _buildRichSpan(block.text, fontSize: 12),
      ),
    );
  }

  TextSpan _buildRichSpan(
    String text, {
    Color? defaultColor,
    double fontSize = 12.0,
  }) {
    final spans = <InlineSpan>[];
    final regex = RegExp(r'(\*\*.*?\*\*|`.*?`)');
    int lastEnd = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: TextStyle(
            color: defaultColor ?? AppColors.textPrimary,
            fontSize: fontSize,
            fontFamily: 'NotoSansEthiopic',
            height: 1.4,
          ),
        ));
      }
      final matchedText = match.group(0)!;
      if (matchedText.startsWith('**') && matchedText.endsWith('**')) {
        spans.add(TextSpan(
          text: matchedText.substring(2, matchedText.length - 2),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
            fontFamily: 'NotoSansEthiopic',
            height: 1.4,
          ),
        ));
      } else if (matchedText.startsWith('`') && matchedText.endsWith('`')) {
        spans.add(TextSpan(
          text: matchedText.substring(1, matchedText.length - 1),
          style: TextStyle(
            color: AppColors.liquidCyanNeon,
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            fontSize: fontSize - 0.5,
          ),
        ));
      }
      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: TextStyle(
          color: defaultColor ?? AppColors.textPrimary,
          fontSize: fontSize,
          fontFamily: 'NotoSansEthiopic',
          height: 1.4,
        ),
      ));
    }

    return TextSpan(children: spans);
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
          IconButton(
            icon: Icon(
              _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
              size: 20,
              color: _isListening ? Colors.redAccent : AppColors.liquidCyanNeon,
            ),
            tooltip: _isListening ? state.tr('aiMicListening') : state.tr('aiMicTooltip'),
            onPressed: _toggleListening,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: TextField(
              controller: _inputController,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: _isListening
                    ? state.tr('aiMicListening')
                    : (state.currentRole == UserRole.customer
                        ? state.tr('askAiCustomerHint')
                        : state.tr('askAiHint')),
                hintStyle: TextStyle(
                  fontSize: 12,
                  color: _isListening ? Colors.redAccent : AppColors.textMuted,
                  fontStyle: _isListening ? FontStyle.italic : FontStyle.normal,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: _isListening ? Colors.redAccent : const Color(0xFF334155),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: _isListening ? Colors.redAccent : const Color(0xFF334155),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: _isListening ? Colors.redAccent : AppColors.liquidCyanNeon,
                    width: 1.5,
                  ),
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
