import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';

import '../../../../core/helper/api_helper.dart';
import '../../../../core/util/app_exceptions.dart';

class SoalServiceAPI {
  final ApiHelper _apiHelper = ApiHelper();

  static final SoalServiceAPI _instance = SoalServiceAPI._internal();

  factory SoalServiceAPI() => _instance;

  SoalServiceAPI._internal();

  Future<bool> simpanJawaban({
    required String tahunAjaran,
    required String noRegistrasi,
    required String idSekolahKelas,
    required String tipeUser,
    required String idKota,
    required String idGedung,
    required String kodeTOB,
    required String kodePaket,
    required int idJenisProduk,
    required int jumlahSoal,
    required List<Map<String, dynamic>> detailJawaban,
  }) async {
    final response = await _apiHelper.requestPost(
      pathUrl: '/bukusoal/simpanjawabanV2',
      bodyParams: {
        'nis': noRegistrasi,
        'role': tipeUser,
        'idsekolahkelas': idSekolahKelas,
        'idpenanda': idKota,
        'idgedung': idGedung,
        'tahunajaran': tahunAjaran,
        'kodetob': kodeTOB,
        'kodepaket': kodePaket,
        'jenisproduk': idJenisProduk,
        'jumsoal': jumlahSoal,
        'detailJawaban': detailJawaban,
      },
    );

    return response['status'];
  }

  Future<dynamic> fetchSolusi({required String idSoal}) async {
    if (kDebugMode) {
      logger.log('SOAL_SERVICE_API-FetchSolusi: START with params($idSoal)');
    }

    final response = await _apiHelper.requestPost(
      pathUrl: '/solusi/getsolusi',
      bodyParams: {'idsoal': idSoal},
    );

    if (kDebugMode) {
      logger.log('SOAL_SERVICE_API-FetchSolusi: response $idSoal >> $response');
    }

    if (!response['status']) throw DataException(message: response['message']);

    return response['data'];
  }

  // Future<dynamic> fetchVideoSolusi({required String idVideo}) async {
  //   final response = await _apiHelper.requestPost(
  //     pathUrl: '/solusi/getvideo',
  //     bodyParams: {'idvideo': idVideo},
  //   );
  //
  //   if (!response['status']) throw DataException(message: response['message']);
  //
  //   return response['data'];
  // }

  Future<List<dynamic>> fetchSobatTips({
    required String idSoal,
    required String idBundel,
    required bool isBeliLengkap,
    required bool isBeliSingkat,
    required bool isBeliRingkas,
  }) async {
    final response = await _apiHelper.requestPost(
      pathUrl: '/solusi/tips/$idBundel/$idSoal',
      bodyParams: {
        'isBeliLengkap': isBeliLengkap,
        'isBeliSingkat': isBeliSingkat,
        'isBeliRingkas': isBeliRingkas,
      },
    );

    if (!response['status']) throw DataException(message: response['message']);

    return response['data'] ?? [];
  }

  Future<List<dynamic>> fetchDetailHasilJawaban({
    required String noRegistrasi,
    required String idSekolahKelas,
    required String jenisHasil,
    required String kodePaket,
    required int jumlahSoal,
  }) async {
    final response = await _apiHelper.requestPost(
      pathUrl:
          '/bukusoal/hasil/$jenisHasil/$kodePaket/$idSekolahKelas/$noRegistrasi',
      bodyParams: {'jumlahSoal': jumlahSoal},
    );

    if (!response['status']) throw DataException(message: response['message']);

    return response['data'] ?? [];
  }
}
