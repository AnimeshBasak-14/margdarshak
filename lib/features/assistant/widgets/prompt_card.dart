import 'package:flutter/material.dart';

import '../../../core/theme/aura.dart';

/// One-tap starter question. Also shows new users what they can ask.
class PromptCard extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final double width;

  const PromptCard({
    super.key,
    required this.text,
    required this.onTap,
    this.width = 172,
  });

  @override
  Widget build(BuildContext context) {
    final a = context.aura;
    return SizedBox(
      width: width,
      child: Material(
        color: a.surface.withValues(alpha: 0.85),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AuraSpace.radius),
          side: BorderSide(color: a.hairline),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.auto_awesome, size: 22, color: a.accent),
                const Spacer(),
                Text(
                  text,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: AuraType.sans(15, a.ink,
                      weight: FontWeight.w500, height: 1.25),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
