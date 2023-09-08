import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';

import '../../entity/solusi.dart';
import '../../model/solusi_model.dart';
import '../../model/detail_hasil_model.dart';
import '../../service/api/soal_service_api.dart';
import '../../../../core/util/app_exceptions.dart';

class SolusiProvider with ChangeNotifier {
  final SoalServiceAPI _apiService = SoalServiceAPI();

  final Map<String, Solusi> _listSolusi = {};
  // Map<String, VideoSolusi> _listVideo = {};

  // Solusi? getSolusiFromCache({required idVideo}) => _listSolusi[idSoal];

  /// [listDetailHasil] untuk menyimpan data benar, salah dan kosong
  List<DetailHasilModel> listDetailHasil = [];
  bool isloading = false;

  Future<Solusi?> getSolusi(
      {required String idSoal, bool isRefresh = false}) async {
    if (!isRefresh && _listSolusi.containsKey(idSoal)) {
      return _listSolusi[idSoal];
    }
    if (isRefresh) {
      _listSolusi.remove(idSoal);
    }
    try {
      Solusi? solusi;

      final responseData = await _apiService.fetchSolusi(idSoal: idSoal);

      if (responseData != null) {
        solusi = SolusiModel.fromJson(responseData);

        if (kDebugMode) {
          logger.log('SOLUSI_PROVIDER-GetSolusi: Solusi Model >> $solusi');
        }

        _listSolusi[idSoal] = solusi;

        if (kDebugMode) {
          logger.log('SOLUSI_PROVIDER-GetSolusi: Solusi Cache >> ${_listSolusi[idSoal]}');
        }
      }

      notifyListeners();
      return solusi;
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-GetSolusi: $e');
      }
      return null;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-GetSolusi: $e');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-GetSolusi: ${e.toString()}');
      }
      return null;
    }
  }

  // Future<VideoSolusi?> getVideoSolusi(
  //     {required String idVideo, bool isRefresh = false}) async {
  //   if (!isRefresh && _listVideo.containsKey(idVideo)) {
  //     return _listVideo[idVideo];
  //   }
  //   if (isRefresh) {
  //     _listVideo.remove(idVideo);
  //   }
  //   try {
  //     VideoSolusi? videoSolusi;
  //
  //     final responseData = await _apiService.fetchVideoSolusi(idVideo: idVideo);
  //
  //     if (responseData != null) {
  //       videoSolusi = VideoSolusiModel.fromJson(responseData);
  //
  //       _listVideo[idVideo] = videoSolusi;
  //     }
  //
  //     notifyListeners();
  //     return videoSolusi;
  //   } on NoConnectionException catch (e) {
  //     if (kDebugMode) {
  //       logger.log('NoConnectionException-GetVideoSolusi: $e');
  //     }
  //     return null;
  //   } on DataException catch (e) {
  //     if (kDebugMode) {
  //       logger.log('Exception-GetVideoSolusi: $e');
  //     }
  //     return null;
  //   } catch (e) {
  //     if (kDebugMode) {
  //       logger.log('FatalException-GetVideoSolusi: ${e.toString()}');
  //     }
  //     return null;
  //   }
  // }

  Future<void> getDetailHasil({
    required String noRegistrasi,
    required String idSekolahKelas,
    required String jenisHasil,
    required String kodePaket,
    required int jumlahSoal,
  }) async {
    isloading = true;
    listDetailHasil.clear();
    notifyListeners();
    try {
      final responseData = await SoalServiceAPI().fetchDetailHasilJawaban(
        noRegistrasi: noRegistrasi,
        idSekolahKelas: idSekolahKelas,
        kodePaket: kodePaket,
        jumlahSoal: jumlahSoal,
        jenisHasil: jenisHasil,
      );

      if (kDebugMode) {
        logger.log(
            'SOAL_PROVIDER-GetDetailHasil: response data >> $responseData');
      }

      if (responseData.isNotEmpty) {
        for (var i = 0; i < responseData.length; i++) {
          listDetailHasil.add(DetailHasilModel.fromJson(responseData[i]));
        }
      }
      if (kDebugMode) {
        logger.log("listDetailHasil : $listDetailHasil");
      }
      isloading = false;
      notifyListeners();
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-GetDetailHasil: $e');
      }
      isloading = false;
      notifyListeners();
      return;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-GetDetailHasil: $e');
      }
      isloading = false;
      notifyListeners();
      return;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-GetDetailHasil: ${e.toString()}');
      }
      isloading = false;
      notifyListeners();
      return;
    }
  }
}
