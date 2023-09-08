import 'dart:convert';
import 'dart:developer' as logger show log;
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../../../core/config/constant.dart';
import '../../../../core/config/enum.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/config/global.dart';
import '../../../../core/shared/screen/splash_screen.dart';
import '../../../buku/entity/bab_buku.dart';
import '../../../buku/model/bab_buku_model.dart';
import '../../../video/model/video_jadwal.dart';

class LocalNotificationService {
  static const String notifChannelId = '2702';
  static const String notifChannelName = 'GO kreasi Rencana Belajar';
  static const String notificationTitle = 'Sobat Reminder!!';

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // LocalNotificationService a singleton object
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();

  factory LocalNotificationService() {
    return _instance;
  }

  LocalNotificationService._internal();

  // static const AndroidNotificationDetails _androidNotificationDetails =
  //     AndroidNotificationDetails(notifChannelId, notifChannelName,
  //         channelDescription: 'Notification for reminder feature',
  //         playSound: true,
  //         priority: Priority.high,
  //         importance: Importance.high);
  //
  // static const DarwinNotificationDetails _iOSNotificationDetails =
  //     DarwinNotificationDetails();

  /// [_getLocalTimeZone] merupakan function untuk get local time zone
  /// menggunakan Package FlutterNativeTimezone.
  /// Jika terjadi error maka akan return default 'Asia/Jakarta'.
  Future<String> _getLocalTimeZone() async {
    try {
      final String timeZone = await FlutterNativeTimezone.getLocalTimezone();

      if (kDebugMode) {
        logger.log(
            'LOCAL_NOTIF_SERVICE-GetLocalTimeZone: Local Time Zone >> $timeZone');
      }

      return timeZone;
    } catch (e) {
      if (kDebugMode) {
        logger.log('LOCAL_NOTIF_SERVICE-GetLocalTimeZone: Error >> $e');
      }
      return 'Asia/Jakarta';
    }
  }

  Future<void> init() async {
    if (kDebugMode) {
      logger.log('LOCAL_NOTIF_SERVICE-Init: START');
    }

    const AndroidInitializationSettings initSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initSettingsIOS =
        DarwinInitializationSettings(
            requestSoundPermission: false,
            requestBadgePermission: false,
            requestAlertPermission: false,
            onDidReceiveLocalNotification: _onDidReceiveLocalNotification);

    final InitializationSettings initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS,
    );

    tz.initializeTimeZones();
    final String localTimeZone = await _getLocalTimeZone();

    tz.setLocalLocation(tz.getLocation(localTimeZone));

    await _flutterLocalNotificationsPlugin.initialize(initSettings,
        onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
        onDidReceiveBackgroundNotificationResponse:
            onDidReceiveBackgroundNotificationResponse);

    if (kDebugMode) {
      logger.log(
          'LOCAL_NOTIF_SERVICE-Init: FINISH initiate FlutterLocalNotificationsPlugin');
    }
    // final NotificationAppLaunchDetails? notificationAppLaunchDetails =
    //     await _flutterLocalNotificationsPlugin
    //         .getNotificationAppLaunchDetails();
    //
    // if (notificationAppLaunchDetails != null &&
    //     notificationAppLaunchDetails.didNotificationLaunchApp) {
    //   _payload =
    //       notificationAppLaunchDetails.notificationResponse?.payload ?? '';
    //
    //   if (kDebugMode) {
    //     logger.log(
    //         'LOCAL_NOTIF_SERVICE-Init: Payload >> ${notificationAppLaunchDetails.notificationResponse?.payload}');
    //     logger.log('LOCAL_NOTIF_SERVICE-Init: Payload Global >> $_payload');
    //   }
    // }
  }

  /// IOS On Did Receive Local Notification
  void _onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
    if (kDebugMode) {
      logger.log('LOCAL_NOTIF_SERVICE-OnDidReceiveIos: '
          'id: $id, title: $title, body: $body, payload: $payload');
    }

    gShowBottomDialog(
      gNavigatorKey.currentState!.context,
      title: notificationTitle,
      message: body ?? 'Notifikasi belajar',
      dialogType: DialogType.success,
      actions: (controller) => [
        TextButton(
          onPressed: () {
            _bukaScreen(payload: payload);
            controller.dismiss(true);
          },
          child: const Text('Belajar Sekarang'),
        ),
        TextButton(
          onPressed: () => controller.dismiss(false),
          child: const Text('Nanti Saja'),
        ),
      ],
    );
  }

  /// _flutterLocalNotificationsPlugin Init
  static void _onDidReceiveNotificationResponse(NotificationResponse details) {
    if (kDebugMode) {
      logger.log('LOCAL_NOTIF_SERVICE-OnDidReceiveNotificationResponse: '
          'Details >> ${details.id}, ${details.actionId}, ${details.input}, ${details.payload}\n'
          'NotificationResponseType >> ${details.notificationResponseType.index}, ${details.notificationResponseType.name}');
    }

    if (details.notificationResponseType ==
        NotificationResponseType.selectedNotification) {
      _bukaScreen(payload: details.payload);
    }
  }

  /// _flutterLocalNotificationsPlugin Init
  @pragma('vm:entry-point')
  static void onDidReceiveBackgroundNotificationResponse(
      NotificationResponse details) {
    // if (kDebugMode) {
    logger.log(
        'LOCAL_NOTIF_SERVICE-OnDidReceiveBackgroundNotificationResponse: '
        'Details >> ${details.id}, ${details.actionId}, ${details.input}, ${details.payload}\n'
        'NotificationResponseType >> ${details.notificationResponseType.index}, ${details.notificationResponseType.name}');
    // }

    try {
      Future.delayed(const Duration(seconds: 4))
          .then((_) => _bukaScreen(payload: details.payload));
    } catch (e) {
      // if (kDebugMode) {
      logger.log(
          'LOCAL_NOTIF_SERVICE-OnDidReceiveBackgroundNotificationResponse: '
          'Error >> $e');
      // }
    }
  }

  /// Function get NotificationDetails
  NotificationDetails _notificationDetails() {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      notifChannelId,
      notifChannelName,
      channelShowBadge: true,
      channelDescription: 'Notification for reminder feature',
      priority: Priority.high,
      importance: Importance.max,
      colorized: true,
      color: Color(0xffffcc29),
      playSound: true,
      sound: RawResourceAndroidNotificationSound('res_ringtone_go'),
    );

    const DarwinNotificationDetails iOSNotificationDetails =
        DarwinNotificationDetails();

    return const NotificationDetails(
      android: androidNotificationDetails,
      iOS: iOSNotificationDetails,
    );
  }

  Future<void> showScheduledNotificationWithPayload({
    required int id,
    required String body,
    required String payload,
    required DateTime startRencana,
  }) async {
    final details = _notificationDetails();
    final triggeredWhen = startRencana.subtract(const Duration(minutes: 15));

    if (kDebugMode) {
      logger.log('LOCAL_NOTIF_SERVICE-ShowScheduled: '
          'Create Notif >> ${triggeredWhen.hoursMinutesDDMMMYYYY}');
    }

    await _flutterLocalNotificationsPlugin.zonedSchedule(id, notificationTitle,
        body, tz.TZDateTime.from(triggeredWhen, tz.local), details,
        payload: payload,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  Future<void> cancelNotifications(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<bool> requestPermissions() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isIOS) {
      // request permission for iOS notification
      return await _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
              ) ??
          false;
    } else {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;

      int sdkLevel = androidDeviceInfo.version.sdkInt;

      // request permission for Android 13 (API level 33) or higher
      if (sdkLevel >= 33) {
        return await _flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                    AndroidFlutterLocalNotificationsPlugin>()
                ?.requestPermission() ??
            false;
      }
      return true;
    }
  }

  static void _bukaScreen({String? payload}) async {
    try {
      final navigator = Navigator.of(gNavigatorKey.currentState!.context);

      if (kDebugMode) {
        logger.log('LOCAL_NOTIF_SERVICE-BukaScreen: Payload >> $payload');
      }
      if (payload == null) return;

      final Map<String, dynamic> argument = json.decode(payload);

      if (kDebugMode) {
        logger.log(
            'LOCAL_NOTIF_SERVICE-BukaScreen: Argument decode >> $argument');
      }

      await Future.delayed(const Duration(seconds: 1));

      switch (argument['idJenisProduk']) {
        // Bundel
        case 76: // Latihan Ekstra
        case 77: // Paket Intensif
        case 78: // Paket Soal Koding
        case 79: // Pendalaman Materi
        case 82: // Soal Referensi
        // Paket
        case 71: // Empati Mandiri, Constant.kRouteBukuSoalScreen
        case 72: // Empati Wajib, Constant.kRouteBukuSoalScreen
          navigator.pushNamed(
            Constant.kRouteSoalBasicScreen,
            arguments: argument,
          );
          break;
        case 88: // Video Teori (Jadwal)
          List<VideoJadwal> daftarVideo = [];

          argument.update('daftarVideo', (dataVideo) {
            if (dataVideo != null) {
              for (var video in dataVideo) {
                daftarVideo.add(VideoJadwal.fromJson(video));
              }
            }
            return daftarVideo;
          }, ifAbsent: () => []);
          argument.update(
              'video', (videoAktif) => VideoJadwal.fromJson(videoAktif));

          navigator.pushNamed(Constant.kRouteVideoPlayer, arguments: argument);
          break;
        case 46: // Buku Rumus
        case 59: // Buku Teori
          final List<BabBuku> daftarIsi = [];

          argument.update('daftarIsi', (dataBab) {
            if (dataBab != null) {
              for (var bab in dataBab) {
                daftarIsi.add(BabBukuModel.fromJson(bab));
              }
            }
            return daftarIsi;
          }, ifAbsent: () => []);

          argument.update('listIdTeoriBabAwal',
              (listIdTeori) => (listIdTeori as List).cast<String>(),
              ifAbsent: () => []);

          navigator.pushNamed(Constant.kRouteBukuTeoriContent,
              arguments: argument);
          break;
        case 65: // VAK, Constant.kRouteProfilingScree
        case 12: // GO-Assessment
          // Navigate to Profiling Screen
          navigator.pushNamed(
            Constant.kRouteProfilingScreen,
            arguments: {'idJenisProduk': argument['idJenisProduk']},
          );
          break;
        case 16: // Kuis
        case 80: // Racing Soal
          // Navigate to Buku Soal Screen
          // Isi argument >> 'kodeTOB', 'kodePaket',
          // 'idJenisProduk', 'namaJenisProduk', 'keterangan'
          navigator.pushNamed(Constant.kRouteBukuSoalScreen,
              arguments: argument);
          break;
        case 25: // TOBK
          // Isi argument >> 'kodeTOB', 'namaTOB', 'keterangan'
          argument.update('idJenisProduk', (value) => 25, ifAbsent: () => 25);
          argument.update('namaJenisProduk', (value) => 'e-TOBK',
              ifAbsent: () => 'e-TOBK');

          // Navigate to TOBK Screen
          navigator.pushNamed(Constant.kRouteTobkScreen, arguments: argument);
          break;
        default:
          navigator.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const SplashScreen()),
            (route) => route.isFirst,
          );
          break;
      }
    } catch (e) {
      if (kDebugMode) {
        logger.log('LOCAL_NOTIF_SERVICE-BukaScreen: Error >> $e');
      }
      Navigator.pushAndRemoveUntil(
        gNavigatorKey.currentState!.context,
        MaterialPageRoute(builder: (_) => const SplashScreen()),
        (route) => route.isFirst,
      );
    }
  }

  Future<void> bukaScreen({required Map<String, dynamic> argument}) async {
    try {
      final navigator = Navigator.of(gNavigatorKey.currentState!.context);

      if (kDebugMode) {
        logger.log(
            'LOCAL_NOTIF_SERVICE-BukaScreen: argument fromOnClickEditor >> $argument');
      }

      await Future.delayed(const Duration(seconds: 1));

      switch (argument['idJenisProduk']) {
        // Bundel
        case 76: // Latihan Ekstra
        case 77: // Paket Intensif
        case 78: // Paket Soal Koding
        case 79: // Pendalaman Materi
        case 82: // Soal Referensi
        // Paket
        case 71: // Empati Mandiri, Constant.kRouteBukuSoalScreen
        case 72: // Empati Wajib, Constant.kRouteBukuSoalScreen
          navigator.pushNamed(
            Constant.kRouteSoalBasicScreen,
            arguments: argument,
          );
          break;
        case 88: // Video Teori (Jadwal)
          List<VideoJadwal> daftarVideo = [];

          argument.update('daftarVideo', (dataVideo) {
            if (dataVideo != null) {
              for (var video in dataVideo) {
                daftarVideo.add(VideoJadwal.fromJson(video));
              }
            }
            return daftarVideo;
          }, ifAbsent: () => []);
          argument.update(
              'video', (videoAktif) => VideoJadwal.fromJson(videoAktif));

          navigator.pushNamed(Constant.kRouteVideoPlayer, arguments: argument);
          break;
        case 46: // Buku Rumus
        case 59: // Buku Teori
          final List<BabBuku> daftarIsi = [];

          argument.update('daftarIsi', (dataBab) {
            if (dataBab != null) {
              for (var bab in dataBab) {
                daftarIsi.add(BabBukuModel.fromJson(bab));
              }
            }
            return daftarIsi;
          }, ifAbsent: () => []);

          argument.update('listIdTeoriBabAwal',
              (listIdTeori) => (listIdTeori as List).cast<String>(),
              ifAbsent: () => []);

          navigator.pushNamed(Constant.kRouteBukuTeoriContent,
              arguments: argument);
          break;
        case 65: // VAK, Constant.kRouteProfilingScree
        case 12: // GO-Assessment
          // Navigate to Profiling Screen
          navigator.pushNamed(
            Constant.kRouteProfilingScreen,
            arguments: {'idJenisProduk': argument['idJenisProduk']},
          );
          break;
        case 16: // Kuis
        case 80: // Racing Soal
          // Navigate to Buku Soal Screen
          // Isi argument >> 'kodeTOB', 'kodePaket',
          // 'idJenisProduk', 'namaJenisProduk', 'keterangan'
          navigator.pushNamed(Constant.kRouteBukuSoalScreen,
              arguments: argument);
          break;
        case 25: // TOBK
          // Isi argument >> 'kodeTOB', 'namaTOB', 'keterangan'
          argument.update('idJenisProduk', (value) => 25, ifAbsent: () => 25);
          argument.update('namaJenisProduk', (value) => 'e-TOBK',
              ifAbsent: () => 'e-TOBK');

          // Navigate to TOBK Screen
          navigator.pushNamed(Constant.kRouteTobkScreen, arguments: argument);
          break;
        default:
          navigator.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const SplashScreen()),
            (route) => route.isFirst,
          );

          if (navigator.canPop()) {
            navigator.popUntil((route) => route.isFirst);
          }
          break;
      }
    } catch (e) {
      if (kDebugMode) {
        logger.log('LOCAL_NOTIF_SERVICE-BukaScreen: Error >> $e');
      }
      Navigator.pushAndRemoveUntil(
        gNavigatorKey.currentState!.context,
        MaterialPageRoute(builder: (_) => const SplashScreen()),
        (route) => route.isFirst,
      );

      if (Navigator.canPop(gNavigatorKey.currentState!.context)) {
        Navigator.popUntil(
            gNavigatorKey.currentState!.context, (route) => route.isFirst);
      }
    }
  }
}
