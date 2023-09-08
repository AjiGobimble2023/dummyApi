import 'dart:convert';
import 'dart:developer' as logger;

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/global.dart';
import '../config/constant.dart';
import '../util/data_formatter.dart';
import '../../features/auth/model/user_model.dart';

// TODO: akan dihapus setelah penggunaan kreasi_shared_pref sudah menyeluruh.
// NOTE: diganti karena sering terjadi anomali bug bada beberapa device.
/// [KreasiSecureStorage] merupakan class yang akan meng-handle semua
/// transaksi Flutter Secure Storage yang di lakukan.
class KreasiSecureStorage {
  // Initiate storage;
  static const _storage = FlutterSecureStorage();
  // Kumpulan Key---------------------------------------------------------------
  static const _keyPilihanKelas = 'pilihan-kelas';
  static const _keyTokenJWT = 'tokenJWT';
  static const _keyUser = 'user';
  static const _keyDeviceID = 'deviceId';

  static AndroidOptions _getAndroidOptions() => const AndroidOptions(
      encryptedSharedPreferences: true,
      preferencesKeyPrefix: 'kreasi',
      sharedPreferencesName: 'ganesha-operation');

  static final KreasiSecureStorage _instance = KreasiSecureStorage._internal();

  factory KreasiSecureStorage() => _instance;

  KreasiSecureStorage._internal();

  /// [setDeviceID] menyimpan data token JWT.
  Future<bool> setDeviceID(String deviceID) async {
    bool isBerhasil = false;

    String encryptedUUID = DataFormatter.encryptString(deviceID);

    final deviceIdStoredData =
        await _storage.read(key: _keyDeviceID, aOptions: _getAndroidOptions());

    if (deviceIdStoredData != null) {
      return false;
    }

    await _storage
        .write(
            key: _keyDeviceID,
            value: encryptedUUID,
            aOptions: _getAndroidOptions())
        .onError((error, stackTrace) {
      isBerhasil = false;
      if (kDebugMode) {
        logger.log(
            'TEAM_SECURE_STORAGE: ERROR setDeviceID => $error\nSTACKTRACE:$stackTrace');
      }
    }).then((value) {
      isBerhasil = true;
      if (kDebugMode) {
        logger.log('TEAM_SECURE_STORAGE: setDeviceID selesai');
      }
    });

    return isBerhasil;
  }

  /// [setPilihanKelas] merupakan fungsi untuk menyimpan pilihan kelas User Tamu.
  Future<void> setPilihanKelas(Map<String, String> pilihan) async {
    await _storage
        .write(
            key: _keyPilihanKelas,
            value: jsonEncode(pilihan),
            aOptions: _getAndroidOptions())
        .onError((error, stackTrace) {
      if (kDebugMode) {
        logger.log(
            'KREASI_SECURE_STORAGE: ERROR setPilihanKelas => $error\nSTACKTRACE:$stackTrace');
      }
    }).then((value) {
      if (kDebugMode) {
        logger.log('KREASI_SECURE_STORAGE: setPilihanKelas selesai');
      }
    });
  }

  /// [getPilihanKelas] merupakan fungsi Getter value pilihan kelas dari secure storage.
  Future<Map<String, dynamic>?> getPilihanKelas() async {
    final String? value = await _storage.read(
        key: _keyPilihanKelas, aOptions: _getAndroidOptions());

    // Future Delayed Di perlukan agar SplashScreen Iklan tampil.
    await Future.delayed(const Duration(seconds: 1));
    if (kDebugMode) {
      logger.log('KREASI_SECURE_STORAGE: getPilihanKelas($value)');
    }
    if (value != null) {
      return json.decode(value) as Map<String, dynamic>;
    } else {
      return null;
    }
  }

  /// [simpanDataLokal] menyimpan data JWT dan user.<br><br>
  /// [gTokenJwt] dan [gUser] merupakan value dari global.dart
  Future<void> simpanDataLokal() async {
    await setTokenJWT(gTokenJwt);
    if (gUser != null) {
      await setUserModel(gUser!);
      await setPilihanKelas(
        Constant.kDataSekolahKelas
            .singleWhere((element) => element['id'] == gUser!.idSekolahKelas),
      );
    }
  }

  /// [setTokenJWT] menyimpan data token JWT.
  Future<void> setTokenJWT(String tokenJwt) async {
    await _storage
        .write(
            key: _keyTokenJWT, value: tokenJwt, aOptions: _getAndroidOptions())
        .onError((error, stackTrace) {
      if (kDebugMode) {
        logger.log(
            'KREASI_SECURE_STORAGE: ERROR setTokenJWT => $error\nSTACKTRACE:$stackTrace');
      }
    }).then((value) {
      if (kDebugMode) {
        logger.log('KREASI_SECURE_STORAGE: setTokenJWT selesai');
      }
    });
  }

  /// [setUserModel] menyimpan data User.
  Future<void> setUserModel(UserModel userModel) async {
    await _storage
        .write(
            key: _keyUser,
            value: json.encode(userModel.toJson()),
            aOptions: _getAndroidOptions())
        .onError((error, stackTrace) {
      if (kDebugMode) {
        logger.log(
            'KREASI_SECURE_STORAGE: ERROR setUserModel => $error\nSTACKTRACE:$stackTrace');
      }
    }).then((value) {
      if (kDebugMode) {
        logger.log('KREASI_SECURE_STORAGE: setUserModel selesai');
      }
    });
  }

  /// [getUser] mengambil data user dari Persistent Data.
  Future<UserModel?> getUser() async {
    try {
      final user =
          await _storage.read(key: _keyUser, aOptions: _getAndroidOptions());

      if (kDebugMode) {
        logger.log('KREASI_SECURE_STORAGE-GetUser: $user');
      }
      if (user?.isNotEmpty ?? false) {
        gTokenJwt = await getTokenJWT() ?? '';
        var userModel = UserModel.fromJson(json.decode(user!));
        gUser = userModel;
        gNoRegistrasi = userModel.noRegistrasi;
        if (kDebugMode) {
          logger.log(
              'KREASI_SECURE_STORAGE-GetUser: Produk Dibeli >> ${userModel.daftarProdukDibeli}');
        }
        return userModel;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        logger.log('KREASI_SECURE_STORAGE-GetUser: ERROR >> $e');
      }
      return null;
    }
  }

  /// [getTokenJWT] mengambil data Token JWT dari Persistent Data.
  Future<String?> getTokenJWT() async {
    final token =
        await _storage.read(key: _keyTokenJWT, aOptions: _getAndroidOptions());
    if (kDebugMode) {
      logger.log('KREASI_SECURE_STORAGE: getTokenJWT($token)');
    }
    return token;
  }

  /// [getDeviceID] mengambil data Token JWT dari Persistent Data.
  Future<String?> getDeviceID() async {
    final uuid =
        await _storage.read(key: _keyDeviceID, aOptions: _getAndroidOptions());

    String? deviceID = uuid;

    if (uuid != null) {
      deviceID = DataFormatter.decryptString(uuid);
    }

    if (kDebugMode) {
      logger.log('TEAM_SECURE_STORAGE: getDeviceID($deviceID)');
    }
    return deviceID;
  }

  Future<void> logout() async {
    _storage.delete(key: _keyTokenJWT, aOptions: _getAndroidOptions());
    _storage.delete(key: _keyUser, aOptions: _getAndroidOptions());
  }
}
