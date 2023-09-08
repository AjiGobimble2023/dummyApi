import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';

import '../../../../core/helper/api_helper.dart';
import '../../../../core/util/app_exceptions.dart';

class PembayaranServiceAPI {
  final ApiHelper _apiHelper = ApiHelper();

  Future<dynamic> fetchPembayaran({required String noRegistrasi}) async {
    final response = await _apiHelper.requestPost(
      pathUrl: '/pembayaran/info',
      bodyParams: {'nis': noRegistrasi},
    );

    if (kDebugMode) {
      logger.log('PEMBAYARAN_SERVICE_API-FetchPembayaran: response >> $response');
    }

    if (!response['status']) throw DataException(message: response['message']);

    return response;
  }

  Future<dynamic> fetchDetailPembayaran({required String noRegistrasi}) async {
    final response = await _apiHelper.requestPost(
      pathUrl: '/pembayaran/infodetail',
      bodyParams: {'nis': noRegistrasi},
    );

    if (kDebugMode) {
      logger.log('PEMBAYARAN_SERVICE_API-FetchDetailPembayaran: response >> $response');
    }

    if (!response['status']) throw DataException(message: response['message']);

    return response['data'];
  }
}
