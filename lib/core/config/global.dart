library config.globals;

import 'dart:io';
import 'dart:developer' as logger show log;

import 'package:ntp/ntp.dart';
import 'package:uuid/uuid.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:unique_identifier/unique_identifier.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'enum.dart';
import 'theme.dart';
import 'extensions.dart';
import '../helper/api_helper.dart';
import '../util/data_formatter.dart';
import '../helper/kreasi_shared_pref.dart';
import '../../features/auth/model/user_model.dart';

/// Global ini merupakan tempat di mana variable dan function yang akan
/// di consume secara bebas di simpan.
/// Format penamaan variabel-nya menggunakan camelCase dan diawali huruf gNamaVariable / gNamaFunction.
const Duration gDelayedNavigation = Duration(milliseconds: 600);
final BorderRadius gDefaultShimmerBorderRadius = BorderRadius.circular(18);
late GlobalKey<NavigatorState> gNavigatorKey;
String gDeviceID = '';
late String gKreasiVersion;
DefaultFlashController? gPreviousBottomDialog;

// User Tester OTP statis
const List<String> gAkunTester = [
  // Siswa
  '08123456789',
  // ORTU
  '08987654321',
];

const String gStaticImei = 'Isi-Static-Imei-Device';

UserModel? gUser;
int? gOffsetServerTime;
String gTokenJwt = '';
String gNoRegistrasi = '';
String gPesanError = 'Waah, sepertinya akses GO Kreasi sedang padat Sobat. '
    'Coba akses kembali nanti yaa!';
String gPesanErrorKoneksi =
    'Ada gangguan koneksi internet, coba periksa konektivitas kamu Sobat!';
// String gPesanErrorData = ' ';
String gPesanErrorImeiPermission =
    'Go Kreasi membutuhkan izin akses penyimpanan untuk login.';
int? gLastIdLogActivity;
String? gLastMenuLogActivity;
String? gKeteranganLogActivity;
bool gShowPopUpNews = true;

// Variable keperluan enkripsi
final encrypt.Key gEncryptKey =
    encrypt.Key.fromUtf8(dotenv.env['KREASI_FERNET_KEY']!);
final encrypt.IV gInitializationVector = encrypt.IV.fromLength(16);

// final gLocalNotif = LocalNotificationService();
// late FlutterLocalNotificationsPlugin gFlutterLocalNotificationsPlugin;
// String gPayload = "";
// AndroidNotificationDetails gAndroidNotification =
//     const AndroidNotificationDetails('channelId', 'GO KREASI',
//         channelDescription: 'Rencana Belajar',
//         sound: RawResourceAndroidNotificationSound("res_ringtone_go"),
//         priority: Priority.high,
//         importance: Importance.max,
//         playSound: true);
//
// DarwinNotificationDetails giOSNotification = const DarwinNotificationDetails();
// NotificationDetails gPlatformNotification =
//     NotificationDetails(android: gAndroidNotification, iOS: giOSNotification);

String gEmptyProductSubtitle(
        {required String namaProduk,
        required bool isNotSiswa,
        required bool isOrtu,
        required bool isProdukDibeli}) =>
    (isOrtu)
        ? 'Teaser $namaProduk belum tersedia'
        : (isNotSiswa)
            ? 'Yaah, Teaser $namaProduk belum tersedia sobat.'
            : (isProdukDibeli)
                ? 'Yaah, isi produk $namaProduk masih kosong'
                : 'Sobat belum membeli produk $namaProduk ya';

String gEmptyProductText({
  required String namaProduk,
  required bool isProdukDibeli,
  required bool isOrtu,
}) {
  String subTitle = isProdukDibeli
      ? 'Kamu sudah membeli produk, namun saat ini isi dari $namaProduk belum tersedia Sobat. Hubungi customer service untuk melakukan request.'
      : 'Beli produk $namaProduk yuk sobat, cukup hubungi cabang Ganesha Operation terdekat.';

  if (isOrtu) {
    subTitle = isProdukDibeli
        ? 'Teaser produk $namaProduk untuk Orang Tua Siswa saat ini tidak tersedia. '
            'Produk $namaProduk yang telah Anda beli, hanya dapat di akses oleh Putra/Putri Bapak/Ibu saja.'
        : 'Anda belum membeli produk $namaProduk untuk Putra/Putri Anda, '
            'untuk membeli produk $namaProduk silahkan hubungi cabang Ganesha Operation terdekat.';
  }

  return subTitle;
}

/// [gGetServerTime] merupakan fungsi untuk mengambil
/// Server Time dari Network Time Protocol (NTP).<br>
/// [$lookUpAddress] default(time.google.com) option(pool.ntp.org, time.apple.com)
Future<DateTime> gGetServerTime() async {
  const timeout = Duration(seconds: 3);
  await gSetServerTimeOffset();
  final DateTime now = DateTime.now();
  DateTime serverTime = await NTP.now(lookUpAddress: 'time.apple.com').timeout(
        timeout,
        onTimeout: () async =>
            await NTP.now(lookUpAddress: 'pool.ntp.org').timeout(
                  timeout,
                  onTimeout: () async => await NTP.now().timeout(
                    timeout,
                    onTimeout: () async {
                      final response = await ApiHelper().requestPost(
                          jwt: false, pathUrl: '/data/waktuserver');

                      if (response['status'] ?? false) {
                        return DataFormatter.stringToDate(response['data']);
                      }
                      return DateTime.now()
                          .add(Duration(milliseconds: gOffsetServerTime!));
                    },
                  ),
                ),
      );

  if (kDebugMode) {
    logger.log('GLOBAL-GetServerTime: $serverTime | $gOffsetServerTime |');
    logger.log(
        'GLOBAL-GetServerTime: ${now.add(Duration(microseconds: gOffsetServerTime!))} | ${now.add(Duration(milliseconds: gOffsetServerTime!))}');
  }

  return serverTime;
}

/// [gSetServerTimeOffset] merupakan fungsi untuk mengambil offset antara LocalTime
/// dengan Server Time dari Network Time Protocol (NTP).<br>
/// [$lookUpAddress] default(time.google.com) option(pool.ntp.org, time.apple.com)
Future<void> gSetServerTimeOffset() async {
  if (gOffsetServerTime != null) return;

  const timeout = Duration(seconds: 3);
  final localTime = DateTime.now();
  gOffsetServerTime = await NTP
      .getNtpOffset(lookUpAddress: 'time.apple.com', localTime: localTime)
      .timeout(
        timeout,
        onTimeout: () async => await NTP
            .getNtpOffset(lookUpAddress: 'pool.ntp.org', localTime: localTime)
            .timeout(
              timeout,
              onTimeout: () async => await NTP
                  .getNtpOffset(localTime: localTime)
                  .timeout(timeout, onTimeout: () => gOffsetServerTime ?? 0),
            ),
      );
}

/// [gShowTopFlash] merupakan fungsi untuk menampilkan FlashBar/SnackBar dari atas.<br>
/// [message] adalah parameter untuk pesan yang akan ditampilkan.<br>
/// [dialogType] adalah tipe flashbar yang akan digunakan (error, info, success, warning)<br>
/// [style] diisi dengan [FlashBehavior] dengan value fixed/float.
Future<void> gShowTopFlash(BuildContext context, String message,
    {DialogType dialogType = DialogType.error,
    Duration duration = const Duration(seconds: 2),
    FlashBehavior style = FlashBehavior.fixed}) async {
  await showModalFlash(
    context: context,
    duration: duration,
    barrierBlur: 1.5,
    barrierColor: Colors.black38,
    builder: (context, controller) => FlashBar(
      useSafeArea: true,
      controller: controller,
      behavior: FlashBehavior.floating,
      position: FlashPosition.top,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        side: BorderSide(
          color: (dialogType == DialogType.error)
              ? context.errorColor
              : (dialogType == DialogType.info)
                  ? context.tertiaryColor
                  : (dialogType == DialogType.warning)
                      ? context.secondaryColor
                      : Palette.kSuccessSwatch[500]!,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      margin: const EdgeInsets.only(top: 32, left: 14, right: 14),
      clipBehavior: Clip.antiAlias,
      iconColor: (dialogType == DialogType.error)
          ? context.errorColor
          : (dialogType == DialogType.info)
              ? context.tertiaryColor
              : (dialogType == DialogType.warning)
                  ? context.secondaryColor
                  : Palette.kSuccessSwatch[500],
      indicatorColor: (dialogType == DialogType.error)
          ? context.errorColor
          : (dialogType == DialogType.info)
              ? context.tertiaryColor
              : (dialogType == DialogType.warning)
                  ? context.secondaryColor
                  : Palette.kSuccessSwatch[500],
      surfaceTintColor: (dialogType == DialogType.error)
          ? context.errorColor
          : (dialogType == DialogType.info)
              ? context.tertiaryColor
              : (dialogType == DialogType.warning)
                  ? context.secondaryColor
                  : Palette.kSuccessSwatch[500],
      titleTextStyle: context.text.titleSmall,
      contentTextStyle: context.text.bodyMedium,
      icon: const Icon(Icons.notifications_on_outlined),
      title: Text(
        (dialogType == DialogType.error)
            ? 'Coba lagi!'
            : (dialogType == DialogType.info)
                ? 'Informasi'
                : (dialogType == DialogType.warning)
                    ? 'Perhatian!'
                    : 'Berhasil',
      ),
      content: Text(message),
    ),
  );
}

/// [gShowBottomDialog] merupakan fungsi untuk menampilkan Dialog dari bawah.<br>
/// [message] adalah parameter untuk pesan yang akan ditampilkan.<br>
/// [dialogType] adalah tipe dialog yang akan digunakan (error, info, success, warning).<br>
/// [persistent] merupakan bool value untuk menandakan apakah dialog akan persistent atau tidak.<br>
/// [margin] [EdgeInsets] untuk mengatur margin dialog.
/// [actions] merupakan paramerer untuk menambahkan Action Button seperti pilihan YA/TIDAK.
Future<bool> gShowBottomDialog(
  BuildContext context, {
  String? title,
  required String message,
  Widget? content,
  DialogType dialogType = DialogType.error,
  bool persistent = true,
  bool barrierDismissible = true,
  List<Widget> Function(FlashController controller)? actions,
}) async {
  if (gPreviousBottomDialog?.isDisposed == false) {
    gPreviousBottomDialog?.dismiss(false);
  }

  gPreviousBottomDialog = DefaultFlashController<bool>(
    context,
    // persistent: persistent,
    barrierBlur: 1.5,
    barrierDismissible: barrierDismissible,
    barrierColor: Colors.black38,
    transitionDuration: const Duration(milliseconds: 300),
    builder: (context, controller) {
      return FlashBar(
        controller: controller,
        title: Text(title ?? 'GO Kreasi'),
        content: content ?? Text(message),
        icon: const Icon(Icons.info_outline),
        useSafeArea: true,
        clipBehavior: Clip.hardEdge,
        behavior: FlashBehavior.fixed,
        backgroundColor: context.background,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: context.text.titleMedium,
        contentTextStyle: context.text.bodySmall,
        margin: (context.isMobile)
            ? const EdgeInsets.all(14)
            : EdgeInsets.symmetric(vertical: 24, horizontal: context.dw * .2),
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(24)),
          side: BorderSide(
            color: (dialogType == DialogType.error)
                ? context.errorColor
                : (dialogType == DialogType.info)
                    ? context.tertiaryColor
                    : (dialogType == DialogType.warning)
                        ? context.secondaryColor
                        : Palette.kSuccessSwatch[500]!,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        iconColor: (dialogType == DialogType.error)
            ? context.errorColor
            : (dialogType == DialogType.info)
                ? context.tertiaryColor
                : (dialogType == DialogType.warning)
                    ? context.secondaryColor
                    : Palette.kSuccessSwatch[500],
        indicatorColor: (dialogType == DialogType.error)
            ? context.errorColor
            : (dialogType == DialogType.info)
                ? context.tertiaryColor
                : (dialogType == DialogType.warning)
                    ? context.secondaryColor
                    : Palette.kSuccessSwatch[500],
        actions: (actions != null)
            ? actions(controller)
            : <Widget>[
                TextButton(
                    onPressed: () => controller.dismiss(true),
                    child: const Text('Ya')),
                TextButton(
                    onPressed: () => controller.dismiss(false),
                    child: const Text('Tidak')),
              ],
      );
    },
  );

  bool? result = await gPreviousBottomDialog?.show();

  return result ?? false;
}

Future<bool> gShowBottomDialogInfo(
  BuildContext context, {
  String? title,
  required String message,
  Widget? content,
  DialogType dialogType = DialogType.error,
  bool persistent = true,
  bool barrierDismissible = true,
  bool displayIcon = true,
  List<Widget> Function(FlashController controller)? actions,
}) async {
  if (gPreviousBottomDialog?.isDisposed == false) {
    gPreviousBottomDialog?.dismiss(false);
  }

  gPreviousBottomDialog = DefaultFlashController<bool>(
    context,
    barrierBlur: 1.5,
    barrierColor: Colors.black38,
    barrierDismissible: barrierDismissible,
    transitionDuration: const Duration(milliseconds: 300),
    builder: (context, controller) {
      return FlashBar(
        controller: controller,
        title: Text(title ?? 'GO Kreasi'),
        content: content ?? Text(message),
        icon: (displayIcon) ? const Icon(Icons.info_outline) : null,
        useSafeArea: true,
        clipBehavior: Clip.hardEdge,
        backgroundColor: context.background,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: context.text.titleMedium,
        contentTextStyle: context.text.bodySmall,
        margin: (context.isMobile)
            ? const EdgeInsets.all(14)
            : EdgeInsets.symmetric(vertical: 24, horizontal: context.dw * .2),
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(24)),
          side: BorderSide(
            color: (dialogType == DialogType.error)
                ? context.errorColor
                : (dialogType == DialogType.info)
                    ? context.tertiaryColor
                    : (dialogType == DialogType.warning)
                        ? context.secondaryColor
                        : Palette.kSuccessSwatch[500]!,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        iconColor: (dialogType == DialogType.error)
            ? context.errorColor
            : (dialogType == DialogType.info)
                ? context.tertiaryColor
                : (dialogType == DialogType.warning)
                    ? context.secondaryColor
                    : Palette.kSuccessSwatch[500],
        indicatorColor: (dialogType == DialogType.error)
            ? context.errorColor
            : (dialogType == DialogType.info)
                ? context.tertiaryColor
                : (dialogType == DialogType.warning)
                    ? context.secondaryColor
                    : Palette.kSuccessSwatch[500],
        actions: (actions != null)
            ? actions(controller)
            : [
                TextButton(
                    onPressed: () => controller.dismiss(true),
                    child: const Text('Mengerti')),
              ],
      );
    },
  );

  bool? result = await gPreviousBottomDialog?.show();

  return result ?? false;
}

/// Setting warna status bar
/// [isBlackIcon] berfungsi untuk mengatur apakah
/// icon status bar akan berwarna gelap atau terang.
void gSetStatusBarColor({bool isBlackIcon = true}) {
  // Setting status bar transparent
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        statusBarIconBrightness:
            isBlackIcon ? Brightness.dark : Brightness.light,
        systemNavigationBarIconBrightness:
            isBlackIcon ? Brightness.dark : Brightness.light),
  );
}

/// Menyetel apakah screen akan berorientasi Portrait atau Landscape.
void gSetDeviceOrientations({bool isLandscape = false}) {
  SystemChrome.setPreferredOrientations(isLandscape
      ? [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]
      : [DeviceOrientation.portraitUp]);
}

/// [gValidateMobile] merupakan fungsi untuk memvalidasi phone number.
bool gValidateMobile(String value) {
  String pattern = r'(^(?:[+0]6)?[0-9]{10,13}$)';
  RegExp regExp = RegExp(pattern);
  return regExp.hasMatch(value);
}

Future<bool> gRequestPermission(Permission permission,
    {required String title, required String message}) async {
  if (await permission.isGranted) {
    return true;
  } else {
    // Memunculkan Pesan Error
    await gShowBottomDialogInfo(
      gNavigatorKey.currentContext!,
      title: title,
      message: message,
    );
    var result = await permission.request();
    if (result == PermissionStatus.granted) {
      return true;
    }
  }
  return false;
}

Future<Map<String, dynamic>> gGetDeviceInfo() async {
  final deviceInfo = DeviceInfoPlugin();

  final appInfo = await PackageInfo.fromPlatform();
  String version = appInfo.version;
  String buildNumber = appInfo.buildNumber;

  if (Platform.isIOS) {
    IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;

    Map<String, dynamic> utsname = {
      'release': iosDeviceInfo.utsname.release,
      'version': iosDeviceInfo.utsname.version,
      'machine': iosDeviceInfo.utsname.machine,
      'nodename': iosDeviceInfo.utsname.nodename,
      'sysname': iosDeviceInfo.utsname.sysname,
    };

    final Map<String, dynamic> dataIOS = {
      'platform': 'iOS',
      'namaDevice': '${iosDeviceInfo.name} ${iosDeviceInfo.utsname.machine}',
      'versiOS': '${iosDeviceInfo.systemName} ${iosDeviceInfo.systemVersion}',
      'versiGOKreasi': '$version($buildNumber)',
      'infoLain': {
        'isPhysicalDevice': iosDeviceInfo.isPhysicalDevice,
        'data': utsname,
      },
    };

    // logger.log('GLOBAL-GetDeviceInfo: Data Device >> $dataIOS');

    return dataIOS;
  } else if (Platform.isAndroid) {
    AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;

    final Map<String, dynamic> dataAndroid = {
      'platform': 'Android',
      'namaDevice':
          '${androidDeviceInfo.manufacturer} ${androidDeviceInfo.brand} ${androidDeviceInfo.model}',
      'versiOS':
          'Android ${androidDeviceInfo.version.release} SDK ${androidDeviceInfo.version.sdkInt}',
      'versiGOKreasi': '$version($buildNumber)',
      'infoLain': {
        'id': androidDeviceInfo.id,
        'isPhysicalDevice': androidDeviceInfo.isPhysicalDevice,
        'data': {
          'board': androidDeviceInfo.board,
          'brand': androidDeviceInfo.brand,
          'device': androidDeviceInfo.device,
          'display': androidDeviceInfo.display,
          'hardware': androidDeviceInfo.hardware,
          'host': androidDeviceInfo.host,
          'product': androidDeviceInfo.product,
          'fingerprint': androidDeviceInfo.fingerprint,
        }
      },
    };

    // logger.log('GLOBAL-GetDeviceInfo: Data Device >> $dataAndroid');

    return dataAndroid;
  }

  return {};
}

Future<String?> gGetIdDevice({int retry = 1}) async {
  var deviceInfo = DeviceInfoPlugin();
  // String nameSpace = dotenv.env['UUID_NAMESPACE']!;

  if (gDeviceID.isNotEmpty) return gDeviceID;

  if (Platform.isIOS) {
    IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;

    // if (kDebugMode) {
    //   logger.log(
    //       'GLOBAL-GetIdDevice: Running on ios >> ${iosDeviceInfo.identifierForVendor}');
    // }
    gDeviceID = iosDeviceInfo.identifierForVendor ??
        'UNIDENTIFIED-IOS: ${iosDeviceInfo.name}--${iosDeviceInfo.localizedModel}--'
            '${iosDeviceInfo.model}--${iosDeviceInfo.systemName}--'
            '${iosDeviceInfo.systemVersion}--${iosDeviceInfo.utsname}';

    return iosDeviceInfo.identifierForVendor; // unique ID on iOS
  } else {
    AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;

    // Mengambil uuid dari file content.
    String? localUUID = await KreasiSharedPref().getDeviceID();

    for (int i = 0; i < 3; i++) {
      if (localUUID != null) continue;
      localUUID ??= await KreasiSharedPref().getDeviceID();
    }

    if (kDebugMode) {
      logger.log('GLOBAL-GetIdDevice: android local UUID >> $localUUID');
      logger.log('GLOBAL-GetIdDevice: ${localUUID != null}');
      logger.log('GLOBAL-GetIdDevice: ${localUUID != 'null'}');
      logger.log('GLOBAL-GetIdDevice: isString >> ${localUUID is String}');
      logger.log('GLOBAL-GetIdDevice: isEmpty >> ${localUUID?.isEmpty}');
    }

    if (localUUID != null && localUUID != 'null') {
      if (kDebugMode) {
        logger.log('GLOBAL-GetIdDevice: local UUID not null');
      }

      gDeviceID = localUUID;
      // Jika localUUID ada, maka kembalikan nilainya.
      // Jika nomorHp null, maka function di jalankan di SplashScreen
      // untuk pengecekan login dam User Belum Login.
      // Untuk kasus itu maka return null.
      return localUUID;
    } else {
      final androidID = await gGetAndroidID(
        '${androidDeviceInfo.host}.${androidDeviceInfo.fingerprint.replaceAll('/', '.')}',
      );

      // Menyimpan UUID ke local file.
      bool isBerhasil = await KreasiSharedPref().setDeviceID(androidID);

      if (isBerhasil) gDeviceID = androidID;

      if (kDebugMode) {
        logger.log(
            'GLOBAL-GetIdDevice: Android New UUID >> ${isBerhasil ? 'Berhasil' : 'Gagal'} '
            'simpan $gDeviceID >> $androidID');
      }
      return androidID; // unique ID on Android
    }
  }
}

Future<String> gGetAndroidID(String androidInfo) async {
  if (kDebugMode) {
    logger.log('GLOBAL-GetIdDevice: START Create UUID');
  }
  const uuid = Uuid();
  // Random uuid v4 untuk menjadi nameSpace agar generate uuid menjadi lebih acak.
  // String nameSpace = uuid.v4();
  String nameSpace = dotenv.env['UUID_NAMESPACE']!;

  // Generate new UUID
  String newAndroidUUID = uuid.v5(nameSpace, androidInfo);
  try {
    if (kDebugMode) {
      logger.log('GLOBAL-GetIdDevice: START Get AndroidID');
    }
    final androidID = await UniqueIdentifier.serial;

    if (kDebugMode) {
      logger.log('GLOBAL-gGetAndroidID: Android ID >> $androidID');
      logger.log('GLOBAL-gGetAndroidID: UUID 4 >> $nameSpace');
      logger.log('GLOBAL-gGetAndroidID: android info >> $androidInfo');
    }

    return androidID ?? newAndroidUUID;
  } on PlatformException catch (e) {
    if (kDebugMode) {
      logger.log('PlatformException-gGetAndroidID: Error >> $e');
    }
    return newAndroidUUID;
  } catch (e) {
    if (kDebugMode) {
      logger.log('FatalException-gGetAndroidID: Error >> $e');
    }
    return newAndroidUUID;
  }
}

Future<String> gGetKreasiVersion() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  String appName = packageInfo.appName;
  String version = packageInfo.version;
  String buildNumber = packageInfo.buildNumber;

  gKreasiVersion = '$appName v$version($buildNumber)';
  return gKreasiVersion;
}
