import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';

import '../../../../../core/config/global.dart';
import '../../../../../core/util/app_exceptions.dart';
import '../entity/laporan_vak.dart';
import '../model/laporan_vak_model.dart';
import '../service/api/laporan_service_api.dart';

class LaporanVakProvider with ChangeNotifier {
  final _apiService = LaporanServiceAPI();

  bool _isLoadingLaporanVAK = true;
  final Map<String, LaporanVAK> _laporanVAK = {};
  final Map<String, bool> _laporanVAKExist = {};

  bool get isLoadingLaporanVAK => _isLoadingLaporanVAK;

  bool isLaporanVAKExist(String noRegistrasi) =>
      _laporanVAKExist[noRegistrasi] ?? false;
  LaporanVAK? getLaporanVAKByNoReg(String noRegistrasi) =>
      _laporanVAK[noRegistrasi];

  Future<LaporanVAK?> loadLaporanVak({
    required String noRegistrasi,
    required String userType,
    bool isRefresh = false,
  }) async {
    if (kDebugMode) {
      logger.log(
          'LAPORAN_VAK_PROVIDER-loadLaporanVak: START with params($noRegistrasi, $userType)');
    }
    if (_laporanVAKExist.containsKey(noRegistrasi)) {
      return getLaporanVAKByNoReg(noRegistrasi);
    }
    if (isRefresh) {
      _isLoadingLaporanVAK = true;
      notifyListeners();
    }
    try {
      final responseData = await _apiService.fetchLaporanVak(
        noRegistrasi: noRegistrasi,
        userType: userType,
      );

      if (kDebugMode) {
        logger.log(
            'LAPORAN_VAK_PROVIDER-loadLaporanVak: response data >> $responseData');
      }

      if (responseData != null) {
        _laporanVAK.update(
            noRegistrasi, (laporan) => LaporanVAKModel.fromJson(responseData),
            ifAbsent: () => LaporanVAKModel.fromJson(responseData));
      }

      _isLoadingLaporanVAK = false;
      notifyListeners();
      return getLaporanVAKByNoReg(noRegistrasi);
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-loadLaporanVak: $e');
      }
      gShowTopFlash(gNavigatorKey.currentState!.context, gPesanErrorKoneksi);

      _isLoadingLaporanVAK = false;
      notifyListeners();
      return getLaporanVAKByNoReg(noRegistrasi);
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-loadLaporanVak: $e');
      }
      gShowTopFlash(gNavigatorKey.currentState!.context, '$e');

      _isLoadingLaporanVAK = false;
      notifyListeners();
      return getLaporanVAKByNoReg(noRegistrasi);
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-loadLaporanVak: $e');
      }
      gShowTopFlash(gNavigatorKey.currentState!.context, gPesanError);

      _isLoadingLaporanVAK = false;
      notifyListeners();
      return getLaporanVAKByNoReg(noRegistrasi);
    }
  }
}
