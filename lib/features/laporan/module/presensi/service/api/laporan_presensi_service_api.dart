import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';

import '../../../../../../core/helper/api_helper.dart';
import '../../../../../../core/util/app_exceptions.dart';

class LaporanPresensiServiceAPI {
  final ApiHelper _apiHelper = ApiHelper();

  /// [fetchPresensi] digunakan untuk mengambil data kehadiran siswa.
  ///
  /// Args:
  ///   userId (String): Nomor Registrasi Siswa.
  Future<dynamic> fetchPresensi({
    required String userId,
  }) async {
    final response = await _apiHelper.requestPost(
      bodyParams: {'noregistrasi': userId},
      pathUrl: '/presence/student',
    );
    if (kDebugMode) {
      logger.log("response : $response");
    }

    if (!response['status']) throw DataException(message: response['message']);

    return response['data'];
  }
}
