import 'dart:collection';
import 'dart:developer' as logger;

import 'package:flutter/foundation.dart';

import '../../entity/berita.dart';
import '../../model/berita_model.dart';
import '../../service/api/berita_service_api.dart';
import '../../../../core/util/app_exceptions.dart';
import '../../../../core/shared/provider/disposable_provider.dart';

class BeritaProvider extends DisposableProvider {
  final BeritaServiceApi _apiService = BeritaServiceApi();

  final Map<String, List<Berita>> _beritaTemp = {};

  final Map<String, List<Berita>> _beritaPopUpTemp = {};

  bool _isLoadingBerita = true;

  bool _isLoadingBeritaPopUp = true;

  String? _userType;

  bool get isLoadingBerita => _isLoadingBerita;

  UnmodifiableListView<Berita> get allNews => UnmodifiableListView(
        _beritaTemp.containsKey(_userType) ? _beritaTemp[_userType]! : [],
      );

  UnmodifiableListView<Berita> get headlineNews => UnmodifiableListView(
        _beritaTemp.containsKey(_userType)
            ? _beritaTemp[_userType]!.take(10)
            : [],
      );

  UnmodifiableListView<Berita> get popUpNews => UnmodifiableListView(
        _beritaPopUpTemp.containsKey(_userType)
            ? _beritaPopUpTemp[_userType]!
            : [],
      );

  @override
  void disposeValues() {
    _beritaTemp.clear();
    _isLoadingBerita = true;
    _userType = null;
    notifyListeners();
  }

  Future<List<Berita>> loadBerita({
    String userType = 'No User',
    bool isRefresh = false,
    bool fromHome = false,
  }) async {
    _userType = userType;
    if (!isRefresh &&
        _beritaTemp.containsKey(userType) &&
        (_beritaTemp[userType] != null)) {
      return (fromHome) ? headlineNews : allNews;
    }

    if (isRefresh) {
      _isLoadingBerita = true;
      await Future.delayed(const Duration(milliseconds: 300));
      notifyListeners();
    }

    try {
      final responseData = await _apiService.fetchBerita(userType: userType);

      if (isRefresh) _beritaTemp.remove(userType);

      if (responseData != null && _beritaTemp[userType] == null) {
        List<Berita> listBerita = [];

        for (Map<String, dynamic> berita in responseData) {
          listBerita.add(BeritaModel.fromJson(berita));
        }

        _beritaTemp[userType] = listBerita;
      }

      // if (kDebugMode) {
      //   logger
      //       .log('BERITA_PROVIDER-LoadBerita: Berita Cache for $userType >>');
      //   if (_beritaTemp[userType]?.isNotEmpty ?? false) {
      //     for (var berita in _beritaTemp[userType]!) {
      //       logger.log(
      //           'BERITA_PROVIDER-LoadBerita: ${berita.id} | ${berita.title}');
      //     }
      //   } else {
      //     logger.log('BERITA_PROVIDER-LoadBerita: $_beritaTemp');
      //   }
      // }

      _isLoadingBerita = false;
      notifyListeners();
      return (fromHome) ? headlineNews : allNews;
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-LoadBerita: $e');
      }

      _isLoadingBerita = false;
      notifyListeners();
      return (fromHome) ? headlineNews : allNews;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-LoadBerita: $e');
      }

      _isLoadingBerita = false;
      notifyListeners();
      return (fromHome) ? headlineNews : allNews;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-LoadBerita: $e');
      }

      _isLoadingBerita = false;
      notifyListeners();
      return (fromHome) ? headlineNews : allNews;
    }
  }

  Future<void> addViewers({required String idBerita}) async {
    try {
      await _apiService.setViewer(idBerita);
    } on NoConnectionException {
      rethrow;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-Response-addViewers: $e');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-Response-addViewers: $e');
      }
      throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti.';
    }
  }

  Future<List<Berita>> loadBeritaPopUp({
    String userType = 'No User',
  }) async {
    _userType = userType;
    try {
      final responseData =
          await _apiService.fetchBeritaPopUp(userType: userType);

      if (kDebugMode) {
        logger.log('Respponse Data PopUp >> $responseData');
      }

      if (responseData != null && _beritaPopUpTemp[userType] == null) {
        List<Berita> listBeritaPopUp = [];

        for (Map<String, dynamic> berita in responseData) {
          listBeritaPopUp.add(BeritaModel.fromJson(berita));
        }
        _beritaPopUpTemp[userType] = listBeritaPopUp;
      }

      _isLoadingBeritaPopUp = false;
      notifyListeners();
      return popUpNews;
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-LoadBeritaPopUp: $e');
      }

      _isLoadingBeritaPopUp = false;
      notifyListeners();
      return popUpNews;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-LoadBeritaPopUp: $e');
      }

      _isLoadingBeritaPopUp = false;
      notifyListeners();
      return popUpNews;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-LoadBeritaPopUp: $e');
      }

      _isLoadingBeritaPopUp = false;
      notifyListeners();
      return popUpNews;
    }
  }
}
