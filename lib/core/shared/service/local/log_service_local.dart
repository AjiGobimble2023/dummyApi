import 'dart:developer' as logger show log;
import 'package:flutter/foundation.dart';

import '../../../helper/db_helper.dart';
import '../../../util/data_formatter.dart';
import '../../model/log_model.dart';

class LogServiceLocal {
  final DBHelper _dbHelper = DBHelper();

  Future<List<Map<String, dynamic>>> fetchLog() async {
    return await _dbHelper.fetchLogActivity();
  }

  Future<void> insertLog({
    required String userId,
    required String userType,
    required String menu,
    required String info,
    required String accessType,
  }) async {
    await _dbHelper.insertLogActivity(
      LogModel(
        userId: userId,
        userType: userType,
        menu: menu,
        info: info,
        accessType: accessType,
        lastUpdate: DataFormatter.formatLastUpdate(),
      ).toDBMap(),
    );
    if (kDebugMode) {
      logger.log("Berhasil menambahkan log local");
    }
  }

  Future<void> deleteLog() async {
    await _dbHelper.rawQueryDelete("DELETE FROM tlogactivity");
  }
}
