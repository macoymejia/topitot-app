import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../constants/aac_constants.dart';

class PhotoStorageResult {
  const PhotoStorageResult._({this.path, this.error});

  const PhotoStorageResult.saved(String path) : this._(path: path);
  const PhotoStorageResult.failed(String error) : this._(error: error);

  final String? path;
  final String? error;

  bool get isSaved => path != null;
}

class PhotoStorageService {
  Future<PhotoStorageResult> validateAndSavePickedFile(
    PlatformFile file,
  ) async {
    final extension = normalizedPhotoExtension(file.name);
    if (extension == null) {
      return const PhotoStorageResult.failed(
        'Please choose a JPG or PNG photo.',
      );
    }

    final bytes = file.bytes;
    if (file.size > maxCellPhotoBytes ||
        (bytes != null && bytes.lengthInBytes > maxCellPhotoBytes)) {
      return const PhotoStorageResult.failed('Photo must be 3 MB or smaller.');
    }

    if (bytes == null) {
      final path = file.path;
      if (path == null) {
        return const PhotoStorageResult.failed('Could not read that photo.');
      }
      final pickedFile = File(path);
      final length = await pickedFile.length();
      if (length > maxCellPhotoBytes) {
        return const PhotoStorageResult.failed(
          'Photo must be 3 MB or smaller.',
        );
      }
      final pickedBytes = await pickedFile.readAsBytes();
      if (!matchesPhotoFormat(pickedBytes, extension)) {
        return const PhotoStorageResult.failed(
          'Please choose a real JPG or PNG photo.',
        );
      }
      return PhotoStorageResult.saved(
        await savePhotoBytes(pickedBytes, extension),
      );
    }

    if (!matchesPhotoFormat(bytes, extension)) {
      return const PhotoStorageResult.failed(
        'Please choose a real JPG or PNG photo.',
      );
    }

    return PhotoStorageResult.saved(await savePhotoBytes(bytes, extension));
  }

  String? normalizedPhotoExtension(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.endsWith('.jpg') || lowerName.endsWith('.jpeg')) {
      return 'jpg';
    }
    if (lowerName.endsWith('.png')) {
      return 'png';
    }
    return null;
  }

  bool matchesPhotoFormat(Uint8List bytes, String extension) {
    if (extension == 'jpg') {
      return bytes.lengthInBytes >= 3 && bytes[0] == 0xFF && bytes[1] == 0xD8;
    }

    const pngSignature = <int>[0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
    if (bytes.lengthInBytes < pngSignature.length) {
      return false;
    }
    for (var index = 0; index < pngSignature.length; index += 1) {
      if (bytes[index] != pngSignature[index]) {
        return false;
      }
    }
    return true;
  }

  Future<String> savePhotoBytes(Uint8List bytes, String extension) async {
    final appDirectory = await getApplicationSupportDirectory();
    final photoDirectory = Directory('${appDirectory.path}/aac_photos');
    if (!await photoDirectory.exists()) {
      await photoDirectory.create(recursive: true);
    }

    final fileName =
        'cell_photo_${DateTime.now().microsecondsSinceEpoch}.$extension';
    final savedFile = File('${photoDirectory.path}/$fileName');
    await savedFile.writeAsBytes(bytes, flush: true);
    return savedFile.path;
  }
}
