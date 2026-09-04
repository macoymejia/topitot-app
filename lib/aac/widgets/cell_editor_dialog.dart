import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../constants/aac_constants.dart';
import '../models/aac_cell.dart';
import '../models/board_level.dart';
import '../services/photo_storage_service.dart';

class CellEditorDialog extends StatefulWidget {
  const CellEditorDialog({super.key, required this.cell, required this.depth});

  final AacCell cell;
  final int depth;

  @override
  State<CellEditorDialog> createState() => _CellEditorDialogState();
}

class _CellEditorDialogState extends State<CellEditorDialog> {
  final PhotoStorageService _photoStorage = PhotoStorageService();
  late final TextEditingController _labelController;
  late final TextEditingController _spokenTextController;
  late final TextEditingController _symbolController;
  late Color _color;
  late bool _isFolder;
  late CellVisualType _visualType;
  String? _photoPath;
  String? _photoError;

  static const List<Color> _swatches = AppColors.cellSwatches;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.cell.label);
    _spokenTextController = TextEditingController(text: widget.cell.spokenText);
    _symbolController = TextEditingController(text: widget.cell.symbol);
    _color = widget.cell.color;
    _isFolder = widget.cell.isFolder;
    _visualType = widget.cell.visualType;
    _photoPath = widget.cell.photoPath;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _spokenTextController.dispose();
    _symbolController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    setState(() => _photoError = null);

    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const <String>['jpg', 'jpeg', 'png'],
      allowMultiple: false,
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final file = result.files.single;
    final saved = await _photoStorage.validateAndSavePickedFile(file);
    if (!mounted) {
      return;
    }
    if (!saved.isSaved) {
      setState(() => _photoError = saved.error);
      return;
    }

    setState(() {
      _visualType = CellVisualType.photo;
      _photoPath = saved.path;
      _photoError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final canCreateFolder = widget.depth < maxFolderDepth;

    return AlertDialog(
      title: const Text('Customize cell'),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _labelController,
                decoration: const InputDecoration(
                  labelText: 'Displayed word',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _spokenTextController,
                decoration: const InputDecoration(
                  labelText: 'Audio playback text',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _symbolController,
                enabled: _visualType == CellVisualType.symbol,
                decoration: const InputDecoration(
                  labelText: 'Picture, icon, or visual symbol',
                  helperText: 'Use an emoji, short text, or icon-like symbol.',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _PhotoPickerPanel(
                photoPath: _photoPath,
                photoError: _photoError,
                usingPhoto: _visualType == CellVisualType.photo,
                onPickPhoto: _pickPhoto,
                onUseSymbol:
                    () => setState(() {
                      _visualType = CellVisualType.symbol;
                      _photoError = null;
                    }),
                onClearPhoto:
                    _photoPath == null
                        ? null
                        : () => setState(() {
                          _visualType = CellVisualType.symbol;
                          _photoPath = null;
                          _photoError = null;
                        }),
              ),
              const SizedBox(height: AppSpacing.xxl),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Open another board level'),
                subtitle: Text(
                  canCreateFolder
                      ? 'Folders can go up to level $maxFolderDepth.'
                      : 'This is already the deepest level.',
                ),
                value: _isFolder,
                onChanged:
                    canCreateFolder
                        ? (value) => setState(() => _isFolder = value)
                        : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children:
                      _swatches.map((color) {
                        final isSelected =
                            color.toARGB32() == _color.toARGB32();
                        return InkWell(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          onTap: () => setState(() => _color = color),
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    isSelected
                                        ? AppColors.neutral900
                                        : AppColors.transparent,
                                width: 3,
                              ),
                            ),
                            child:
                                isSelected
                                    ? const Icon(Icons.check_rounded)
                                    : null,
                          ),
                        );
                      }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: () {
            final edited =
                widget.cell.clone()
                  ..label =
                      _labelController.text.trim().isEmpty
                          ? 'Empty'
                          : _labelController.text.trim()
                  ..spokenText =
                      _spokenTextController.text.trim().isEmpty
                          ? _labelController.text.trim()
                          : _spokenTextController.text.trim()
                  ..symbol =
                      _symbolController.text.trim().isEmpty
                          ? '...'
                          : _symbolController.text.trim()
                  ..visualType = _visualType
                  ..photoPath =
                      _visualType == CellVisualType.photo ? _photoPath : null
                  ..color = _color
                  ..kind = _isFolder ? CellKind.folder : CellKind.speak;

            if (_isFolder && edited.children == null) {
              edited.children = BoardLevel.blank('${edited.label} board');
            }
            if (!_isFolder) {
              edited.children = null;
            }

            Navigator.pop(context, edited);
          },
          icon: const Icon(Icons.save_rounded),
          label: const Text('Save'),
        ),
      ],
    );
  }
}

class _PhotoPickerPanel extends StatelessWidget {
  const _PhotoPickerPanel({
    required this.photoPath,
    required this.photoError,
    required this.usingPhoto,
    required this.onPickPhoto,
    required this.onUseSymbol,
    required this.onClearPhoto,
  });

  final String? photoPath;
  final String? photoError;
  final bool usingPhoto;
  final VoidCallback onPickPhoto;
  final VoidCallback onUseSymbol;
  final VoidCallback? onClearPhoto;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.selectedSurface,
        borderRadius: AppRadius.largeBorder,
        border: Border.all(color: AppColors.neutral200, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                _PhotoPreview(photoPath: photoPath, selected: usingPhoto),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: <Widget>[
                      FilledButton.icon(
                        onPressed: onPickPhoto,
                        icon: const Icon(Icons.add_photo_alternate_rounded),
                        label: Text(
                          photoPath == null ? 'Choose photo' : 'Change',
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: onUseSymbol,
                        icon: const Icon(Icons.text_fields_rounded),
                        label: const Text('Use symbol'),
                      ),
                      if (photoPath != null)
                        IconButton.filledTonal(
                          tooltip: 'Remove photo',
                          onPressed: onClearPhoto,
                          icon: const Icon(Icons.delete_outline_rounded),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'JPG or PNG only. 3 MB max. PNG transparency is kept.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.neutral700,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (photoError != null) ...<Widget>[
              const SizedBox(height: AppSpacing.xs),
              Text(
                photoError!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({required this.photoPath, required this.selected});

  final String? photoPath;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final path = photoPath;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.largeBorder,
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.neutral200,
          width: 3,
        ),
      ),
      child: SizedBox.square(
        dimension: 86,
        child:
            path == null
                ? const Icon(
                  Icons.photo_size_select_actual_rounded,
                  color: AppColors.neutral500,
                  size: 40,
                )
                : ClipRRect(
                  borderRadius: AppRadius.mediumBorder,
                  child: Image.file(
                    File(path),
                    fit: BoxFit.cover,
                    cacheWidth: 200,
                    cacheHeight: 200,
                    alignment: Alignment.center,
                  ),
                ),
      ),
    );
  }
}
