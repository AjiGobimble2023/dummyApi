// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer' as logger;
import 'dart:math';

import 'package:flash/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../widget/login_form_widget.dart';
import '../widget/sign_up_form_widget.dart';
import '../provider/auth_otp_provider.dart';
import '../../../profile/presentation/provider/profile_provider.dart';
import '../../../profile/presentation/widget/auth/tata_tertib_widget.dart';
import '../../../../core/config/enum.dart';
import '../../../../core/config/global.dart';
import '../../../../core/config/constant.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/util/data_formatter.dart';
import '../../../../core/helper/firebase_helper.dart';
import '../../../../core/helper/kreasi_shared_pref.dart';
import '../../../../core/shared/builder/responsive_builder.dart';

class AuthScreen extends StatefulWidget {
  final AuthMode authMode;

  const AuthScreen({Key? key, required this.authMode}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Local Variable
  bool _login = true;

  final _scrollController = ScrollController();
  late final _navigator = Navigator.of(context);
  late final AuthOtpProvider _authOtpProvider = context.read<AuthOtpProvider>();

  // Form Controller And Notifier
  final _loginFormKey = GlobalKey<FormState>();
  final _regisFormKey = GlobalKey<FormState>();

  final _pilihanRole = ValueNotifier<AuthRole>(AuthRole.siswa);
  final _noHpController = TextEditingController();
  final _noRegistrasiController = TextEditingController();
  final _namaLengkapController = TextEditingController();
  final _emailController = TextEditingController();
  final _tanggalLahirController = TextEditingController();

  @override
  void dispose() {
    _pilihanRole.dispose();
    _noHpController.dispose();
    _noRegistrasiController.dispose();
    _namaLengkapController.dispose();
    _emailController.dispose();
    _tanggalLahirController.dispose();

    if (kDebugMode) {
      logger.log('USER_INFO_APP_BAR: On Click Navigate to Main Screen');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            width: context.dw,
            height: context.dh,
            padding: EdgeInsets.only(
              top: (context.isMobile) ? context.dp(38) : 32,
              right: (context.isMobile) ? context.dp(20) : 14,
              left: min(32, context.dp(20)),
              bottom: (context.isMobile) ? context.dp(30) : 32,
            ),
            child: ResponsiveBuilder(
              mobile: Column(
                children: [
                  _buildAnimatedImage(context),
                  _buildForm(context),
                  _buildMasukDaftarButton(context),
                ],
              ),
              tablet: Row(
                children: [
                  _buildAnimatedImage(context),
                  Expanded(
                    child: Scrollbar(
                      controller: _scrollController,
                      thickness: 8,
                      thumbVisibility: true,
                      trackVisibility: true,
                      radius: const Radius.circular(14),
                      child: ListView(
                        controller: _scrollController,
                        padding: const EdgeInsets.only(
                          left: 12,
                          right: 12,
                        ),
                        children: [
                          _buildForm(context),
                          const SizedBox(height: 32),
                          _buildMasukDaftarButton(context),
                          const SizedBox(height: 82),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// NOTE: Tempat function - function fungsional-------------------------------
  void _onClickedChangeLogin() => setState(() => _login = !_login);

  /// [_onClickedMasuk] Function on click Masuk Button
  void _onClickedMasuk(BuildContext context) async {
    if (!_login) {
      _onClickedChangeLogin();
      return;
    }
    if (_noHpController.text.isEmpty) {
      gShowTopFlash(
          context,
          (_pilihanRole.value.name == 'siswa')
              ? 'Isi dulu nomor HP kamu ya Sobat'
              : 'Mohon isi terlebih dahulu nomor HP anda');
      return;
    }
    var completer = Completer();
    try {
      context.showBlockDialog(dismissCompleter: completer);

      // Jika di tampung di dalam late final, maka hasil generate OTP akan sama,
      // Kecuali keluar dari AuthScreen terlebih dahulu.
      // Hal tersebut dikarenakan hasil generate OTP sudah di store pada variable late final.
      final otp = await _authOtpProvider
          .generateOTP()
          .onError((error, stackTrace) async {
        if (kDebugMode) {
          logger.log(
              'AUTH_SCREEN: ERROR generateOTP >> $error\nSTACKTRACE: $stackTrace');
        }
        gShowTopFlash(context, 'Gagal Memuat OTP',
            dialogType: DialogType.error);
        // generate ulang OTP
        return await _authOtpProvider.generateOTP();
      });

      Map<String, dynamic> loginResponse = await _authOtpProvider.login(
        otp: otp,
        nomorHp: DataFormatter.formatPhoneNumber(
          phoneNumber: _noHpController.text,
        ),
      );

      if (kDebugMode) {
        logger.log(
            'AUTH_SCREEN-ON_CLICK_MASUK: Nomor HP >> ${_authOtpProvider.nomorHp}');
        logger.log('AUTH_SCREEN-ON_CLICK_MASUK: Generate OTP >> $otp');
        logger.log(
            'AUTH_SCREEN-ON_CLICK_MASUK: Request Login Response >> $loginResponse');
      }

      completer.complete();
      if (!loginResponse['status']) {
        return;
      }
      if (loginResponse['kirimOTP']) {
        _navigator.pushNamed(Constant.kRouteOTPScreen,
            arguments: {'isLogin': _login});
      } else {
        // Simpan data user di local storage agar persistent.
        await KreasiSharedPref().simpanDataLokal();

        if (kDebugMode) logger.log("MASUK HOME SCREEN");
        // Navigate ke HOME SCREEN
        Future.delayed(gDelayedNavigation).then((_) {
          _navigator.popUntil((route) => route.isFirst);
          Future.delayed(gDelayedNavigation).then((value) {
            var context = gNavigatorKey.currentContext!;
            final userData = context.read<AuthOtpProvider>().userData;
            // Stream check login firebase
            FirebaseHelper().streamCheckLogin(
              noRegistrasi: userData?.noRegistrasi,
              userType: userData?.siapa ?? '',
              deviceId: (gAkunTester.contains((userData?.isOrtu ?? false)
                      ? '${userData?.nomorHpOrtu}'
                      : '${userData?.nomorHp}'))
                  ? gStaticImei
                  : gDeviceID,
              logout: () async =>
                  await context.read<AuthOtpProvider>().logout(),
            );
          });
        });
      }
    } catch (e) {
      if (kDebugMode) logger.log('AUTH_SCREEN: ERROR _onClickedMasuk >> $e');
      if (!completer.isCompleted) completer.complete();
    }
  }

  /// [_onClickedDaftar] Function on click Daftar Button
  void _onClickedDaftar(BuildContext context) async {
    if (_login) {
      _onClickedChangeLogin();
      return;
    }

    if (kDebugMode) {
      logger.log('AUTH_SCREEN-ON_CLICK_REGISTER: User Input >> '
          '(${_noRegistrasiController.text}, ${_noHpController.text}, '
          '${_pilihanRole.value.name})');
      logger.log('AUTH_SCREEN-ON_CLICK_REGISTER: User Input Tamu >> '
          '(${_emailController.text},'
          ' ${_namaLengkapController.text},'
          '${_tanggalLahirController.text})');
    }

    if (_noRegistrasiController.text.isEmpty &&
        _pilihanRole.value.name != 'tamu') {
      if (_pilihanRole.value.name == 'siswa') {
        gShowTopFlash(context, 'Isi dulu no registrasi kamu ya Sobat');
      } else {
        gShowBottomDialogInfo(context,
            dialogType: DialogType.error,
            message:
                'Mohon isi terlebih dahulu no registrasi putra/putri anda');
      }
      return;
    }
    if (_noHpController.text.isEmpty) {
      if (_pilihanRole.value.name == 'ortu') {
        gShowBottomDialogInfo(context,
            dialogType: DialogType.error,
            message: 'Mohon isi terlebih dahulu nomor handphone anda');
      } else {
        gShowTopFlash(context, 'Isi dulu nomor HP kamu ya Sobat');
      }
      return;
    }
    if (_pilihanRole.value.name.isEmpty) {
      gShowTopFlash(context, 'Mohon pilih daftar sebagai apa');
      return;
    }
    if (_pilihanRole.value.name == 'tamu') {
      if (_authOtpProvider.idSekolahKelas.value?.isEmpty ?? true) {
        gShowTopFlash(context, 'Pilih dulu tingkat kelas kamu ya Sobat');
        return;
      }
      if (_namaLengkapController.text.isEmpty) {
        gShowTopFlash(context, 'Isi dulu nama kamu ya Sobat');
        return;
      }
      if (_emailController.text.isEmpty) {
        gShowTopFlash(context, 'Isi dulu email kamu ya Sobat');
        return;
      }
      if (_tanggalLahirController.text.isEmpty) {
        gShowTopFlash(context, 'Isi dulu tanggal lahir kamu ya Sobat');
        return;
      }
    }

    var completerAturan = Completer();

    context.showBlockDialog(dismissCompleter: completerAturan);

    // Jika di tampung di dalam late final, maka hasil generate OTP akan sama,
    // Kecuali keluar dari AuthScreen terlebih dahulu.
    // Hal tersebut dikarenakan hasil generate OTP sudah di store pada variable late final.
    final otp = await _authOtpProvider.generateOTP().onError(
      (error, stackTrace) async {
        if (kDebugMode) {
          logger.log(
              'AUTH_SCREEN: ERROR generateOTP >> $error\nSTACKTRACE: $stackTrace');
        }
        gShowTopFlash(context, 'Gagal Memuat OTP',
            dialogType: DialogType.error);
        // generate ulang OTP
        return await _authOtpProvider.generateOTP();
      },
    );

    bool isOrtu = _pilihanRole.value.name.equalsIgnoreCase('ortu');
    bool isTamu = _pilihanRole.value.name.equalsIgnoreCase('tamu');

    bool isSetujuAturan = (isTamu)
        ? true
        : await context.read<ProfileProvider>().loadAturanSiswa(
              noRegistrasi: _noRegistrasiController.text,
              tipeUser: _pilihanRole.value.name.toUpperCase(),
            );

    if (!completerAturan.isCompleted) {
      completerAturan.complete();
    }

    if (!isSetujuAturan) {
      isSetujuAturan = (await showModalBottomSheet<bool>(
            context: context,
            isDismissible: true,
            isScrollControlled: true,
            constraints: BoxConstraints(
              minHeight: 10,
              maxHeight: context.dh * 0.9,
              maxWidth: (context.isMobile) ? context.dw : 650,
            ),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            builder: (context) => TataTertibWidget(
              noRegistrasi: _noRegistrasiController.text,
              tipeUser: _pilihanRole.value.name.toUpperCase(),
            ),
          )) ??
          false;
    }

    if (isSetujuAturan || isTamu) {
      var completerRegistrasi = Completer();

      Future.delayed(
        gDelayedNavigation,
        () => context.showBlockDialog(dismissCompleter: completerRegistrasi),
      );

      Map<String, dynamic> responseRegister =
          await context.read<AuthOtpProvider>().cekValidasiRegistrasi(
                otp: otp,
                noRegistrasi: DataFormatter.formatNIS(
                  roleIndex: 0,
                  userId: _noRegistrasiController.text,
                ),
                nomorHp: DataFormatter.formatPhoneNumber(
                  phoneNumber: _noHpController.text,
                ),
                namaLengkap: _namaLengkapController.text,
                email: _emailController.text,
                authRole: _pilihanRole.value,
                ttl: (_tanggalLahirController.text.isNotEmpty)
                    ? DataFormatter.dateTimeToString(
                        DataFormatter.stringToDate(
                            _tanggalLahirController.text, 'dd MMM yyyy'),
                        'yyyy-MM-dd',
                      )
                    : null,
              );

      bool isValidToRegister = responseRegister['status'];
      if (kDebugMode) {
        logger.log('AUTH_SCREEN-ON_CLICK_REGISTER: Generate OTP >> $otp');
        logger.log(
            'AUTH_SCREEN-ON_CLICK_REGISTER: Cek Validasi Response >> $isValidToRegister');
      }

      if (!completerRegistrasi.isCompleted) {
        completerRegistrasi.complete();
      }

      if (isValidToRegister) {
        if (responseRegister['message'] == "Sudah pernah terdaftar") {
          /// Jika Sudah pernah mendaftar dan imeinya sama maka langsung memanggil fungsi login

          await _authOtpProvider.login(
            otp: otp,
            nomorHp: _noHpController.text,
          );
          await KreasiSharedPref().simpanDataLokal();
          if (kDebugMode) {
            logger.log("MASUK HOME SCREEN");
          }
          Future.delayed(gDelayedNavigation)
              .then((value) => _navigator.popUntil((route) => route.isFirst));
        } else {
          Future.delayed(
            gDelayedNavigation,
            () => _navigator.pushNamed(Constant.kRouteOTPScreen,
                arguments: {'isLogin': _login}),
          );
        }
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 600));
      if (!isSetujuAturan) {
        gShowBottomDialogInfo(
          context,
          message:
              'Untuk mendaftar GO Kreasi, ${isOrtu ? 'anda' : 'kamu'} harus menyetujui peraturan '
              'tata tertib yang berlaku di Ganesha Operation!',
        );
      }
    }
  }

  /// NOTE: Tempat function - function fungsional END---------------------------

  /// NOTE: Kumpulan function widget--------------------------------------------
  // Animated Image Header
  Widget _buildAnimatedImage(BuildContext context) {
    double imgHeightLogin = (context.dh < 550)
        ? context.h(280)
        : (context.dh < 690)
            ? context.h(310)
            : context.h(350);
    double imgHeightTamu = (context.dh < 550)
        ? context.h(80)
        : (context.dh < 690)
            ? context.h(100)
            : context.h(150);
    double imgHeightRegis = (context.dh < 550)
        ? context.h(200)
        : (context.dh < 690)
            ? context.h(220)
            : context.h(300);

    if (!context.isMobile) {
      imgHeightLogin = min(660, context.dh);
      imgHeightTamu = min(660, context.dh);
      imgHeightRegis = min(660, context.dh);
    }

    return ValueListenableBuilder<AuthRole>(
      valueListenable: _pilihanRole,
      builder: (context, pilihanRole, child) {
        bool isTamu = pilihanRole == AuthRole.tamu;

        return AnimatedContainer(
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 500),
          width: ((context.isMobile) ? context.dw : context.dw / 2) -
              context.dp(40),
          height: _login
              ? imgHeightLogin
              : isTamu
                  ? imgHeightTamu
                  : imgHeightRegis,
          alignment:
              (context.isMobile) ? Alignment.center : Alignment.bottomCenter,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(context.dp(18)),
            gradient: LinearGradient(
              colors: [
                context.primaryColor,
                const Color(0xFFF25C38),
                context.secondaryColor,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.2, 0.4, 1],
            ),
            image: DecorationImage(
              image: const CachedNetworkImageProvider(
                  'https://firebasestorage.googleapis.com/v0/b/kreasi-f1f7b.appspot.com/o/ilustrasi%2Filustrasi_auth.png?alt=media',
                  cacheKey: 'AUTH-ILLUSTRATION'),
              fit: BoxFit.fitWidth,
              alignment: (context.isMobile)
                  ? Alignment.topCenter
                  : Alignment.bottomCenter,
              onError: (error, stackTrace) {
                if (kDebugMode) {
                  logger.log(
                      'AUTH_SCREEN: ERROR CachedNetworkImageProvider {\nError: $error\nStackTrace:$stackTrace}');
                }
              },
            ),
          ),
        );
      },
    );
  }

  // Animated Form
  Widget _buildForm(BuildContext context) {
    Widget animatedSwitcher = AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _login
          ? Form(
              key: _loginFormKey,
              child: LoginFormWidget(
                key: const Key('Login-Form-Widget'),
                nomorHandphoneTextController: _noHpController,
              ),
            )
          : Form(
              key: _regisFormKey,
              child: SignUpFormWidget(
                key: const Key('Sign-Up-Form-Widget'),
                pilihanRoleController: _pilihanRole,
                noRegistrasiController: _noRegistrasiController,
                nomorHandphoneController: _noHpController,
                namaLengkapController: _namaLengkapController,
                emailController: _emailController,
                tanggalLahirController: _tanggalLahirController,
              ),
            ),
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
    );

    return (context.isMobile)
        ? Expanded(child: animatedSwitcher)
        : animatedSwitcher;
  }

  // Animated Button Login dan Sign-Up
  Container _buildMasukDaftarButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: (context.isMobile) ? context.dp(62) : context.dp(32),
      clipBehavior: Clip.hardEdge,
      margin: EdgeInsets.symmetric(horizontal: context.dp(30)),
      decoration: BoxDecoration(
        color: context.primaryColor,
        borderRadius: (context.isMobile)
            ? BorderRadius.circular(20)
            : BorderRadius.circular(32),
      ),
      child: LayoutBuilder(builder: (context, constraint) {
        double buttonWidth = (context.isMobile)
            ? (context.dw - context.dp(100)) / 2
            : constraint.maxWidth / 2;

        return Stack(
          children: [
            AnimatedAlign(
              curve: Curves.easeOut,
              duration: const Duration(milliseconds: 500),
              alignment: _login ? Alignment.centerLeft : Alignment.centerRight,
              child: Container(
                width: buttonWidth,
                decoration: BoxDecoration(
                  color: context.secondaryColor,
                  borderRadius: (context.isMobile)
                      ? BorderRadius.circular(20)
                      : BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: context.disableColor,
                      blurRadius: 4,
                      spreadRadius: 0,
                      offset: const Offset(-2, 0),
                    ),
                    BoxShadow(
                      color: context.disableColor,
                      blurRadius: 4,
                      spreadRadius: 0,
                      offset: const Offset(2, 0),
                    )
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              heightFactor: context.dp(62),
              widthFactor: buttonWidth,
              child: TextButton(
                onPressed: () => _onClickedMasuk(context),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical:
                        (context.isMobile) ? context.dp(16) : context.dp(10),
                    horizontal:
                        (context.isMobile) ? context.dp(40) : context.dp(24),
                  ),
                ),
                child: Text(
                  'Masuk',
                  style: context.text.headlineSmall
                      ?.copyWith(fontSize: (context.isMobile) ? 20 : 17),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              heightFactor: context.dp(62),
              widthFactor: buttonWidth,
              child: TextButton(
                onPressed: () => _onClickedDaftar(context),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical:
                        (context.isMobile) ? context.dp(16) : context.dp(10),
                    horizontal:
                        (context.isMobile) ? context.dp(40) : context.dp(24),
                  ),
                ),
                child: Text(
                  'Daftar',
                  style: context.text.headlineSmall
                      ?.copyWith(fontSize: (context.isMobile) ? 20 : 17),
                ),
              ),
            )
          ],
        );
      }),
    );
  }

  /// NOTE: Kumpulan function widget END----------------------------------------
}
