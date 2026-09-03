import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:topitot_app/aac/aac_home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:topitot_app/aac/constants/aac_constants.dart';
import 'package:topitot_app/aac/models/board_models.dart';
import 'package:topitot_app/aac/widgets/walkthrough_overlay.dart';
import 'package:topitot_app/app/topitot_app.dart';
import 'package:topitot_app/app/widgets/launch_splash_overlay.dart';
import 'package:topitot_app/theme/app_colors.dart';

void main() {
  test('Android keyboard pans instead of resizing the AAC screen', () {
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();

    expect(manifest, contains('android:windowSoftInputMode="adjustPan"'));
    expect(
      manifest,
      isNot(contains('android:windowSoftInputMode="adjustResize"')),
    );
  });

  test(
    'starter board uses action phrase labels for root and Actions cells',
    () {
      final board = BoardLevel.starter();

      expect(board.cells[4].label, 'help');
      expect(board.cells[4].spokenText, 'help');
      expect(board.cells[5].label, 'to eat');
      expect(board.cells[5].spokenText, 'to eat');
      expect(board.cells[5].symbol, '🍽️');
      expect(board.cells[5].color, AppColors.greenSoft);
      expect(board.cells[2].symbol, '➕');
      expect(board.cells[3].symbol, '👉');
      expect(board.cells[17].label, 'to play');
      expect(board.cells[17].spokenText, 'to play');
      expect(board.cells[18].symbol, '❓');
      expect(board.cells[22].label, 'to sleep');
      expect(board.cells[22].spokenText, 'to sleep');

      final actions = board.cells.singleWhere(
        (cell) => cell.label == 'Actions',
      );
      final people = board.cells.singleWhere((cell) => cell.label == 'People');
      final places = board.cells.singleWhere((cell) => cell.label == 'Places');
      final actionCells = actions.children!.cells.where(
        (cell) => !cell.isBlank,
      );

      expect(people.symbol, '👫');
      expect(places.symbol, '🏘️');

      expect(actionCells.map((cell) => cell.label), <String>[
        'to go',
        'stop',
        'to play',
        'to sleep',
        'to eat',
        'to drink',
        'help',
        'look',
        'to listen',
        'to wash',
        'to hug',
        'open',
        'close',
        'to run',
        'to jump',
        'to sing',
      ]);
      expect(
        actionCells.firstWhere((cell) => cell.label == 'to eat').symbol,
        '🍽️',
      );
      expect(
        actionCells.firstWhere((cell) => cell.label == 'to play').symbol,
        '⛹️',
      );
      expect(
        actionCells.firstWhere((cell) => cell.label == 'open').symbol,
        '📖',
      );
      expect(
        actionCells.firstWhere((cell) => cell.label == 'close').color,
        AppColors.pinkSoft,
      );
      expect(
        actionCells.firstWhere((cell) => cell.label == 'close').symbol,
        '📕',
      );
    },
  );

  test('walkthrough target rect shifts out safe-area padding', () {
    final rect = const Rect.fromLTWH(32, 180, 280, 96);

    expect(
      insetWalkthroughTargetRect(
        rect,
        const EdgeInsets.only(top: 24, left: 0, right: 0, bottom: 0),
      ),
      const Rect.fromLTWH(32, 156, 280, 96),
    );
  });

  void mockTts({
    List<MethodCall>? calls,
    Map<String, Object> prefs = const <String, Object>{
      'walkthrough_seen': true,
    },
  }) {
    SharedPreferences.setMockInitialValues(prefs);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('flutter_tts'), (
          methodCall,
        ) async {
          calls?.add(methodCall);
          if (methodCall.method == 'getVoices') {
            return <Map<String, String>>[
              <String, String>{'name': 'Test Voice', 'locale': 'en-US'},
            ];
          }
          return null;
        });
  }

  testWidgets('launch splash disappears after 3 seconds', (tester) async {
    mockTts();

    await tester.pumpWidget(const TopitotApp());
    expect(find.byType(LaunchSplashOverlay), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pump();

    expect(find.byType(LaunchSplashOverlay), findsNothing);
    expect(find.byType(AacHomePage), findsOneWidget);
  });

  testWidgets('launch splash keeps the AAC home screen underneath', (
    tester,
  ) async {
    mockTts();

    await tester.pumpWidget(const TopitotApp());
    await tester.pump();

    expect(find.byType(AacHomePage), findsOneWidget);
    expect(find.text('Choose words'), findsOneWidget);
  });

  testWidgets('first-use walkthrough appears after the launch splash', (
    tester,
  ) async {
    mockTts(prefs: <String, Object>{});

    await tester.pumpWidget(const TopitotApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();

    expect(find.byKey(const ValueKey<String>('walkthrough-overlay')), findsOneWidget);
    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('Tap Speak to hear the words in your sentence.'), findsOneWidget);
  });

  testWidgets('walkthrough skip hides it and keeps it dismissed', (
    tester,
  ) async {
    mockTts(prefs: <String, Object>{});

    await tester.pumpWidget(const TopitotApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('walkthrough-overlay')), findsNothing);

    await tester.pumpWidget(const TopitotApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();

    expect(find.byKey(const ValueKey<String>('walkthrough-overlay')), findsNothing);
  });

  testWidgets('walkthrough completion hides it and keeps it dismissed', (
    tester,
  ) async {
    mockTts(prefs: <String, Object>{});

    await tester.pumpWidget(const TopitotApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('walkthrough-overlay')), findsNothing);

    await tester.pumpWidget(const TopitotApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();

    expect(find.byKey(const ValueKey<String>('walkthrough-overlay')), findsNothing);
  });

  testWidgets('AAC screen does not resize when keyboard appears', (
    tester,
  ) async {
    mockTts();

    await tester.pumpWidget(const TopitotApp());
    await tester.pump(const Duration(milliseconds: 250));

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));

    expect(scaffold.resizeToAvoidBottomInset, isFalse);
  });

  testWidgets('AAC board shows sentence strip and 5 by 5 grid', (tester) async {
    mockTts();

    await tester.pumpWidget(const TopitotApp());
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Choose words'), findsOneWidget);
    expect(find.text('Speech Relay'), findsOneWidget);
    expect(find.text('Topitot AAC'), findsNothing);
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

    await tester.tap(find.byKey(const ValueKey<String>('aac-cell-8')));
    await tester.pump();

    expect(find.text('rice'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('grid-back-cell')));
    await tester.pump();

    expect(find.text('Speech Relay'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('aac-cell-8')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey<String>('grid-home-cell')));
    await tester.pump();

    expect(find.text('Speech Relay'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
  });

  testWidgets('board toolbar uses action labels for mode switching', (
    tester,
  ) async {
    mockTts();

    await tester.pumpWidget(const TopitotApp());
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Speech Relay'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('toolbar-app-icon')),
      findsOneWidget,
    );
    expect(find.byTooltip('Expand toolbar'), findsOneWidget);
    expect(find.text('Edit Board'), findsNothing);
    expect(find.text('Done Editing'), findsNothing);

    await tester.tap(find.byTooltip('Expand toolbar'));
    await tester.pump();

    expect(find.byTooltip('Collapse toolbar'), findsOneWidget);
    expect(find.text('Edit Board'), findsOneWidget);

    await tester.tap(find.text('Edit Board'));
    await tester.pump();

    expect(find.text('Done Editing'), findsOneWidget);

    await tester.tap(find.byTooltip('Collapse toolbar'));
    await tester.pump();

    expect(find.byTooltip('Expand toolbar'), findsOneWidget);
    expect(find.text('Done Editing'), findsNothing);

    await tester.tap(find.byTooltip('Expand toolbar'));
    await tester.pump();

    expect(find.text('Edit Board'), findsOneWidget);
  });

  testWidgets('board toolbar edit action fits phone width', (tester) async {
    mockTts();
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const TopitotApp());
    await tester.pump(const Duration(milliseconds: 250));

    await tester.tap(find.byTooltip('Expand toolbar'));
    await tester.pump();
    await tester.tap(find.byTooltip('Switch to edit mode'));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('empty folder cells do not add words in use mode', (
    tester,
  ) async {
    mockTts();

    await tester.pumpWidget(const TopitotApp());
    await tester.pump(const Duration(milliseconds: 250));

    await tester.tap(find.text('People'));
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey<String>('aac-cell-12')));
    await tester.pump();

    expect(find.byType(Chip), findsNothing);
    expect(find.text('Choose words'), findsOneWidget);
  });

  testWidgets('sentence word area speaks selected words', (tester) async {
    final ttsCalls = <MethodCall>[];
    mockTts(calls: ttsCalls);

    await tester.pumpWidget(const TopitotApp());
    await tester.pump(const Duration(milliseconds: 250));

    await tester.tap(find.text('want'));
    await tester.tap(find.text('more'));
    await tester.pump();

    ttsCalls.clear();
    await tester.tap(find.byKey(const ValueKey<String>('sentence-word-area')));
    await tester.pump();

    final speakCalls = ttsCalls.where((call) => call.method == 'speak');
    expect(speakCalls, isNotEmpty);
    expect(speakCalls.last.arguments, 'want more');
  });

  testWidgets('sentence undo button deletes one word or clears all words', (
    tester,
  ) async {
    mockTts();

    await tester.pumpWidget(const TopitotApp());
    await tester.pump(const Duration(milliseconds: 250));

    await tester.tap(find.text('want'));
    await tester.tap(find.text('more'));
    await tester.pump();

    expect(find.byType(Chip), findsNWidgets(2));

    final undoButton = find.byTooltip(
      'Tap to delete one word. Double tap or hold to clear.',
    );

    await tester.tap(undoButton);
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byType(Chip), findsOneWidget);
    expect(find.text('want'), findsWidgets);

    await tester.tap(find.text('more'));
    await tester.pump();

    expect(find.byType(Chip), findsNWidgets(2));

    await tester.tap(undoButton);
    await tester.pump(const Duration(milliseconds: 80));
    await tester.tap(undoButton);
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byType(Chip), findsNothing);
    expect(find.text('Choose words'), findsOneWidget);
  });

  testWidgets('AAC board fits an iPad portrait viewport', (tester) async {
    mockTts();
    tester.view.physicalSize = const Size(768, 1024);
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
