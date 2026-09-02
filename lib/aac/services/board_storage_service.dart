import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/board_level.dart';

class BoardStorageService {
  static const String boardKey = 'aac_board';

  Future<BoardLevel> loadBoard() async {
    final prefs = await SharedPreferences.getInstance();
    final savedBoard = prefs.getString(boardKey);
    if (savedBoard == null) {
      return BoardLevel.starter();
    }

    return BoardLevel.fromJson(jsonDecode(savedBoard) as Map<String, dynamic>);
  }

  Future<void> saveBoard(BoardLevel board) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(boardKey, jsonEncode(board.toJson()));
  }
}
