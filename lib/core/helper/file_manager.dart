import 'dart:io';
import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';

import '../util/data_formatter.dart';

class FileManager {
  static FileManager? _instance;

  FileManager._internal() {
    _instance = this;
  }

  factory FileManager() => _instance ?? FileManager._internal();

  Future<String> get _directoryPath async {
    Directory? directory = await getExternalStorageDirectory();

    return directory?.path ?? _getGoKreasiPath();
  }

  String _getGoKreasiPath([String? rootPath]) => (rootPath != null)
      ? '${rootPath}0/Documents'
      : '/storage/emulated/0/Documents';

  Future<File> _getFile(bool isWrite) async {
    String path = await _directoryPath;

    if (!isWrite) {
      path = _getGoKreasiPath(path.split('0')[0]);
    }

    final directory = Directory(path);

    if (await directory.exists()) {
      if (kDebugMode) {
        logger.log('FILE_MANAGER-GetFile: directory exist >> $path');
      }
      return File('$path/.${dotenv.env['KREASI_UUID_FILE']}.txt');
    } else {
      final createDirectory = await directory.create(recursive: true);
      if (kDebugMode) {
        logger.log(
            'FILE_MANAGER-GetFile: create directory >> ${createDirectory.path}');
      }
      return File(
          '${createDirectory.path}/.${dotenv.env['KREASI_UUID_FILE']}.txt');
    }
  }

  Future<String?> readTextFile() async {
    String? fileContent;

    File file = await _getFile(false);

    if (await file.exists()) {
      try {
        fileContent = DataFormatter.decryptString(await file.readAsString());
      } catch (e) {
        logger.log('FILE_MANAGER-ReadTextFile: Error >> $e');
      }
    }

    return fileContent;
  }

  Future<bool> writeTextFile({required String uuid}) async {
    try {
      File file = await _getFile(true);
      File copyFile = await _getFile(false);

      String encryptedUUID = DataFormatter.encryptString(uuid);

      await file.writeAsString(encryptedUUID).then((file) {
        if (kDebugMode) {
          logger.log('FILE_MANAGER-WriteTextFile: then >> ${file.path}');
        }
      });

      // Copy file to go kreasi path
      await file.copy(copyFile.path).then((file) {
        if (kDebugMode) {
          logger.log('FILE_MANAGER-WriteTextFile: copy to >> ${copyFile.path}');
        }
      });

      return true;
    } catch (e) {
      logger.log('FILE_MANAGER-WriteTextFile: Error >> $e');
      return false;
    }
  }
}
