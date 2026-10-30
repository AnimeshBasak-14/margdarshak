import 'package:flutter/material.dart';

import '../../../core/session.dart';
import '../../../core/theme/aura.dart';

/// Lets the user pick the language they will speak in. Answers are spoken
/// back in the same language.
Future<void> showLanguageSheet(BuildContext context) {
  final session = SessionScope.of(context);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      final a = context.aura;
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
              AuraSpace.gutter, 0, AuraSpace.gutter, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Speak in your language',
                  style: AuraType.sans(20, a.ink, weight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('Raah listens and replies in the language you pick.',
                  style: AuraType.sans(14, a.inkMuted)),
              const SizedBox(height: 16),
              for (final lang in AppLanguage.values)
                _LanguageTile(
                  language: lang,
                  selected: lang == session.language,
                  onTap: () {
                    session.language = lang;
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        ),
      );
    },
  );
}

class _LanguageTile extends StatelessWidget {
  final AppLanguage language;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.language,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final a = context.aura;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? a.accentSoft : a.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: selected ? a.accent : a.hairline),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(language.nativeName,
                      style:
                          AuraType.sans(17, a.ink, weight: FontWeight.w500)),
                ),
                if (language.nativeName != language.englishName)
                  Text(language.englishName,
                      style: AuraType.sans(14, a.inkFaint)),
                if (selected) ...[
                  const SizedBox(width: 10),
                  Icon(Icons.check_rounded, size: 20, color: a.accent),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
