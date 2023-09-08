import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';

import '../../../../../../../core/helper/api_helper.dart';
import '../../../../../../../core/util/app_exceptions.dart';

class PtnServiceApi {
  final ApiHelper _apiHelper = ApiHelper();

  Future<dynamic> fetchUniversitas() async {
    final response = await _apiHelper.requestPost(
      pathUrl: '/ptn/universitas',
    );

    if (kDebugMode) {
      logger.log('PTN_SERVICE_API-FetchPTN: response >> $response');
    }

    if (!response['status']) throw DataException(message: response['message']);

    return response['data'];
  }

  Future<dynamic> fetchJurusan({
    required int idPtn,
  }) async {
    if (kDebugMode) {
      logger.log('PTN_SERVICE_API-FetchPTN: START with params($idPtn)');
    }

    final response = await _apiHelper.requestPost(
      pathUrl: '/ptn/jurusan',
      bodyParams: {'idPtn': idPtn},
    );

    if (kDebugMode) {
      logger.log('PTN_SERVICE_API-FetchPTN: response >> $response');
    }

    if (!response['status']) throw DataException(message: response['message']);

    return response['data'];
  }

  Future<dynamic> fetchDetailJurusan({
    required int idJurusan,
  }) async {
    if (kDebugMode) {
      logger.log(
          'PTN_SERVICE_API-FetchDetailJurusan: START with params($idJurusan)');
    }

    final response = await _apiHelper.requestPost(
      pathUrl: '/ptn/jurusan/detail',
      bodyParams: {'idJurusan': idJurusan},
    );

    if (kDebugMode) {
      logger.log('PTN_SERVICE_API-FetchDetailJurusan: response >> $response');
    }

    if (!response['status']) throw DataException(message: response['message']);

    return response['data'];
  }

  Future<dynamic> fetchKampusImpianPilihan({
    required String noRegistrasi,
  }) async {
    if (kDebugMode) {
      logger.log(
          'PTN_SERVICE_API-FetchKampusImpianPilihan: START with params($noRegistrasi)');
    }

    final response = await _apiHelper.requestPost(
      pathUrl: '/ptn/pilihan',
      bodyParams: {'noRegistrasi': noRegistrasi},
    );

    if (kDebugMode) {
      logger.log(
          'PTN_SERVICE_API-FetchKampusImpianPilihan: response >> $response');
    }

    if (!response['status']) throw DataException(message: response['message']);

    return response;
  }

  Future<dynamic> putKampusImpian(
      {required String noRegistrasi,
      required int pilihanKe,
      required int idJurusan}) async {
    if (kDebugMode) {
      logger.log('PTN_SERVICE_API-UpdateKampusImpian: '
          'START with params($noRegistrasi, $pilihanKe, $idJurusan)');
    }

    final response = await _apiHelper.requestPost(
      pathUrl: '/ptn/pilihan/simpan',
      bodyParams: {
        'noRegistrasi': noRegistrasi,
        'pilihanKe': pilihanKe,
        'idJurusan': idJurusan,
      },
    );

    if (kDebugMode) {
      logger.log('PTN_SERVICE_API-UpdateKampusImpian: response >> $response');
    }

    return response;
  }
}
