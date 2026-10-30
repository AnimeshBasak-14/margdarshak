import 'dart:convert';

import 'package:flutter/services.dart';

import '../../core/states.dart';

enum UpdateKind {
  recruitment('Jobs'),
  result('Results'),
  admitCard('Admit cards'),
  answerKey('Answer keys'),
  examDate('Exam dates'),
  notice('Notices');

  final String label;
  const UpdateKind(this.label);

  static UpdateKind parse(String? s) => switch (s) {
        'recruitment' => recruitment,
        'result' => result,
        'admit_card' => admitCard,
        'answer_key' => answerKey,
        'exam_date' => examDate,
        _ => notice,
      };
}

class FeedItem {
  final String title;
  final Uri url;
  final String source;
  final String state;
  final UpdateKind kind;
  final DateTime? date;

  const FeedItem(
      {required this.title,
      required this.url,
      required this.source,
      required this.state,
      required this.kind,
      this.date});

  factory FeedItem.fromJson(Map<String, dynamic> j) => FeedItem(
        title: j['title'] as String,
        url: Uri.parse(j['url'] as String),
        source: j['sourceName'] as String,
        state: j['state'] as String,
        kind: UpdateKind.parse(j['kind'] as String?),
        date: DateTime.tryParse(j['date'] as String? ?? ''),
      );
}

class Feed {
  final DateTime? generatedAt;
  final List<FeedItem> items;
  const Feed(this.generatedAt, this.items);

  /// States we actually have items for.
  Set<String> get coveredStates => {for (final i in items) i.state};

  List<FeedItem> forState(String? code) => code == null
      ? items
      : [
          for (final i in items)
            if (i.state == code || i.state == IndianState.central) i
        ];

  static Feed parse(String json) {
    final m = jsonDecode(json) as Map<String, dynamic>;
    return Feed(
      DateTime.tryParse(m['generatedAt'] as String? ?? ''),
      [
        for (final j in (m['items'] as List))
          FeedItem.fromJson(j as Map<String, dynamic>)
      ],
    );
  }

  /// The feed bundled with the app. A server can replace this later by
  /// serving the scraper's feed.json.
  static Future<Feed> loadBundled() async =>
      parse(await rootBundle.loadString('assets/data/feed.json'));
}
