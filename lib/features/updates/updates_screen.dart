import 'package:flutter/material.dart';

import '../../core/open_link.dart';
import '../../core/session.dart';
import '../../core/states.dart';
import '../../core/theme/aura.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/glow_backdrop.dart';
import '../shell/state_sheet.dart';
import 'feed_repo.dart';

class UpdatesScreen extends StatefulWidget {
  const UpdatesScreen({super.key});

  @override
  State<UpdatesScreen> createState() => _UpdatesScreenState();
}

class _UpdatesScreenState extends State<UpdatesScreen> {
  late final Future<Feed> _feed = Feed.loadBundled();
  UpdateKind? _kind;

  @override
  Widget build(BuildContext context) {
    final a = context.aura;
    final session = SessionScope.of(context);
    final state = IndianState.byCode(session.stateCode);

    return Scaffold(
      body: GlowBackdrop(
        reach: 0.3,
        child: SafeArea(
          bottom: false,
          child: FutureBuilder<Feed>(
            future: _feed,
            builder: (context, snap) {
              final feed = snap.data;
              final all = feed?.forState(session.stateCode) ?? const <FeedItem>[];
              final shown = [
                for (final i in all)
                  if (_kind == null || i.kind == _kind) i
              ];
              final noCoverage = feed != null &&
                  state != null &&
                  !feed.coveredStates.contains(state.code);

              return ListView(
                padding: const EdgeInsets.fromLTRB(AuraSpace.gutter, 12, AuraSpace.gutter, 24),
                children: [
                  Text('Latest updates', style: AuraType.display(34, a.ink)),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: PillButton(
                      label: state?.name ?? 'All India',
                      leading: Icons.place_outlined,
                      trailing: Icons.keyboard_arrow_down_rounded,
                      semanticLabel: 'State: ${state?.name ?? 'All India'}. Change',
                      onPressed: () => showStateSheet(context),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _KindChip('All', _kind == null, () => setState(() => _kind = null)),
                        for (final k in UpdateKind.values)
                          _KindChip(k.label, _kind == k, () => setState(() => _kind = k)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (snap.hasError)
                    _Note('Could not load updates.')
                  else if (feed == null)
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else ...[
                    if (noCoverage)
                      _Note('We are not reading ${state.name}\'s commission site yet. '
                          'Showing all-India updates. Open the Websites tab to go to '
                          'the official site directly.'),
                    if (shown.isEmpty && !noCoverage) _Note('Nothing here yet.'),
                    for (final item in shown) _UpdateTile(item),
                    if (feed.generatedAt != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          'Collected ${_ago(feed.generatedAt!)} from official sites. '
                          'Always check the official notice before you apply.',
                          style: AuraType.sans(12, a.inkFaint),
                        ),
                      ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

String _ago(DateTime t) {
  final d = DateTime.now().difference(t);
  if (d.inHours < 1) return 'just now';
  if (d.inHours < 24) return '${d.inHours} hours ago';
  return '${d.inDays} days ago';
}

String _fmt(DateTime d) {
  const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${d.day} ${m[d.month - 1]} ${d.year}';
}

class _KindChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _KindChip(this.label, this.selected, this.onTap);

  @override
  Widget build(BuildContext context) {
    final a = context.aura;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: selected ? a.accent : a.surface,
        shape: StadiumBorder(side: BorderSide(color: selected ? a.accent : a.hairline)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(label,
                  style: AuraType.sans(14, selected ? a.onAccent : a.ink,
                      weight: FontWeight.w500)),
            ),
          ),
        ),
      ),
    );
  }
}

class _UpdateTile extends StatelessWidget {
  final FeedItem item;
  const _UpdateTile(this.item);

  @override
  Widget build(BuildContext context) {
    final a = context.aura;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: a.surface.withValues(alpha: 0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AuraSpace.radius),
          side: BorderSide(color: a.hairline),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => openLink(context, item.url),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(item.kind.label.toUpperCase(),
                      style: AuraType.sans(11, a.accent,
                          weight: FontWeight.w600, letterSpacing: 1)),
                  const Spacer(),
                  if (item.date != null)
                    Text(_fmt(item.date!), style: AuraType.sans(12, a.inkFaint)),
                ]),
                const SizedBox(height: 8),
                Text(item.title,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: AuraType.sans(15.5, a.ink, weight: FontWeight.w500, height: 1.3)),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                    child: Text(item.source,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AuraType.sans(12.5, a.inkMuted)),
                  ),
                  Icon(Icons.open_in_new_rounded, size: 16, color: a.inkMuted),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Note extends StatelessWidget {
  final String text;
  const _Note(this.text);

  @override
  Widget build(BuildContext context) {
    final a = context.aura;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: a.surface,
        borderRadius: BorderRadius.circular(AuraSpace.radius),
        border: Border.all(color: a.hairline),
      ),
      child: Text(text, style: AuraType.sans(14, a.inkMuted, height: 1.4)),
    );
  }
}
