import 'dart:convert';
import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

import '../../../../core/helper/api_helper.dart';
import '../../../../core/util/app_exceptions.dart';

class VideoServiceApi {
  final ApiHelper _apiHelper = ApiHelper();

  Future<List> fetchVideoTeori({
    required String noRegistrasi,
    required String kodeBab,
    required String levelTeori,
    required String kelengkapan,
    required String idTeoriBab,
    required String jenisBuku,
  }) async {
    if (kDebugMode) {
      logger.log('VIDEO_SERVICE_API-FetchVideoTeori: START with '
          'params($noRegistrasi, $kodeBab, $jenisBuku)');
    }

    final response = await _apiHelper.requestPost(
        pathUrl: "/video",
        bodyParams: {
          'noRegistrasi': noRegistrasi,
          'kodeBab': kodeBab,
          'levelTeori': levelTeori,
          'kelengkapan': kelengkapan,
          'idTeoriBab': idTeoriBab,
          'jenisBuku': jenisBuku
        });

    if (kDebugMode) {
      logger.log('VIDEO_SERVICE_API-FetchVideoTeori: response >> $response');
    }

    if (!response['status']) throw DataException(message: response['message']);

    return response['data'] ?? [];
  }

  Future<dynamic> fetchVideoSoal({required int idVideo}) async {
    final response = await _apiHelper.requestPost(
      pathUrl: "/solusi/getvideo",
      bodyParams: {'idvideo': idVideo},
    );

    if (kDebugMode) {
      logger.log('VIDEO_SERVICE_API-FetchVideoSoal: response >> $response');
    }

    if (!response['status']) throw DataException(message: response['message']);

    return response['data'];
  }

  Future<dynamic> fetchVideoTeaser({
    required String idSekolahKelas,
    required String userType,
  }) async {
    final response = await _apiHelper.requestPost(
      jwt: false,
      pathUrl: "/video/videoteaser",
      bodyParams: {
        'idsekolahkelas': idSekolahKelas,
        'role': userType,
      },
    );

    if (kDebugMode) {
      logger.log(
          'VIDEO_SERVICE_API-FetchVideoTeaser: $idSekolahKelas-$userType response >> $response');
    }

    return response;
  }

  Future<List> fetchVideoJadwalMapel({
    required String noRegistrasi,
    required String userType,
    required bool isProdukDibeli,
  }) async {
    final response = await _apiHelper.requestPost(
      jwt: false,
      pathUrl: "/video/getmapel",
      bodyParams: {
        'nis': noRegistrasi,
        'role': userType,
        'dibeli': isProdukDibeli,
      },
    );

    if (kDebugMode) {
      logger.log(
          'VIDEO_SERVICE_API-FetchVideoJadwalMapel: $noRegistrasi-$userType response >> $response');
    }

    if (!response['status']) throw DataException(message: response['message']);

    return response['data'] ?? [];
  }

  Future<List> fetchVideoJadwal(
      {required String noRegistrasi,
      required String idMataPelajaran,
      required String tingkatSekolah}) async {
    final response = await _apiHelper.requestPost(
      pathUrl: "/video/getbab",
      bodyParams: {
        'noregistrasi': noRegistrasi,
        'idmapel': idMataPelajaran,
        'level': tingkatSekolah,
      },
    );

    if (kDebugMode) {
      logger.log(
          'VIDEO_SERVICE_API-FetchVideoJadwal: $idMataPelajaran response >> $response');
    }

    if (!response['status']) throw DataException(message: response['message']);

    return response['data'] ?? [];
  }

  // Request token key to get url video stream.
  Future<dynamic> fetchStreamToken() async {
    final Response response =
        await _apiHelper.requestPatch(requestType: RequestType.video);

    if (kDebugMode) {
      logger.log(
          "VIDEO_SERVICE_API-FetchStreamToken: response body >> ${response.body}");
    }

    Map<String, dynamic> data = jsonDecode(response.body);

    return data['message'];
  }
}
