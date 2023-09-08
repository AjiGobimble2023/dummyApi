import 'dart:collection';
import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';

import '../../../../core/config/global.dart';
import '../../../../core/shared/provider/disposable_provider.dart';
import '../../../../core/util/app_exceptions.dart';
import '../../../../core/util/data_formatter.dart';
import '../../entity/jadwal_siswa.dart';
import '../../model/jadwal_siswa_model.dart';
import '../../service/api/jadwal_service_api.dart';

class JadwalProvider extends DisposableProvider {
  final _apiService = JadwalServiceApi();

  bool isLoading = true;
  bool _isLoadingJadwalKBM = true;

  // ignore: prefer_final_fields
  List<InfoJadwal> _listInfoJadwalKBM = [];

  String get deviceTime => DataFormatter.formatLastUpdate();
  bool get isLoadingJadwalKBM => _isLoadingJadwalKBM;

  UnmodifiableListView<InfoJadwal> get daftarJadwalSiswa =>
      UnmodifiableListView<InfoJadwal>(_listInfoJadwalKBM);

  @override
  void disposeValues() {
    isLoading = true;
    _isLoadingJadwalKBM = true;
    _listInfoJadwalKBM.clear();

    notifyListeners();
  }

  Future<List<InfoJadwal>> loadJadwal({
    required String noRegistrasi,
    required String userType,
    bool isRefresh = false,
  }) async {
    if (!isRefresh && _listInfoJadwalKBM.isNotEmpty) {
      return daftarJadwalSiswa;
    }
    if (isRefresh) {
      _isLoadingJadwalKBM = true;
      notifyListeners();
    }
    if (kDebugMode) {
      logger.log(
          'JADWAL_PROVIDER-LoadJadwal: START with Params($noRegistrasi, $userType)');
    }
    try {
      final responseData = await _apiService.fetchJadwal(
        noRegistrasi: noRegistrasi,
        userType: userType,
        feedbackTime: deviceTime,
      );
      if (kDebugMode) {
        logger
            .log('JADWAL_PROVIDER-LoadJadwal: response data >> $responseData');
      }

      if (isRefresh) _listInfoJadwalKBM.clear();

      if (responseData != null && _listInfoJadwalKBM.isEmpty) {
        Map<String, dynamic> jsonJadwal = {};

        responseData.forEach((tanggal, listJadwal) {
          jsonJadwal['tanggal'] = tanggal;
          jsonJadwal['listJadwal'] = listJadwal ?? [];

          if (kDebugMode) {
            logger.log(
                'JADWAL_PROVIDER-LoadJadwal: response data >> $tanggal: $listJadwal || $jsonJadwal');
          }

          _listInfoJadwalKBM.add(InfoJadwalModel.fromJson(jsonJadwal));
        });

        if (kDebugMode) {
          logger.log(
              'JADWAL_PROVIDER-LoadJadwal: First Jadwal Date >> ${_listInfoJadwalKBM.first.tanggal}\n'
              'JADWAL_PROVIDER-LoadJadwal: First List Jadwal >> ${_listInfoJadwalKBM.first.daftarJadwalSiswa}');
          logger.log(
              'JADWAL_PROVIDER-LoadJadwal: Last Jadwal Date >> ${_listInfoJadwalKBM.last.tanggal}\n'
              'JADWAL_PROVIDER-LoadJadwal: Last List Jadwal >> ${_listInfoJadwalKBM.last.daftarJadwalSiswa}');
        }
      }

      if (kDebugMode) {
        logger.log(
            'JADWAL_PROVIDER-LoadJadwal: Result >> userType: $_listInfoJadwalKBM');
      }

      _isLoadingJadwalKBM = false;
      notifyListeners();
      return daftarJadwalSiswa;
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-LoadJadwal: $e');
      }
      gShowTopFlash(gNavigatorKey.currentState!.context, gPesanErrorKoneksi);

      _isLoadingJadwalKBM = false;
      notifyListeners();
      return daftarJadwalSiswa;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-LoadJadwal: $e');
      }
      if (!'$e'.contains('Tidak ada')) {
        gShowTopFlash(gNavigatorKey.currentState!.context, '$e');
      }

      _isLoadingJadwalKBM = false;
      notifyListeners();
      return daftarJadwalSiswa;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-LoadJadwal: $e');
      }
      gShowTopFlash(gNavigatorKey.currentState!.context, gPesanError);

      _isLoadingJadwalKBM = false;
      notifyListeners();
      return daftarJadwalSiswa;
    }
  }

  Future<String> setPresensiSiswa(Map<String, dynamic> dataPresensi) async {
    if (kDebugMode) {
      logger.log(
          'JADWAL_PROVIDER-SetPresensiSiswa: START with Params$dataPresensi');
    }
    try {
      return await _apiService.setPresensiSiswa(dataPresensi);
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-SetPresensiSiswa: $e');
      }
      gShowTopFlash(gNavigatorKey.currentState!.context, gPesanErrorKoneksi);
      rethrow;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-SetPresensiSiswa: $e');
      }
      gShowTopFlash(gNavigatorKey.currentState!.context, '$e');
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-SetPresensiSiswa: $e');
      }
      gShowTopFlash(gNavigatorKey.currentState!.context, gPesanError);
      throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti';
    }
  }

  Future<String> setPresensiSiswaTst(Map<String, dynamic> dataPresensi) async {
    if (kDebugMode) {
      logger.log(
          'JADWAL_PROVIDER-SetPresensiSiswaTST: START with Params$dataPresensi');
    }
    try {
      logger.log("cek provider");
      return await _apiService.setPresensiSiswaTst(dataPresensi);
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-SetPresensiSiswaTST: $e');
      }
      gShowTopFlash(gNavigatorKey.currentState!.context, gPesanErrorKoneksi);
      rethrow;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-SetPresensiSiswaTST: $e');
      }
      gShowTopFlash(gNavigatorKey.currentState!.context, '$e');
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-SetPresensiSiswaTST: $e');
      }
      gShowTopFlash(gNavigatorKey.currentState!.context, gPesanError);
      throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti';
    }
  }
}
