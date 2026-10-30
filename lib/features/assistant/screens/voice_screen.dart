import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/session.dart';
import '../../../core/theme/aura.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/glow_backdrop.dart';
import '../../../core/widgets/soft_route.dart';
import '../widgets/voice_orb.dart';
import 'chat_screen.dart';

/// Full-screen listening mode: the orb, the live transcript, and controls to
/// start over, pause, or send.
///
/// Speech recognition is simulated here (a sample question is "heard" word
/// by word) until Bhashini ASR is connected.
class VoiceScreen extends StatefulWidget {
  /// When opened from a chat, hand the transcript back instead of starting a
  /// new conversation.
  final bool returnTranscript;

  const VoiceScreen({super.key, this.returnTranscript = false});

  static const _samples = {
    AppLanguage.hindi:
        'क्या मैं इस साल SSC CGL के लिए पात्र हूँ? मेरा जन्म मार्च 2001 में '
            'हुआ था और मैंने पिछले साल B.Com पूरा किया।',
  };
  static const _sampleEnglish =
      'Am I eligible for SSC CGL this year? I was born in March 2001 and '
      'I finished my B.Com last summer.';

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> {
  /// Words at the end of the transcript that may still change.
  static const _tentative = 4;

  final _level = ValueNotifier<double>(0);
  final _rng = math.Random();
  late List<String> _words;
  int _heard = 0;
  bool _listening = true;
  Timer? _wordTimer;
  Timer? _meterTimer;

  bool get _done => _heard >= _words.length;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final lang = SessionScope.of(context).language;
    _words = (VoiceScreen._samples[lang] ?? VoiceScreen._sampleEnglish)
        .split(' ');
    _wordTimer ??= Timer.periodic(const Duration(milliseconds: 290), _hear);
    _meterTimer ??= Timer.periodic(const Duration(milliseconds: 60), _meter);
  }

  void _hear(Timer _) {
    if (!_listening || _done) return;
    setState(() => _heard++);
  }

  void _meter(Timer _) {
    final speaking = _listening && !_done;
    final target = speaking
        ? 0.25 + _rng.nextDouble() * 0.75
        : (_listening ? 0.04 + _rng.nextDouble() * 0.06 : 0.0);
    _level.value += (target - _level.value) * 0.3;
  }

  @override
  void dispose() {
    _wordTimer?.cancel();
    _meterTimer?.cancel();
    _level.dispose();
    super.dispose();
  }

  void _startOver() => setState(() {
        _heard = 0;
        _listening = true;
      });

  void _toggleListening() => setState(() => _listening = !_listening);

  void _send() {
    if (_heard == 0) return;
    final text = _words.take(_heard).join(' ');
    if (widget.returnTranscript) {
      Navigator.of(context).pop(text);
    } else {
      Navigator.of(context)
          .pushReplacement(softRoute(ChatScreen(initialQuery: text)));
    }
  }

  String get _status {
    if (_heard == 0 && !_listening) return 'Paused';
    if (!_listening) return 'Paused. Tap the mic to carry on.';
    if (_done) return 'Got it. Tap send when you\'re ready.';
    return 'Raah is listening…';
  }

  @override
  Widget build(BuildContext context) {
    final a = context.aura;
    final size = MediaQuery.sizeOf(context);
    final orbSize = math.min(size.width * 0.68, size.height * 0.34);
    final settled = _done ? _heard : math.max(0, _heard - _tentative);

    return Scaffold(
      body: GlowBackdrop(
        shape: GlowShape.well,
        wellCenter: const Alignment(0, -0.15),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              PillButton(
                label: 'Close chat',
                leading: Icons.close_rounded,
                onPressed: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        VoiceOrb(size: orbSize, level: _level),
                        const SizedBox(height: 20),
                        Semantics(
                          liveRegion: true,
                          child: Text(_status,
                              textAlign: TextAlign.center,
                              style: AuraType.sans(13, a.inkFaint)),
                        ),
                        const SizedBox(height: 28),
                        _heard == 0
                            ? Text(
                                'Ask about an exam, your eligibility or a deadline.',
                                textAlign: TextAlign.center,
                                style: _transcriptStyle(a.inkFaint),
                              )
                            : Text.rich(
                                TextSpan(children: [
                                  TextSpan(
                                    text: _words.take(settled).join(' '),
                                    style: _transcriptStyle(a.ink),
                                  ),
                                  if (settled < _heard)
                                    TextSpan(
                                      text:
                                          '${settled > 0 ? ' ' : ''}${_words.sublist(settled, _heard).join(' ')}',
                                      style: _transcriptStyle(a.inkFaint),
                                    ),
                                ]),
                                textAlign: TextAlign.center,
                              ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleIconButton(
                      icon: Icons.replay_rounded,
                      tooltip: 'Start over',
                      outlined: true,
                      onPressed: _heard == 0 ? null : _startOver,
                    ),
                    const SizedBox(width: 32),
                    _MicRing(
                      level: _level,
                      child: MicButton(
                        size: 78,
                        icon: _listening
                            ? Icons.mic_rounded
                            : Icons.mic_off_rounded,
                        tooltip: _listening ? 'Pause' : 'Keep listening',
                        onPressed: _toggleListening,
                      ),
                    ),
                    const SizedBox(width: 32),
                    CircleIconButton(
                      icon: Icons.send_rounded,
                      tooltip: 'Send',
                      outlined: true,
                      onPressed: _heard == 0 ? null : _send,
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

  TextStyle _transcriptStyle(Color color) => AuraType.sans(26, color,
      weight: FontWeight.w500, height: 1.28, letterSpacing: -0.6);
}

/// Hairline ring around the mic that breathes with the voice level.
class _MicRing extends StatelessWidget {
  final ValueListenable<double> level;
  final Widget child;

  const _MicRing({required this.level, required this.child});

  @override
  Widget build(BuildContext context) {
    final a = context.aura;
    return SizedBox.square(
      dimension: 112,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ValueListenableBuilder<double>(
            valueListenable: level,
            builder: (_, l, _) => Transform.scale(
              scale: 1 + l * 0.08,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: a.bg.withValues(alpha: 0.4),
                  border: Border.all(color: a.hairline, width: 1.2),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
