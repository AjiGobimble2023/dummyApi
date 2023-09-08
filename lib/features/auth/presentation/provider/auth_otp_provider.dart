// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as logger show log;
import 'dart:math';

import 'package:flash/flash_helper.dart';
import 'package:otp/otp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../../ptn/module/ptnclopedia/entity/kampus_impian.dart';
import '../../model/produk_dibeli_model.dart';
import '../../model/user_model.dart';
import '../../service/api/auth_service_api.dart';
import '../../../bookmark/entity/bookmark.dart';
import '../../../profile/entity/kelompok_ujian.dart';
import '../../../../core/config/enum.dart';
import '../../../../core/config/global.dart';
import '../../../../core/config/constant.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/helper/hive_helper.dart';
import '../../../../core/util/app_exceptions.dart';
import '../../../../core/util/data_formatter.dart';
import '../../../../core/helper/app_providers.dart';
import '../../../../core/helper/firebase_helper.dart';
import '../../../../core/helper/kreasi_shared_pref.dart';

class AuthOtpProvider with ChangeNotifier {
  final _apiService = AuthServiceApi();

  // Error message
  static const String _errorNomorHp = 'Mohon masukkan nomor handphone anda';

  static final AuthOtpProvider _instance = AuthOtpProvider._internal();

  factory AuthOtpProvider() => _instance;

  AuthOtpProvider._internal();

  // Local variable
  bool _isLoading = true;
  // bool _isLoadingTahunAjaran = false;
  bool _isResend = false;
  bool get isResend => _isResend;
  late String _otp;
  int _otpExpireTime = 30;
  ValueNotifier<OtpVia> otpVia = ValueNotifier<OtpVia>(OtpVia.wa);

  // Data User Variable
  UserModel? _userModelTemp;
  final ValueNotifier<UserModel?> _userModel = ValueNotifier(null);
  AuthRole authRole = AuthRole.siswa;
  String? _nomorHp;
  // Data User Daftar Tamu
  String? _email;
  String? _tahunAjaran;
  ValueNotifier<String?> idSekolahKelas = ValueNotifier<String?>(null);

  // Getter and setter
  bool get isLoading => _isLoading;
  set isLoading(bool value) => _isLoading = _isLoading;

  ValueNotifier<UserModel?> get userModel => _userModel;
  UserModel? get userData => _userModel.value;

  bool get isSiswa =>
      _userModel.value != null && _userModel.value?.siapa == 'SISWA';
  bool get isTamu =>
      _userModel.value != null && _userModel.value?.siapa == 'TAMU';
  bool get isOrtu =>
      _userModel.value != null && _userModel.value?.siapa == 'ORTU';
  bool get isKelasSMA => (_userModel.value == null)
      ? tingkat == 'SMA'
      : _userModel.value.isKelasSMA;
  bool get isKelasAlumni => (_userModel.value == null)
      ? tingkat == 'ALUMNI'
      : _userModel.value.isKelasAlumni;

  bool get isLogin => _userModel.value != null;

  String get userType => authRole.name.toUpperCase();

  String get teaserRole =>
      (!isLogin || isOrtu) ? 'No User' : _userModel.value?.siapa ?? 'No User';

  String get otp => _otp;
  int get otpExpireTime => _otpExpireTime;

  String get nomorHp =>
      DataFormatter.formatPhoneNumber(phoneNumber: _nomorHp ?? '');

  set nomorHp(String value) {
    _nomorHp = value;
    if (kDebugMode) {
      logger.log('SET NOMOR HP >> $_nomorHp | formatted >> $nomorHp');
    }
  }

  String get namaSekolahKelas =>
      Constant.kDataSekolahKelas.singleWhere(
        (sekolah) => sekolah['id'] == idSekolahKelas.value,
        orElse: () => {
          'id': '0',
          'kelas': 'Undefined',
          'tingkat': 'Other',
          'tingkatKelas': '0'
        },
      )['kelas'] ??
      'Undefined';
  String get tingkatKelas =>
      Constant.kDataSekolahKelas.singleWhere(
        (sekolah) => sekolah['id'] == idSekolahKelas.value,
        orElse: () => {
          'id': '0',
          'kelas': 'Undefined',
          'tingkat': 'Other',
          'tingkatKelas': '0'
        },
      )['tingkatKelas'] ??
      '0';

  String get tingkat =>
      Constant.kDataSekolahKelas.singleWhere(
        (sekolah) => sekolah['id'] == idSekolahKelas.value,
        orElse: () => {
          'id': '0',
          'kelas': 'Undefined',
          'tingkat': 'N/a',
          'tingkatKelas': '0'
        },
      )['tingkat'] ??
      '0';

  // String get email => _email ?? '';
  // set email(String value) => _email = value;

  // String get ttl => _ttl ?? '';
  // set ttl(String value) => _ttl = value;

  String get tahunAjaran {
    final bulanSekarang = DateTime.now().month;
    final tahunSekarang = DateTime.now().year;
    final tahunDepan = tahunSekarang + 1;
    final tahunKemarin = tahunSekarang - 1;

    final defaultTahunAjaran = (bulanSekarang < 7)
        ? '$tahunKemarin/$tahunSekarang'
        : '$tahunSekarang/$tahunDepan';
    if (kDebugMode) {
      logger.log('DEFAULT TAHUN AJARAN >> $defaultTahunAjaran');
    }
    return _tahunAjaran ?? defaultTahunAjaran;
  }

  String getNamaKelasGOByIdKelas(String idKelas) {
    if (_userModel.value == null) return '-';
    int indexKelas = userData!.idKelasGO.indexWhere((id) => id == idKelas);

    if (kDebugMode) {
      logger.log(
          'AUTH_OTP_PROVIDER-GetNamaKelasGO: $idKelas >> ${userData!.idKelasGO}');
      logger.log(
          'AUTH_OTP_PROVIDER-GetNamaKelasGO: $idKelas >> ${userData!.namaKelasGO}');
    }

    if (indexKelas < 0) {
      return '-';
    }

    return userData!.namaKelasGO[indexKelas];
  }

  /// [isProdukDibeliSiswa] merupakan function untuk mengecek apakah siswa sudah
  /// membeli suatu produk atau belum berdasarkan dari idJenisProduknya.
  bool isProdukDibeliSiswa(int idJenisProduk, {bool ortuBolehAkses = false}) {
    bool isDibeli = userData?.daftarProdukDibeli.any((produk) =>
            produk.idJenisProduk == idJenisProduk && !produk.isExpired) ??
        false;
    if (kDebugMode) {
      logger.log('AUTH_PROVIDER-IsProdukDibeli: $idJenisProduk >> $isDibeli');
      logger.log(
          'AUTH_PROVIDER-IsProdukDibeli: $idJenisProduk >> ${userData?.daftarProdukDibeli.where((produk) => produk.idJenisProduk == idJenisProduk)}');
    }
    return isOrtu ? (ortuBolehAkses && isDibeli) : isDibeli;
  }

  Future<bool> logout() async {
    try {
      await KreasiSharedPref().logout();
      _userModel.value = null;

      if (!HiveHelper.isBoxOpen<BookmarkMapel>(
          boxName: HiveHelper.kBookmarkMapelBox)) {
        await HiveHelper.openBox<BookmarkMapel>(
            boxName: HiveHelper.kBookmarkMapelBox);
      }
      if (!HiveHelper.isBoxOpen<KelompokUjian>(
          boxName: HiveHelper.kKelompokUjianPilihanBox)) {
        await HiveHelper.openBox<KelompokUjian>(
            boxName: HiveHelper.kKelompokUjianPilihanBox);
      }
      if (!HiveHelper.isBoxOpen<KampusImpian>(
          boxName: HiveHelper.kKampusImpianBox)) {
        await HiveHelper.openBox<KampusImpian>(
            boxName: HiveHelper.kKampusImpianBox);
      }
      if (!HiveHelper.isBoxOpen<KampusImpian>(
          boxName: HiveHelper.kRiwayatKampusImpianBox)) {
        await HiveHelper.openBox<KampusImpian>(
            boxName: HiveHelper.kRiwayatKampusImpianBox);
      }
      await HiveHelper.clearKampusImpianBox();
      await HiveHelper.clearRiwayatKampusImpian();
      await HiveHelper.clearBookmarkBox();
      await HiveHelper.clearKelompokUjianPilihanBox();
      await HiveHelper.closeBox<BookmarkMapel>(
          boxName: HiveHelper.kBookmarkMapelBox);

      await Future.delayed(gDelayedNavigation);
      Navigator.popUntil(
          gNavigatorKey.currentState!.context, (route) => route.isFirst);
      AppProviders.disposeAllDisposableProviders(
          gNavigatorKey.currentState!.context);

      // Cancel stream dan set to null.
      FirebaseHelper().stopStreamCheckLogin();
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        logger.log('AUTH_PROVIDER-Logout: Error >> $e');
      }
      return false;
    }
  }

  /// Menyetel value OTP dan waktu expired-nya.
  Future<void> _setOTPAndExpireTime(int? expireTime, String otp) async {
    _otp = otp;
    _otpExpireTime = expireTime ?? 180;
    if (kDebugMode) {
      logger.log('AUTH_OTP_PROVIDER-SET_OTP_AND_EXPIRE_TIME: OTP >> $_otp | '
          'expired from response >> $expireTime detik | stored >> $_otpExpireTime detik');
    }
    notifyListeners();
  }

  Future<String> generateOTP() async {
    try {
      if (gAkunTester
          .contains(DataFormatter.formatPhoneNumber(phoneNumber: nomorHp))) {
        return '886644';
      }
      final generatedOTP = OTP.generateTOTPCodeString(
        Constant.secretOTP,
        DateTime.now().serverTimeFromOffset.millisecondsSinceEpoch,
        length: 6,
        interval: 10,
      );

      if (kDebugMode) {
        logger.log(
            'AUTH_OTP_PROVIDER-GenerateOTP: OTP Generated >> $generatedOTP');
      }

      return generatedOTP;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('DataException-GenerateOTP: $e');
      }
      var rng = Random();
      int formattedOTP = rng.nextInt(900000) + 100000;
      return formattedOTP.toString();
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-GenerateOTP: $e');
      }
      var rng = Random();
      int formattedOTP = rng.nextInt(900000) + 100000;
      return formattedOTP.toString();
    }
  }

  Future<String> resendOTP() async {
    if (kDebugMode) {
      logger.log('RESEND_OTP: Nomor Handphone >> $_nomorHp');
    }
    if (_nomorHp == null) {
      gShowTopFlash(
        gNavigatorKey.currentContext!,
        _errorNomorHp,
        dialogType: DialogType.error,
      );
      return 'Nomor Hp tidak terbaca, coba lagi';
    }
    try {
      _isResend = false;

      final String generateNewOTP = await generateOTP();

      if (kDebugMode) {
        logger.log('RESEND_OTP: NEW OTP >> $generateNewOTP');
      }

      final String responseWaktu = await _apiService.resendOTP(
        userPhoneNumber: (otpVia.value != OtpVia.email)
            ? nomorHp
            : _email ?? _userModelTemp?.email ?? '',
        otpCode: generateNewOTP,
        via: otpVia.value.name,
      );

      if (kDebugMode) {
        logger.log('RESEND_OTP: Response Resend OTP >> $responseWaktu');
      }

      await _setOTPAndExpireTime(int.parse(responseWaktu), generateNewOTP);

      return 'Kirim Ulang OTP ke ${(otpVia.value != OtpVia.email) ? nomorHp : _email ?? _userModelTemp?.email}';
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-ResendOTP: $e');
      }
      return 'Gagal mengirim OTP, coba lagi';
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-ResendOTP: $e');
      }
      return 'Gagal mengirim OTP, coba lagi';
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-ResendOTP: ${e.toString()}');
      }
      return 'Gagal mengirim OTP, coba lagi';
    }
  }

  /// [switchAccount] saat ini hanya di gunakan khusus ORTU saja.
  Future<bool> switchAccount({
    required bool isTambahAkun,
    required String noRegistrasi,
  }) async {
    var completer = Completer();
    try {
      if (_userModel.value == null) {
        gShowTopFlash(
            gNavigatorKey.currentState!.context, 'Login terlebih dahulu');
        return false;
      }
      if (isTambahAkun &&
          userData!.daftarAnak
              .any((anak) => anak.noRegistrasi == noRegistrasi)) {
        gShowTopFlash(gNavigatorKey.currentState!.context,
            'Akun $noRegistrasi sudah terdaftar');
        return false;
      }
      if (noRegistrasi.length < 11) {
        gShowTopFlash(gNavigatorKey.currentState!.context,
            'No Registrasi minimal 11 digit');
        return false;
      }
      gNavigatorKey.currentState!.context
          .showBlockDialog(dismissCompleter: completer);

      // Mencoba login terlebih dahulu
      String? imei = (gAkunTester.contains(nomorHp) ||
              gAkunTester.contains('${userData?.nomorHp}'))
          ? gStaticImei
          : await gGetIdDevice();

      if (kDebugMode) {
        logger.log('AUTH_OTP_PROVIDER-SwitchAccount: imei >> $imei');
      }

      if (imei == null) {
        gShowTopFlash(gNavigatorKey.currentState!.context,
            'Gagal mengambil ID Perangkat, Coba lagi!');
        completer.complete();
        return false;
      }

      String errorMessage =
          'Gagal ${isTambahAkun ? 'menambahkan akun' : 'pindah akun'}, Coba lagi!';

      final responseLogin = await _apiService.login(
        imei: imei,
        userType: 'ORTU',
        noRegistrasi: noRegistrasi,
        userPhoneNumber: userData!.nomorHpOrtu,
        otp: '',
        via: '',
      );

      if (kDebugMode) {
        logger.log(
            'AUTH_OTP_PROVIDER-SwitchAccount: response login >> $responseLogin');
      }

      var responseData = responseLogin['data'];
      // Jika login berhasil, berarti data ortu dengan noRegistrasi
      // tersebut ter-data di GO_Kreasi.t_register
      if (responseLogin['status'] && isTambahAkun) {
        // Jika berhasil login dan akses dari tambah akun, maka hanya tambahkan akun saja.
        if (kDebugMode) {
          logger.log(
              'AUTH_OTP_PROVIDER-TambahAkun: Before daftar anak >> ${userData?.daftarAnak}');
        }
        Anak anak = Anak(
          noRegistrasi: responseData['noRegistrasi'],
          namaLengkap: responseData['namaLengkap'],
          nomorHandphone: responseData['nomorHp'],
        );

        _userModel.value!.daftarAnak.add(anak);
        if (kDebugMode) {
          logger.log(
              'AUTH_OTP_PROVIDER-TambahAkun: After daftar anak >> ${_userModel.value?.daftarAnak}');
        }
        gUser = _userModel.value;
        await KreasiSharedPref().setUserModel(gUser!);
        await Future.delayed(const Duration(milliseconds: 700));
        notifyListeners();
        completer.complete();
        return true;
      } else if (responseLogin['status'] && !isTambahAkun) {
        // Jika berhasil login dan akses dari switch account,
        // maka hanya dispose semua provider dan switch ke akun yang di pilih.
        if (kDebugMode) {
          logger.log(
              'AUTH_OTP_PROVIDER-SwitchAccount: Before NoRegistrasi $gNoRegistrasi | JWT >> $gTokenJwt\n'
              'UserModel >> $gUser');
        }

        Navigator.pop(gNavigatorKey.currentState!.context);
        bool berhasilLogout = await logout();
        if (berhasilLogout) {
          _userModelTemp = _responseLoginToUserModel(responseLogin);

          // Store token JWT ke global.dart
          gTokenJwt = responseLogin['tokenJWT'];

          // Pindahkan userModelTemp ke userModel dan
          // Store UserModel ke global.dart
          _userModel.value = _userModelTemp;
          idSekolahKelas.value = _userModel.value!.idSekolahKelas;
          gUser = _userModel.value!;

          // Store noRegistrasi Siswa/Ortu ke global.dart
          gNoRegistrasi = gUser!.noRegistrasi;

          if (kDebugMode) {
            logger.log(
                'AUTH_OTP_PROVIDER-SwitchAccount: After NoRegistrasi $gNoRegistrasi | JWT >> $gTokenJwt\n'
                'UserModel >> $gUser');
          }
          await KreasiSharedPref().simpanDataLokal();
          // Memunculkan Pesan Sukses
          gShowTopFlash(
            gNavigatorKey.currentContext!,
            'Selamat Datang Bpk/Ibu dari ${_userModelTemp?.namaLengkap}',
            dialogType: DialogType.success,
          );
          await Future.delayed(const Duration(milliseconds: 700));
          notifyListeners();
          completer.complete();
          return true;
        }
      } else if (!responseLogin['status'] && isTambahAkun) {
        // Jika login gagal dan akses dari tambah akun dan gagal,
        // artinya belum terdaftar, maka lakukan registrasi.
        final responseValidasi = await _apiService.cekValidasiRegistrasi(
          userType: 'ORTU',
          noRegistrasi: noRegistrasi,
          nomorHp: userData!.nomorHpOrtu,
          otp: null,
          kirimOtpVia: null,
          nama: '',
          email: '',
          tanggalLahir: '',
          idSekolahKelas: '',
          namaSekolahKelas: '',
        );

        if (kDebugMode) {
          logger.log(
              'AUTH_OTP_PROVIDER-SwitchAccount: response registrasi >> $responseValidasi');
        }

        // Jika valid untuk melakukan registrasi, maka simpan registrasi.
        if (responseValidasi['status']) {
          responseData = responseValidasi['data'];
          if (kDebugMode) {
            logger.log(
                'AUTH_OTP_PROVIDER-TambahAkun: Cek Validasi Registrasi >> ${responseValidasi["status"]}');
            logger.log(
                'AUTH_OTP_PROVIDER-TambahAkun: Before daftar anak >> ${userData?.daftarAnak}');
          }
          // Simpan registrasi, lalu store data ke daftar anak.
          final responseSimpanRegistrasi = await _apiService.simpanRegistrasi(
            imei: imei,
            jwtSwitchOrtu: responseValidasi['tokenJWT'],
          );

          if (kDebugMode) {
            logger.log(
                'AUTH_OTP_PROVIDER-SwitchAccount: response simpan registrasi >> $responseSimpanRegistrasi');
          }

          if (responseSimpanRegistrasi["status"]) {
            Anak anak = Anak(
              noRegistrasi: responseData['noRegistrasi'],
              namaLengkap: responseData['namaLengkap'],
              nomorHandphone: responseData['nomorHp'],
            );

            _userModel.value!.daftarAnak.add(anak);
            if (kDebugMode) {
              logger.log(
                  'AUTH_OTP_PROVIDER-TambahAkun: After daftar anak >> ${userData?.daftarAnak}');
            }
            gUser = _userModel.value;
            await KreasiSharedPref().setUserModel(gUser!);

            gShowTopFlash(gNavigatorKey.currentState!.context,
                'Berhasil menambahkan akun',
                dialogType: DialogType.success);
            await Future.delayed(const Duration(milliseconds: 700));
            notifyListeners();
            completer.complete();
            return true;
          }
        } else {
          if (responseValidasi['message'].contains('tidak terdaftar')) {
            errorMessage =
                'Nomor Registrasi $noRegistrasi tidak terdaftar dengan '
                'nomor handphone Orang Tua ${userData!.nomorHpOrtu}';
            completer.complete();
            gShowBottomDialogInfo(gNavigatorKey.currentState!.context,
                title: 'Nomor Registrasi tidak sesuai', message: errorMessage);
            return false;
          }
          if (responseValidasi['message'].contains('tidak sesuai')) {
            errorMessage = responseValidasi['message'];
            completer.complete();
            gShowBottomDialogInfo(gNavigatorKey.currentState!.context,
                title: 'Gagal tambah akun anak', message: errorMessage);
            return false;
          }
        }
      }

      if (responseLogin['message'].contains('perangkat lain')) {
        completer.complete();
        gShowBottomDialogInfo(
          gNavigatorKey.currentState!.context,
          title: responseLogin['message'],
          message: responseLogin['data'],
        );
        return false;
      }

      if ((responseLogin['message'].contains('tidak terdaftar') ||
              responseLogin['message'].contains('telah terdaftar')) &&
          !isTambahAkun) {
        errorMessage = responseLogin['message'];
      }
      completer.complete();
      gShowTopFlash(gNavigatorKey.currentState!.context, errorMessage);
      return false;
    } on NoConnectionException catch (e) {
      gShowTopFlash(
        gNavigatorKey.currentContext!,
        gPesanErrorKoneksi,
        dialogType: DialogType.error,
      );
      if (kDebugMode) {
        logger.log('NoConnectionException-SwitchAccount: $e');
      }
      completer.complete();
      return false;
    } on DataException catch (e) {
      gShowTopFlash(
        gNavigatorKey.currentContext!,
        '$e',
        dialogType: DialogType.error,
      );
      if (kDebugMode) {
        logger.log('Exception-SwitchAccount: $e');
      }
      completer.complete();
      return false;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-SwitchAccount: $e');
      }
      gShowTopFlash(
        gNavigatorKey.currentContext!,
        gPesanError,
        dialogType: DialogType.error,
      );
      completer.complete();
      return false;
    }
  }

  /// [cekValidasiRegistrasi] merupakan function untuk memvalidasi data registrasi User.
  Future<Map<String, dynamic>> cekValidasiRegistrasi({
    required AuthRole authRole,
    required String noRegistrasi,
    required String nomorHp,
    required String otp,
    String? namaLengkap,
    String? email,
    String? ttl,
  }) async {
    Map<String, dynamic> result = {'data': '', 'status': false};
    if (_nomorHp == null) {
      gShowTopFlash(
        gNavigatorKey.currentContext!,
        _errorNomorHp,
        dialogType: DialogType.error,
      );
      return result;
    }
    try {
      _isResend = false;
      _nomorHp = DataFormatter.formatPhoneNumber(phoneNumber: nomorHp);
      _email = email;
      authRole = authRole;

      final responseValidasi = await _apiService.cekValidasiRegistrasi(
          nomorHp: nomorHp,
          otp: otp,
          kirimOtpVia: otpVia.value.name,
          noRegistrasi: noRegistrasi,
          nama: namaLengkap,
          email: email,
          tanggalLahir: ttl,
          idSekolahKelas: idSekolahKelas.value,
          namaSekolahKelas: namaSekolahKelas,
          userType: authRole.name);

      if (kDebugMode) {
        logger.log(
            'AUTH_OTP_PROVIDER-CekValidasiRegistrasi: Daftar Anak >> ${responseValidasi['daftarAnak']}\n'
            'AUTH_OTP_PROVIDER-CekValidasiRegistrasi: Pilihan PTN >> ${responseValidasi['pilihanPTN']}\n'
            'AUTH_OTP_PROVIDER-CekValidasiRegistrasi: Produk Dibeli >> ${responseValidasi['daftarProduk']}');
      }

      if (responseValidasi["status"]) {
        result = responseValidasi;
        if (responseValidasi["message"] == "Sudah pernah terdaftar") {
          notifyListeners();
          return result;
        }
        // if (responseValidasi["message"] == "Sudah pernah terdaftar") {
        // }
        // Value OTP dan Expire Time OTP.
        await _setOTPAndExpireTime(int.parse(responseValidasi['waktu']), otp);

        // mengambil data User dari token JWT
        Map<String, dynamic> userJson =
            JwtDecoder.decode(responseValidasi['tokenJWT']);

        // Decode Object ptn pilihan
        Map<String, dynamic>? ptnPilihan =
            (responseValidasi['pilihanPTN'] != null &&
                    (responseValidasi['pilihanPTN']?.isNotEmpty ?? false))
                ? json.decode(responseValidasi['pilihanPTN'])
                : null;

        // token jwt pada user tamu akan berbeda, di sini token jwt tamu tidak mengandung
        // payload no registrasi, jadi perlu update jwt di simpan registrasi.
        // Store token jwt ke gTokenJwt (global.dart) untuk keperluan simpan registrasi.
        gTokenJwt = responseValidasi['tokenJWT'];
        // Menambahkan daftar anak untuk akun ORTU
        List<dynamic>? daftarAnakResponse;
        // Convert daftarAnak to List<Anak>
        List<Anak> daftarAnak = const [];

        // Add data register ke dalam daftar Anak untuk switch account
        if (userJson['data']['siapa'] == 'ORTU') {
          // Menambahkan daftar anak untuk akun ORTU
          daftarAnakResponse = (responseValidasi['daftarAnak'] == null)
              ? null
              : json.decode(jsonEncode(responseValidasi['daftarAnak']));
          // Convert daftarAnak to List<Anak>
          daftarAnak = daftarAnakResponse
                  ?.map<Anak>((anak) => Anak.fromJson(anak))
                  .toList() ??
              [];

          daftarAnak.add(
            Anak(
              noRegistrasi: userJson['data']['noRegistrasi'],
              namaLengkap: userJson['data']['namaLengkap'],
              nomorHandphone: userJson['data']['nomorHp'],
            ),
          );
        }

        // TODO: jika tamu jadi fix mempunyai produk di beli, maka hapus if else
        // if (_authRole.name.toUpperCase() == "SISWA" ||
        //     _authRole.name.toUpperCase() == "ORTU") {
        // Mendaftarkan produk yg dibeli siswa
        // TODO: ganti nullable / non nullable jika flow tamu sudah jelas
        List<dynamic>? daftarProduk = (responseValidasi['daftarProduk'] == null)
            ? null
            : responseValidasi['daftarProduk'];
        // Convert daftarProduk to List<ProdukDibeli>
        List<ProdukDibeli> daftarProdukDibeli = daftarProduk
                ?.map<ProdukDibeli>(
                    (produkJson) => ProdukDibeli.fromJson(produkJson))
                .toList() ??
            [];

        daftarProdukDibeli
            .sort((a, b) => a.idJenisProduk.compareTo(b.idJenisProduk));

        // Convert jsonUser menjadi UserModel dan store ke global.dart
        // Data di store sementara karena menunggu validasi OTP,
        // jika OTP berhasil baru safe data ke _userModel.
        _userModelTemp = UserModel.fromJson(
          userJson['data'],
          daftarAnak: daftarAnak,
          daftarProduk: daftarProdukDibeli,
          idJurusanPilihan1: (ptnPilihan?['pilihan1'] is int)
              ? (ptnPilihan?['pilihan1'])
              : int.tryParse('${ptnPilihan?['pilihan1']}'),
          idJurusanPilihan2: (ptnPilihan?['pilihan2'] is int)
              ? (ptnPilihan?['pilihan2'])
              : int.tryParse('${ptnPilihan?['pilihan2']}'),
          pekerjaanOrtu: responseValidasi['jobOrtu'],
        );
        // gUser = _userModelTemp!;

        // Store noRegistrasi Siswa/Ortu dan token JWT ke global.dart
        // gNoRegistrasi = gUser.noRegistrasi;
        // } else {
        //   _userModelTemp = UserModel.fromJson(
        //     userJson['data'],
        //     daftarProduk: const [],
        //     idJurusanPilihan1: ptnPilihan?['pilihan1'],
        //     idJurusanPilihan2: ptnPilihan?['pilihan2'],
        //     pekerjaanOrtu: responseData['jobortu'],
        //   );
        // }

        if (kDebugMode) {
          logger.log(
              'AUTH_OTP_PROVIDER-CekValidasiRegistrasi: Register Sebagai >> ${_userModelTemp?.noRegistrasi} | ${_userModelTemp?.namaLengkap} | ${_userModelTemp?.siapa}\n'
              'AUTH_OTP_PROVIDER-CekValidasiRegistrasi: Daftar Anak >> ${_userModelTemp?.daftarAnak}\n'
              'AUTH_OTP_PROVIDER-CekValidasiRegistrasi: Pilihan PTN >> ${_userModelTemp?.idJurusanPilihan1}, ${_userModelTemp?.idJurusanPilihan2}}\n'
              'AUTH_OTP_PROVIDER-CekValidasiRegistrasi: Produk Dibeli >> ${_userModelTemp?.daftarProdukDibeli}');
        }

        // Memunculkan Pesan Sukses
        if (_userModelTemp != null) {
          await gShowTopFlash(
            gNavigatorKey.currentContext!,
            responseValidasi['message'],
            dialogType: DialogType.success,
          );
        } else {
          gShowTopFlash(
            gNavigatorKey.currentContext!,
            'Gagal mengambil data pengguna, coba lagi!',
            duration: const Duration(seconds: 4),
            dialogType: DialogType.error,
          );
        }

        notifyListeners();
        return result;
      } else {
        // Munculkan pesan error
        gShowTopFlash(
          gNavigatorKey.currentContext!,
          responseValidasi['message'],
          duration: const Duration(seconds: 4),
          dialogType: DialogType.error,
        );
      }
      return result;
    } on NoConnectionException catch (e) {
      gShowTopFlash(
        gNavigatorKey.currentContext!,
        gPesanErrorKoneksi,
        dialogType: DialogType.error,
      );
      if (kDebugMode) {
        logger.log('NoConnectionException-CekValidasiRegistrasi: $e');
      }
      return result;
    } on DataException catch (e) {
      gShowTopFlash(
        gNavigatorKey.currentContext!,
        '$e',
        dialogType: DialogType.error,
      );
      if (kDebugMode) {
        logger.log('Exception-CekValidasiRegistrasi: $e');
      }
      return result;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-CekValidasiRegistrasi: $e');
      }
      gShowTopFlash(
        gNavigatorKey.currentContext!,
        gPesanError,
        dialogType: DialogType.error,
      );
      return result;
    }
  }

  /// [login] function untuk request login ke API.<br><br>
  /// [nomorHp] >> Valuenya diambil dari TextFormField.
  /// [otp] >> Didapat dari generateOTP()
  Future<Map<String, dynamic>> login({
    required String otp,
    required String nomorHp,
    String? noRegistrasiRefresh,
    String? userTypeRefresh,
  }) async {
    Map<String, dynamic> mapHasil = {
      'status': false,
      'kirimOTP': false,
      'pesan': _errorNomorHp
    };

    if (nomorHp.isEmpty) {
      gShowTopFlash(gNavigatorKey.currentContext!, _errorNomorHp);
      return mapHasil;
    }

    try {
      _isResend = false;
      _nomorHp = DataFormatter.formatPhoneNumber(phoneNumber: nomorHp);
      String? imei =
          (gAkunTester.contains(nomorHp)) ? gStaticImei : await gGetIdDevice();

      if (kDebugMode) {
        logger.log('AUTH_OTP_PROVIDER-Login: imei >> $imei');
      }

      if (imei == null) mapHasil['pesan'] = gPesanErrorImeiPermission;

      if (imei != null) {
        final responseLogin = await _apiService.login(
          userPhoneNumber: this.nomorHp,
          otp: otp,
          via: otpVia.value.name,
          imei: imei,
          userType: userTypeRefresh,
          noRegistrasi: noRegistrasiRefresh,
        );

        if (kDebugMode) {
          logger.log(
              'AUTH_OTP_PROVIDER-Login: Produk Dibeli >> ${responseLogin['daftarProduk']}\n'
              'AUTH_OTP_PROVIDER-Login: ${responseLogin["status"]} '
              'kirim otp >> ${responseLogin["kirimOTP"]} | ${responseLogin['message']}');
        }

        if (responseLogin["status"]) {
          mapHasil['status'] = true;
          mapHasil['pesan'] = responseLogin['message'];
          mapHasil['kirimOTP'] = responseLogin['kirimOTP'];
          if (kDebugMode) {
            logger.log('AUTH_OTP_PROVIDER-Login: Map Hasil >> $mapHasil');
          }
          // Buat user model dari json yang telah di dapatkan.
          // Data di store sementara karena menunggu validasi OTP,
          // jika OTP berhasil baru safe data ke _userModel.
          _userModelTemp = _responseLoginToUserModel(responseLogin);

          if (responseLogin['kirimOTP']) {
            await _setOTPAndExpireTime(int.parse(responseLogin['waktu']), otp);
          } else {
            _userModel.value = _userModelTemp;
            idSekolahKelas.value = _userModel.value!.idSekolahKelas;
            // Store user model dan no registrasi ke global.dart.
            gUser = _userModel.value!;
            gNoRegistrasi = gUser!.noRegistrasi;

            if (kDebugMode) {
              logger.log(
                  'AUTH_OTP_PROVIDER-Login: Kirim OTP false | UserModel >> ${gUser!.noRegistrasi}, '
                  '${gUser!.namaLengkap}, ${gUser!.idSekolahKelas} | TOKEN JWT >> $gTokenJwt');
            }
          }

          // Store token JWT ke global.dart
          gTokenJwt = responseLogin['tokenJWT'];
          // Memunculkan Pesan Sukses jika bukan dari refresh profile.
          if (noRegistrasiRefresh == null) {
            await gShowTopFlash(
              gNavigatorKey.currentContext!,
              (responseLogin['kirimOTP'])
                  ? 'Silahkan Input OTP'
                  : 'Selamat Datang ${_userModelTemp?.namaLengkap}',
              dialogType: DialogType.success,
            );

            if (!responseLogin['kirimOTP']) {
              await Future.delayed(gDelayedNavigation);
              AppProviders.disposeAllDisposableProviders(
                  gNavigatorKey.currentState!.context);
            }
          }
          notifyListeners();
        } else {
          mapHasil['pesan'] = responseLogin['message'];
          // Memunculkan Pesan Error
          gShowBottomDialogInfo(
            gNavigatorKey.currentContext!,
            title: (responseLogin['data'] != null)
                ? responseLogin['message']
                : null,
            message: responseLogin['data'] ?? responseLogin['message'],
          );
        }
      }
      return mapHasil;
    } on NoConnectionException catch (e) {
      gShowTopFlash(
        gNavigatorKey.currentContext!,
        gPesanErrorKoneksi,
        dialogType: DialogType.error,
      );
      if (kDebugMode) {
        logger.log('NoConnectionException-Login: $e');
      }
      mapHasil['status'] = false;
      mapHasil['kirimOTP'] = false;
      mapHasil['pesan'] = gPesanErrorKoneksi;
      return mapHasil;
    } on DataException catch (e) {
      if (kDebugMode) logger.log('Exception-Login: $e');
      gShowTopFlash(
        gNavigatorKey.currentContext!,
        '$e',
        dialogType: DialogType.error,
      );
      mapHasil['status'] = false;
      mapHasil['kirimOTP'] = false;
      mapHasil['pesan'] = '$e';
      return mapHasil;
    } catch (e) {
      if (kDebugMode) logger.log('FatalException-Login: ${e.toString()}');
      gShowTopFlash(
        gNavigatorKey.currentContext!,
        gPesanError,
        dialogType: DialogType.error,
      );
      mapHasil['status'] = false;
      mapHasil['kirimOTP'] = false;
      mapHasil['pesan'] = gPesanError;
      return mapHasil;
    }
  }

  UserModel _responseLoginToUserModel(Map<String, dynamic> response) {
    // Menambahkan daftar anak untuk akun ORTU
    List<dynamic>? daftarAnakResponse =
        (response['daftarAnak'] == null || response['data']['siapa'] != 'ORTU')
            ? null
            : json.decode(jsonEncode(response['daftarAnak']));

    //mendaftarkan produk yg dibeli siswa
    // TODO: ganti nullable / non nullable jika flow tamu sudah jelas
    List<dynamic>? daftarProduk =
        json.decode(jsonEncode(response['daftarProduk']));

    // Decode Object ptn pilihan
    Map<String, dynamic>? ptnPilihan = (response['pilihanPTN'] != null &&
            (response['pilihanPTN']?.isNotEmpty ?? false))
        ? json.decode(response['pilihanPTN'])
        : null;

    if (kDebugMode) {
      logger.log(
          'AUTH_OTP_PROVIDER-ResponseLoginToUserModel: PTN Pilihan Json Decode >> $ptnPilihan | '
          '${ptnPilihan?['pilihan1'] is String} | ${ptnPilihan?['pilihan2'] is String}\n'
          'AUTH_OTP_PROVIDER-ResponseLoginToUserModel: Produk Dibeli Json Decode >> $daftarProduk\n'
          'AUTH_OTP_PROVIDER-ResponseLoginToUserModel: Daftar Anak Json Decode >> $daftarAnakResponse');
    }

    // Convert daftarAnak to List<Anak>
    List<Anak> daftarAnak =
        daftarAnakResponse?.map<Anak>((anak) => Anak.fromJson(anak)).toList() ??
            [];

    // Convert daftarProduk to List<ProdukDibeli>
    List<ProdukDibeli> daftarProdukDibeli = daftarProduk
            ?.map<ProdukDibeli>(
                (produkJson) => ProdukDibeli.fromJson(produkJson))
            .toList() ??
        [];

    daftarProdukDibeli
        .sort((a, b) => a.idJenisProduk.compareTo(b.idJenisProduk));

    /// [_userJson] merupakan json User Data yang di dapat dari hasil decode dari Token JWT
    var userJson = JwtDecoder.decode(response['tokenJWT']);

    if (kDebugMode) {
      logger.log(
          'AUTH_OTP_PROVIDER-ResponseLoginToUserModel: UserModel >> ${userJson['data']}');
    }
    return UserModel.fromJson(
      userJson['data'],
      daftarAnak: daftarAnak,
      daftarProduk: daftarProdukDibeli,
      idJurusanPilihan1: (ptnPilihan?['pilihan1'] is int)
          ? (ptnPilihan?['pilihan1'])
          : int.tryParse('${ptnPilihan?['pilihan1']}'),
      idJurusanPilihan2: (ptnPilihan?['pilihan2'] is int)
          ? (ptnPilihan?['pilihan2'])
          : int.tryParse('${ptnPilihan?['pilihan2']}'),
      pekerjaanOrtu: response['jobOrtu'],
    );
  }

  Future<bool> simpanRegistrasi() async {
    try {
      String? imei =
          (gAkunTester.contains(nomorHp)) ? gStaticImei : await gGetIdDevice();
      if (imei == null) {
        return false;
      }
      final response = await _apiService.simpanRegistrasi(imei: imei);

      if (kDebugMode) {
        logger.log('AUTH_OTP_PROVIDER-SimpanRegistrasi: Response >> $response');
      }
      if (response["status"]) {
        // Pindahkan userModelTemp ke userModel dan
        _userModel.value = _userModelTemp;
        idSekolahKelas.value = _userModel.value!.idSekolahKelas;

        // token jwt jika userType nya TAMU. Dikirim dari simpan registrasi
        // karena pada cek validasi registrasi, no registrasi tamu belum ter-generate.
        if (response["tokenJWT"] != "") {
          // Update toke jwt tamu.
          gTokenJwt = response['tokenJWT'];

          // mengambil data User dari token JWT
          Map<String, dynamic> userJson =
              JwtDecoder.decode(response['tokenJWT']);

          // Decode Object ptn pilihan
          Map<String, dynamic>? ptnPilihan = (response['pilihanPTN'] != null &&
                  (response['pilihanPTN']?.isNotEmpty ?? false))
              ? json.decode(response['pilihanPTN'])
              : null;

          // Update user model jika dari Tamu.
          _userModel.value = UserModel.fromJson(
            userJson['data'],
            daftarAnak: const [],
            daftarProduk: _userModel.value?.daftarProdukDibeli ?? const [],
            idJurusanPilihan1: (ptnPilihan?['pilihan1'] is int)
                ? (ptnPilihan?['pilihan1'])
                : int.tryParse('${ptnPilihan?['pilihan1']}'),
            idJurusanPilihan2: (ptnPilihan?['pilihan2'] is int)
                ? (ptnPilihan?['pilihan2'])
                : int.tryParse('${ptnPilihan?['pilihan2']}'),
            pekerjaanOrtu: response['jobOrtu'],
          );
          idSekolahKelas.value = _userModel.value!.idSekolahKelas;
        }
        // Store UserModel ke global.dart
        gUser = _userModel.value!;

        // Store noRegistrasi Siswa/Ortu ke global.dart
        gNoRegistrasi = gUser!.noRegistrasi;

        // Memunculkan Pesan Sukses
        if (response["message"] != "") {
          String pesanSelamatDatang = 'Selamat Datang ';
          pesanSelamatDatang += (_userModel.value!.nomorHpOrtu == nomorHp)
              ? 'Bpk/Ibu dari ${_userModel.value!.namaLengkap}'
              : _userModel.value!.namaLengkap;

          // Memunculkan Pesan Sukses
          gShowTopFlash(
            gNavigatorKey.currentContext!,
            pesanSelamatDatang,
            dialogType: DialogType.success,
          );
        }

        await Future.delayed(gDelayedNavigation);
        AppProviders.disposeAllDisposableProviders(
            gNavigatorKey.currentState!.context);
        notifyListeners();
        return response["status"];
      } else {
        // Memunculkan Pesan Error
        gShowTopFlash(
          gNavigatorKey.currentContext!,
          response["message"],
          dialogType: DialogType.error,
        );
        return false;
      }
    } on NoConnectionException catch (e) {
      if (kDebugMode) logger.log('NoConnectionException-SimpanRegistrasi: $e');
      // Memunculkan Pesan Error
      gShowTopFlash(
        gNavigatorKey.currentContext!,
        gPesanErrorKoneksi,
        dialogType: DialogType.error,
      );
      return false;
    } on DataException catch (e) {
      if (kDebugMode) logger.log('Exception-SimpanRegistrasi: $e');
      // Memunculkan Pesan Error
      gShowTopFlash(
        gNavigatorKey.currentContext!,
        '$e',
        dialogType: DialogType.error,
      );
      return false;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-SimpanRegistrasi: ${e.toString()}');
      }
      // Memunculkan Pesan Error
      gShowTopFlash(
        gNavigatorKey.currentContext!,
        gPesanError,
        dialogType: DialogType.error,
      );
      return false;
    }
  }

  Future<bool> simpanLogin({String? jwtSwitchOrtu}) async {
    try {
      String? imei = (gAkunTester.contains(nomorHp))
          ? gStaticImei
          : (gDeviceID.isNotEmpty)
              ? gDeviceID
              : await gGetIdDevice();
      if (imei == null || _nomorHp == null) {
        return false;
      }
      final bool isBerhasilSimpan = await _apiService.simpanLogin(
        nomorHp: nomorHp,
        imei: imei,
        noRegistrasi: _userModelTemp?.noRegistrasi ?? '-',
        siapa: _userModelTemp?.siapa ?? 'No User',
        jwtSwitchOrtu: jwtSwitchOrtu,
      );

      if (isBerhasilSimpan) {
        // Pindahkan userModelTemp ke userModel dan
        // Store UserModel ke global.dart
        _userModel.value = _userModelTemp;
        idSekolahKelas.value = _userModel.value!.idSekolahKelas;
        gUser = _userModel.value!;

        // Store noRegistrasi Siswa/Ortu ke global.dart
        gNoRegistrasi = gUser!.noRegistrasi;

        String pesanSelamatDatang = 'Selamat Datang ';
        pesanSelamatDatang += _userModel.value!.nomorHpOrtu == nomorHp
            ? 'Bpk/Ibu dari ${_userModel.value!.namaLengkap}'
            : _userModel.value!.namaLengkap;

        // Memunculkan Pesan Sukses
        gShowTopFlash(
          gNavigatorKey.currentContext!,
          pesanSelamatDatang,
          dialogType: DialogType.success,
        );

        await FirebaseHelper().updateImeiLogin(
          noRegistrasi: _userModel.value!.noRegistrasi,
          userType: _userModel.value!.siapa,
          deviceId: imei,
        );
        await Future.delayed(gDelayedNavigation);
        AppProviders.disposeAllDisposableProviders(
            gNavigatorKey.currentState!.context);
        notifyListeners();
        return isBerhasilSimpan;
      } else {
        // Memunculkan Pesan Error
        return gShowBottomDialog(gNavigatorKey.currentContext!,
            title: 'Terjadi Kesalahan',
            message: 'Gagal menyimpan data login, coba lagi!\n'
                'Terjadi karena masalah koneksi jaringan',
            barrierDismissible: false,
            actions: (controller) => [
                  TextButton(
                      onPressed: () async =>
                          controller.dismiss(await simpanLogin()),
                      child: const Text('Coba Lagi'))
                ]);
      }
    } on NoConnectionException catch (e) {
      if (kDebugMode) logger.log('NoConnectionException-SimpanLogin: $e');
      // Memunculkan Pesan Error
      gShowTopFlash(
        gNavigatorKey.currentContext!,
        gPesanErrorKoneksi,
        dialogType: DialogType.error,
      );
      return false;
    } on DataException catch (e) {
      if (kDebugMode) logger.log('Exception-SimpanLogin: $e');
      // Memunculkan Pesan Error
      gShowTopFlash(
        gNavigatorKey.currentContext!,
        '$e',
        dialogType: DialogType.error,
      );
      return false;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-SimpanLogin: ${e.toString()}');
      }
      // Memunculkan Pesan Error
      gShowTopFlash(
        gNavigatorKey.currentContext!,
        gPesanError,
        dialogType: DialogType.error,
      );
      return false;
    }
  }

  Future<UserModel?> refreshUserData() async {
    try {
      // Get user data
      _userModel.value = await KreasiSharedPref().getUser();

      if (kDebugMode) {
        logger.log(
            'AUTH_OTP_PROVIDER-RefreshUserData: ${userData?.noRegistrasi} | ${userData?.namaLengkap}');
        logger.log(
            'AUTH_OTP_PROVIDER-RefreshUserData: Produk >> ${userData?.daftarProdukDibeli}');
        logger.log(
            'AUTH_OTP_PROVIDER-RefreshUserData: is user model exist >> ${userData != null}');
      }

      if (_userModel.value != null) {
        notifyListeners();
      }

      return _userModel.value;
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-RefreshUserData: $e');
      }
      return null;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-RefreshUserData: $e');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-RefreshUserData: $e');
      }
      return null;
    }
  }

  Future<UserModel?> checkIsLogin(
      [BuildContext? context, bool checkFromMain = false]) async {
    try {
      // Mengambil data tahun ajaran default
      if (_tahunAjaran == null) {
        final responseData = await _apiService.fetchDefaultTahunAjaran();
        _tahunAjaran = responseData;

        if (kDebugMode) {
          logger.log(
              'AUTH_OTP_PROVIDER-GetDefaultTahunAjaran: response data >> $responseData');
          logger.log(
              'AUTH_OTP_PROVIDER-GetDefaultTahunAjaran: Tahun Ajaran >> $_tahunAjaran');
        }
      }

      // Get ServerTime Offset setiap membuka aplikasi
      await gSetServerTimeOffset();

      // Get user data
      _userModel.value = await KreasiSharedPref().getUser();
      idSekolahKelas.value =
          (await KreasiSharedPref().getPilihanKelas())?['id'] ?? '14';
      // Function di panggil 2x karena saat SplashScreen
      // get data pertama kali bernilai null, dan menyebabkan logout.
      for (int i = 0; i < 3; i++) {
        if (_userModel.value != null) continue;
        _userModel.value ??= await KreasiSharedPref().getUser();
      }
      for (int i = 0; i < 3; i++) {
        if (idSekolahKelas.value != null) continue;
        idSekolahKelas.value =
            (await KreasiSharedPref().getPilihanKelas())?['id'] ?? '14';
      }

      if (kDebugMode) {
        logger.log(
            'AUTH_OTP_PROVIDER-CheckIsLogin: no reg >> ${userData?.namaLengkap} '
            '| ${userData?.noRegistrasi} | ${userData?.siapa}');
        logger.log(
            'AUTH_OTP_PROVIDER-CheckIsLogin: daftar anak >> ${userData?.daftarAnak}');
        logger.log('AUTH_OTP_PROVIDER-CheckIsLogin: pilihan PTN >> '
            '${userData?.idJurusanPilihan1}, ${userData?.idJurusanPilihan2}');
        logger.log(
            'AUTH_OTP_PROVIDER-CheckIsLogin: user model >> ${_userModel.value}');
      }

      if (_userModel.value == null) return null;

      final String? responseImei = await _apiService.fetchImei(
        noRegistrasi: userData?.noRegistrasi,
        siapa: userData?.siapa,
      );

      String? localImei = (gAkunTester.contains(userData?.siapa == 'ORTU'
              ? userData?.nomorHpOrtu
              : userData?.nomorHp))
          ? gStaticImei
          : await gGetIdDevice();

      if (kDebugMode) {
        logger.log('AUTH_OTP_PROVIDER-CheckIsLogin: $responseImei : $localImei '
            '>> ${responseImei == localImei}');
      }

      if (localImei != null && responseImei != localImei) {
        await KreasiSharedPref().logout();
        _userModel.value = null;

        AppProviders.disposeAllDisposableProviders(
            context ?? gNavigatorKey.currentContext!);
        if (checkFromMain) notifyListeners();
        // Setelah logout auto balik ke MainScreen.
        Navigator.of(gNavigatorKey.currentContext!)
            .popUntil((route) => route.isFirst);
        return null;
      }
      // if (checkFromMain) notifyListeners();
      gUser = _userModel.value;
      return _userModel.value;
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-CheckIsLogin: $e');
      }
      return null;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-CheckIsLogin: $e');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-CheckIsLogin: $e');
      }
      return null;
    }
  }

  // // Fetch Tahun Ajaran Default
  // Future<String> getDefaultTahunAjaran() async {
  //   if (_tahunAjaran != null) {
  //     return _tahunAjaran!;
  //   }
  //   try {
  //     if (kDebugMode) {
  //       logger.log('AUTH_OTP_PROVIDER-GetDefaultTahunAjaran: START DELAYED');
  //     }
  //     if (_tahunAjaran == null) {
  //       final responseData = await _apiService.fetchDefaultTahunAjaran();
  //       _tahunAjaran = responseData;
  //
  //       if (kDebugMode) {
  //         logger.log(
  //             'AUTH_OTP_PROVIDER-GetDefaultTahunAjaran: response data >> $responseData');
  //         logger.log(
  //             'AUTH_OTP_PROVIDER-GetDefaultTahunAjaran: Tahun Ajaran >> $_tahunAjaran');
  //       }
  //     }
  //     return tahunAjaran;
  //   } on NoConnectionException catch (e) {
  //     if (kDebugMode) {
  //       logger.log('NoConnectionException-GetDefaultTahunAjaran: $e');
  //     }
  //     return tahunAjaran;
  //   } on DataException catch (e) {
  //     if (kDebugMode) {
  //       logger.log('Exception-GetDefaultTahunAjaran: $e');
  //     }
  //     return tahunAjaran;
  //   } catch (e) {
  //     if (kDebugMode) {
  //       logger.log('FatalException-GetDefaultTahunAjaran: $e');
  //     }
  //     // throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti';
  //     return tahunAjaran;
  //   }
  // }
}
