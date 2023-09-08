import 'dart:developer' as logger show log;
import 'package:flutter/foundation.dart';
import '../../model/laporan_aktivitas_model.dart';
import '../../service/api/laporan_aktivitas_service_api.dart';
import '../../../../../../core/util/app_exceptions.dart';

class LaporanAktivitasProvider {
  final _apiService = LaporanAktifitasServiceAPI();

  /// [loadLogAktivitas] fungsi yang digunakan untuk memuat data log aktivitas.
  ///
  /// Args:
  ///   userId (String): Nomor registrasi siswa
  ///   type (String): Jenis Log Aktivitas (Hari Ini / Minggu Ini)
  ///
  /// Returns:
  ///   List<LaporanAktivitasModel>
  Future<List<LaporanAktivitasModel>> loadLogAktivitas({
    /// [userId] merupakan variable yang berisi no Registrasi Siswa
    String? userId,

    /// [type] merupakan variable yang berisi tipe log aktivitas (Hari ini / Minggu ini)
    String? type,
  }) async {
    try {
      final responseData = await _apiService.fetchAktifitas(
        type: type!,
        userId: userId!,
      );

      List<LaporanAktivitasModel> listAktivitas = [];

      for (int i = 0; i < responseData.length; i++) {
        listAktivitas.add(LaporanAktivitasModel.fromJson(responseData[i]));
      }

      return listAktivitas;
    } on NoConnectionException {
      rethrow;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-LoadLogAktivitas: $e');
      }
      rethrow;
    } catch (e) {
      logger.log('FatalException-LoadLogAktivitas: $e');
      throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti.';
    }
  }
}
