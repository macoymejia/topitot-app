import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../constants/aac_constants.dart';

enum CellKind { speak, folder }

enum CellVisualType { symbol, photo }

class BoardLevel {
  BoardLevel({required this.title, required this.cells});

  String title;
  List<AacCell> cells;

  factory BoardLevel.blank(String title) {
    return BoardLevel(
      title: title,
      cells: List<AacCell>.generate(
        cellsPerPage,
        (index) => AacCell.blank(index),
      ),
    );
  }

  factory BoardLevel.starter() {
    final board = BoardLevel.blank('Topitot');
    board.cells = <AacCell>[
      // Row 1: Back (taken by navigation), Home (taken by navigation), I, want, more
      AacCell.speak('I', 'I', '🧒', AppColors.yellowSoft),
      AacCell.speak('want', 'want', '🤲', AppColors.greenSoft),
      AacCell.speak('more', 'more', '➕', AppColors.lavender),

      // Row 2: you, help, to eat, Food (folder), please
      AacCell.speak('you', 'you', '👉', AppColors.yellowSoft),
      AacCell.speak('help', 'help', '🤝', AppColors.greenSoft),
      AacCell.speak('to eat', 'to eat', '🍽️', AppColors.greenSoft),
      AacCell.folder(
        'Food',
        'Food',
        '🍎',
        AppColors.coralSoft,
        BoardLevel(
          title: 'Food',
          cells: <AacCell>[
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
              cellsPerPage - 16,
              (index) => AacCell.blank(index + 16),
            ),
          ],
        ),
      ),
      AacCell.speak('please', 'please', '🙏', AppColors.lavender),

      // Row 3: People (folder), Actions (folder), Feelings (folder), Places (folder), thank you
      AacCell.folder(
        'People',
        'People',
        '👫',
        AppColors.yellowSoft,
        BoardLevel(
          title: 'People',
          cells: <AacCell>[
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
          ],
        ),
      ),
      AacCell.folder(
        'Actions',
        'Actions',
        '🏃',
        AppColors.greenSoft,
        BoardLevel(
          title: 'Actions',
          cells: <AacCell>[
            AacCell.speak('to go', 'to go', '🚶', AppColors.greenSoft),
            AacCell.speak('stop', 'stop', '✋', AppColors.pinkSoft),
            AacCell.speak('to play', 'to play', '⛹️', AppColors.greenSoft),
            AacCell.speak('to sleep', 'to sleep', '😴', AppColors.greenSoft),
            AacCell.speak('to eat', 'to eat', '🍽️', AppColors.greenSoft),
            AacCell.speak('to drink', 'to drink', '🥤', AppColors.greenSoft),
            AacCell.speak('help', 'help', '🤝', AppColors.greenSoft),
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
              cellsPerPage - 16,
              (index) => AacCell.blank(index + 16),
            ),
          ],
        ),
      ),
      AacCell.folder(
        'Feelings',
        'Feelings',
        '😊',
        AppColors.blueSoft,
        BoardLevel(
          title: 'Feelings',
          cells: <AacCell>[
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
          ],
        ),
      ),
      AacCell.folder(
        'Places',
        'Places',
        '🏘️',
        AppColors.coralSoft,
        BoardLevel(
          title: 'Places',
          cells: <AacCell>[
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
          ],
        ),
      ),
      AacCell.speak('thank you', 'thank you', '💖', AppColors.lavender),

      // Row 4: me, go, yes, bathroom, to play
      AacCell.speak('me', 'me', '🙋', AppColors.yellowSoft),
      AacCell.speak('go', 'go', '🚶', AppColors.greenSoft),
      AacCell.speak('yes', 'yes', '👍', AppColors.greenSoft),
      AacCell.speak('bathroom', 'bathroom', '🚽', AppColors.coralSoft),
      AacCell.speak('to play', 'to play', '⛹️', AppColors.greenSoft),

      // Row 5: who, stop, no, toy, to sleep
      AacCell.speak('who', 'who', '❓', AppColors.lavender),
      AacCell.speak('stop', 'stop', '✋', AppColors.pinkSoft),
      AacCell.speak('no', 'no', '👎', AppColors.pinkSoft),
      AacCell.speak('toy', 'toy', '🧸', AppColors.coralSoft),
      AacCell.speak('to sleep', 'to sleep', '😴', AppColors.greenSoft),

      // Blank slots (23 and 24) since AacGrid displays up to cells[22]
      AacCell.blank(23),
      AacCell.blank(24),
    ];
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
    return AacCell(
      label: '${json['label'] ?? 'Empty'}',
      spokenText: '${json['spokenText'] ?? ''}',
      symbol: '${json['symbol'] ?? '+'}',
      visualType:
          json['visualType'] == 'photo'
              ? CellVisualType.photo
              : CellVisualType.symbol,
      photoPath:
          json['photoPath'] is String ? json['photoPath'] as String : null,
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
