import 'dart:developer' as logger show log;
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

import '../../../../../../core/helper/api_helper.dart';
import '../../../../../../core/util/app_exceptions.dart';

class LaporanTryoutServiceAPI {
  final ApiHelper _apiHelper = ApiHelper();

  Future<dynamic> fetchLaporanTryout({
    required String noRegistrasi,
    required String idSekolahKelas,
    required String userType,
    required String jenisTO,
    required int idJurusanPilihan1,
    required int idJurusanPilihan2,
  }) async {
    if (kDebugMode) {
      logger.log('LAPORAN_TRYOUT_SERVICE-FetchLaporanTryout: START with Params '
          '($noRegistrasi, $idSekolahKelas, $userType, $jenisTO)');
      logger.log('LAPORAN_TRYOUT_SERVICE-FetchLaporanTryout: idJurusan 1 '
          '>> $idJurusanPilihan1');
      logger.log('LAPORAN_TRYOUT_SERVICE-FetchLaporanTryout: idJurusan 2 '
          '>> $idJurusanPilihan2');
    }
    final response = await _apiHelper.requestPost(
      pathUrl: '/tryout/laporan/tryout',
      bodyParams: {
        'nis': noRegistrasi,
        'idSekolahKelas': idSekolahKelas,
        'jenisTO': jenisTO,
        'jenis': userType,
        'pilihan1': idJurusanPilihan1,
        'pilihan2': idJurusanPilihan2
      },
      // pathUrl: '/tryout/laporan/$jenisTO',
      // bodyParams: {
      //   'noRegistrasi': noRegistrasi,
      //   'idSekolahKelas': idSekolahKelas,
      //   'userType': userType,
      //   'pilihan1': idJurusanPilihan1,
      //   'pilihan2': idJurusanPilihan2
      // },
    );

    if (kDebugMode) {
      logger.log('LAPORAN_TRYOUT_SERVICE-FetchLaporanTryout: Response '
          '>> $response');
    }

    if (!response['status']) throw DataException(message: response['message']);

    return response['data'];
  }

  Future<dynamic> fetchLaporanListTryout({
    required String userId,
    required String userClassLevelId,
    required String jenisTO,
    required String jenis,
  }) async {
    if (kDebugMode) {
      logger.log("LAPORAN TRYOUT SERVICE: execute fetchLaporanTryout()");
    }
    final response = await _apiHelper.requestPost(
      pathUrl: '/tryout/laporan/list',
      bodyParams: {
        "nis": userId,
        "idSekolahKelas": userClassLevelId,
        "jenisTO": jenisTO,
        "jenis": jenis,
      },
    );
    if (kDebugMode) {
      logger.log("response['data'] $response");
      logger.log("$userId $userClassLevelId $jenisTO $jenis");
    }
    if (kDebugMode) {
      logger.log("BodyParams : $userId $userClassLevelId $jenisTO");
      logger.log("Response Laporan TO : $response");
    }

    return response['data'];
  }

  Future<dynamic> fetchLaporanNilai(
      {required String userId,
      required String userClassLevelId,
      required String userType,
      required String kodeTOB,
      required String penilaian,
      required String pilihan1,
      required String pilihan2}) async {
    final response = await _apiHelper.requestPost(
      pathUrl: '/tryout/laporan/nilai',
      bodyParams: {
        'nis': userId,
        'idSekolahKelas': userClassLevelId,
        'jenis': userType,
        'kodeTOB': kodeTOB,
        'penilaian': penilaian,
        'pilihan1': pilihan1,
        'pilihan2': pilihan2,
      },
    );

    if (kDebugMode) {
      logger.log("Response fetchLaporanNilai : $response");
      logger.log(
          "bodyParamss : $userId $userClassLevelId $userType $kodeTOB $penilaian $pilihan1 $pilihan2");
    }
    return response['data'];
  }

  Future<void> uploadFeed(
      {String? userId, String? content, String? file64}) async {
    final response = await _apiHelper.requestPost(
        pathUrl: '/upload/feed',
        bodyParams: {"nis": userId, "text": content, "file64": file64});
    if (!response['status']) throw DataException(message: response['message']);
  }

  // Request token key to get url video stream.
  Future<dynamic> fetchEpbToken() async {
    final Response response = await _apiHelper.requestPatch(
      requestType: RequestType.epb,
    );
    if (kDebugMode) {
      logger.log("cek nilai : $response");
    }
    Map<String, dynamic> data = jsonDecode(response.body);
    return data['message'];
  }
}
