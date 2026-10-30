import 'package:flutter/material.dart';

import '../../../core/session.dart';
import '../../../core/theme/aura.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/glow_backdrop.dart';
import '../../../core/widgets/soft_route.dart';
import '../chat_controller.dart';
import '../data/assistant_service.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/voice_orb.dart';
import 'voice_screen.dart';

class ChatScreen extends StatefulWidget {
  final String initialQuery;
  const ChatScreen({super.key, required this.initialQuery});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _chat = ChatController(const DemoAssistantService());
  final _input = TextEditingController();
  final _scroll = ScrollController();
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _chat.addListener(_onChat);
    _input.addListener(() => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      _chat.send(widget.initialQuery, SessionScope.of(context).language);
    }
  }

  @override
  void dispose() {
    _chat.dispose();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onChat() {
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _send(String text) {
    if (text.trim().isEmpty || _chat.busy) return;
    _input.clear();
    _chat.send(text, SessionScope.of(context).language);
  }

  Future<void> _listen() async {
    FocusScope.of(context).unfocus();
    final heard = await Navigator.of(context)
        .push<String>(softRoute(const VoiceScreen(returnTranscript: true)));
    if (heard != null && mounted) _send(heard);
  }

  @override
  Widget build(BuildContext context) {
    final messages = _chat.messages;

    return Scaffold(
      body: GlowBackdrop(
        reach: 0.42,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              PillButton(
                label: 'Close chat',
                leading: Icons.close_rounded,
                onPressed: () =>
                    Navigator.of(context).popUntil((r) => r.isFirst),
              ),
              Expanded(
                child: ListView(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(14, 28, 14, 16),
                  children: [
                    for (var i = 0; i < messages.length; i++)
                      Padding(
                        key: ValueKey(i),
                        padding: const EdgeInsets.only(bottom: 18),
                        child: _Appear(child: ChatBubble(message: messages[i])),
                      ),
                    if (_chat.busy) _Working(stage: _chat.stage!),
                  ],
                ),
              ),
              _FollowUpBar(
                controller: _input,
                busy: _chat.busy,
                onSend: () => _send(_input.text),
                onListen: _listen,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Live pipeline status, so it's clear what the assistant is doing:
/// "Translating from Hindi…" → "Searching notifications…" → …
class _Working extends StatelessWidget {
  final String stage;
  const _Working({required this.stage});

  @override
  Widget build(BuildContext context) {
    final a = context.aura;
    return Semantics(
      liveRegion: true,
      child: Row(
        children: [
          const VoiceOrb(size: 36),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Raah is working…',
                    style: AuraType.sans(13, a.inkFaint)),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    stage,
                    key: ValueKey(stage),
                    style: AuraType.sans(14, a.inkMuted,
                        weight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FollowUpBar extends StatelessWidget {
  final TextEditingController controller;
  final bool busy;
  final VoidCallback onSend;
  final VoidCallback onListen;

  const _FollowUpBar({
    required this.controller,
    required this.busy,
    required this.onSend,
    required this.onListen,
  });

  @override
  Widget build(BuildContext context) {
    final a = context.aura;
    final hasText = controller.text.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
      decoration: BoxDecoration(
        color: a.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: a.hairline),
        boxShadow: a.elevatedShadow,
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Attach a notification PDF',
            icon: Icon(Icons.attach_file_rounded, color: a.inkMuted),
            onPressed: () => ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(const SnackBar(
                  content: Text('Uploading notification PDFs is coming soon.'))),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              style: AuraType.sans(17, a.ink),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: 'Ask a follow-up',
                hintStyle: AuraType.sans(17, a.inkFaint),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (hasText)
            MicButton(
              size: 44,
              icon: Icons.arrow_upward_rounded,
              tooltip: busy ? 'Wait for the reply' : 'Send',
              onPressed: busy ? null : onSend,
            )
          else
            IconButton(
              tooltip: 'Speak your question',
              icon: Icon(Icons.mic_rounded, color: a.ink),
              onPressed: onListen,
            ),
        ],
      ),
    );
  }
}

/// Fades and lifts a message in the first time it is built.
class _Appear extends StatelessWidget {
  final Widget child;
  const _Appear({required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      builder: (_, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, (1 - t) * 12), child: child),
      ),
      child: child,
    );
  }
}
