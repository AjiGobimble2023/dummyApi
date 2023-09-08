import 'dart:developer' as logger show log;
import 'package:flutter/foundation.dart';

import '../../model/laporan_presensi.dart';
import '../../service/api/laporan_presensi_service_api.dart';
import '../../../../../../core/util/app_exceptions.dart';

class LaporanPresensiProvider {
  final _apiService = LaporanPresensiServiceAPI();

  /// [loadPresensi] digunakan untuk memuat data kehadiran dari server.
  ///
  /// Args:
  ///   userId (String): No Registrasi Siswa.
  ///
  /// Returns:
  ///   List<LaporanPresensiDate>
  Future<List<LaporanPresensiDate>> loadPresensi({
    String? userId,
  }) async {
    try {
      final responseData = await _apiService.fetchPresensi(userId: userId!);

      List<LaporanPresensiDate> listJadwalPresence = [];

      if (responseData != null) {
        for (int i = 0; i < responseData.length; i++) {
          listJadwalPresence.add(LaporanPresensiDate.fromJson(responseData[i]));
        }
      }

      return listJadwalPresence;
    } on NoConnectionException {
      rethrow;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-LoadPresensi: $e');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-LoadPresensi: $e');
      }
      throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti.';
    }
  }
}
