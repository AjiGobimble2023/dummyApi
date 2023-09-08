import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:developer' as logger;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

// import 'kreasi_secure_storage.dart';
import 'kreasi_shared_pref.dart';
import '../config/global.dart';
import '../config/constant.dart';
import '../util/app_exceptions.dart';

/// Enum untuk Patch request, untuk mengetahui tipe permintaan token yang di minta.
enum RequestType { video, epb, teori, rumus, kreasi }

class ApiHelper {
  /// HTTP Request POST method<br>
  /// Parameter bersifat wajib:<br>
  /// [pathUrl] akan diisi dengan end point dari suatu request. (ex: /refreshToken)<br>
  /// Parameter bersifat opsional:<br>
  /// [hostUrl] akan diisi oleh host API GO Kreasi. (ex: kreasi.ganeshaoperation.com)<br>
  /// [baseUrl] akan diisi oleh base API url GO Kreasi (ex: /apigokreasiios/api/v3)<br>
  /// [optionalHeader] akan diisi bila isi Map<> pada [header] kurang memenuhi request yang diminta.<br>
  /// [bodyParams] akan diisi bila isi Map<> pada [bodyToken] kurang memenuhi request yang diminta.<br>
  /// Default Value:<br>
  /// [hostUrl] = kreasi.ganeshaoperation.com<br>
  /// [baseUrl] = /apigokreasiios/api/v3<br>
  Future<dynamic> requestPost({
    required String pathUrl,
    String? baseUrl,
    String? hostUrl,
    String? jwtSwitchOrtu,
    Map<String, String>? optionalHeader,
    Map<String, dynamic>? bodyParams,
    bool jwt = true,
    bool isEncoded = false,
  }) async {
    if (jwt) {
      if (kDebugMode) {
        logger.log('CHECK JWT START');
      }
      if (gTokenJwt.isEmpty && gUser == null) {
        await gGetIdDevice();
        gTokenJwt = await refreshJwtToken(
            noRegistrasi:
                (gDeviceID.isEmpty) ? 'Undefined_Device_ID' : gDeviceID,
            siapa: 'No User');
        KreasiSharedPref().setTokenJWT(gTokenJwt);
        if (kDebugMode) {
          logger.log('JWT NO USER >> $gTokenJwt');
        }
      }

      DateTime expirationDate =
          JwtDecoder.getExpirationDate(jwtSwitchOrtu ?? gTokenJwt);
      DateTime today = await gGetServerTime();
      // Ketika _expirationDate melewati waktu sekarang (_today), maka token JWT harus di refresh.
      if (kDebugMode) {
        logger.log('IS JWT EXPIRED >> ${expirationDate.isBefore(today)}');
      }
      if (expirationDate.isBefore(today)) {
        gTokenJwt = await refreshJwtToken(
            noRegistrasi: gUser?.noRegistrasi ?? gDeviceID,
            siapa: gUser?.siapa ?? 'No User');
        KreasiSharedPref().setTokenJWT(gTokenJwt);
      }
    }
    Map<String, String> header = {
      'Accept': 'application/json',
      'Kreasi-Key': dotenv.env['KREASI_KEY']!,
    };
    if (jwt) {
      String tokenJwt = jwtSwitchOrtu ?? gTokenJwt;
      String auth = 'Bearer $tokenJwt';
      header.putIfAbsent('Authorization', () => auth.replaceAll('"', ''));
    }
    if (optionalHeader != null && optionalHeader.isNotEmpty) {
      header.addAll(optionalHeader);
    }

    // Request Body
    Map<String, dynamic> body = {
      'token': "YGfdsk3452355mj56uy",
      ...?bodyParams
    };
    // Try Catch Http Request
    try {
      if (kDebugMode) {
        logger.log('API HELPER: JWT is $jwt');
        logger.log('URI URL POST: ${Uri.http(
          hostUrl ?? Constant.kKreasiBaseHost,
          (baseUrl ?? Constant.kKreasiBasePath.toString()) + pathUrl,
        )}');
        logger.log('API HELPER POST: header $header');
        logger.log('API HELPER POST: param ${json.encode(body)}');
      }
      final response = await http
          .post(
        Uri.http(hostUrl ?? Constant.kKreasiBaseHost,
            (baseUrl ?? Constant.kKreasiBasePath) + pathUrl),
        headers: header,
        encoding: isEncoded ? Encoding.getByName('utf-8') : null,
        body: isEncoded ? body : json.encode(body),
      )
          .onError((error, stackTrace) {
        if (kDebugMode) {
          logger.log('API HELPER POST: Error >> $error');
          logger.log('API HELPER POST: StackTrace >> $stackTrace');
        }
        return http.Response('{"status": false, "message": $error}', 500);
      });
      if (kDebugMode) {
        logger.log('API HELPER POST: status ${response.statusCode}');
        if (response.statusCode != 200) {
          logger.log('API HELPER POST: ERROR ON ${response.request?.url}');
          logger.log('API HELPER POST: response ${response.body}');
        }
      }
      return _returnResponse(response);
    } on SocketException {
      throw NoConnectionException(
          message:
              'Tidak dapat terhubung dengan internet, mohon periksa koneksi internet Anda dan coba kembali.');
    }
  }

  /// REQUEST PATCH FOR VIDEO STREAM AND ENCRYPTED FILE TOKEN PURPOSE.
  Future<http.Response> requestPatch({
    RequestType requestType = RequestType.kreasi,
    String? pathUrl,
    String? baseUrl,
    String? hostUrl,
  }) async {
    try {
      late Uri uriUrl;
      switch (requestType) {
        case RequestType.video:
          uriUrl = Uri.http(dotenv.env['STREAM_TOKEN_BASE_URL']!,
              dotenv.env['STREAM_TOKEN_BASE_PATH']!);
          break;
        case RequestType.epb:
          uriUrl = Uri.http(dotenv.env['EPB_TOKEN_BASE_URL']!,
              dotenv.env['EPB_TOKEN_BASE_PATH']!);
          break;
        default:
          uriUrl = Uri.http(hostUrl ?? Constant.kKreasiBaseHost,
              (baseUrl ?? Constant.kKreasiBasePath) + (pathUrl ?? ''));
          break;
      }
      // Request patch
      final response = await http.patch(uriUrl);
      if (kDebugMode) {
        logger.log('URI URL PATCH: $uriUrl');
        logger.log('API HELPER PATCH: status ${response.statusCode}');
        if (response.statusCode != 200) {
          logger.log('API HELPER PATCH: ERROR ON ${response.request?.url}');
          logger.log('API HELPER PATCH: response ${response.body}');
        }
      }
      return response;
    } on SocketException {
      throw NoConnectionException(
          message:
              'Tidak dapat terhubung dengan internet, mohon periksa koneksi internet Anda dan coba kembali.');
    }
  }

  /// REQUEST GET.
  Future<http.Response> requestGet({
    required String pathUrl,
    String? baseUrl,
    String? hostUrl,
    Map<String, String>? optionalHeader,
  }) async {
    // Static header request
    String auth = 'Bearer $gTokenJwt';
    Map<String, String> header = {
      'Accept': 'application/json',
      'Kreasi-Key': dotenv.env['KREASI_KEY']!,
      'Authorization': auth.replaceAll('"', ''),
      'nik': gNoRegistrasi,
    };
    // Adding optional header
    if (optionalHeader != null && optionalHeader.isNotEmpty) {
      header.addAll(optionalHeader);
    }

    // Try Catch Http Request
    try {
      if (kDebugMode) {
        logger.log('URI URL GET: ${Uri.http(
          hostUrl ?? Constant.kKreasiBaseHost,
          (baseUrl ?? Constant.kKreasiBasePath.toString()) + pathUrl,
        )}');
        logger.log('API HELPER GET: header $header');
      }
      final response = await http.get(
          Uri.http(hostUrl ?? Constant.kKreasiBaseHost,
              (baseUrl ?? Constant.kKreasiBasePath) + pathUrl),
          headers: header);
      if (kDebugMode) {
        logger.log('API HELPER GET: status ${response.statusCode}');
        if (response.statusCode != 200) {
          logger.log('API HELPER GET: ERROR ON ${response.request?.url}');
        }
        if (![200, 404].contains(response.statusCode)) {
          logger.log('API HELPER GET: response ${response.body}');
        }
      }

      return _returnResponse(response);
    } on SocketException {
      throw NoConnectionException(
          message:
              'Tidak dapat terhubung dengan internet, mohon periksa koneksi internet Anda dan coba kembali.');
    }
  }

  // Handle return response success and exception
  dynamic _returnResponse(http.Response response) {
    final responseBody = json.decode(response.body.toString());
    // if (kDebugMode) {
    //   logger.log('API HELPER: returnResponseFunction $responseBody');
    // }
    if (responseBody['message'] == 'No route to host') {
      gShowTopFlash(gNavigatorKey.currentState!.context, gPesanErrorKoneksi);
    }
    if ('${responseBody['message']}'.contains('Connection closed')) {
      throw NoConnectionException(message: '${responseBody['message']}');
    }
    switch (response.statusCode) {
      case 500:
      case 502:
      case 504:
        return {
          'status': false,
          'message': 'Oops ${response.statusCode}!! $gPesanError',
          'data': null
        };
      case 200:
        return responseBody;
      case 400:
        throw BadRequestException(
            message:
                'Anda telah mengeluarkan permintaan yang salah atau ilegal.');
      case 401:
      case 403:
        throw UnauthorisedException(
            message: 'Anda tidak memiliki izin untuk mengakses sistem.');
      case 404:
        throw NotFoundException(
            message: 'Permintaan Anda tidak ditemukan di sistem.');
      default:
        throw BasicException(
            message:
                'Terjadi kesalahan saat berkomunikasi dengan server, mohon coba kembali nanti.');
    }
  }

  /// Refresh JWT Token if expired
  Future<String> refreshJwtToken(
      {required String noRegistrasi, required String siapa}) async {
    final response = await requestPost(
      pathUrl: '/refreshtoken',
      jwt: false,
      bodyParams: {'nis': noRegistrasi, "role": siapa},
    );
    if (!response['status']) throw DataException(message: response['message']);
    return response['data'];
  }
}
