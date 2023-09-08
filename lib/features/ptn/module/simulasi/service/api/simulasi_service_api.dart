import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';
import '../../../../../../core/config/global.dart';

import '../../../../../../core/config/enum.dart';
import '../../../../../../core/helper/api_helper.dart';
import '../../../../../../core/util/app_exceptions.dart';

class SimulasiServiceAPI {
  final ApiHelper _apiHelper = ApiHelper();

  /// [fetchNilai] is used to fetch the student's score.
  ///
  /// Args:
  ///   noRegistrasi (String): NIS
  ///   idSekolahKelas (String): The id of the school class.
  ///
  /// Returns:
  ///   The response is a Map<String, dynamic>
  Future<dynamic> fetchNilai({
    required String noRegistrasi,
    required String idSekolahKelas,
  }) async {
    if (kDebugMode) {
      logger.log(
          'SIMULASI_SERVICE_API-FetchNilai: START with params($noRegistrasi)');
    }

    final response = await _apiHelper.requestPost(
      pathUrl: '/simulasi/nilai',
      bodyParams: {
        'nis': noRegistrasi,
        'idSekolahKelas': idSekolahKelas,
      },
    );

    if (kDebugMode) {
      logger.log('SIMULASI_SERVICE_API-FetchNilai: Response >> $response');
    }

    return response['data'];
  }

  /// [fetchPilihan] is used to fetch the data of the selected college.
  ///
  /// Args:
  ///   noRegistrasi (String): The registration number of the student
  ///
  /// Returns:
  ///   A Future<dynamic>
  Future<dynamic> fetchPilihan({
    required String noRegistrasi,
  }) async {
    if (kDebugMode) {
      logger.log(
          'SIMULASI_SERVICE_API-FetchPilihan: START with params($noRegistrasi)');
    }

    final response = await _apiHelper.requestPost(
      pathUrl: '/simulasi/pilihan',
      bodyParams: {'nis': noRegistrasi},
    );

    if (kDebugMode) {
      logger.log('SIMULASI_SERVICE_API-FetchPilihan: Response >> $response');
    }

    if (!response['status']) throw DataException(message: response['message']);

    return response['data'];
  }

  Future<dynamic> fetchUniversitas({
    required String idSekolahKelas,
  }) async {
    if (kDebugMode) {
      logger.log('SIMULASI_SERVICE_API-FetchUniversitas: START with '
          'params($idSekolahKelas)');
    }

    final response = await _apiHelper.requestPost(
      pathUrl: '/simulasi/pilihan/universitas',
      bodyParams: {
        'idSekolahKelas': idSekolahKelas,
      },
    );

    if (kDebugMode) {
      logger
          .log('SIMULASI_SERVICE_API-FetchUniversitas: Response >> $response');
    }

    if (!response['status']) throw DataException(message: response['message']);

    return response['data'];
  }

  Future<dynamic> fetchSimulasi({
    required String noRegistrasi,
    required String userType,
  }) async {
    if (kDebugMode) {
      logger.log(
          'SIMULASI_SERVICE_API-FetchSimulasi: START with params($noRegistrasi, $userType)');
    }

    final response = await _apiHelper.requestPost(
      pathUrl: '/simulasi/hasil',
      bodyParams: {
        'nis': noRegistrasi,
        'jenis': userType,
      },
    );

    if (kDebugMode) {
      logger.log('SIMULASI_SERVICE_API-FetchSimulasi: Response >> $response');
    }

    return response['data'];
  }

  Future<void> setNilai({
    required String noRegistrasi,
    required String kodeTOB,
    required String status,
    required List<Map<String, dynamic>> listNilai,
  }) async {
    if (kDebugMode) {
      logger.log('SIMULASI_SERVICE_API-SetNilai: START with '
          'params($noRegistrasi, $kodeTOB, $status, $listNilai)');
    }

    final response = await _apiHelper.requestPost(
      bodyParams: {
        'nis': noRegistrasi,
        'kodeTob': kodeTOB,
        'detailNilai': listNilai,
        'status': status,
      },
      pathUrl: '/simulasi/nilai/simpan',
    );

    if (kDebugMode) {
      logger.log('SIMULASI_SERVICE_API-SetNilai: Response >> $response');
    }

    if (!response['status']) throw DataException(message: response['message']);
  }

  Future<void> setPilihan({
    required String noRegistrasi,
    required String prioritas,
    required String status,
    required String idJurusan,
  }) async {
    if (kDebugMode) {
      logger.log('SIMULASI_SERVICE_API-SetPilihan: START with '
          'params($noRegistrasi, $prioritas, $status, $idJurusan)');
    }

    final response = await _apiHelper.requestPost(
      pathUrl: '/simulasi/pilihan/simpan',
      bodyParams: {
        'noregistrasi': noRegistrasi,
        'prioritas': prioritas,
        'status': status,
        'idJurusan': idJurusan,
      },
    );

    if (kDebugMode) {
      logger.log('SIMULASI_SERVICE_API-SetPilihan: Response >> $response');
    }

    if (response['status']) {
      gShowTopFlash(
          gNavigatorKey.currentState!.context, 'Data pilihan berhasil disimpan',
          dialogType: DialogType.success);
    } else {
      gShowBottomDialogInfo(gNavigatorKey.currentState!.context,
          title: 'Set Pilihan PTN', message: response['message']);
    }
  }
}
