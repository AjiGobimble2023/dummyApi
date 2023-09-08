import 'dart:convert';
import 'dart:developer' as logger show log;

import 'package:http/http.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/helper/api_helper.dart';
import '../../../../core/util/app_exceptions.dart';

class BukuServiceAPI {
  final _apiHelper = ApiHelper();

  Future<List> fetchDaftarBuku({
    String? noRegistrasi,
    String jenisBuku = 'teori',
    required String idSekolahKelas,
    required String roleTeaser,
    required bool isProdukDibeli,
  }) async {
    if (kDebugMode) {
      logger.log(
          'BUKU_SERVICE_API-FetchBuku: START params(NoReg: $noRegistrasi, jenis: $jenisBuku, '
          '$idSekolahKelas, $roleTeaser, $isProdukDibeli)');
    }

    final response = await _apiHelper.requestPost(
      pathUrl: '/14.06.23/buku/$jenisBuku',
      bodyParams: {
        'noRegistrasi': noRegistrasi,
        'teaserRole': roleTeaser,
        'idSekolahKelas': idSekolahKelas,
        'diBeli': isProdukDibeli
      },
    );

    if (kDebugMode) {
      logger.log('BUKU_SERVICE_API-FetchBuku: response >> $response');
    }

    if (!response['status']) throw DataException(message: response['message']);

    return response['data'] ?? [];
  }

  Future<List> fetchDaftarBab({
    // String jenisBuku = 'teori',
    required String kodeBuku,
    required String kelengkapan,
    required String levelTeori,
  }) async {
    if (kDebugMode) {
      logger.log(
          'BUKU_SERVICE_API-FetchDaftarBab: START params(KodeBuku: $kodeBuku, '
          'kelengkapan: $kelengkapan, levelteori: $levelTeori)');
    }
    final response = await _apiHelper.requestPost(
      pathUrl: '/buku/bab/$kodeBuku',
      bodyParams: {
        'kelengkapan': kelengkapan,
        'levelTeori': levelTeori,
      },
    );
    if (kDebugMode) {
      logger.log("Response-FetchDaftarBab: $response");
    }

    if (kDebugMode) {
      logger.log('BUKU_SERVICE_API-FetchDaftarBab: response >> $response');
    }

    if (!response['status']) throw DataException(message: response['message']);

    return response['data'] ?? [];
  }

  Future<dynamic> fetchContent({required String idTeoriBab}) async {
    if (kDebugMode) {
      logger.log(
          'BUKU_SERVICE_API-FetchContent: START params(idTeoriBab: $idTeoriBab)');
    }

    final response = await _apiHelper.requestPost(
      pathUrl: '/buku/content/$idTeoriBab',
    );

    if (kDebugMode) {
      logger.log('BUKU_SERVICE_API-FetchContent: response >> $response');
    }

    if (!response['status']) throw DataException(message: response['message']);

    return response['data'];
  }
}
