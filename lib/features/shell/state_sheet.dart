import 'package:flutter/material.dart';

import '../../core/session.dart';
import '../../core/states.dart';
import '../../core/theme/aura.dart';

/// Pick the state to follow, or "All India".
Future<void> showStateSheet(BuildContext context) {
  final session = SessionScope.of(context);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) {
      final a = context.aura;
      Widget tile(String? code, String name) {
        final selected = code == session.stateCode;
        return ListTile(
          title: Text(name, style: AuraType.sans(16, a.ink, weight: FontWeight.w500)),
          trailing: selected ? Icon(Icons.check_rounded, color: a.accent) : null,
          selected: selected,
          onTap: () {
            session.selectState(code);
            Navigator.pop(context);
          },
        );
      }

      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        builder: (context, scroll) => ListView(
          controller: scroll,
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AuraSpace.gutter, 0, AuraSpace.gutter, 8),
              child: Text('Which state do you follow?',
                  style: AuraType.sans(20, a.ink, weight: FontWeight.w600)),
            ),
            tile(null, 'All India'),
            for (final s in IndianState.all) tile(s.code, s.name),
          ],
        ),
      );
    },
  );
}
