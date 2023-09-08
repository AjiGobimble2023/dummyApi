import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';

import '../../model/standby_model.dart';
import '../../service/api/standby_service_api.dart';
import '../../../../core/config/global.dart';
import '../../../../core/util/app_exceptions.dart';

class StandbyProvider {
  final _apiService = StandbyServiceApi();

  /// The above function is used to load standby data from the server.
  ///
  /// Args:
  ///   buildingId (String): The ID of the building where the student is currently located.
  ///   userId (String): The user's registration number.
  ///
  /// Returns:
  ///   List<StandbyModel>
  Future<List<StandbyModel>> loadStandby({
    required String buildingId,
    required String userId,
  }) async {
    if (kDebugMode) {
      logger.log(
          'STANDBY_PROVIDER-LoadStandBy: START with Params(Id Gedung: $buildingId, noReg: $userId)');
    }
    try {
      final responseData = await _apiService.fetchStandby({
        "buildingId": buildingId,
        "studentId": userId,
      });

      if (kDebugMode) {
        logger.log(
            'STANDBY_PROVIDER-LoadStandBy: response data >> $responseData');
      }

      List<StandbyModel> listStandby = [];

      if (responseData != null) {
        for (var i = 0; i < responseData.length; i++) {
          listStandby.add(StandbyModel.fromJson(responseData[i]));
        }
      }

      if (kDebugMode) {
        logger
            .log('STANDBY_PROVIDER-LoadStandBy: list standby >> $listStandby');
      }

      return listStandby;
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-LoadStandBy: $e');
      }
      gShowTopFlash(gNavigatorKey.currentState!.context, gPesanErrorKoneksi);
      rethrow;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-LoadStandBy: $e');
      }
      if (!'$e'.contains('Tidak ada')) {
        gShowTopFlash(gNavigatorKey.currentState!.context, '$e');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-LoadStandBy: $e');
      }
      gShowTopFlash(gNavigatorKey.currentState!.context, gPesanError);
      throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti.';
    }
  }

  /// The above function is used to request a TST (Test of Science and Technology) for a student.
  ///
  /// Args:
  ///   planId (String): The ID of the plan that the user wants to request TST for.
  ///   userId (String): The user's ID.
  ///   updater (String): The user who is currently logged in.
  Future<void> setRequestTST({
    required String planId,
    required String userId,
    required String updater,
  }) async {
    try {
      await _apiService.requestTST(
        {
          'planId': planId,
          'studentId': userId,
          'updater': userId,
        },
      );
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-SetRequestTST: $e');
      }
      gShowTopFlash(gNavigatorKey.currentState!.context, gPesanErrorKoneksi);
      rethrow;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-SetRequestTST: $e');
      }
      gShowTopFlash(gNavigatorKey.currentState!.context, '$e');
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-SetRequestTST: $e');
      }
      gShowTopFlash(gNavigatorKey.currentState!.context, gPesanError);
      throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti.';
    }
  }
}
