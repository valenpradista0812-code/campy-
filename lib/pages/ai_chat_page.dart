import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class AiChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  AiChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class AiChatPage extends StatefulWidget {
  final String? initialPrompt;

  const AiChatPage({super.key, this.initialPrompt});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final TextEditingController _textC = TextEditingController();
  final ScrollController _scrollC = ScrollController();
  final List<AiChatMessage> _messages = [];
  bool _isLoading = false;

  final List<String> _quickPrompts = [
    'Rekomendasi tenda 4 orang',
    'Perlengkapan camping pemula',
    'Tips camping saat musim hujan',
    'Peralatan masak outdoor praktis',
    'Tips mendaki gunung aman',
  ];

  @override
  void initState() {
    super.initState();
    // Welcome message from Campy AI
    _messages.add(
      AiChatMessage(
        text:
            'Halo! Saya Campy AI Assistant yang ditenagai oleh Google Gemini. 🏕️\n\nAda yang bisa saya bantu untuk persiapan camping, sewa alat, atau tips mendaki gunung Anda?',
        isUser: false,
      ),
    );

    if (widget.initialPrompt != null && widget.initialPrompt!.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendMessage(widget.initialPrompt!.trim());
      });
    }
  }

  @override
  void dispose() {
    _textC.dispose();
    _scrollC.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollC.hasClients) {
        _scrollC.animateTo(
          _scrollC.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isLoading) return;

    _textC.clear();
    setState(() {
      _messages.add(AiChatMessage(text: trimmed, isUser: true));
      _isLoading = true;
    });
    _scrollToBottom();

    // Prepare history for API context
    final history = _messages
        .take(_messages.length - 1)
        .map((m) => {
              'role': m.isUser ? 'user' : 'model',
              'text': m.text,
            })
        .toList();

    final reply = await ApiService.askCampyAi(trimmed, history: history);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _messages.add(AiChatMessage(text: reply, isUser: false));
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 24),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 18,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Campy AI Assistant',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Gemini AI • Online',
                      style: TextStyle(fontSize: 10, color: AppColors.muted),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const Divider(height: 1),

          // ── Chat Messages List ─────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              controller: _scrollC,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),

          // ── Loading Indicator saat AI sedang mengetik ──────────────────────
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.lightGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Campy AI sedang berpikir...',
                    style: TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

          // ── Quick Prompt Chips ─────────────────────────────────────────────
          Container(
            height: 38,
            margin: const EdgeInsets.only(bottom: 6),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _quickPrompts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, i) {
                final prompt = _quickPrompts[i];
                return InkWell(
                  onTap: _isLoading ? null : () => _sendMessage(prompt),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.fieldBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.lightbulb_outline,
                          size: 13,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          prompt,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Input Field Bar ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.fieldBg,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      controller: _textC,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _sendMessage,
                      maxLines: null,
                      style: const TextStyle(fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'Tanyakan rekomendasi alat camping...',
                        hintStyle: TextStyle(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _isLoading ? null : () => _sendMessage(_textC.text),
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: _isLoading ? AppColors.muted : AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(AiChatMessage msg) {
    if (msg.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10, left: 48),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(14),
              topRight: Radius.circular(14),
              bottomLeft: Radius.circular(14),
              bottomRight: Radius.circular(2),
            ),
          ),
          child: Text(
            msg.text,
            style: const TextStyle(
              fontSize: 12.5,
              color: Colors.white,
              height: 1.4,
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, right: 36),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.fieldBg,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(14),
            bottomLeft: Radius.circular(2),
            bottomRight: Radius.circular(14),
          ),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.auto_awesome, size: 12, color: AppColors.primary),
                SizedBox(width: 4),
                Text(
                  'Campy AI',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            SelectableText(
              msg.text,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textDark,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
