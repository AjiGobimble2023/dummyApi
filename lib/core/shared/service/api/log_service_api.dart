import 'dart:developer' as logger show log;
import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../../config/global.dart';
import '../../../helper/api_helper.dart';
import '../../../util/app_exceptions.dart';

class LogServiceAPI {
  final ApiHelper _apiHelper = ApiHelper();

  Future<void> setLog({
    required String userType,
    required List<Map<String, dynamic>> listLog,
    required String platform,
  }) async {
    final dynamic response;
    if (kDebugMode) {
      logger.log(
          "listlog1 ${listLog.asMap().values.elementAt(0).values.elementAt(2)}");
    }
    if (gLastIdLogActivity != null &&
        gLastMenuLogActivity ==
            listLog.asMap().values.elementAt(0).values.elementAt(2) &&
        gKeteranganLogActivity ==
            listLog.asMap().values.elementAt(0).values.elementAt(3)) {
      response = await _apiHelper.requestPost(
        pathUrl: '/2210/log/save',
        bodyParams: {
          'jenis': userType,
          'listLog': listLog,
          'platform': platform,
          'updateId': gLastIdLogActivity
        },
      );
    } else {
      response = await _apiHelper.requestPost(
        pathUrl: '/2210/log/save',
        bodyParams: {
          'jenis': userType,
          'listLog': listLog,
          'platform': platform
        },
      );
    }
    if (kDebugMode) {
      logger.log("cek log $listLog, $userType, $platform");
      logger.log("cek log lastId ${response['lastId']}");
    }
    if (!response['status']) throw DataException(message: response['message']);
    gLastIdLogActivity = response['lastId'];
    gLastMenuLogActivity =
        listLog.asMap().values.elementAt(0).values.elementAt(2);
    gKeteranganLogActivity =
        listLog.asMap().values.elementAt(0).values.elementAt(3);
    if (kDebugMode) {
      logger.log("cek $gLastIdLogActivity");
    }
    return response['lastId'];
  }
}
