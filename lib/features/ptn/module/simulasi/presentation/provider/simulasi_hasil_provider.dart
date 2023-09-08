import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';

import '../../model/hasil_model.dart';
import '../../service/api/simulasi_service_api.dart';
import '../../../../../../core/util/app_exceptions.dart';

class SimulasiHasilProvider with ChangeNotifier {
  final _apiService = SimulasiServiceAPI();

  bool _isLoading = false;
  final List<HasilModel> _listSimulasi = [];

  bool get isLoading => _isLoading;
  List<HasilModel> get listSimulasi => _listSimulasi;

  /// The above function is used to load the simulation data from the API.
  ///
  /// Args:
  ///   noRegistrasi (String): The registration number of the user.
  ///   userType (String): The type of user, either 'P' for personal or 'B' for business.
  ///
  /// Returns:
  ///   List of HasilModel
  Future<List<HasilModel>> loadSimulasi({
    required String noRegistrasi,
    required String userType,
  }) async {
    if (kDebugMode) {
      logger.log(
          'SIMULASI_HASIL_PROVIDER-LoadSimulasi: START with params($noRegistrasi, $userType)');
    }
    try {
      _listSimulasi.clear();
      _isLoading = true;
      notifyListeners();
      final responseData = await _apiService.fetchSimulasi(
          noRegistrasi: noRegistrasi, userType: userType);

      /// Used to check if the responseData is not null, then it will loop through the responseData and
      /// add it to the _listSimulasi.
      if (responseData != null) {
        for (int i = 0; i < responseData.length; i++) {
          _listSimulasi.add(HasilModel.fromJson(responseData[i]));
        }
      }

      if (kDebugMode) {
        logger.log(
            'SIMULASI_HASIL_PROVIDER-LoadSimulasi: List Simulasi >> $_listSimulasi');
      }
      _isLoading = false;
      notifyListeners();
      return [..._listSimulasi];
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-LoadSimulasi: $e');
      }
      rethrow;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-LoadSimulasi: $e');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-LoadSimulasi: $e');
      }
      throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti.';
    }
  }
}
