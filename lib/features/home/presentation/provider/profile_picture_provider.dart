import 'dart:async';
import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';
import 'package:flash/flash_helper.dart';
import 'package:flutter/material.dart';

import '../../../../core/config/constant.dart';
import '../../service/profile_picture_service_api.dart';
import '../../../../core/config/enum.dart';
import '../../../../core/config/global.dart';
import '../../../../core/util/app_exceptions.dart';

// import 'package:http/http.dart' as http;
class ProfilePictureProvider with ChangeNotifier {
  final _apiService = ProfilePictureServiceApi();

  final Map<String, bool> _isPhotoProfileExist = {};
  final Map<String, String> _profileUrl = {};

  bool isPhotoProfileExist({required String noRegistrasi}) {
    if (noRegistrasi.isEmpty || noRegistrasi == '-') return false;
    return _isPhotoProfileExist[noRegistrasi] ?? false;
  }

  String? getPictureByNoReg({required String noRegistrasi}) {
    if (noRegistrasi.isEmpty || noRegistrasi == '-') return null;
    return _profileUrl[noRegistrasi];
  }

  String? getSelectedAvatar({required String noRegistrasi}) {
    if (noRegistrasi.isEmpty || noRegistrasi == '-') return null;
    if (!(_isPhotoProfileExist[noRegistrasi] ?? false) ||
        _profileUrl[noRegistrasi] == null) {
      return null;
    }
    if (_profileUrl[noRegistrasi]?.contains('firebasestorage') ?? false) {
      String url = _profileUrl[noRegistrasi]!;

      int startIndex = url.indexOf('%2F');
      int endIndex = url.indexOf('.png');

      if (kDebugMode) {
        logger.log(
            'TEST Selected Avatar >> ${url.substring(startIndex + 3, endIndex)}');
      }

      return url.substring(startIndex + 3, endIndex);
    }
    return null;
  }

  Future<String?> getProfilePicture({
    required String namaLengkap,
    required String noRegistrasi,
    bool isLogin = false,
  }) async {
    if (!isLogin) return null;
    if (_isPhotoProfileExist[noRegistrasi] != null) {
      if ((_isPhotoProfileExist[noRegistrasi] ?? false) &&
          _profileUrl[noRegistrasi] != null) {
        return _profileUrl[noRegistrasi]!;
      }
      return null;
    }
    try {
      if (isLogin) {
        final responseData = await _apiService.fetchProfilePicture(
            namaLengkap: namaLengkap, noRegistrasi: noRegistrasi);

        if (responseData != null) {
          _profileUrl.update(
            noRegistrasi,
            (value) => responseData,
            ifAbsent: () => responseData,
          );
        } else if (noRegistrasi == gUser?.noRegistrasi) {
          // _showMessageFiturBaru();
        }
        _isPhotoProfileExist.update(
          noRegistrasi,
          (value) => responseData != null,
          ifAbsent: () => responseData != null,
        );
      }
      return _profileUrl[noRegistrasi];
    } on NotFoundException {
      _isPhotoProfileExist.update(
        noRegistrasi,
        (value) => false,
        ifAbsent: () => false,
      );
      return null;
    } catch (e) {
      _isPhotoProfileExist.update(
        noRegistrasi,
        (value) => false,
        ifAbsent: () => false,
      );
      return null;
    }
  }

  Future<void> _showMessageFiturBaru() async {
    const duration = Duration(seconds: 1);

    await Future.delayed(duration).then(
      (value) => gShowBottomDialogInfo(
        gNavigatorKey.currentContext!,
        title: 'Fitur Baru!!',
        message: 'Hai Sobat! GO Kreasi punya fitur baru lohh. '
            'Sekarang kamu bisa pilih avatar sesuka kamu. '
            'Yuk cobain fiturnya sekarang!',
        dialogType: DialogType.info,
        actions: (controller) => [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(
                gNavigatorKey.currentContext!,
                Constant.kRouteEditProfileScreen,
              );
              controller.dismiss(true);
            },
            child: const Text('Pilih Avatar'),
          ),
        ],
      ),
    );
  }

  Future<void> saveProfilePicture({
    required String noRegistrasi,
    required String photoUrl,
    bool isAvatar = true,
  }) async {
    String pesanGagal = 'Yaah, foto kamu gagal disimpan Sobat, coba lagi yaa!';

    if (noRegistrasi.isEmpty || photoUrl.isEmpty) return;
    if (noRegistrasi == '-' || photoUrl == '-') return;

    final completer = Completer();
    gNavigatorKey.currentContext!.showBlockDialog(dismissCompleter: completer);
    try {
      final resposeMessage = await _apiService.setProfilePicture(
        noRegistrasi: noRegistrasi,
        photoUrl: photoUrl,
        isAvatar: isAvatar,
      );

      if (!completer.isCompleted) {
        completer.complete();
      }
      if (resposeMessage != null) {
        _profileUrl.update(noRegistrasi, (value) => photoUrl,
            ifAbsent: () => photoUrl);

        _isPhotoProfileExist.update(noRegistrasi, (value) => true,
            ifAbsent: () => true);

        await gShowTopFlash(
          gNavigatorKey.currentContext!,
          resposeMessage,
          dialogType: DialogType.success,
        ).then((value) {
          notifyListeners();
          Future.delayed(gDelayedNavigation).then(
            (value) => Navigator.pop(gNavigatorKey.currentContext!),
          );
        });
      } else {
        gShowTopFlash(
          gNavigatorKey.currentContext!,
          pesanGagal,
          dialogType: DialogType.error,
        );
      }
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('PROFILE_PICTURE-SaveExection: Error >> $e');
      }
      if (!completer.isCompleted) {
        completer.complete();
      }
      gShowTopFlash(
        gNavigatorKey.currentContext!,
        '$e',
        dialogType: DialogType.success,
      );
    } catch (e) {
      if (kDebugMode) {
        logger.log('PROFILE_PICTURE-SaveFatalException: Error >> $e');
      }
      if (!completer.isCompleted) {
        completer.complete();
      }
      gShowTopFlash(
        gNavigatorKey.currentContext!,
        pesanGagal,
        dialogType: DialogType.error,
      );
    }
  }
}
