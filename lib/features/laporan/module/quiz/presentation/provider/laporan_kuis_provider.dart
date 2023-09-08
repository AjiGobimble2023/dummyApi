import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';

import '../../model/laporan_kuis_model.dart';
import '../../service/api/laporan_quiz_service_api.dart';

class LaporanKuisProvider extends ChangeNotifier {
  final _apiHelper = LaporanKuisServiceAPI();

  /// [_list] Variabel pribadi yang digunakan untuk menyimpan data nilai kuis yang diambil dari API.
  List<LaporanKuisModel> _list = [];

  /// [list] Variabel getter.
  List<LaporanKuisModel> get list => _list;

  /// [isLoading] Digunakan untuk menunjukkan indikator pemuatan saat data diambil.
  bool isLoading = false;

  /// [getLaporanKuis] digunakan untuk mendapatkan data laporan kuis.
  ///
  /// Args:
  ///   noRegistrasi (String): Nomor pendaftaran siswa
  ///   idSekolahKelas (String): ID kelas
  ///   tahunAjaran (String): Tahun ajaran, misalnya: 2022/2023
  ///
  /// Returns:
  ///   A map with a status and data.
  Future<Map<String, dynamic>> getLaporanKuis({
    required String noRegistrasi,
    required String idSekolahKelas,
    required String tahunAjaran,
  }) async {
    Map<String, dynamic> result;
    if (kDebugMode) {
      logger.log('LAPORAN_KUIS_PROVIDER-GetLaporanKuis: START with '
          'params($noRegistrasi, $idSekolahKelas, $tahunAjaran)');
    }
    try {
      isLoading = true;
      notifyListeners();

      /// Memanggil API untuk mendapatkan data.
      final response = await _apiHelper.fetchLaporanKuis(
        noRegistrasi: noRegistrasi,
        idSekolahKelas: idSekolahKelas,
        tahunAjaran: tahunAjaran,
      );

      if (kDebugMode) {
        logger
            .log('LAPORAN_KUIS_PROVIDER-GetLaporanKuis: response >> $response');
      }

      if (response['status']) {
        /// [body] untuk mendapatkan data dari respons.
        List<dynamic> body = response["data"];

        /// Menambahkan data dummy ke daftar.
        LaporanKuisModel a =
            LaporanKuisModel(cnamamapel: "Pilih Mata Pelajaran", info: []);

        /// Proses untuk mengonversi List dynamic menjadi list LaporanKuisModel.
        _list = body
            .map((dynamic item) => LaporanKuisModel.fromJson(item))
            .toList();

        /// Proses menambahkan data dummy ke daftar.
        _list.insert(0, a);

        result = {'status': true, 'data': _list};
      } else {
        result = {'status': false, 'data': null};
      }
      isLoading = false;
      notifyListeners();
    } on Exception catch (_) {
      result = {'status': false, 'message': "Terjadi kesalahan"};
      isLoading = false;
      notifyListeners();
    } catch (error) {
      result = {'status': false, 'message': error};
      isLoading = false;
      notifyListeners();
    }

    return result;
  }
}
