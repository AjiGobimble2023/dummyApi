import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';

import '../../../../core/helper/api_helper.dart';
import '../../../../core/util/app_exceptions.dart';

/// [LeaderboardServiceApi] merupakan service class penghubung provider dengan request api.
class LeaderboardServiceApi {
  final _apiHelper = ApiHelper();

  Future<dynamic> fetchLeaderboardBukuSakti({
    required String noRegistrasi,
    required String idSekolahKelas,
    required String idKota,
    required String idGedung,
    required int tipeJuara,
    required String tahunAjaran,
  }) async {
    if (kDebugMode) {
      logger.log('LEADERBOARD_SERVICE_API-FetchLeaderboard: START with '
          'params($noRegistrasi,$idSekolahKelas,$idKota,$idGedung,$tipeJuara,$tahunAjaran)');
    }
    final response = await _apiHelper.requestPost(
      pathUrl: '/leaderboard',
      bodyParams: {
        'nis': noRegistrasi,
        'jenis': 'SISWA',
        'idSekolahKelas': idSekolahKelas,
        'penanda': idKota,
        'idGedung': idGedung,
        'ta': tahunAjaran,
        'tipe': tipeJuara.toString(),
      },
    );

    if (kDebugMode) {
      logger.log('LEADERBOARD_SERVICE_API-FetchLeaderboard: '
          'Response >> $response');
    }

    if (!response['status']) throw DataException(message: response['message']);

    return response;
  }

  Future<dynamic> fetchFirstRankBukuSakti({
    required String idSekolahKelas,
    required String idKota,
    required String idGedung,
    required String tahunAjaran,
  }) async {
    if (kDebugMode) {
      logger.log('LEADERBOARD_SERVICE_API-FetchFirstRank: START with '
          'params($idSekolahKelas, $idKota, $idGedung, $tahunAjaran)');
    }
    final response = await _apiHelper.requestPost(
      jwt: false,
      pathUrl: '/leaderboard/firstRank',
      bodyParams: {
        'idSekolahKelas': idSekolahKelas,
        'penanda': idKota,
        'idGedung': idGedung,
        'tahunAjaran': tahunAjaran,
      },
    );

    if (kDebugMode) {
      logger.log('LEADERBOARD_SERVICE_API-FetchFirstRank: '
          'response >> $response');
    }
    if (!response['status']) throw DataException(message: response['data']);

    return response['data'];
  }

  Future<dynamic> fetchCapaianScoreKamu({
    required String noRegistrasi,
    required String tahunAjaran,
    required String idSekolahKelas,
    required String userType,
    required String idKota,
    required String idGedung,
  }) async {
    if (kDebugMode) {
      logger.log('LEADERBOARD_SERVICE_API-FetchCapaianScoreKamu: START with '
          'params($noRegistrasi, $idSekolahKelas, $tahunAjaran, $userType, $idKota, $idGedung)');
    }
    final response = await _apiHelper.requestPost(
      pathUrl: '/leaderboard/capaian',
      bodyParams: {
        'noRegistrasi': noRegistrasi,
        'ta': tahunAjaran,
        'idSekolahKelas': idSekolahKelas,
        'jenis': userType,
        'penanda': idKota,
        'idGedung': idGedung,
      },
    );

    if (kDebugMode) {
      logger.log('LEADERBOARD_SERVICE_API-FetchCapaianScoreKamu: '
          'response >> $response');
    }
    if (!response['status']) throw DataException(message: response['message']);

    return response['data'];
    // return {
    //   "detail": {
    //     "benarlevel1": 6,
    //     "benarlevel2": 78,
    //     "benarlevel3": 278,
    //     "benarlevel4": 259,
    //     "benarlevel5": 24,
    //     "salahlevel1": 6,
    //     "salahlevel2": 57,
    //     "salahlevel3": 205,
    //     "salahlevel4": 167,
    //     "salahlevel5": 24
    //   },
    //   "totalScore": 2152,
    //   "targetJumlahSoal": 12000,
    //   "totalSoal": 8104,
    //   "totalSoalBenar": 645,
    //   "totalSoalSalah": 459,
    //   "rankGedung": 27,
    //   "rankKota": 27,
    //   "rankNasional": 7014
    // };
  }

  Future<dynamic> fetchHasilPengerjaanSoal({
    required String noRegistrasi,
    required String idSekolahKelas,
    required String tahunAjaran,
  }) async {
    if (kDebugMode) {
      logger.log('LEADERBOARD_SERVICE_API-FetchHasilPengerjaanSoal: START with '
          'params($noRegistrasi, $idSekolahKelas, $tahunAjaran)');
    }
    final response = await _apiHelper.requestPost(
      pathUrl: '/capaian/bar',
      // bodyParams: {
      //   'nis': '050820090601',
      //   'tahunajaran': '2023/2024',
      //   'idSekolahKelas': '13',
      //   'semester': null
      // },
      bodyParams: {
        'nis': noRegistrasi,
        'tahunajaran': tahunAjaran,
        'idSekolahKelas': idSekolahKelas,
        'semester': null
      },
    );

    if (kDebugMode) {
      logger.log(
          "LEADERBOARD_SERVICE_API-FetchHasilPengerjaanSoal: response >> $response");
    }

    if (!response['status']) throw DataException(message: response['message']);

    return response['data'];
  }
}
