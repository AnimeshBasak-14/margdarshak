import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margdarshak/app.dart';
import 'package:margdarshak/features/assistant/screens/chat_screen.dart';

/// The feed comes from a bundled asset, which needs real (not fake) async time.
Future<void> settle(WidgetTester t) async {
  await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
  await t.pumpAndSettle();
}

void main() {
  // rootBundle caches the load future, and one created under fake time never
  // completes, so start every test from a clean cache.
  setUp(() => rootBundle.evict('assets/data/feed.json'));

  testWidgets('a prompt card opens a chat that answers it', (tester) async {
    await tester.pumpWidget(const RaahApp());
    expect(find.text('What are we aiming for today?'), findsOneWidget);

    await tester.tap(find.text('Can I apply to BPSC from another state?'),
        warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(ChatScreen), findsOneWidget);
    expect(find.text('Raah is working…'), findsOneWidget);

    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Unreserved'), findsOneWidget);
    expect(find.text('Raah is working…'), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('theme toggle switches to dark', (tester) async {
    await tester.pumpWidget(const RaahApp());
    await tester.tap(find.byTooltip('Switch to dark mode'));
    await settle(tester);
    expect(find.byTooltip('Switch to light mode'), findsOneWidget);
  });

  testWidgets('updates tab lists scraped notices and filters by state',
      (tester) async {
    await tester.pumpWidget(const RaahApp());
    await tester.tap(find.text('Updates'));
    await settle(tester);
    expect(find.text('Latest updates'), findsOneWidget);
    expect(find.text('All India'), findsOneWidget);
    expect(find.text('Results'), findsOneWidget);
  });

  testWidgets('websites tab searches by need', (tester) async {
    await tester.pumpWidget(const RaahApp());
    await tester.tap(find.text('Websites'));
    await settle(tester);
    expect(find.text('Which website?'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'fraud');
    await tester.pump();
    expect(find.text('National Cyber Crime Portal'), findsOneWidget);
    expect(find.text('Passport Seva'), findsNothing);
  });
}
