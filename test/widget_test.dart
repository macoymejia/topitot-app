import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:topitot_app/main.dart';

void main() {
  testWidgets('AAC board shows sentence strip and 5 by 5 grid', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('flutter_tts'), (
          methodCall,
        ) async {
          if (methodCall.method == 'getVoices') {
            return <Map<String, String>>[
              <String, String>{'name': 'Test Voice', 'locale': 'en-US'},
            ];
          }
          return null;
        });

    await tester.pumpWidget(const TopitotApp());
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Choose words'), findsOneWidget);
    expect(find.text('Topitot AAC'), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);
    expect(boardRows, 5);
    expect(boardColumns, 5);
    expect(cellsPerPage, 25);
    expect(find.text('I'), findsWidgets);
    expect(find.text('Food'), findsOneWidget);

    await tester.tap(find.text('want'));
    await tester.pump();

    expect(find.byType(Chip), findsOneWidget);
    expect(find.byIcon(Icons.clear_all_rounded), findsOneWidget);
  });
}
