import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';

import '../../../../core/helper/api_helper.dart';
import '../../../../core/util/app_exceptions.dart';

class BeritaServiceApi {
  final ApiHelper _apiHelper = ApiHelper();

  Future<dynamic> fetchBerita({String userType = "UMUM"}) async {
    final response = await _apiHelper.requestPost(
      jwt: false,
      pathUrl: '/information',
      bodyParams: {'jenis': userType},
    );

    if (kDebugMode && !response['status']) {
      logger.log('BERITA_SERVICE_API-FetchBerita: response >> '
          '$response');
    }

    if (!response['status']) throw DataException(message: response['message']);

    return response['data'];
  }

  Future<dynamic> fetchBeritaPopUp({String userType = "UMUM"}) async {
    final response = await _apiHelper.requestPost(
      jwt: false,
      pathUrl: '/information/daily',
      bodyParams: {'jenis': userType},
    );

    if (kDebugMode && !response['status']) {
      logger.log('BERITA_SERVICE_API-FetchBeritaPopUp: response >> '
          '$response');
    }

    if (!response['status']) throw DataException(message: response['message']);

    return response['data'];
  }

  Future<void> setViewer(String idBerita) async {
    final response = await _apiHelper.requestPost(
      pathUrl: "/information/setviewers",
      bodyParams: {"idBerita": idBerita},
    );

    if (!response['status']) throw DataException(message: response['message']);
  }
}
