import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:teldrive_easy/features/auth/server_url_screen.dart';

void main() {
  testWidgets('Server URL screen rejects empty input', (tester) async {
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(home: ServerUrlScreen()),
    ));

    final continueBtn = find.text('Continue');
    expect(continueBtn, findsOneWidget);

    final field = find.byType(TextFormField);
    await tester.enterText(field, '');
    await tester.tap(continueBtn);
    await tester.pump();

    expect(find.text('Enter your TelDrive URL'), findsOneWidget);
  });

  testWidgets('Server URL screen rejects bad scheme', (tester) async {
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(home: ServerUrlScreen()),
    ));

    await tester.enterText(find.byType(TextFormField), 'ftp://nope');
    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(find.text('Must start with http:// or https://'), findsOneWidget);
  });
}
