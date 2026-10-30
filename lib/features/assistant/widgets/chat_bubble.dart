import 'package:flutter/material.dart';

import '../../../core/theme/aura.dart';
import '../models.dart';
import 'voice_orb.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final a = context.aura;
    final maxWidth = MediaQuery.sizeOf(context).width * 0.8;

    if (message.sender == Sender.user) {
      return Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: a.accentGradient,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AuraSpace.radius),
                topRight: Radius.circular(AuraSpace.radius),
                bottomLeft: Radius.circular(AuraSpace.radius),
                bottomRight: Radius.circular(8),
              ),
              boxShadow: a.shadow,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Text(message.text,
                  style: AuraType.sans(15.5, a.onAccent, height: 1.4)),
            ),
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 4),
          child: VoiceOrb(size: 36, animate: false),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: a.surface.withValues(alpha: 0.92),
                border: Border.all(color: a.hairline),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(AuraSpace.radius),
                  bottomLeft: Radius.circular(AuraSpace.radius),
                  bottomRight: Radius.circular(AuraSpace.radius),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message.text,
                      style: AuraType.sans(15.5, a.ink, height: 1.45)),
                  if (message.facts.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < message.facts.length; i++) ...[
                            if (i > 0) const SizedBox(width: 8),
                            Expanded(child: _FactTile(message.facts[i])),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A key number in large type, the way the eye wants to find it.
class _FactTile extends StatelessWidget {
  final KeyFact fact;
  const _FactTile(this.fact);

  @override
  Widget build(BuildContext context) {
    final a = context.aura;
    final color = switch (fact.tone) {
      FactTone.neutral => a.ink,
      FactTone.review => a.review,
      FactTone.success => a.success,
    };
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: a.bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: a.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(fact.value, style: AuraType.digits(24, color)),
          ),
          const SizedBox(height: 4),
          Text(fact.label,
              style: AuraType.sans(12, a.inkMuted, height: 1.3)),
        ],
      ),
    );
  }
}
