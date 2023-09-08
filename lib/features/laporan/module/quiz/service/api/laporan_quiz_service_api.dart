import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';

import '../../../../../../core/helper/api_helper.dart';

class LaporanKuisServiceAPI {
  final ApiHelper _apiHelper = ApiHelper();

  Future<Map<String, dynamic>> fetchLaporanKuis({
    required String noRegistrasi,
    required String idSekolahKelas,
    required String tahunAjaran,
  }) async {
    if (kDebugMode) {
      logger.log('LAPORAN_SERVICE_API-FetchLaporanKuis: START with '
          'params($noRegistrasi, $idSekolahKelas, $tahunAjaran)');
    }
    final response = await _apiHelper.requestPost(
      pathUrl: '/getlaporankuis',
      bodyParams: {
        'nis': noRegistrasi,
        'idsekolahkelas': idSekolahKelas,
        'tahunajaran': tahunAjaran,
      },
    );
    if (kDebugMode) {
      logger.log('LAPORAN_SERVICE_API-FetchLaporanKuis: Response >> $response');
    }

    // if (!response['status']) throw DataException(message: response['message']);

    return response;
  }
}
