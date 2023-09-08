import 'dart:async';
import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';

import '../../../../core/helper/api_helper.dart';
import '../../../../core/util/app_exceptions.dart';

class DataServiceAPI {
  final ApiHelper _apiHelper = ApiHelper();

  Future<dynamic> fetchAbout() async {
    final response = await _apiHelper.requestPost(pathUrl: '/about');

    if (!response['status']) throw DataException(message: response['message']);

    return response['data'];
  }

  Future<dynamic> fetchAturanSiswa({
    required String noRegistrasi,
    required String tipeUser,
  }) async {
    final response = await _apiHelper.requestPost(
      pathUrl: '/aturan',
      bodyParams: {
        'noRegistrasi': noRegistrasi,
        'siapa': tipeUser,
      },
    );

    if (!response['status']) throw DataException(message: response['message']);

    return response['data'];
  }

  Future<dynamic> setAturanSiswa({
    required String noRegistrasi,
    required String tipeUser,
  }) async {
    final response = await _apiHelper.requestPost(
      pathUrl: '/aturan/simpan',
      bodyParams: {
        'noRegistrasi': noRegistrasi,
        'siapa': tipeUser,
      },
    );

    if (!response['status']) throw DataException(message: response['message']);

    return response['data'];
  }

  Future<dynamic> fetchKelompokUjianPilihan(
      {required String noRegistrasi}) async {
    final response = await _apiHelper.requestPost(
      pathUrl: '/tryout/getmapelpilihan',
      bodyParams: {'nis': noRegistrasi},
    );

    if (!response['status']) throw DataException(message: response['message']);

    return response['data'];
  }

  Future<dynamic> setKelompokUjianPilihan({
    required String noRegistrasi,
    required List<String> daftarIdKelompokUjian,
  }) async {
    try {
      final response = await _apiHelper.requestPost(
        pathUrl: '/tryout/simpanmapelpilihan',
        bodyParams: {
          'nis': noRegistrasi,
          'idmapeluji': daftarIdKelompokUjian,
        },
      );

      return (response['status'] is bool) ? response['status'] : false;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-SetKelompokUjianPilihan: $e');
      }
      return false;
    }
  }

  Future<dynamic> deleteAccount({
    required String nomorHp,
    required String noRegistrasi,
  }) async {
    final response = await _apiHelper.requestPost(
      pathUrl: '/auth/delete',
      bodyParams: {
        'nomorHp': nomorHp,
        'noRegistrasi': noRegistrasi,
      },
    );

    return response;
  }
}
