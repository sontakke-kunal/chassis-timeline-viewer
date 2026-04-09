import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;

class FileUtils {
  FileUtils._();

  static FileUtils instance = FileUtils._();

  Future<void> moveDirectory(String sourcePath, String destinationPath) async {
    final sourceDir = Directory(sourcePath);
    final destinationDir = Directory(destinationPath);

    if (!await sourceDir.exists()) {
      print('Source directory does not exist.');
      return;
    }

    // Ensure destination parent directory exists
    await destinationDir.parent.create(recursive: true);

    try {
      // Move the entire directory
      await sourceDir.rename(destinationPath);
      print('Directory moved successfully.');
    } catch (e) {
      // Fallback: Manually copy then delete
      print('Rename failed. Trying manual copy...');
      await _copyDirectory(sourceDir, destinationDir);
      await sourceDir.delete(recursive: true);
      print('Directory moved via copy + delete.');
    }
  }

  Future<void> _copyDirectory(Directory source, Directory destination) async {
    if (!await destination.exists()) {
      await destination.create(recursive: true);
    }

    await for (FileSystemEntity entity in source.list(recursive: false)) {
      if (entity is Directory) {
        final newDirectory = Directory(p.join(destination.path, p.basename(entity.path)));
        await _copyDirectory(entity, newDirectory);
      } else if (entity is File) {
        await entity.copy(p.join(destination.path, p.basename(entity.path)));
      }
    }
  }

  Future<void> moveFilesToDirectory(List<File> files, Directory targetDir) async {
    if (!(await targetDir.exists())) {
      await targetDir.create(recursive: true);
    }

    for (File file in files) {
      if (file.path.contains('__MACOSX')) continue;
      final fileName = p.basename(file.path);
      final newFile = File(p.join(targetDir.path, fileName));
      await file.copy(newFile.path);
      await file.delete();
    }
  }

  Future<void> deleteInsideDirectory(Directory dir) async {
    if (await dir.exists()) {
      await for (var entity in dir.list(recursive: false)) {
        try {
          if (entity is File) {
            await entity.delete();
          } else if (entity is Directory) {
            await entity.delete(recursive: true);
          }
        } catch (e) {
          print('Failed to delete ${entity.path}: $e');
        }
      }
    } else {
      print('Directory does not exist: ${dir.path}');
    }
  }

  Future<void> zipFiles(IsolateZipModel data) async {
    final List<String> files = data.files;
    final List<String>? relativePaths = data.relativePaths;
    final String zipFileName = data.zipFileName;
    final SendPort sendPort = data.sendPort;
    final String directoryPath = data.directoryPath;

    try {
      final encoder = ZipFileEncoder();
      final zipPath = '$directoryPath/$zipFileName';
      // await File(zipPath).create(recursive: true);
      encoder.create(zipPath);
      int totalBytes = 0;
      int sendBytes = 0;
      files.map((file) => File(file).statSync().size).forEach((bytes) {
        totalBytes += bytes;
      });
      for (int i = 0; i < files.length; i++) {
        final file = File(files[i]);
        if (!await file.exists()) continue;
        sendBytes += file.statSync().size;
        final relativePath = relativePaths?[i] ?? files[i];
        await encoder.addFile(file, relativePath);
        final double progress = (sendBytes / totalBytes) * 100;
        sendPort.send(jsonEncode({'type': 'progress', 'progress': progress}));
      }
      encoder.close();
      sendPort.send(jsonEncode({'type': 'success', 'path': zipPath}));
    } catch (e) {
      sendPort.send(jsonEncode({'type': 'error', 'message': e.toString()}));
    }
  }

  Future<void> unzipFile(IsolateUnzipModel model) async {
    final zipFilePath = model.zipFilePath;
    final destinationDirectory = model.destinationDirectory;
    final SendPort sendPort = model.resultPort;

    try {

      final bytes = await File(zipFilePath).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes, password: model.password);

      // Step 1: Calculate total uncompressed size
      int totalBytes = 0;
      for (final file in archive) {
        if (file.isFile) {
          totalBytes += file.size.toInt();
        }
      }
      // Step 2: Extract files with progress
      int extractedBytes = 0;

      for (final file in archive) {
        var filename = file.name;
        filename = filename.split('/file_picker/').last;
        filename = filename.split('/').last;
        final filePath = destinationDirectory.endsWith('/') || filename.startsWith('/') ? '$destinationDirectory$filename' : '$destinationDirectory/$filename';
        if (file.isFile) {
          final data = file.content as List<int>;
          final outFile = File(filePath);
          await outFile.create(recursive: true);
          final zipStream = outFile.openWrite();
          zipStream.add(data);
          await zipStream.close();

          // Byte-level progress
          extractedBytes += data.length.toInt();
          final progress = (extractedBytes / totalBytes) * 100;
          sendPort.send(jsonEncode({'type': 'progress', 'progress': progress}));
        } else {
          await Directory(filePath).create(recursive: true);
        }
      }
      sendPort.send(jsonEncode({'type': 'success'}));
    } catch (e) {
      print('Error in unzip: $e');
      sendPort.send(jsonEncode({'type': 'error', 'e': e.toString()}));
    }
  }
}

class IsolateUnzipModel {
  final String zipFilePath;
  final String destinationDirectory;
  final SendPort resultPort;
  final String? password;

  IsolateUnzipModel(this.zipFilePath, this.destinationDirectory, this.resultPort, {this.password});
}

class IsolateZipModel {
  final List<String> files;
  final List<String>? relativePaths;
  final String zipFileName;
  final String directoryPath;
  final SendPort sendPort;
  final String? password;

  IsolateZipModel(this.files, this.relativePaths, this.zipFileName, this.sendPort, this.directoryPath, {this.password});
}
