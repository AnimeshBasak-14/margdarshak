import 'package:flutter/material.dart';

import '../theme/aura.dart';

/// Frosted round button for secondary actions (alerts, theme, attach).
class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final double size;
  final bool outlined;

  const CircleIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.size = 48,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final a = context.aura;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: outlined ? Colors.transparent : a.surface.withValues(alpha: 0.7),
        shape: CircleBorder(side: BorderSide(color: a.hairline)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox.square(
            dimension: size,
            child: Icon(icon,
                size: size * 0.42,
                color: onPressed == null
                    ? a.inkFaint.withValues(alpha: 0.4)
                    : a.inkMuted),
          ),
        ),
      ),
    );
  }
}

/// Pill with an optional leading and trailing icon ("✕ Close chat",
/// "हिन्दी ⌄").
class PillButton extends StatelessWidget {
  final String label;
  final IconData? leading;
  final IconData? trailing;
  final VoidCallback? onPressed;
  final String? semanticLabel;

  const PillButton({
    super.key,
    required this.label,
    this.leading,
    this.trailing,
    required this.onPressed,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final a = context.aura;
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: semanticLabel != null,
      child: Material(
        color: a.surface.withValues(alpha: 0.75),
        shape: StadiumBorder(side: BorderSide(color: a.hairline)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Padding(
              padding: EdgeInsets.only(
                left: leading == null ? 18 : 14,
                right: trailing == null ? 18 : 12,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leading != null) ...[
                    Icon(leading, size: 18, color: a.ink),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AuraType.sans(15, a.ink, weight: FontWeight.w500),
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 6),
                    Icon(trailing, size: 18, color: a.inkMuted),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The primary action: a glossy accent disc with a mic (or send) glyph.
class MicButton extends StatelessWidget {
  final double size;
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const MicButton({
    super.key,
    this.size = 56,
    this.icon = Icons.mic_rounded,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final a = context.aura;
    return Tooltip(
      message: tooltip,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: a.accentGradient,
          ),
          boxShadow: [
            BoxShadow(
              color: a.orbHalo,
              blurRadius: size * 0.4,
              offset: Offset(0, size * 0.12),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: SizedBox.square(
              dimension: size,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Icon(icon,
                    key: ValueKey(icon), size: size * 0.45, color: a.onAccent),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
