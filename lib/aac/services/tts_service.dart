import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  TtsService({FlutterTts? flutterTts}) : _tts = flutterTts ?? FlutterTts();

  final FlutterTts _tts;

  Future<void> setup() async {
    try {
      await _tts.awaitSpeakCompletion(true);
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.0);
    } on MissingPluginException {
      debugPrint('Text to speech setup is not available in this environment');
    } on PlatformException {
      debugPrint('Text to speech setup failed');
    }
  }

  Future<void> speak(String text) async {
    if (text.trim().isEmpty) {
      return;
    }

    try {
      await _tts.stop();
      await _tts.speak(text.trim());
    } on MissingPluginException {
      debugPrint('Text to speech is not available in this environment: $text');
    } on PlatformException {
      debugPrint('Text to speech failed: $text');
    }
  }
}
