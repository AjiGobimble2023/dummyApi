import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';

import '../../../core/helper/api_helper.dart';
import '../../../core/util/app_exceptions.dart';

/// [ProfilePictureServiceApi] merupakan service class penghubung provider dengan request api.
class ProfilePictureServiceApi {
  final _apiHelper = ApiHelper();

  // Future<bool> checkProfilePicture(
  //     {required String userType, required String noRegistrasi}) async {
  //   try {
  //     final response = await _apiHelper.requestGet(
  //         hostUrl: 'images.ganeshaoperation.com',
  //         baseUrl: '/gokreasi/profile',
  //         pathUrl: '/$userType/$noRegistrasi.jpeg');
  //
  //     if (kDebugMode) {
  //       logger.log('PROFILE_PICTURE_SERVICE_API: response >> $response');
  //     }
  //
  //     return response.statusCode == 200;
  //   } catch (e) {
  //     if (kDebugMode) {
  //       logger.log('PROFILE_PICTURE_SERVICE_API-CatchError: $e');
  //     }
  //     return false;
  //   }
  // }

  Future<String?> fetchProfilePicture(
      {required String namaLengkap, required String noRegistrasi}) async {
    try {
      final response = await _apiHelper.requestPost(
        pathUrl: '/profile/url/$noRegistrasi',
        bodyParams: {'namaLengkap': namaLengkap},
      );

      if (kDebugMode) {
        logger.log('PROFILE_PICTURE-GetProfilePicture: response >> $response');
      }

      if (response == null ||
          response['status'] == false ||
          response['data'] == null) {
        return null;
      }

      return response['data'];
    } catch (e) {
      if (kDebugMode) {
        logger.log('PROFILE_PICTURE-GetProfilePicture-CatchError: $e');
      }
      return null;
    }
  }

  Future<dynamic> setProfilePicture({
    required String noRegistrasi,
    required String photoUrl,
    bool isAvatar = true,
  }) async {
    String pesanGagal = 'Yaah, foto kamu gagal disimpan Sobat, coba lagi yaa!';
    try {
      final response = await _apiHelper.requestPost(
        pathUrl: '/profile/simpan/$noRegistrasi',
        bodyParams: {'url': photoUrl, 'isAvatar': isAvatar},
      );

      if (kDebugMode) {
        logger.log('PROFILE_PICTURE-SetProfilePicture: response >> $response');
      }

      if (!response['status']) {
        throw DataException(message: response['message'] ?? pesanGagal);
      }

      return response['message'] ?? pesanGagal;
    } catch (e) {
      if (kDebugMode) {
        logger.log('PROFILE_PICTURE-SetProfilePicture-CatchError: $e');
      }
      return pesanGagal;
    }
  }
}
