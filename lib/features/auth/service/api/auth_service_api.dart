import 'dart:developer' as logger;

import 'package:flutter/foundation.dart';

import '../../../../core/config/global.dart';
import '../../../../core/helper/api_helper.dart';
import '../../../../core/util/app_exceptions.dart';

/// [AuthServiceApi] merupakan service class penghubung provider dengan request api.
class AuthServiceApi {
  final _apiHelper = ApiHelper();

  // Future<bool> checkProfilePicture(
  //     {required String userType, required String noRegistrasi}) async {
  //   final response = await _apiHelper.requestGet(
  //       hostUrl: 'images.ganeshaoperation.com',
  //       baseUrl: '/gokreasi/profile',
  //       pathUrl: '/$userType/$noRegistrasi.jpeg');
  //
  //   return response.statusCode == 200;
  // }

  Future<String?> fetchImei({
    String? noRegistrasi,
    String? siapa,
  }) async {
    if (noRegistrasi == null || siapa == null) {
      return null;
    }
    logger.log('FETCH IMEI START');
    try {
      final response = await _apiHelper.requestPost(
        jwt: false,
        pathUrl: '/auth/imei',
        bodyParams: {'noRegistrasi': noRegistrasi, 'role': siapa},
      );
      if (kDebugMode) logger.log('FETCH IMEI: response >> $response');

      return (!response['status']) ? null : response['data']?['cImei'];
    } catch (e) {
      if (kDebugMode) {
        logger.log('AUTH_SERVICE_API-CatchError: $e');
      }
      return null;
    }
  }

  /// [resendOTP] service untuk request pengiriman ulang OTP kepada user.
  Future<dynamic> resendOTP({
    required String userPhoneNumber,
    required String otpCode,
    required String via,
  }) async {
    final response = await _apiHelper.requestPost(
      jwt: false,
      pathUrl: '/auth/otp/resend',
      bodyParams: {
        'registeredNumber': userPhoneNumber,
        'otp': otpCode,
        'via': via,
      },
    );

    if (kDebugMode) {
      /* Bentuk Response:
        {
          "status": true,
          "waktu": "180",
          "message": "sukses"
        }
      */
      logger.log('AUTH_SERVICE_API-ResendOTP: response >> $response');
    }

    if (!response['status']) throw DataException(message: response['message']);

    return response['waktu'];
  }

  Future<Map<String, dynamic>> cekValidasiRegistrasi({
    required String noRegistrasi,
    required String nomorHp,
    required String userType,
    String? otp,
    String? kirimOtpVia,
    String? nama,
    String? email,
    String? tanggalLahir,
    String? idSekolahKelas,
    String? namaSekolahKelas,
  }) async {
    final response = await _apiHelper.requestPost(
      jwt: otp == null,
      pathUrl: '/auth/registrasi/validasi',
      bodyParams: {
        'registeredNumber': nomorHp,
        'otp': otp,
        'via': kirimOtpVia,
        'noRegistrasi': noRegistrasi,
        'nama': nama,
        'email': email,
        'tanggalLahir': tanggalLahir,
        'idSekolahKelas': idSekolahKelas,
        'namaSekolahKelas': namaSekolahKelas,
        'jenis': userType.toUpperCase(),
        'imei': gDeviceID
      },
    );

    if (kDebugMode) {
      logger
          .log('AUTH_SERVICE_API-CekValidasiRegistrasi: response >> $response');
    }

    if (!response['status']) throw DataException(message: response['message']);

    return response;
  }

  /// [noRegistrasi] dan [userType] diisi untuk keperluan refresh data user.
  Future<Map<String, dynamic>> login({
    required String userPhoneNumber,
    required String otp,
    required String via,
    required String imei,
    String? userType,
    String? noRegistrasi,
  }) async {
    if (kDebugMode) {
      logger
          .log('AUTH_SERVICE_API-Login: IS REFRESH >> ${noRegistrasi != null}');
      logger.log('AUTH_SERVICE_API-Login: START with '
          'params($userPhoneNumber, $otp, $via, $imei, $noRegistrasi, $userType)');
    }

    final response = await _apiHelper.requestPost(
      jwt: noRegistrasi != null,
      pathUrl: '/auth/login',
      bodyParams: {
        'registeredNumber': userPhoneNumber,
        'otp': otp,
        'via': via,
        'imei': imei,
        'jenis': userType,
        'noRegistrasi': noRegistrasi,
      },
    );

    if (kDebugMode) {
      logger.log('AUTH_SERVICE_API-Login: response >> $response');
    }
    return response;
  }

  Future<Map<String, dynamic>> simpanRegistrasi({
    required String imei,
    String? jwtSwitchOrtu,
  }) async {
    Map<String, dynamic> bodyParams = {'imei': imei};
    final Map<String, dynamic> additionalInfo = await gGetDeviceInfo();
    bodyParams.addAll(additionalInfo);

    final response = await _apiHelper.requestPost(
      jwtSwitchOrtu: jwtSwitchOrtu,
      pathUrl: '/auth/registrasi/simpan',
      bodyParams: bodyParams,
    );

    if (kDebugMode) {
      logger.log('AUTH_SERVICE_API-SimpanRegistrasi: response >> $response');
    }
    return response;
  }

  Future<bool> simpanLogin({
    required String noRegistrasi,
    required String nomorHp,
    required String imei,
    required String siapa,
    String? jwtSwitchOrtu,
  }) async {
    Map<String, dynamic> bodyParams = {
      'noRegistrasi': noRegistrasi,
      'registeredNumber': nomorHp,
      'imei': imei,
      'siapa': siapa
    };
    final Map<String, dynamic> additionalInfo = await gGetDeviceInfo();
    bodyParams.addAll(additionalInfo);

    final response = await _apiHelper.requestPost(
      jwtSwitchOrtu: jwtSwitchOrtu,
      pathUrl: '/auth/login/update',
      bodyParams: bodyParams,
    );

    if (kDebugMode) {
      logger.log('AUTH_SERVICE_API-SimpanLogin: response >> $response');
    }
    return response['status'];
  }

  Future<dynamic> fetchDefaultTahunAjaran() async {
    final response =
        await _apiHelper.requestPost(jwt: false, pathUrl: '/auth/tahun_ajaran');

    return response['data'];
  }
}
