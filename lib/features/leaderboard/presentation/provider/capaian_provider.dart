import 'dart:collection';
import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';

import '../../model/capaian_score.dart';
import '../../model/pengerjaan_soal.dart';
import '../../model/capaian_detail_score.dart';
import '../../service/api/leaderboard_service_api.dart';
import '../../../../core/config/global.dart';
import '../../../../core/util/app_exceptions.dart';
import '../../../../core/shared/provider/disposable_provider.dart';

enum FilterNilai { harian, mingguan, bulanan }

class CapaianProvider extends DisposableProvider {
  final _apiService = LeaderboardServiceApi();

  CapaianScore? _capaianScoreKamu;
  final List<CapaianDetailScore> _capaianNilaiDetail = [];
  List<PengerjaanSoal> _listPengerjaanSoal = [];

  // Local variable
  bool _isPengerjaanSoalLoading = true;
  bool _isCapaianScoreLoading = true;
  String? _errorGrafikNilai;
  FilterNilai _filterNilai = FilterNilai.harian;

  // Getter Setter
  bool get isPengerjaanSoalLoading => _isPengerjaanSoalLoading;
  bool get isCapaianScoreLoading => _isCapaianScoreLoading;
  String? get errorGrafikNilai => _errorGrafikNilai;
  CapaianScore? get capaianScoreKamu => _capaianScoreKamu;

  FilterNilai get filterNilai => _filterNilai;
  set filterNilai(FilterNilai selectedFilter) {
    _filterNilai = selectedFilter;
    notifyListeners();
  }

  // Get list detail capaian score
  UnmodifiableListView<CapaianDetailScore> get capaianNilaiDetail =>
      UnmodifiableListView(_capaianNilaiDetail);
  // Get list pengerjaan soal
  UnmodifiableListView<PengerjaanSoal> get hasilPengerjaanSoal =>
      UnmodifiableListView(_listPengerjaanSoal);

  @override
  void disposeValues() {
    _capaianScoreKamu = null;
    _capaianNilaiDetail.clear();
    _listPengerjaanSoal.clear();
  }

  Future<CapaianScore?> getCapaianScoreKamu({
    required String noRegistrasi,
    required String idSekolahKelas,
    required String tahunAjaran,
    required String userType,
    required String idKota,
    required String idGedung,
    bool refresh = false,
  }) async {
    if (refresh) {
      _isCapaianScoreLoading = true;
      _capaianNilaiDetail.clear();
      await Future.delayed(gDelayedNavigation);
      notifyListeners();
    }
    // Jika sudah get data, maka gunakan data tersebut agar
    // tidak terjadi perulangan request yang tidak perlu.
    if (_capaianScoreKamu != null && _capaianNilaiDetail.isNotEmpty) {
      return _capaianScoreKamu;
    }
    try {
      final responseData = await _apiService.fetchCapaianScoreKamu(
        noRegistrasi: noRegistrasi,
        tahunAjaran: tahunAjaran,
        idSekolahKelas: idSekolahKelas,
        userType: userType,
        idKota: idKota,
        idGedung: idGedung,
      );

      if (kDebugMode) {
        logger.log(
            'CAPAIAN_PROVIDER-GetCapaianScoreKamu: response >> $responseData');
      }

      if (responseData == null) {
        // throw DataException(message: 'Capaian skor kamu tidak ditemukan');
        _isCapaianScoreLoading = false;
        await Future.delayed(gDelayedNavigation);
        notifyListeners();
        return _capaianScoreKamu;
      }

      _capaianScoreKamu = CapaianScore.fromJson(responseData);

      // Detail ini untuk menampilkan detail nilai capaian siswa
      final Map<String, dynamic>? detail =
          responseData.containsKey('detail') ? responseData['detail'] : null;

      // total merupakan totalScore siswa
      final int total = responseData.containsKey('totalScore')
          ? responseData['totalScore']
          : 0;

      if (detail != null && _capaianNilaiDetail.isEmpty) {
        int totalBenar = 0;
        int totalSalah = 0;

        for (int i = 1; i <= 5; i++) {
          totalBenar += detail['benarlevel$i'] as int;
          totalSalah += detail['salahlevel$i'] as int;

          _capaianNilaiDetail.add(
            CapaianDetailScore(
              label: 'Bintang $i',
              benar: detail['benarlevel$i'],
              salah: detail['salahlevel$i'],
              score: detail['benarlevel$i'] * i,
            ),
          );
        }

        _capaianNilaiDetail.add(
          CapaianDetailScore(
            label: 'Total',
            benar: totalBenar,
            salah: totalSalah,
            score: total,
          ),
        );
      }

      if (kDebugMode) {
        logger.log('CAPAIAN_PROVIDER-GetCapaianScoreKamu: Card >> $_capaianScoreKamu');
        logger.log('CAPAIAN_PROVIDER-GetCapaianScoreKamu: Detail >> $_capaianNilaiDetail');
      }

      _isCapaianScoreLoading = false;
      notifyListeners();
      return _capaianScoreKamu;
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-GetCapaianScoreKamu: $e');
      }
      _isCapaianScoreLoading = false;
      notifyListeners();
      rethrow;
    } on DataException catch (e) {
      if (kDebugMode) logger.log('Exception-GetCapaianScoreKamu: $e');
      _isCapaianScoreLoading = false;
      notifyListeners();
      return _capaianScoreKamu;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-GetCapaianScoreKamu: ${e.toString()}');
      }
      _isCapaianScoreLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<List<PengerjaanSoal>> getHasilPengerjaanSoal({
    required String noRegistrasi,
    required String idSekolahKelas,
    required tahunAjaran,
    bool isTamu = true,
    bool refresh = false,
  }) async {
    _errorGrafikNilai = null;
    // Jika sudah get data, maka gunakan data tersebut agar
    // tidak terjadi perulangan request yang tidak perlu.
    if ((!refresh && _listPengerjaanSoal.isNotEmpty) || isTamu) {
      return hasilPengerjaanSoal;
    }
    if (refresh) {
      _isPengerjaanSoalLoading = true;
      await Future.delayed(gDelayedNavigation);
      notifyListeners();
    }
    try {
      final responseData = await _apiService.fetchHasilPengerjaanSoal(
          noRegistrasi: noRegistrasi,
          idSekolahKelas: idSekolahKelas,
          tahunAjaran: tahunAjaran);

      if (kDebugMode) {
        logger.log(
            'CAPAIAN_PROVIDER-GetHasilPengerjaanSoal: response >> $responseData');
      }

      if (responseData != null) {
        if (refresh) {
          _listPengerjaanSoal.clear();
        }

        List<PengerjaanSoal> listPengerjaanSoal = [];
        for (Map<String, dynamic> hasilPengerjaan in responseData) {
          listPengerjaanSoal.add(PengerjaanSoal.fromJson(hasilPengerjaan));
        }
        _listPengerjaanSoal = listPengerjaanSoal;
      }

      if (kDebugMode) {
        logger.log(
            'CAPAIAN_PROVIDER-GetHasilPengerjaanSoal: List Pengerjaan >> ${_listPengerjaanSoal.length} | $_listPengerjaanSoal');
      }
      _isPengerjaanSoalLoading = false;
      notifyListeners();
      return hasilPengerjaanSoal;
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-GetHasilPengerjaanSoal: $e');
      }
      _errorGrafikNilai = gPesanErrorKoneksi;
      _isPengerjaanSoalLoading = false;
      notifyListeners();
      return hasilPengerjaanSoal;
    } on DataException catch (e) {
      if (kDebugMode) logger.log('Exception-GetHasilPengerjaanSoal: $e');

      // _errorGrafikNilai = '$e';
      _isPengerjaanSoalLoading = false;
      notifyListeners();
      return hasilPengerjaanSoal;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-GetHasilPengerjaanSoal: ${e.toString()}');
      }

      _errorGrafikNilai = gPesanError;
      _isPengerjaanSoalLoading = false;
      notifyListeners();
      return hasilPengerjaanSoal;
    }
  }
}
