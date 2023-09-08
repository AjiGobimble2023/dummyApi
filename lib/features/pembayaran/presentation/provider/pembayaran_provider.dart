import 'dart:collection';
import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';
import '../../../../core/config/global.dart';

import '../../entity/pembayaran.dart';
import '../../model/pembayaran_model.dart';
import '../../service/api/pembayaran_service_api.dart';
import '../../../../core/util/app_exceptions.dart';
import '../../../../core/shared/provider/disposable_provider.dart';

class PembayaranProvider extends DisposableProvider {
  final _apiService = PembayaranServiceAPI();

  bool _isLoadingPembayaran = true;
  bool _isLoadingDetail = true;

  String? _pesanPembayaran;

  int _currentBayar = -1;
  Pembayaran? _infoPembayaran;
  // ignore: prefer_final_fields
  List<Pembayaran> _listDetailPembayaran = [];

  bool get isLoadingPembayaran => _isLoadingPembayaran;
  bool get isLoadingDetail => _isLoadingDetail;

  int get currentBayar => _currentBayar;

  String get pesanPembayaran =>
      _pesanPembayaran ??
      'Jika tidak sesuai silahkan hubungi 0853 5199 1159 (WA)';

  Pembayaran? get dataPembayaran => _infoPembayaran;

  UnmodifiableListView<Pembayaran> get detailPembayaran =>
      UnmodifiableListView(_listDetailPembayaran);

  @override
  void disposeValues() {
    _isLoadingPembayaran = true;
    _infoPembayaran = null;
    _listDetailPembayaran.clear();
  }

  Future<int> loadPembayaran({
    required String noRegistrasi,
    bool isRefresh = false,
  }) async {
    if (!isRefresh && _infoPembayaran != null) {
      return currentBayar;
    }
    if (isRefresh) {
      _isLoadingPembayaran = true;
      notifyListeners();
      await Future.delayed(gDelayedNavigation);
    }
    try {
      final response = await _apiService.fetchPembayaran(
        noRegistrasi: noRegistrasi,
      );

      if (kDebugMode) {
        logger.log('PEMBAYARAN_PROVIDER-LoadPembayaran: response >> $response');
      }

      _pesanPembayaran = response['message'];

      if (response['data'] != null) {
        _infoPembayaran = PembayaranModel.fromJson(response['data']);
        _currentBayar = int.parse(_infoPembayaran!.current);
      }

      _isLoadingPembayaran = false;
      notifyListeners();
      return _currentBayar;
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-LoadPembayaran: $e');
      }
      _isLoadingPembayaran = false;
      notifyListeners();
      return currentBayar;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-LoadPembayaran: $e');
      }
      _isLoadingPembayaran = false;
      notifyListeners();
      return currentBayar;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-LoadPembayaran: $e');
      }
      _isLoadingPembayaran = false;
      notifyListeners();
      return currentBayar;
    }
  }

  Future<List<Pembayaran>> loadDetailPembayaran({
    required String noRegistrasi,
    bool isRefresh = false,
  }) async {
    if (_listDetailPembayaran.isNotEmpty && !isRefresh) {
      return detailPembayaran;
    }
    if (isRefresh) {
      _isLoadingDetail = true;
      notifyListeners();
      await Future.delayed(gDelayedNavigation);
    }
    try {
      final responseData =
          await _apiService.fetchDetailPembayaran(noRegistrasi: noRegistrasi);

      if (kDebugMode) {
        logger.log(
            'PEMBAYARAN_PROVIDER-LoadDetailPembayaran: response data >> $responseData');
      }

      if (responseData != null && isRefresh) {
        _listDetailPembayaran.clear();
      }

      if (responseData != null && _listDetailPembayaran.isEmpty) {
        for (Map<String, dynamic> pembayaran in responseData) {
          _listDetailPembayaran.add(PembayaranModel.fromJson(pembayaran));
        }
      }

      _isLoadingDetail = false;
      notifyListeners();
      return detailPembayaran;
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-LoadDetailPembayaran: $e');
      }
      _isLoadingDetail = false;
      notifyListeners();
      return detailPembayaran;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-LoadDetailPembayaran: $e');
      }
      _isLoadingDetail = false;
      notifyListeners();
      return detailPembayaran;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-LoadDetailPembayaran: $e');
      }
      _isLoadingDetail = false;
      notifyListeners();
      return detailPembayaran;
    }
  }
}
