import 'dart:developer' as logger show log;
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../model/laporan_list_tryout_model.dart';
import '../../model/laporan_tryout_nilai_model.dart';
import '../../model/laporan_tryout_pilihan_model.dart';
import '../../model/laporan_tryout_tob_model.dart';
import '../../service/api/laporan_tryout_service_api.dart';
import '../../../../../ptn/module/ptnclopedia/entity/kampus_impian.dart';
import '../../../../../../core/config/global.dart';
import '../../../../../../core/helper/hive_helper.dart';
import '../../../../../../core/util/app_exceptions.dart';

class LaporanTryoutProvider extends ChangeNotifier {
  final _apiService = LaporanTryoutServiceAPI();

  final List<LaporanTryoutPilihanModel> _listPilihan = [];
  final List<LaporanTryoutNilaiModel> _listNilai = [];
  List<LaporanListTryoutModel> _listTryOut = [];
  List<LaporanTryoutTobModel> _listLaporanTryout = [];

  bool _isLoading = false;
  bool _isLoadingChart = false;

  bool get isLoading => _isLoading;
  bool get isLoadingChart => _isLoadingChart;
  List<LaporanTryoutTobModel> get listLaporanTryout => _listLaporanTryout;
  List<LaporanListTryoutModel> get listTryout => _listTryOut;

  /// [loadLaporanTryout] digunakan untuk memuat data laporan TO.
  ///
  /// Args:
  ///   userId (String): nomor registrasi,
  ///   userClassLevelId (String): idSekolahKeas
  ///   userJenis (String): 'SISWA' / 'TAMU'
  ///   jenisTO (String): Jenis TO, bisa "UTBK" atau "Ujian Sekolah"
  ///   pilihan1 (int): idPilihan1 ?? 0,
  ///   pilihan2 (int): idPilihan2 ?? 0,
  ///
  /// Returns:
  ///   List<LaporanTryoutTobModel>
  Future<List<LaporanTryoutTobModel>> loadLaporanTryout({
    required String noRegistrasi,
    required String idSekolahKelas,
    required String tingkatKelas,
    required String userType,
    required String jenisTO,
    int? idJurusanPilihan1,
    int? idJurusanPilihan2,
  }) async {
    try {
      if (tingkatKelas == "13" || tingkatKelas == "12" || jenisTO == "UTBK") {
        if (idJurusanPilihan1 == null) {
          throw DataException(
            message: 'Isi dulu target kampus impian kamu yuk Sobat!',
          );
        }
        if (idJurusanPilihan2 == null) {
          throw DataException(
            message:
                'Kampus impian pilihan kedua kamu masih kosong nih, isi dulu yaa!',
          );
        }
      }
      _listLaporanTryout.clear();
      _isLoadingChart = true;
      await Future.delayed(gDelayedNavigation);
      notifyListeners();
      await Future.delayed(gDelayedNavigation);
      if (kDebugMode) {
        logger.log(
          'LAPORAN_TRYOUT_PROVIDER-LoadLaporanTryout: START with >>\n'
          '($noRegistrasi, $idSekolahKelas, $userType, $jenisTO, '
          '$idJurusanPilihan1 $idJurusanPilihan2)',
        );
      }

      final responseData = await _apiService.fetchLaporanTryout(
        noRegistrasi: noRegistrasi,
        idSekolahKelas: idSekolahKelas,
        userType: userType,
        jenisTO: jenisTO,
        idJurusanPilihan1: idJurusanPilihan1 ?? 0,
        idJurusanPilihan2: idJurusanPilihan2 ?? 0,
      );

      List<LaporanTryoutTobModel> listTryoutLaporan = [];
      if (kDebugMode) {
        logger.log('LAPORAN_TRYOUT_PROVIDER-LoadLaporanTryout: responseData >> '
            '$responseData');
      }

      if (responseData != null) {
        for (int i = 0; i < responseData.length; i++) {
          listTryoutLaporan
              .add(LaporanTryoutTobModel.fromJson(responseData[i]));
        }
      }
      if (kDebugMode) {
        logger.log('LAPORAN_TRYOUT_PROVIDER-LoadLaporanTryout: Final Result >> '
            'listTryoutLaporan $listTryoutLaporan');
      }
      _listLaporanTryout = listTryoutLaporan;
      _isLoadingChart = false;
      notifyListeners();
      return listTryoutLaporan;
    } on NoConnectionException {
      gShowTopFlash(gNavigatorKey.currentContext!, gPesanErrorKoneksi);
      rethrow;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-LoadLaporanTryout: $e');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-LoadLaporanTryout: $e');
      }
      // gShowTopFlash(gNavigatorKey.currentContext!, gPesanError);
      throw gPesanError;
    }
  }

  /// [loadLaporanListTryout] digunakan untuk memuat List laporan TO.
  ///
  /// Args:
  ///   userId (String): nomor registrasu
  ///   userClassLevelId (String): idSekolah Kelas
  ///   userJenis (String): 'SISWA' atau 'TAMU'
  ///   jenisTO (String): Jenis TO, bisa "UTBK" atau "Ujian Sekolah"
  ///
  /// Returns:
  ///   List<LaporanListTryoutModel>
  Future<List<LaporanListTryoutModel>> loadLaporanListTryout({
    required String userId,
    required String userClassLevelId,
    required String userJenis,
    required String jenisTO,
  }) async {
    try {
      if (kDebugMode) {
        logger.log("$userId $userClassLevelId $jenisTO $userJenis");
      }
      _isLoading = true;
      _listTryOut.clear();
      notifyListeners();

      final responseData = await _apiService.fetchLaporanListTryout(
        userId: userId,
        userClassLevelId: userClassLevelId,
        jenis: userJenis,
        jenisTO: jenisTO,
      );

      List<LaporanListTryoutModel> tryoutList = [];
      if (kDebugMode) {
        logger.log(
            'LAPORAN TRYOUT PROVIDER: failed getting data responseData $responseData');
      }

      if (responseData != null) {
        if (kDebugMode) {
          logger.log('LAPORAN TRYOUT PROVIDER: get response data succeed');
        }
        for (int i = 0; i < responseData.length; i++) {
          tryoutList.add(LaporanListTryoutModel.fromJson(responseData[i]));
        }
      }
      if (kDebugMode) {
        logger.log("loadLaporanListTryout $tryoutList");
      }
      _listTryOut = tryoutList;
      _isLoading = false;
      notifyListeners();
      return tryoutList;
    } on NoConnectionException {
      rethrow;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-LoadLaporanListTryout: $e');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-LoadLaporanListTryout: $e');
      }
      throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti.';
    }
  }

  /// [loadLaporanNilai] digunakan untuk memuat data laporan detail nilai dari server.
  ///
  /// Args:
  ///   userId (String): nomor registrasi,
  ///   userClassLevelId (String): idSekolahKelas.
  ///   userType (String): 'SISWA' atau 'TAMU'
  ///   kodeTOB (String): Kode TOB yang ingin Anda lihat laporannya.
  ///   penilaian (String): Jenis penilaiannya, yang sepeti (irt, stan, 4b-s, b-s, b saja, atau akm).
  ///   pilihan1 (String): Pilihan 1 Kampus Impian,
  ///   pilihan2 (String): Pilihan 2 Kampus Impian,
  ///   jenisTO (String): Jenis TO, yang bisa berupa 'utbk' atau 'Ujian Sekolah'.
  Future<Map<String, dynamic>> loadLaporanNilai({
    String? userId,
    String? userClassLevelId,
    String? userType,
    String? kodeTOB,
    String? penilaian,
    String? pilihan1,
    String? pilihan2,
    String? jenisTO,
  }) async {
    double totalNilai = 0;

    try {
      List<String> formatPenilaian = [
        'IRT',
        'STAN',
        '4B-S',
        'B-S',
        'B Saja',
        'AKM'
      ];

      if (penilaian == null || !formatPenilaian.contains(penilaian)) {
        throw DataException(message: 'Silahkan pilih terlebih dahulu Tryout');
      }

      if (!HiveHelper.isBoxOpen<KampusImpian>(
          boxName: HiveHelper.kKampusImpianBox)) {
        await HiveHelper.openBox<KampusImpian>(
            boxName: HiveHelper.kKampusImpianBox);
      }

      int idPilihan1 = HiveHelper.getKampusImpian(pilihanKe: 1)?.idJurusan ?? 0;
      int idPilihan2 = HiveHelper.getKampusImpian(pilihanKe: 2)?.idJurusan ?? 0;

      if (penilaian == "IRT") {
        if (idPilihan1 == 0) {
          throw DataException(
              message:
                  'Untuk melihat laporan UTBK, Sobat perlu mengisi pilihan 1 '
                  '& pilihan 2 dari kampus impian Sobat. Isi dulu yuk kampus impian kamu!');
        } else if (idPilihan2 == 0) {
          throw DataException(
              message:
                  'Untuk melihat laporan UTBK, Sobat perlu mengisi pilihan 2 '
                  'dari kampus impian Sobat. Isi dulu yuk kampus impian kamu!');
        }
      }

      final responseData = await _apiService.fetchLaporanNilai(
        userId: userId!,
        userClassLevelId: userClassLevelId!,
        userType: userType!,
        kodeTOB: kodeTOB!,
        penilaian: penilaian,
        pilihan1: '$idPilihan1',
        pilihan2: '$idPilihan2',
      );

      if (_listPilihan.isNotEmpty) _listPilihan.clear();
      if (_listNilai.isNotEmpty) _listNilai.clear();

      if (responseData != null) {
        if (responseData.containsKey('pilihan')) {
          final pilihan = responseData['pilihan'];

          for (int i = 0; i < pilihan.length; i++) {
            _listPilihan.add(LaporanTryoutPilihanModel.fromJson(pilihan[i]));
          }
        }

        if (responseData.containsKey('nilai')) {
          final nilai = responseData['nilai'];

          for (int i = 0; i < nilai.length; i++) {
            totalNilai += nilai[i]['nilai'].toDouble();
            _listNilai.add(LaporanTryoutNilaiModel.fromJson(nilai[i]));
          }
        }
      }

      if (_listNilai.isEmpty) {
        throw DataException(
            message: 'Laporan Tryout masih belum tersedia saat ini Sobat');
      }

      switch (penilaian) {
        case 'IRT':
        case 'STAN':
        case '4B-S':
          return {'pilihan': _listPilihan, 'nilai': _listNilai};
        case 'B-S':
        case 'B Saja':
          return {'nilai': _listNilai, 'total': totalNilai.toStringAsFixed(2)};
        case 'AKM':
          return {'nilai': _listNilai};
        default:
          throw DataException(message: 'Silahkan pilih terlebih dahulu Tryout');
      }
    } on NoConnectionException {
      rethrow;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-LoadLaporanNilai: $e');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-LoadLaporanNilai: $e');
      }
      throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti.';
    }
  }

  /// [fetchEpbToken] Ini untuk mengambil token bagi pengguna untuk mengakses EPB.
  Future<String> fetchEpbToken() async {
    try {
      final responseData = await _apiService.fetchEpbToken();
      Codec<String, String> stringToBase64 = utf8.fuse(base64);
      String encoded = stringToBase64.encode(responseData.toString());
      encoded = stringToBase64.encode(encoded);
      encoded = stringToBase64.encode(encoded);

      return encoded;
    } on NoConnectionException {
      rethrow;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-FetchTokenLaporanTryoutEpb: $e');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-FetchTokenLaporanTryoutEpb: $e');
      }
      throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti.';
    }
  }

  /// [uploadFeed] untuk mengupload feed Nilai TO dan feed ranking.
  ///
  /// Args:
  ///   userId (String): nomor registrasi.
  ///   content (String): Isi dari feed (berupa text).
  ///   file64 (String): url gambar dari feed tersebut.
  Future<void> uploadFeed(
      {String? userId, String? content, String? file64}) async {
    try {
      await _apiService.uploadFeed(
          userId: userId, content: content, file64: file64);
    } on NoConnectionException {
      rethrow;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-Data-UploadFeed: $e');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-Data-UploadFeed: $e');
      }
      return;
    }
  }
}
