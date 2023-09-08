import 'dart:async';
import 'dart:developer' as logger show log;
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../service/api/log_service_api.dart';
import '../service/local/log_service_local.dart';
import '../../config/global.dart';
import '../../config/extensions.dart';
import '../../util/app_exceptions.dart';

class LogProvider {
  final _apiService = LogServiceAPI();
  final _localService = LogServiceLocal();

  Future<void> sendLogActivity(String? userType) async {
    try {
      if (gUser == null || gUser.isOrtu || userType == null) {
        return;
      }
      String platform = "Android";
      if (Platform.isIOS) {
        platform = "IOS";
      }
      final listLog = await _localService.fetchLog();

      if (listLog.isNotEmpty) {
        await _apiService.setLog(
          userType: userType,
          listLog: listLog.toList(),
          platform: platform,
        );
        if (kDebugMode) {
          logger.log("cek log ${listLog.toList()}");
        }
        await _localService.deleteLog();
      }
    } on TimeoutException catch (e) {
      // throw 'TimeoutException-SendLogActivity: $e';
      if (kDebugMode) {
        logger.log('TimeoutException-SendLogActivity: $e');
      }
    } on DataException catch (e) {
      // throw 'Exception-SendLogActivity: $e';
      if (kDebugMode) {
        logger.log('Exception-SendLogActivity: $e');
      }
    } catch (e) {
      // throw 'FatalException-SendLogActivity: $e';
      if (kDebugMode) {
        logger.log('FatalException-SendLogActivity: $e');
      }
    }
  }

  Future<void> saveLog({
    String? userId,
    String? userType,
    String? menu,
    String? info,
    String? accessType,
  }) async {
    try {
      if (gUser == null || gUser.isOrtu) {
        return;
      }
      await _localService.insertLog(
        userId: userId!,
        userType: userType!,
        menu: menu!,
        info: info!,
        accessType: accessType!,
      );
      if (kDebugMode) {
        logger.log("Berhasil menyimpan log aktivitas");
      }
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-SaveLog: $e');
      }
    }
  }
}
