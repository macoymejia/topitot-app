import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/aac_constants.dart';
import '../models/aac_cell.dart';
import '../models/board_level.dart';
import '../services/board_storage_service.dart';
import '../services/tts_service.dart';
import '../services/walkthrough_storage_service.dart';

class AacController extends ChangeNotifier {
  AacController({
    BoardStorageService? boardStorage,
    WalkthroughStorageService? walkthroughStorage,
    TtsService? ttsService,
  })  : _boardStorage = boardStorage ?? BoardStorageService(),
        _walkthroughStorage = walkthroughStorage ?? WalkthroughStorageService(),
        _ttsService = ttsService ?? TtsService();

  final BoardStorageService _boardStorage;
  final WalkthroughStorageService _walkthroughStorage;
  final TtsService _ttsService;

  final List<AacCell> _sentence = <AacCell>[];
  final List<BoardLevel> _path = <BoardLevel>[];
  late BoardLevel _root;

  bool _isLoading = true;
  bool _editMode = false;
  bool _toolbarExpanded = false;
  bool _showWalkthrough = false;
  int _walkthroughStepIndex = 0;
  Rect? _walkthroughTargetRect;

  // Getters
  List<AacCell> get sentence => List<AacCell>.unmodifiable(_sentence);
  List<BoardLevel> get path => List<BoardLevel>.unmodifiable(_path);
  BoardLevel get currentBoard => _path.isEmpty ? _root : _path.last;
  int get pathDepth => _path.length + 1;
  bool get canGoBack => _path.isNotEmpty;
  bool get isLoading => _isLoading;
  bool get editMode => _editMode;
  bool get toolbarExpanded => _toolbarExpanded;
  bool get showWalkthrough => _showWalkthrough;
  int get walkthroughStepIndex => _walkthroughStepIndex;
  Rect? get walkthroughTargetRect => _walkthroughTargetRect;

  String get sentenceText =>
      _sentence.map((cell) => cell.spokenText).join(' ');

  Future<void> loadApp() async {
    try {
      _root = await _boardStorage.loadBoard();
      await _ttsService.setup();
      final hasSeenWalkthrough =
          await _walkthroughStorage.hasSeenWalkthrough();
      _showWalkthrough = !hasSeenWalkthrough;
    } catch (_) {
      _root = BoardLevel.starter();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveBoard() async {
    await _boardStorage.saveBoard(_root);
    notifyListeners();
  }

  Future<void> speak(String text) async {
    await _ttsService.speak(text);
  }

  Future<void> playLimitBeep() async {
    await SystemSound.play(SystemSoundType.click);
  }

  void handleCellTap(AacCell cell) {
    if (cell.label == 'Back') {
      if (_editMode || _path.isEmpty) {
        return;
      }
      goBack();
      return;
    }

    if (cell.label == 'Home') {
      if (_editMode || _path.isEmpty) {
        return;
      }
      goHome();
      return;
    }

    if (cell.isBlank && !_editMode) {
      return;
    }

    if (!_editMode) {
      if (_sentence.length >= maxSentenceWords) {
        unawaited(playLimitBeep());
        return;
      }

      if (_sentence.isNotEmpty &&
          _sentence.last.spokenText == cell.spokenText) {
        return;
      }

      if (cell.isFolder) {
        cell.children ??= BoardLevel.blank('${cell.label} board');
        _path.add(cell.children!);
        notifyListeners();
        return;
      }

      _sentence.add(cell);
      notifyListeners();
      unawaited(speak(cell.spokenText));
    }
  }

  void goBack() {
    if (_path.isNotEmpty) {
      _path.removeLast();
      notifyListeners();
    }
  }

  void goHome() {
    if (_path.isNotEmpty) {
      _path.clear();
      notifyListeners();
    }
  }

  void clearSentence() {
    _sentence.clear();
    notifyListeners();
  }

  void removeLastSentenceWord() {
    if (_sentence.isNotEmpty) {
      _sentence.removeLast();
      notifyListeners();
    }
  }

  void setToolbarExpanded(bool value) {
    _toolbarExpanded = value;
    if (!value) {
      _editMode = false;
    }
    notifyListeners();
  }

  void setEditMode(bool value) {
    _editMode = value;
    notifyListeners();
  }

  void setWalkthroughTargetRect(Rect? rect) {
    if (_walkthroughTargetRect != rect) {
      _walkthroughTargetRect = rect;
      notifyListeners();
    }
  }

  Future<void> advanceWalkthrough() async {
    if (_walkthroughStepIndex >= 2) {
      await dismissWalkthrough();
      return;
    }

    _walkthroughStepIndex += 1;
    _walkthroughTargetRect = null;
    notifyListeners();
  }

  Future<void> dismissWalkthrough() async {
    _showWalkthrough = false;
    _walkthroughTargetRect = null;
    notifyListeners();
    await _walkthroughStorage.markWalkthroughSeen();
  }

  Future<void> resetBoard() async {
    _root = BoardLevel.starter();
    _path.clear();
    _editMode = false;
    _toolbarExpanded = false;
    notifyListeners();
    await saveBoard();
  }
}
