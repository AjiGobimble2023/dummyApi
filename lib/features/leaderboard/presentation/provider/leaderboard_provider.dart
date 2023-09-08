import 'dart:collection';
import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';
import '../../../../core/config/global.dart';

import '../../model/ranking_satu_model.dart';
import '../../model/leaderboard_rank_model.dart';
import '../../service/api/leaderboard_service_api.dart';
import '../../../../core/util/app_exceptions.dart';
import '../../../../core/shared/provider/disposable_provider.dart';

class LeaderboardProvider extends DisposableProvider {
  final _apiService = LeaderboardServiceApi();

  static const String juaraGedungKey = 'gedung';
  static const String juaraKotaKey = 'kota';
  static const String juaraNasionalKey = 'nasional';
  static const String topFiveKey = 'topFive';
  static const String terdekatKey = 'terdekat';

  // Temporary Variable
  String? _idSekolahKelas;
  String? _idKota;
  String? _idGedung;
  String? _tahunAjaran;
  String _pesan = '*Rangking dan skor diupdate setiap jam 1, 11, dan 18 WIB';
  String? _pesanError;
  bool _isLoading = true;
  bool _isLoadingFirstRank = false;

  bool get isLoading => _isLoading;
  bool get isLoadingFirstRank => _isLoadingFirstRank;
  String get pesan => _pesan;
  String? get pesanError => _pesanError;

  final HashMap<String, List<RankingSatuModel>> _listRankingSatuBukuSakti =
      HashMap();
  final HashMap<String, List<LeaderboardRankModel>> _listTopFiveBukuSakti =
      HashMap();
  final HashMap<String, List<LeaderboardRankModel>>
      _listRankingTerdekatBukuSakti = HashMap();

  UnmodifiableListView<RankingSatuModel> get listRankingSatu =>
      UnmodifiableListView(_listRankingSatuBukuSakti[
              '$_idSekolahKelas-$_idKota-$_idGedung-$_tahunAjaran'] ??
          [
            UndefinedRankingSatu(tipe: 'Nasional'),
            UndefinedRankingSatu(tipe: 'Kota'),
            UndefinedRankingSatu(tipe: 'Gedung')
          ]);

  UnmodifiableListView<LeaderboardRankModel> getListTopFiveBukuSakti(
          String tipe) =>
      UnmodifiableListView(_listTopFiveBukuSakti[(tipe == 'Gedung')
              ? juaraGedungKey
              : (tipe == 'Kota')
                  ? juaraKotaKey
                  : juaraNasionalKey] ??
          []);

  UnmodifiableListView<LeaderboardRankModel> getListRankingTerdekatBukuSakti(
          String tipe) =>
      UnmodifiableListView(_listRankingTerdekatBukuSakti[(tipe == 'Gedung')
              ? juaraGedungKey
              : (tipe == 'Kota')
                  ? juaraKotaKey
                  : juaraNasionalKey] ??
          []);

  String getKeyType(int tipe) => (tipe == 0)
      ? juaraGedungKey
      : (tipe == 1)
          ? juaraKotaKey
          : juaraNasionalKey;

  @override
  void disposeValues() {
    _listTopFiveBukuSakti.clear();
    _listRankingTerdekatBukuSakti.clear();
  }

  void _setLeaderboardRank(
      Map<String, dynamic> leaderboardRankData, String keyTipe) {
    List<dynamic> topFive = leaderboardRankData.containsKey('topfive') &&
            leaderboardRankData['topfive'] != null
        ? leaderboardRankData['topfive']
        : [];

    List<dynamic> myRank = leaderboardRankData.containsKey('myrank') &&
            leaderboardRankData['myrank'] != null
        ? leaderboardRankData['myrank']
        : [];

    if (!_listTopFiveBukuSakti.containsKey(keyTipe)) {
      _listTopFiveBukuSakti[keyTipe] = [];
    }

    if (!_listRankingTerdekatBukuSakti.containsKey(keyTipe)) {
      _listRankingTerdekatBukuSakti[keyTipe] = [];
    }

    for (var data in topFive) {
      _listTopFiveBukuSakti[keyTipe]!.add(LeaderboardRankModel.fromJson(data));
    }

    for (var data in myRank) {
      _listRankingTerdekatBukuSakti[keyTipe]!
          .add(LeaderboardRankModel.fromJson(data));
    }
  }

  Future<void> loadLeaderboardBukuSakti({
    required String noRegistrasi,
    required String idSekolahKelas,
    required String idKota,
    required String idGedung,
    required int tipeJuara,
    required String tahunAjaran,
    bool refresh = false,
  }) async {
    // Jika tidak refresh dan value tersedia di cache data, maka return cache data;
    if (!refresh &&
        _listTopFiveBukuSakti.containsKey(getKeyType(tipeJuara)) &&
        _listRankingTerdekatBukuSakti.containsKey(getKeyType(tipeJuara))) {
      if (kDebugMode) {
        logger.log('LEADERBOARD_PROVIDER-LoadLeaderboardBukuSakti: EXIST');
        logger.log(
            'LEADERBOARD_PROVIDER-LoadLeaderboardBukuSakti: TopFive Exist >> ${_listTopFiveBukuSakti[getKeyType(tipeJuara)]}');
        logger.log(
            'LEADERBOARD_PROVIDER-LoadLeaderboardBukuSakti: Terdekat Exist >> ${_listRankingTerdekatBukuSakti[getKeyType(tipeJuara)]}');
      }
      return;
    }
    if (refresh) {
      _listTopFiveBukuSakti[getKeyType(tipeJuara)]?.clear();
      _listRankingTerdekatBukuSakti[getKeyType(tipeJuara)]?.clear();
    }
    try {
      _isLoading = true;
      final response = await _apiService.fetchLeaderboardBukuSakti(
          noRegistrasi: noRegistrasi,
          idSekolahKelas: idSekolahKelas,
          idKota: idKota,
          idGedung: idGedung,
          tipeJuara: tipeJuara,
          tahunAjaran: tahunAjaran);

      if (response == null) {
        _isLoading = false;
        _pesanError = 'Data leaderboard kamu tidak ditemukan';
        notifyListeners();
        throw DataException(message: 'Data leaderboard kamu tidak ditemukan');
      }
      _pesanError = null;

      // Konversi int tipe menjadi String Key
      var rankKey = (tipeJuara == 0)
          ? 'gedung'
          : (tipeJuara == 1)
              ? 'city'
              : 'national';

      // Data Ranking topFive dan terdekat dari API.
      final Map<String, dynamic>? dataRanking =
          response['data'].containsKey(rankKey)
              ? response['data'][rankKey]
              : null;

      if (kDebugMode) {
        logger.log(
            'LEADERBOARD_PROVIDER-LoadLeaderboardBukuSakti: Key Tipe >> $rankKey');
        logger.log(
            'LEADERBOARD_PROVIDER-LoadLeaderboardBukuSakti: Data Ranking >> $dataRanking');
      }

      _pesan = response['data']['pesan'];
      _pesanError = response['status'] ? null : response['message'];

      if (dataRanking != null) {
        _setLeaderboardRank(dataRanking, getKeyType(tipeJuara));
      }

      _isLoading = false;
      notifyListeners();
    } on NoConnectionException {
      _isLoading = false;
      notifyListeners();
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('EXCEPTION_LoadLeaderboard: $e');
      }
      _isLoading = false;
      _pesanError = 'Data tidak ditemukan';
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        logger.log('FATAL_EXCEPTION_LoadLeaderboard: $e');
      }
      _isLoading = false;
      _pesanError =
          'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti';
      notifyListeners();
      // throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti';
    }
  }

  Future<void> getFirstRankBukuSakti({
    required String idSekolahKelas,
    required String idKota,
    required String idGedung,
    required String tahunAjaran,
  }) async {
    _idSekolahKelas = idSekolahKelas;
    _idKota = idKota;
    _idGedung = idGedung;
    _tahunAjaran = tahunAjaran;
    if (_listRankingSatuBukuSakti.isNotEmpty &&
        (_listRankingSatuBukuSakti[
                    '$idSekolahKelas-$idKota-$idGedung-$tahunAjaran']
                ?.isNotEmpty ??
            false)) {
      await Future.delayed(gDelayedNavigation);
      notifyListeners();
      return;
    }
    if (_isLoadingFirstRank) return;
    try {
      _isLoadingFirstRank = true;
      if (kDebugMode) {
        logger.log(
            "LEADERBOARD_PROVIDER-GetFirstRank: params(s: $_idSekolahKelas, k: $_idKota, g: $_idGedung, $_tahunAjaran)");
      }
      final responseData = await _apiService.fetchFirstRankBukuSakti(
        idSekolahKelas: idSekolahKelas,
        idKota: idKota,
        idGedung: idGedung,
        tahunAjaran: tahunAjaran,
      );
      if (kDebugMode) {
        logger.log(
            "LEADERBOARD_PROVIDER-GetFirstRank: response >> $responseData");
      }
      List<dynamic> body = responseData;
      List<RankingSatuModel> list =
          body.map((dynamic item) => RankingSatuModel.fromJson(item)).toList();
      // Reverse list juara.
      list = list.reversed.toList();
      // Menambahkan Empty Juara kalau data tidak tersedia.
      if (!list.any((juara) => juara.tipe == "Nasional")) {
        list.insert(0, UndefinedRankingSatu(tipe: 'Nasional'));
      }
      if (!list.any((juara) => juara.tipe == "Kota")) {
        list.insert(1, UndefinedRankingSatu(tipe: 'Kota'));
      }
      if (!list.any((juara) => juara.tipe == "Gedung")) {
        list.insert(2, UndefinedRankingSatu(tipe: 'Gedung'));
      }

      _listRankingSatuBukuSakti[
          '$idSekolahKelas-$idKota-$idGedung-$tahunAjaran'] = list;

      _isLoadingFirstRank = false;
      notifyListeners();
    } on NoConnectionException catch (e) {
      if (kDebugMode) logger.log('NoConnectionException-GetFirstRank: $e');
      _isLoadingFirstRank = false;
      notifyListeners();
    } on DataException catch (e) {
      if (kDebugMode) logger.log('Exception-GetFirstRank: $e');
      _listRankingSatuBukuSakti[
          '$idSekolahKelas-$idKota-$idGedung-$tahunAjaran'] = [
        UndefinedRankingSatu(tipe: 'Nasional'),
        UndefinedRankingSatu(tipe: 'Kota'),
        UndefinedRankingSatu(tipe: 'Gedung')
      ];
      _isLoadingFirstRank = false;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-GetFirstRank: ${e.toString()}');
      }
      _isLoadingFirstRank = false;
      notifyListeners();
    }
  }
}
