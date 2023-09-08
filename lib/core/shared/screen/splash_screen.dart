import 'dart:developer' as logger show log;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

import 'pilih_kelas_screen.dart';
import '../../config/global.dart';
import '../../config/constant.dart';
import '../../config/extensions.dart';
import '../../util/platform_channel.dart';
import '../../helper/firebase_helper.dart';
import '../../helper/kreasi_shared_pref.dart';
// import '../../helper/kreasi_secure_storage.dart';
import '../../../features/auth/model/user_model.dart';
import '../../../features/home/presentation/provider/data_provider.dart';
import '../../../features/auth/presentation/provider/auth_otp_provider.dart';

/// [SplashScreen] ini akan menampilkan iklan selama minimal 2 detik.
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final Future<Map<String, dynamic>?> _getPilihanKelas =
      KreasiSharedPref().getPilihanKelas();

  @override
  void initState() {
    PlatformChannel.setSecureScreen('POP', true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    gGetDeviceInfo();
    // Set Device Orientation
    gSetDeviceOrientations(isLandscape: !context.isMobile);
    if (kDebugMode) {
      logger.log('SPLASH_SCREEN-Build: Size '
          '${context.dw.toStringAsFixed(2)} x ${context.dh.toStringAsFixed(2)}');
      logger.log('SPLASH_SCREEN-Build: Size Ratio '
          '${(context.dw / context.dh).toStringAsFixed(2)}');
    }

    return FutureBuilder<bool>(
      future: context.read<DataProvider>().checkUpdateVersion(),
      builder: (_, snapshot) {
        if (snapshot.hasData &&
            snapshot.connectionState == ConnectionState.done) {
          return FutureBuilder<UserModel?>(
            future: context.read<AuthOtpProvider>().checkIsLogin(context),
            builder: (_, snapUser) {
              if (snapUser.hasError && kDebugMode) {
                logger.log('SPLASH_SCREEN-CheckIsLogin: ${snapUser.error}');
                logger
                    .log('SPLASH_SCREEN-CheckIsLogin: ${snapUser.stackTrace}');
              }

              if (mounted &&
                  snapUser.connectionState == ConnectionState.done &&
                  snapUser.data == null) {
                return FutureBuilder<Map<String, dynamic>?>(
                  future: _getPilihanKelas,
                  builder: (_, snapPilihanKelas) {
                    if (snapPilihanKelas.hasError && kDebugMode) {
                      logger.log(
                          'KREASI_SECURE_STORAGE GET_PILIHAN_KELAS: ${snapPilihanKelas.error}');
                      logger.log(
                          'KREASI_SECURE_STORAGE GET_PILIHAN_KELAS: ${snapPilihanKelas.stackTrace}');
                    }

                    if (mounted &&
                        snapPilihanKelas.connectionState ==
                            ConnectionState.done) {
                      if (snapPilihanKelas.data == null) {
                        return const PilihKelasScreen();
                      }

                      // return MainScreen(
                      //     idSekolahKelas: snapPilihanKelas.data?['id'] ?? '31');
                      Future.delayed(
                          const Duration(seconds: 1),
                          () => Navigator.pushReplacementNamed(
                                  context, Constant.kRouteMainScreen,
                                  arguments: {
                                    'idSekolahKelas':
                                        snapPilihanKelas.data?['id'] ?? '31'
                                  }));
                    }
                    return _buildSlashScreen();
                  },
                );
              }
              // Jika user model exist, maka navigate ke MainScreen.
              // Jika snapUser.data null, maka artinya user belum login.
              if (snapUser.data != null) {
                final authProvider = context.read<AuthOtpProvider>();
                // Stream check login firebase
                FirebaseHelper().streamCheckLogin(
                  noRegistrasi: snapUser.data?.noRegistrasi,
                  userType: snapUser.data?.siapa ?? '',
                  deviceId: (gAkunTester.contains(
                          (snapUser.data?.isOrtu ?? false)
                              ? '${snapUser.data?.nomorHpOrtu}'
                              : '${snapUser.data?.nomorHp}'))
                      ? gStaticImei
                      : gDeviceID,
                  logout: () async => await gNavigatorKey.currentContext!
                      .read<AuthOtpProvider>()
                      .logout(),
                );

                if (snapUser.data!.tahunAjaran != authProvider.tahunAjaran) {
                  return FutureBuilder<UserModel>(
                    future: _autoRefreshUserData(authProvider, snapUser.data!),
                    builder: (context, snapshot) {
                      if (snapshot.data != null) {
                        Future.delayed(
                          const Duration(seconds: 1),
                          () => Navigator.pushReplacementNamed(
                              context, Constant.kRouteMainScreen, arguments: {
                            'idSekolahKelas': snapshot.data!.idSekolahKelas,
                            'userModel': snapshot.data!
                          }),
                        );
                      }
                      return _buildSlashScreen();
                    },
                  );
                } else {
                  Future.delayed(
                    const Duration(seconds: 1),
                    () => Navigator.pushReplacementNamed(
                        context, Constant.kRouteMainScreen, arguments: {
                      'idSekolahKelas': snapUser.data!.idSekolahKelas,
                      'userModel': snapUser.data!
                    }),
                  );
                }
              }
              return _buildSlashScreen();
            },
          );
        }

        return _buildSlashScreen();
      },
    );
  }

  Future<UserModel> _autoRefreshUserData(
      AuthOtpProvider authProvider, UserModel userData) async {
    await authProvider.login(
        otp: '0000',
        nomorHp: userData.isOrtu ? userData.nomorHpOrtu : userData.nomorHp,
        userTypeRefresh: userData.siapa,
        noRegistrasiRefresh: userData.noRegistrasi);
    await KreasiSharedPref().simpanDataLokal();

    if (mounted) {
      return context.read<AuthOtpProvider>().userModel.value!;
    } else {
      return authProvider.userModel.value!;
    }
  }

  Scaffold _buildSlashScreen() => Scaffold(
        body: Image.asset(
          'assets/img/splash_ads.jpg',
          width: context.dw,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
      );
}
