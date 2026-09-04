import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/board_level.dart';

class BoardStorageService {
  static const String boardKey = 'aac_board';

  Future<BoardLevel> loadBoard() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedBoard = prefs.getString(boardKey);
      if (savedBoard == null) {
        return BoardLevel.starter();
      }

      final dynamic decoded = jsonDecode(savedBoard);
      if (decoded is Map<String, dynamic>) {
        return BoardLevel.fromJson(decoded);
      }
      return BoardLevel.starter();
    } catch (_) {
      return BoardLevel.starter();
    }
  }

  Future<void> saveBoard(BoardLevel board) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(boardKey, jsonEncode(board.toJson()));
  }
}
