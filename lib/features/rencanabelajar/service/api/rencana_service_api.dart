// import 'dart:convert';
import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';

import '../../../../core/helper/api_helper.dart';

// $route['v4/rencanabelajar/list/menu'] = 'v4/rencanabelajar_controller/getListMenu';
// $route['v4/rencanabelajar/list/rencana'] = 'v4/rencanabelajar_controller/getListRencanaBelajar';
// $route['v4/rencanabelajar/simpanrencanabelajar'] = 'v4/rencanabelajar_controller/simpanrencanabelajar';
class RencanaBelajarServiceAPI {
  final ApiHelper _apiHelper = ApiHelper();

  Future<Map<String, dynamic>> fetchListMenu() async {
    if (kDebugMode) {
      logger.log('RENCANA_SERVICE_API-FetchListMenu: START');
    }
    Map<String, Object> result;
    try {
      final response = await _apiHelper.requestPost(
        pathUrl: '/rencanabelajar/list/menu',
      );

      if (kDebugMode) {
        logger.log('RENCANA_SERVICE_API-FetchListMenu: Response >> $response');
      }

      return response;
    } on Exception catch (e) {
      if (kDebugMode) {
        logger.log('Exception-FetchListMenu: $e');
      }
      result = {'status': false, 'message': "Terjadi kesalahan"};
    } catch (error) {
      if (kDebugMode) {
        logger.log('FatalException-FetchListMenu: $error');
      }
      result = {'status': false, 'message': error};
    }

    return result;
  }

  Future<Map<String, dynamic>> fetchDataRencanaBelajar({
    required String noRegistrasi,
  }) async {
    if (kDebugMode) {
      logger.log('RENCANA_SERVICE_API-FetchDataRencanaBelajar: '
          'START with params($noRegistrasi)');
    }
    Map<String, Object> result;
    try {
      var response = await _apiHelper.requestPost(
        pathUrl: '/rencanabelajar/list/rencana',
        bodyParams: {
          'noRegistrasi': noRegistrasi,
        },
      );

      if (kDebugMode) {
        logger.log(
            'RENCANA_SERVICE_API-FetchDataRencanaBelajar: Response >> $response');
      }

      return response;
    } on Exception catch (_) {
      result = {'status': false, 'message': "Terjadi kesalahan"};
    } catch (error) {
      result = {'status': false, 'message': error};
    }

    return result;
  }

  Future<Map<String, dynamic>> simpanRencanaBelajar({
    required String noRegistrasi,
    String? idRencana,
    required String menu,
    required String keterangan,
    required String awalRencanaDate,
    required String akhirRencanaDate,
    required String jenisSimpan,
    required Map<String, dynamic> argument,
  }) async {
    if (kDebugMode) {
      logger.log('RENCANA_SERVICE_API-SimpanRencanaBelajar: '
          'START with params($noRegistrasi, $idRencana, $menu, $keterangan, '
          '$awalRencanaDate, $akhirRencanaDate, $jenisSimpan, $argument)');
    }

    Map<String, dynamic> result;

    try {
      final response = await _apiHelper.requestPost(
        pathUrl: '/rencanabelajar/simpan',
        bodyParams: {
          'noRegistrasi': noRegistrasi,
          'idRencana': idRencana,
          'menu': menu,
          'keterangan': keterangan,
          'awal': awalRencanaDate,
          'akhir': akhirRencanaDate,
          'jenisSimpan': jenisSimpan,
          'argument': argument,
        },
      );

      if (kDebugMode) {
        logger.log('RENCANA_SERVICE_API-SimpanRencanaBelajar: $response');
      }

      return response;
    } on Exception catch (e) {
      if (kDebugMode) {
        logger.log('Exception-SimpanRencanaBelajar: $e');
      }
      result = {'status': false, 'message': "Terjadi kesalahan"};
    } catch (error) {
      if (kDebugMode) {
        logger.log('FatalException-SimpanRencanaBelajar: $error');
      }
      result = {'status': false, 'message': error};
    }

    return result;
  }

  // Future<Map<String, dynamic>> hapusrencana({
  //   required String id,
  // }) async {
  //   Map<String, dynamic> result;
  //   Map<String, dynamic> kirim = {
  //     'id': id,
  //   };
  //   try {
  //     final response = await _apiHelper.requestPost(
  //       pathUrl: 'hapus_rencana_belajar',
  //       bodyParams: kirim,
  //     );
  //     if (response['status']) {
  //       result = {'status': true, 'data': response['data']};
  //     } else {
  //       result = {'status': false, 'data': null};
  //     }
  //   } on Exception catch (_) {
  //     result = {'status': false, 'message': "Terjadi kesalahan"};
  //   } catch (error) {
  //     result = {'status': false, 'message': error};
  //   }
  //
  //   return result;
  // }
}
