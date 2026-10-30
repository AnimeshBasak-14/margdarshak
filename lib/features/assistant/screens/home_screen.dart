import 'package:flutter/material.dart';

import '../../../core/session.dart';
import '../../../core/theme/aura.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/glow_backdrop.dart';
import '../../../core/widgets/soft_route.dart';
import '../../../core/widgets/raah_mark.dart';
import '../widgets/language_sheet.dart';
import '../widgets/prompt_card.dart';
import 'chat_screen.dart';
import 'voice_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const prompts = [
    'Am I eligible for SSC CGL based on my age?',
    'Banking exams with over 1,000 vacancies',
    'Negative marking in SSC CGL Tier 1 and 2',
    'Can I apply to BPSC from another state?',
  ];

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _input = TextEditingController();

  @override
  void initState() {
    super.initState();
    _input.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _ask(String query) {
    if (query.trim().isEmpty) return;
    _input.clear();
    FocusScope.of(context).unfocus();
    Navigator.of(context).push(softRoute(ChatScreen(initialQuery: query)));
  }

  void _listen() {
    FocusScope.of(context).unfocus();
    Navigator.of(context).push(softRoute(const VoiceScreen()));
  }

  void _soon(String what) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$what is coming soon.')));
  }

  @override
  Widget build(BuildContext context) {
    final a = context.aura;
    final width = MediaQuery.sizeOf(context).width;
    // Cards grow with the system text size so the prompts stay readable.
    final scaler = MediaQuery.textScalerOf(context);
    final cardWidth = (scaler.scale(172) * 0.85 + 26).clamp(172.0, 240.0);
    final cardHeight = scaler.scale(15) * 1.25 * 4 + 78;

    return Scaffold(
      body: GlowBackdrop(
        reach: 0.6,
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          AuraSpace.gutter, 12, AuraSpace.gutter, 0),
                      child: _Header(
                        onAlerts: () => _soon('Exam alerts'),
                        onToggleTheme: () => SessionScope.of(context)
                            .toggleTheme(Theme.of(context).brightness),
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AuraSpace.gutter),
                      child: Semantics(
                        header: true,
                        child: Text(
                          'What are we aiming for today?',
                          style: AuraType.display(
                              (width * 0.105).clamp(32, 48), a.ink),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: cardHeight,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: AuraSpace.gutter),
                        itemCount: HomeScreen.prompts.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemBuilder: (_, i) => PromptCard(
                          width: cardWidth,
                          text: HomeScreen.prompts[i],
                          onTap: () => _ask(HomeScreen.prompts[i]),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _Composer(
                      controller: _input,
                      onSubmit: () => _ask(_input.text),
                      onListen: _listen,
                      onAttach: () => _soon('Uploading notification PDFs'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onAlerts;
  final VoidCallback onToggleTheme;

  const _Header({required this.onAlerts, required this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    final a = context.aura;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: a.bg,
            border: Border.all(color: a.ink, width: 1.5),
          ),
          alignment: Alignment.center,
          child: RaahMark(size: 28, color: a.ink),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Namaste,', style: AuraType.sans(14, a.inkMuted)),
              Text('Welcome back',
                  style: AuraType.sans(15, a.ink, weight: FontWeight.w500)),
            ],
          ),
        ),
        CircleIconButton(
          icon: Icons.notifications_none_rounded,
          tooltip: 'Exam alerts',
          onPressed: onAlerts,
        ),
        const SizedBox(width: 8),
        CircleIconButton(
          icon: dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          tooltip: dark ? 'Switch to light mode' : 'Switch to dark mode',
          onPressed: onToggleTheme,
        ),
      ],
    );
  }
}

/// The big ask box at the bottom of home: type a question, or tap the mic.
class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;
  final VoidCallback onListen;
  final VoidCallback onAttach;

  const _Composer({
    required this.controller,
    required this.onSubmit,
    required this.onListen,
    required this.onAttach,
  });

  @override
  Widget build(BuildContext context) {
    final a = context.aura;
    final session = SessionScope.of(context);
    final hasText = controller.text.trim().isNotEmpty;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      margin: EdgeInsets.fromLTRB(10, 0, 10, bottomInset + 10),
      padding: const EdgeInsets.fromLTRB(22, 8, 14, 14),
      decoration: BoxDecoration(
        color: a.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AuraSpace.radiusL),
        border: Border.all(color: a.hairline),
        boxShadow: a.elevatedShadow,
      ),
      child: Column(
        children: [
          TextField(
            controller: controller,
            minLines: 4,
            maxLines: 6,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => onSubmit(),
            style: AuraType.sans(18, a.ink),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Ask about any exam, or tell me about yourself',
              hintStyle: AuraType.sans(18, a.inkFaint),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              CircleIconButton(
                icon: Icons.attach_file_rounded,
                tooltip: 'Attach a notification PDF',
                onPressed: onAttach,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: PillButton(
                    label: session.language.nativeName,
                    trailing: Icons.keyboard_arrow_down_rounded,
                    semanticLabel:
                        'Speaking language: ${session.language.englishName}. Change',
                    onPressed: () => showLanguageSheet(context),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              MicButton(
                icon: hasText
                    ? Icons.arrow_upward_rounded
                    : Icons.mic_rounded,
                tooltip: hasText ? 'Send' : 'Speak your question',
                onPressed: hasText ? onSubmit : onListen,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
