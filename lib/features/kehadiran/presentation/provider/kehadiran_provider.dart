import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';

import '../../../../core/config/global.dart';
import '../../entity/kehadiran_minggu_ini.dart';
import '../../service/kehadiran_service_api.dart';
import '../../model/kehadiran_minggu_ini_model.dart';
import '../../../../core/util/app_exceptions.dart';
import '../../../../core/shared/provider/disposable_provider.dart';

class KehadiranProvider extends DisposableProvider {
  final _apiService = KehadiranServiceApi();

  bool _isLoadingKehadiran = true;

  KehadiranMingguIni _infoKehadiranMingguIni =
      const KehadiranMingguIni(jumlahHadir: -1, jumlahPertemuan: -1);

  bool get isLoadingKehadiran => _isLoadingKehadiran;
  KehadiranMingguIni get infoKehadiranMingguIni => _infoKehadiranMingguIni;

  @override
  void disposeValues() {
    _infoKehadiranMingguIni =
        const KehadiranMingguIni(jumlahHadir: -1, jumlahPertemuan: -1);
  }

  Future<KehadiranMingguIni> getKehadiranMingguIni({
    required String noRegistrasi,
    bool isRefresh = false,
  }) async {
    if (!isRefresh && _infoKehadiranMingguIni.jumlahPertemuan > -1) {
      return infoKehadiranMingguIni;
    }
    if (isRefresh) {
      _isLoadingKehadiran = true;
      notifyListeners();
      await Future.delayed(gDelayedNavigation);
    }
    try {
      final responseData = await _apiService.fetchKehadiranMingguIni(
        noRegistrasi: noRegistrasi,
      );

      // if (kDebugMode) {
      //   logger.log('KEHADIRAN_PROVIDER-GetKehadiranMingguIni: Data >> $responseData');
      // }

      if (responseData != null) {
        _infoKehadiranMingguIni =
            KehadiranMingguIniModel.fromJson(responseData);
      }
      // if (kDebugMode) {
      //   logger.log('KEHADIRAN_PROVIDER-GetKehadiranMingguIni: Info Kehadiran >> $_infoKehadiranMingguIni');
      // }

      _isLoadingKehadiran = false;
      notifyListeners();
      return infoKehadiranMingguIni;
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-GetKehadiranMingguIni: $e');
      }
      // rethrow;
      _isLoadingKehadiran = false;
      notifyListeners();
      return infoKehadiranMingguIni;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('DataException-GetKehadiranMingguIni: $e');
      }
      // rethrow;
      _isLoadingKehadiran = false;
      notifyListeners();
      return infoKehadiranMingguIni;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-GetKehadiranMingguIni: $e');
      }
      // throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti';
      _isLoadingKehadiran = false;
      notifyListeners();
      return infoKehadiranMingguIni;
    }
  }
}
