import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../constants/aac_constants.dart';
import '../services/photo_storage_service.dart';

enum CellKind { speak, folder }

enum CellVisualType { symbol, photo }

class BoardLevel {
  BoardLevel({required this.title, required this.cells});

  String title;
  List<AacCell> cells;

  factory BoardLevel.blank(String title) {
    return BoardLevel(title: title, cells: _withFixedRow(<AacCell>[]));
  }

  factory BoardLevel.starter() {
    final board = BoardLevel.blank('Topitot');
    board.cells = _withFixedRow(<AacCell>[
      AacCell.speak('I love', 'I love', '❤️', AppColors.blueSoft),
      AacCell.speak('to sleep', 'to sleep', '😴', AppColors.greenSoft),
      AacCell.speak('help', 'help', '🤝', AppColors.greenSoft),
      AacCell.speak('to eat', 'to eat', '🍽️', AppColors.greenSoft),
      AacCell.speak('to play', 'to play', '⛹️', AppColors.greenSoft),
      AacCell.folder(
        'People',
        'People',
        '👫',
        AppColors.yellowSoft,
        BoardLevel(
          title: 'People',
          cells: _withFixedRow(<AacCell>[
            AacCell.speak('mom', 'mom', '👩', AppColors.yellowSoft),
            AacCell.speak('dad', 'dad', '👨', AppColors.yellowSoft),
            AacCell.speak('me', 'me', '🙋', AppColors.yellowSoft),
            AacCell.speak('brother', 'brother', '👦', AppColors.yellowSoft),
            AacCell.speak('sister', 'sister', '👧', AppColors.yellowSoft),
            AacCell.speak('baby', 'baby', '👶', AppColors.yellowSoft),
            AacCell.speak('grandma', 'grandma', '👵', AppColors.yellowSoft),
            AacCell.speak('grandpa', 'grandpa', '👴', AppColors.yellowSoft),
            AacCell.speak('teacher', 'teacher', '👩‍🏫', AppColors.yellowSoft),
            AacCell.speak('friend', 'friend', '🧒', AppColors.yellowSoft),
            ...List<AacCell>.generate(
              cellsPerPage - 10,
              (index) => AacCell.blank(index + 10),
            ),
          ]),
        ),
      ),
      AacCell.folder(
        'Actions',
        'Actions',
        '🏃',
        AppColors.greenSoft,
        BoardLevel(
          title: 'Actions',
          cells: _withFixedRow(<AacCell>[
            AacCell.speak('to go', 'to go', '🚶', AppColors.greenSoft),
            AacCell.speak('stop', 'stop', '✋', AppColors.pinkSoft),
            AacCell.speak('to play', 'to play', '⛹️', AppColors.greenSoft),
            AacCell.speak('to eat', 'to eat', '🍽️', AppColors.greenSoft),
            AacCell.speak('to drink', 'to drink', '🥤', AppColors.greenSoft),
            AacCell.speak('look', 'look', '👀', AppColors.greenSoft),
            AacCell.speak('to listen', 'to listen', '👂', AppColors.greenSoft),
            AacCell.speak('to wash', 'to wash', '🧼', AppColors.greenSoft),
            AacCell.speak('to hug', 'to hug', '🫂', AppColors.greenSoft),
            AacCell.speak('open', 'open', '📖', AppColors.greenSoft),
            AacCell.speak('close', 'close', '📕', AppColors.pinkSoft),
            AacCell.speak('to run', 'to run', '🏃', AppColors.greenSoft),
            AacCell.speak('to jump', 'to jump', '🦘', AppColors.greenSoft),
            AacCell.speak('to sing', 'to sing', '🎤', AppColors.greenSoft),
            ...List<AacCell>.generate(
              cellsPerPage - 14,
              (index) => AacCell.blank(index + 14),
            ),
          ]),
        ),
      ),
      AacCell.folder(
        'Feelings',
        'Feelings',
        '😊',
        AppColors.blueSoft,
        BoardLevel(
          title: 'Feelings',
          cells: _withFixedRow(<AacCell>[
            AacCell.speak('happy', 'happy', '😊', AppColors.blueSoft),
            AacCell.speak('sad', 'sad', '😢', AppColors.blueSoft),
            AacCell.speak('angry', 'angry', '😠', AppColors.blueSoft),
            AacCell.speak('tired', 'tired', '😴', AppColors.blueSoft),
            AacCell.speak('hurt', 'hurt', '🤕', AppColors.blueSoft),
            AacCell.speak('scared', 'scared', '😟', AppColors.blueSoft),
            AacCell.speak('hot', 'hot', '🥵', AppColors.blueSoft),
            AacCell.speak('cold', 'cold', '🥶', AppColors.blueSoft),
            AacCell.speak('hungry', 'hungry', '😋', AppColors.blueSoft),
            AacCell.speak('thirsty', 'thirsty', '🥤', AppColors.blueSoft),
            AacCell.speak('excited', 'excited', '🤩', AppColors.blueSoft),
            AacCell.speak('bored', 'bored', '🥱', AppColors.blueSoft),
            ...List<AacCell>.generate(
              cellsPerPage - 12,
              (index) => AacCell.blank(index + 12),
            ),
          ]),
        ),
      ),
      AacCell.folder(
        'Food',
        'Food',
        '🍎',
        AppColors.coralSoft,
        BoardLevel(
          title: 'Food',
          cells: _withFixedRow(<AacCell>[
            AacCell.speak('rice', 'rice', '🍚', AppColors.coralSoft),
            AacCell.speak('bread', 'bread', '🍞', AppColors.coralSoft),
            AacCell.speak('banana', 'banana', '🍌', AppColors.coralSoft),
            AacCell.speak('apple', 'apple', '🍎', AppColors.coralSoft),
            AacCell.speak('chicken', 'chicken', '🍗', AppColors.coralSoft),
            AacCell.speak('egg', 'egg', '🥚', AppColors.coralSoft),
            AacCell.speak('water', 'water', '🥛', AppColors.coralSoft),
            AacCell.speak('milk', 'milk', '🥛', AppColors.coralSoft),
            AacCell.speak('juice', 'juice', '🧃', AppColors.coralSoft),
            AacCell.speak('cookie', 'cookie', '🍪', AppColors.coralSoft),
            AacCell.speak('fruit', 'fruit', '🍇', AppColors.coralSoft),
            AacCell.speak('snack', 'snack', '🍿', AppColors.coralSoft),
            AacCell.speak('pizza', 'pizza', '🍕', AppColors.coralSoft),
            AacCell.speak('pasta', 'pasta', '🍝', AppColors.coralSoft),
            AacCell.speak('soup', 'soup', '🥣', AppColors.coralSoft),
            AacCell.speak('cheese', 'cheese', '🧀', AppColors.coralSoft),
            ...List<AacCell>.generate(
              (cellsPerPage - 5) - 16,
              (index) => AacCell.blank(index + 16),
            ),
          ]),
        ),
      ),
      AacCell.folder(
        'toy',
        'toy',
        '🧸',
        AppColors.coralSoft,
        BoardLevel(
          title: 'Toy',
          cells: _withFixedRow(<AacCell>[
            AacCell.speak('cellphone', 'cellphone', '📱', AppColors.coralSoft),
            AacCell.speak('car', 'car', '🚗', AppColors.coralSoft),
            AacCell.speak('ball', 'ball', '⚽', AppColors.coralSoft),
            AacCell.speak(
              'teddy bear',
              'teddy bear',
              '🧸',
              AppColors.coralSoft,
            ),
            AacCell.speak('blocks', 'blocks', '🧱', AppColors.coralSoft),
            AacCell.speak('doll', 'doll', '🪆', AppColors.coralSoft),
          ]),
        ),
      ),
      AacCell.speak('open', 'open', '📖', AppColors.greenSoft),
      AacCell.speak('go', 'go', '🚶', AppColors.greenSoft),
      AacCell.speak('yes', 'yes', '👍', AppColors.greenSoft),
      AacCell.folder(
        'Places',
        'Places',
        '🏘️',
        AppColors.coralSoft,
        BoardLevel(
          title: 'Places',
          cells: _withFixedRow(<AacCell>[
            AacCell.speak('home', 'home', '🏠', AppColors.coralSoft),
            AacCell.speak('school', 'school', '🏫', AppColors.coralSoft),
            AacCell.speak('park', 'park', '🛝', AppColors.coralSoft),
            AacCell.speak('bathroom', 'bathroom', '🚽', AppColors.coralSoft),
            AacCell.speak('outside', 'outside', '🌳', AppColors.coralSoft),
            AacCell.speak('bedroom', 'bedroom', '🛏️', AppColors.coralSoft),
            AacCell.speak('kitchen', 'kitchen', '🍳', AppColors.coralSoft),
            AacCell.speak('store', 'store', '🛒', AppColors.coralSoft),
            AacCell.speak('pool', 'pool', '🏊', AppColors.coralSoft),
            AacCell.speak('beach', 'beach', '🏖️', AppColors.coralSoft),
            ...List<AacCell>.generate(
              cellsPerPage - 10,
              (index) => AacCell.blank(index + 10),
            ),
          ]),
        ),
      ),
      AacCell.speak('More', 'more', '➕', AppColors.lavender),
      AacCell.speak('close', 'close', '📕', AppColors.pinkSoft),
      AacCell.speak('stop', 'stop', '✋', AppColors.pinkSoft),
      AacCell.speak('no', 'no', '👎', AppColors.pinkSoft),
      AacCell.speak('bathroom', 'bathroom', '🚽', AppColors.coralSoft),
      AacCell.speak('please', 'please', '🙏', AppColors.lavender),
      AacCell.speak('left', 'left', '◀️', AppColors.greenSoft),
      AacCell.speak('up', 'up', '🔼', AppColors.greenSoft),
      AacCell.speak('down', 'down', '🔽', AppColors.greenSoft),
      AacCell.speak('right', 'right', '▶️', AppColors.greenSoft),
      AacCell.speak('thank you', 'thank you', '💖', AppColors.lavender),
    ]);
    return board;
  }

  factory BoardLevel.fromJson(Map<String, dynamic> json) {
    final rawCells = json['cells'];
    final parsedCells =
        rawCells is List
            ? rawCells
                .whereType<Map<String, dynamic>>()
                .map(AacCell.fromJson)
                .toList()
            : <AacCell>[];

    if (_looksLikeLegacyBoard(parsedCells)) {
      return BoardLevel(
        title: '${json['title'] ?? 'AAC board'}',
        cells: _withFixedRow(
          parsedCells.skip(5).take(cellsPerPage - 5).toList(),
        ),
      );
    }

    return BoardLevel(
      title: '${json['title'] ?? 'AAC board'}',
      cells: _normalizeCells(parsedCells),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'cells': cells.map((cell) => cell.toJson()).toList(),
    };
  }

  static List<AacCell> _normalizeCells(List<AacCell> cells) {
    final normalized = List<AacCell>.from(cells.take(cellsPerPage));
    while (normalized.length < cellsPerPage) {
      normalized.add(AacCell.blank(normalized.length));
    }
    return normalized;
  }

  static bool _looksLikeLegacyBoard(List<AacCell> cells) {
    if (cells.length < cellsPerPage) {
      return false;
    }

    return cells.first.label != 'Back';
  }

  static List<AacCell> _withFixedRow(List<AacCell> contentCells) {
    final normalizedContent = List<AacCell>.from(
      contentCells.take(cellsPerPage - 5),
    );
    while (normalizedContent.length < cellsPerPage - 5) {
      normalizedContent.add(AacCell.blank(normalizedContent.length + 5));
    }

    return <AacCell>[
      AacCell.speak('Back', 'back', '↩', AppColors.slateSoft),
      AacCell.speak('Home', 'home', '🏠', AppColors.slateSoft),
      AacCell.speak('I', 'I', '🧒', AppColors.yellowSoft),
      AacCell.speak('Me', 'me', '🙋', AppColors.yellowSoft),
      AacCell.speak('I want', 'I want', '🤲', AppColors.greenSoft),
      ...normalizedContent,
    ];
  }
}

class AacCell {
  AacCell({
    required this.label,
    required this.spokenText,
    required this.symbol,
    required this.visualType,
    required this.color,
    required this.kind,
    this.children,
    this.photoPath,
  });

  String label;
  String spokenText;
  String symbol;
  CellVisualType visualType;
  String? photoPath;
  Color color;
  CellKind kind;
  BoardLevel? children;

  bool get isFolder => kind == CellKind.folder;
  bool get isBlank => label == 'Empty';
  bool get hasPhoto =>
      visualType == CellVisualType.photo &&
      photoPath != null &&
      photoPath!.isNotEmpty;

  factory AacCell.blank(int index) {
    return AacCell(
      label: 'Empty',
      spokenText: '',
      symbol: '+',
      visualType: CellVisualType.symbol,
      color: AppColors.emptyCell,
      kind: CellKind.speak,
    );
  }

  factory AacCell.speak(
    String label,
    String spokenText,
    String symbol,
    Color color,
  ) {
    return AacCell(
      label: label,
      spokenText: spokenText,
      symbol: symbol,
      visualType: CellVisualType.symbol,
      color: color,
      kind: CellKind.speak,
    );
  }

  factory AacCell.folder(
    String label,
    String spokenText,
    String symbol,
    Color color,
    BoardLevel children,
  ) {
    return AacCell(
      label: label,
      spokenText: spokenText,
      symbol: symbol,
      visualType: CellVisualType.symbol,
      color: color,
      kind: CellKind.folder,
      children: children,
    );
  }

  factory AacCell.fromJson(Map<String, dynamic> json) {
    final rawPhotoPath =
        json['photoPath'] is String ? json['photoPath'] as String : null;
    final isSafePhoto = PhotoStorageService.isSafePhotoPath(rawPhotoPath);
    final rawVisualType = json['visualType'];

    return AacCell(
      label: '${json['label'] ?? 'Empty'}',
      spokenText: '${json['spokenText'] ?? ''}',
      symbol: '${json['symbol'] ?? '+'}',
      visualType:
          (rawVisualType == 'photo' && isSafePhoto)
              ? CellVisualType.photo
              : CellVisualType.symbol,
      photoPath: isSafePhoto ? rawPhotoPath : null,
      color: Color(
        json['color'] is int ? json['color'] as int : AppColors.emptyCellArgb,
      ),
      kind: json['kind'] == 'folder' ? CellKind.folder : CellKind.speak,
      children:
          json['children'] is Map<String, dynamic>
              ? BoardLevel.fromJson(json['children'] as Map<String, dynamic>)
              : null,
    );
  }

  AacCell clone() {
    return AacCell(
      label: label,
      spokenText: spokenText,
      symbol: symbol,
      visualType: visualType,
      photoPath: photoPath,
      color: color,
      kind: kind,
      children: children,
    );
  }

  void copyFrom(AacCell other) {
    label = other.label;
    spokenText = other.spokenText;
    symbol = other.symbol;
    visualType = other.visualType;
    photoPath = other.photoPath;
    color = other.color;
    kind = other.kind;
    children = other.children;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'label': label,
      'spokenText': spokenText,
      'symbol': symbol,
      'visualType': visualType.name,
      'photoPath': photoPath,
      'color': color.toARGB32(),
      'kind': kind.name,
      'children': children?.toJson(),
    };
  }
}
