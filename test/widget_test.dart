import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:topitot_app/main.dart';

void main() {
  void mockTts() {
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
  }

  testWidgets('AAC board shows sentence strip and 5 by 5 grid', (tester) async {
    mockTts();

    await tester.pumpWidget(const TopitotApp());
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Choose words'), findsOneWidget);
    expect(find.text('Topitot AAC'), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);
    expect(boardRows, 5);
    expect(boardColumns, 5);
    expect(cellsPerPage, 25);
    expect(
      find.byKey(const ValueKey<String>('grid-back-cell')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('grid-home-cell')),
      findsOneWidget,
    );
    expect(find.text('I'), findsWidgets);
    expect(find.text('Food'), findsOneWidget);

    await tester.tap(find.text('want'));
    await tester.pump();

    expect(find.byType(Chip), findsOneWidget);
    expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);
    expect(find.byIcon(Icons.clear_all_rounded), findsNothing);
  });

  testWidgets('grid navigation cells go back and home', (tester) async {
    mockTts();

    await tester.pumpWidget(const TopitotApp());
    await tester.pump(const Duration(milliseconds: 250));

    await tester.tap(find.text('Food'));
    await tester.pump();

    expect(find.text('Food'), findsOneWidget);
    expect(find.text('rice'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('grid-back-cell')));
    await tester.pump();

    expect(find.text('Topitot AAC'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);

    await tester.tap(find.text('Food'));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey<String>('grid-home-cell')));
    await tester.pump();

    expect(find.text('Topitot AAC'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
  });

  testWidgets('sentence undo button deletes one word or clears all words', (
    tester,
  ) async {
    mockTts();

    await tester.pumpWidget(const TopitotApp());
    await tester.pump(const Duration(milliseconds: 250));

    await tester.tap(find.text('want'));
    await tester.tap(find.text('eat'));
    await tester.pump();

    expect(find.byType(Chip), findsNWidgets(2));

    final undoButton = find.byTooltip(
      'Tap to delete one word. Double tap or hold to clear.',
    );

    await tester.tap(undoButton);
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byType(Chip), findsOneWidget);
    expect(find.text('want'), findsWidgets);

    await tester.tap(find.text('eat'));
    await tester.pump();

    expect(find.byType(Chip), findsNWidgets(2));

    await tester.tap(undoButton);
    await tester.pump(const Duration(milliseconds: 80));
    await tester.tap(undoButton);
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byType(Chip), findsNothing);
    expect(find.text('Choose words'), findsOneWidget);
  });

  testWidgets('AAC board fits an iPad landscape viewport', (tester) async {
    mockTts();
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const TopitotApp());
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.byType(GridView), findsOneWidget);
    final gridRect = tester.getRect(find.byType(GridView));
    final lastCellRect = tester.getRect(
      find.byKey(const ValueKey<String>('aac-cell-24')),
    );

    expect(lastCellRect.bottom, lessThanOrEqualTo(gridRect.bottom + 0.1));
    expect(lastCellRect.right, lessThanOrEqualTo(gridRect.right + 0.1));
    expect(tester.takeException(), isNull);
  });
}
