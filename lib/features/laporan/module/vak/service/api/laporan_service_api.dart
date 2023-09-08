import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';

import '../../../../../../core/helper/api_helper.dart';
import '../../../../../../core/util/app_exceptions.dart';

class LaporanServiceAPI {
  final ApiHelper _apiHelper = ApiHelper();

  Future<dynamic> fetchLaporanVak({
    required String noRegistrasi,
    required String userType,
  }) async {
    if (kDebugMode) {
      logger.log(
          'LAPORAN_VAK_SERVICE_API-FetchLaporanVak: START with params($noRegistrasi, $userType)');
    }

    final response = await _apiHelper.requestPost(
      pathUrl: '/vak',
      bodyParams: {'nis': noRegistrasi, 'jenis': userType},
    );

    if (kDebugMode) {
      logger.log(
          'LAPORAN_VAK_SERVICE_API-FetchLaporanVak: response >> $response');
    }

    if (!response['status'] &&
        !response['message'].contains('belum mengerjakan')) {
      throw DataException(message: response['message']);
    }

    return response['data'];
  }
}
