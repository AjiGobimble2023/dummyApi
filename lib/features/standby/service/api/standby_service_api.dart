import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';

import '../../../../core/helper/api_helper.dart';
import '../../../../core/util/app_exceptions.dart';

class StandbyServiceApi {
  final ApiHelper _apiHelper = ApiHelper();

  Future<dynamic> fetchStandby(Map<String, dynamic> bodyParams) async {
    if (kDebugMode) {
      logger.log(
          'STANDBY_SERVICE_API-FetchStandby: START with Params$bodyParams');
    }
    final response = await _apiHelper.requestPost(
      bodyParams: bodyParams,
      pathUrl: '/standby/schedule',
    );

    if (kDebugMode) {
      logger.log('STANDBY_SERVICE_API-FetchStandby: response >> $response');
    }

    if (!response['status']) throw DataException(message: response['message']);

    return response['data'];
  }

  Future<void> requestTST(Map<String, dynamic> bodyParams) async {
    if (kDebugMode) {
      logger
          .log('STANDBY_SERVICE_API-RequestTST: START with Params$bodyParams');
    }
    final response = await _apiHelper.requestPost(
      bodyParams: bodyParams,
      pathUrl: '/standby/tst/request',
    );

    if (kDebugMode) {
      logger.log('STANDBY_SERVICE_API-RequestTST: response >> $response');
    }

    if (!response['status']) throw DataException(message: response['message']);
  }
}
