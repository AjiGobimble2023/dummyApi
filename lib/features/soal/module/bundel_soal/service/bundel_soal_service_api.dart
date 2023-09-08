import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';

import '../../../../../core/helper/api_helper.dart';
import '../../../../../core/util/app_exceptions.dart';
import '../entity/bundel_soal.dart';

class BundelSoalServiceApi {
  final _apiHelper = ApiHelper();

  Future<List<dynamic>> fetchDaftarBundel({
    String? noRegistrasi,
    required String idSekolahKelas,
    required String idJenisProduk,
    required String roleTeaser,
    required bool isProdukDibeli,
  }) async {
    if (kDebugMode) {
      logger.log('BUNDEL_SOAL_SERVICE_API-FetchDaftarBundel: START');
    }
    final Map<String, dynamic> response = await _apiHelper.requestPost(
        jwt: noRegistrasi != null,
        pathUrl: '/bukusoal/bundel/$idJenisProduk',
        bodyParams: {
          'noRegistrasi': noRegistrasi,
          'teaserRole': roleTeaser,
          'idSekolahKelas': idSekolahKelas,
          'diBeli': isProdukDibeli,
        });

    if (kDebugMode) {
      logger.log(
          'BUNDEL_SOAL_SERVICE_API-FetchDaftarBundel: response >> $response');
    }

    if (!response['status']) throw DataException(message: response['message']);

    return response['data'];
  }

  Future<List<dynamic>> fetchDaftarBabSubBab(
      {required bool isJWT, required String idBundel}) async {
    final Map<String, dynamic> response = await _apiHelper.requestPost(
        jwt: isJWT, pathUrl: '/bukusoal/bab/$idBundel');

    if (!response['status']) throw DataException(message: response['message']);

    return response['data'];
  }

  Future<List<dynamic>> fetchDaftarSoal({
    required bool isJWT,
    String? kodeBab,
    required String idBundel,
    required OpsiUrut opsiUrut,
  }) async {
    String pathUrl = '/bukusoal/soal/${opsiUrut.name}/$idBundel';
    if (kDebugMode) {
      logger.log('BUNDEL_SOAL_SERVICE_API-FetchDaftarSoal: START with '
          'params(KodeBab: $kodeBab, IdBundel: $idBundel, OpsiUrut: $opsiUrut)');
    }
    final Map<String, dynamic> response = await _apiHelper.requestPost(
      jwt: isJWT,
      pathUrl: pathUrl,
      bodyParams: (opsiUrut == OpsiUrut.bab) ? {'kodeBab': kodeBab} : null,
    );

    if (!response['status']) throw DataException(message: response['message']);

    return response['data'] ?? [];
  }
}
