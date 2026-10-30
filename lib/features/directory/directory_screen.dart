import 'package:flutter/material.dart';

import '../../core/open_link.dart';
import '../../core/theme/aura.dart';
import '../../core/widgets/glow_backdrop.dart';
import 'directory_data.dart';

/// "Which website do I go to?" Search by need or by name; every link is an
/// official government or statutory-body site.
class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool _matches(PortalGroup g, Portal p, String q) =>
      q.isEmpty ||
      [g.title, p.name, p.what, p.host].any((s) => s.toLowerCase().contains(q));

  @override
  Widget build(BuildContext context) {
    final a = context.aura;
    final q = _search.text.trim().toLowerCase();

    return Scaffold(
      body: GlowBackdrop(
        reach: 0.3,
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AuraSpace.gutter, 12, AuraSpace.gutter, 24),
            children: [
              Text('Which website?', style: AuraType.display(34, a.ink)),
              const SizedBox(height: 6),
              Text('Official government sites only, grouped by what you need.',
                  style: AuraType.sans(14.5, a.inkMuted)),
              const SizedBox(height: 16),
              TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                style: AuraType.sans(16, a.ink),
                decoration: InputDecoration(
                  hintText: 'Try "court", "insurance", "fraud"',
                  hintStyle: AuraType.sans(16, a.inkFaint),
                  prefixIcon: Icon(Icons.search_rounded, color: a.inkMuted),
                  filled: true,
                  fillColor: a.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide(color: a.hairline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide(color: a.hairline),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              for (final g in portalGroups)
                if (g.portals.any((p) => _matches(g, p, q))) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 10),
                    child: Row(children: [
                      Icon(g.icon, size: 20, color: a.accent),
                      const SizedBox(width: 8),
                      Text(g.title,
                          style: AuraType.sans(18, a.ink, weight: FontWeight.w600)),
                    ]),
                  ),
                  for (final p in g.portals)
                    if (_matches(g, p, q)) _PortalTile(p),
                ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PortalTile extends StatelessWidget {
  final Portal portal;
  const _PortalTile(this.portal);

  @override
  Widget build(BuildContext context) {
    final a = context.aura;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: a.surface.withValues(alpha: 0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: a.hairline),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => openLink(context, Uri.parse(portal.url)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(portal.name,
                          style: AuraType.sans(16, a.ink, weight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(portal.what,
                          style: AuraType.sans(14, a.inkMuted, height: 1.35)),
                      if (portal.tip != null) ...[
                        const SizedBox(height: 6),
                        Text(portal.tip!,
                            style: AuraType.sans(13, a.review, weight: FontWeight.w500)),
                      ],
                      const SizedBox(height: 6),
                      Text(portal.host, style: AuraType.sans(12.5, a.inkFaint)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.open_in_new_rounded, size: 18, color: a.inkMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
