import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart'
    show FlutterNativeSplash;

import 'core/config/route.dart';
import 'core/config/theme.dart';
import 'core/config/global.dart';
import 'core/config/extensions.dart';
import 'core/shared/screen/splash_screen.dart';
import 'core/shared/provider/log_provider.dart';
import 'features/bookmark/entity/bookmark.dart';
import 'features/soal/entity/detail_jawaban.dart';
import 'features/profile/entity/scanner_type.dart';
import 'features/profile/entity/kelompok_ujian.dart';
import 'core/shared/widget/image/logo_image_widget.dart';
import 'features/home/presentation/provider/data_provider.dart';
import 'features/buku/presentation/provider/buku_provider.dart';
import 'features/soal/presentation/provider/solusi_provider.dart';
import 'features/video/presentation/provider/video_provider.dart';
import 'features/ptn/module/ptnclopedia/entity/kampus_impian.dart';
import 'features/jadwal/presentation/provider/jadwal_provider.dart';
import 'features/auth/presentation/provider/auth_otp_provider.dart';
import 'features/berita/presentation/provider/berita_provider.dart';
import 'features/standby/presentation/provider/standby_provider.dart';
import 'features/profile/presentation/provider/profile_provider.dart';
import 'features/laporan/module/vak/provider/laporan_vak_provider.dart';
import 'features/bookmark/presentation/provider/bookmark_provider.dart';
import 'features/feedback/presentation/provider/feedback_provider.dart';
import 'features/kehadiran/presentation/provider/kehadiran_provider.dart';
import 'features/leaderboard/presentation/provider/capaian_provider.dart';
import 'features/home/presentation/provider/profile_picture_provider.dart';
import 'features/notifikasi/presentation/provider/notifikasi_provider.dart';
import 'features/pembayaran/presentation/provider/pembayaran_provider.dart';
import 'features/sosmed/module/feed/presentation/provider/feed_provider.dart';
import 'features/leaderboard/presentation/provider/leaderboard_provider.dart';
import 'features/soal/module/timer_soal/presentation/provider/tob_provider.dart';
import 'features/ptn/module/ptnclopedia/presentation/provider/ptn_provider.dart';
import 'features/sosmed/module/friends/presentation/provider/friends_provider.dart';
import 'features/rencanabelajar/service/notifikasi/local_notification_service.dart';
import 'features/rencanabelajar/presentation/provider/rencana_belajar_provider.dart';
import 'features/laporan/module/quiz/presentation/provider/laporan_kuis_provider.dart';
import 'features/sosmed/module/leaderboard/provider/leaderboard_friends_provider.dart';
import 'features/soal/module/paket_soal/presentation/provider/paket_soal_provider.dart';
import 'features/ptn/module/simulasi/presentation/provider/simulasi_hasil_provider.dart';
import 'features/ptn/module/simulasi/presentation/provider/simulasi_nilai_provider.dart';
import 'features/laporan/module/tobk/presentation/provider/laporan_tryout_provider.dart';
import 'features/soal/module/bundel_soal/presentation/provider/bundel_soal_provider.dart';
import 'features/ptn/module/simulasi/presentation/provider/simulasi_pilihan_provider.dart';
import 'features/laporan/module/aktivitas/presentation/provider/laporan_aktivitas_provider.dart';

void main() async {
  // Untuk membuat Splash Screen tetap berjalan, hingga diberhentikan.
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Setting status bar transparent dan Device Orientation
  gSetStatusBarColor();
  // gSetDeviceOrientations();

  //inisialisasi notifikasi :

  await LocalNotificationService().init();
  // LocalNotificationService().requestIOSPermissions;

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // const option = FirebaseOptions(
  //   projectId: '-',
  //   messagingSenderId: '-',
  //   apiKey: '-',
  //   appId: '-',
  // );

  // await Firebase.initializeApp(name: 'NameApp_Firebase', options: option);
  // await Firebase.initializeApp();

  // Initialized Hive
  await Hive.initFlutter();
  _registerHiveAdapter();

  // Http Overrides
  HttpOverrides.global = MyHttpOverrides();

  // To load the .env file contents into dotenv.
  await dotenv.load(fileName: ".env");

  //...run app
  runApp(const MyApp());
}

void _registerHiveAdapter() {
  Hive.registerAdapter(DetailJawabanAdapter());
  Hive.registerAdapter(BookmarkMapelAdapter());
  Hive.registerAdapter(BookmarkSoalAdapter());
  Hive.registerAdapter(ScannerTypeAdapter());
  Hive.registerAdapter(KelompokUjianAdapter());
  Hive.registerAdapter(KampusImpianAdapter());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  // final LocalNotificationService _notificationService = LocalNotificationService();

  @override
  void initState() {
    gNavigatorKey = _navigatorKey;
    // if (gPayload.isNotEmpty) {
    //   _notificationService.bukaScreen();
    // }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Kapanpun initialization selesai, menghentikan splash screen:
    FlutterNativeSplash.remove();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FeedbackProvider>(
          create: (_) => FeedbackProvider(),
        ),
        Provider<LogProvider>(
          create: (_) => LogProvider(),
        ),
        ChangeNotifierProvider<LaporanKuisProvider>(
          create: (_) => LaporanKuisProvider(),
        ),
        ChangeNotifierProvider<LaporanVakProvider>(
          create: (_) => LaporanVakProvider(),
        ),
        ChangeNotifierProvider<SimulasiPilihanProvider>(
          create: (_) => SimulasiPilihanProvider(),
        ),
        ChangeNotifierProvider<SimulasiNilaiProvider>(
          create: (_) => SimulasiNilaiProvider(),
        ),
        ChangeNotifierProvider<SimulasiHasilProvider>(
          create: (_) => SimulasiHasilProvider(),
        ),
        ChangeNotifierProvider<BeritaProvider>(
          create: (_) => BeritaProvider(),
        ),
        ChangeNotifierProvider<FeedProvider>(
          create: (_) => FeedProvider(),
        ),
        ChangeNotifierProvider<FriendsProvider>(
          create: (_) => FriendsProvider(),
        ),
        ChangeNotifierProvider<LeaderboardFriendsProvider>(
          create: (_) => LeaderboardFriendsProvider(),
        ),
        ChangeNotifierProvider<RencanaBelajarProvider>(
          create: (_) => RencanaBelajarProvider(),
        ),
        Provider<LaporanAktivitasProvider>(
          create: (_) => LaporanAktivitasProvider(),
        ),
        ChangeNotifierProvider<LaporanTryoutProvider>(
          create: (_) => LaporanTryoutProvider(),
        ),
        ChangeNotifierProvider<ProfilePictureProvider>(
          create: (_) => ProfilePictureProvider(),
        ),
        ChangeNotifierProvider<BukuProvider>(
          create: (_) => BukuProvider(),
        ),
        ChangeNotifierProvider<BookmarkProvider>(
          create: (_) => BookmarkProvider(),
        ),
        ChangeNotifierProvider<LeaderboardProvider>(
          create: (_) => LeaderboardProvider(),
        ),
        ChangeNotifierProvider<PembayaranProvider>(
          create: (_) => PembayaranProvider(),
        ),
        ChangeNotifierProvider<KehadiranProvider>(
          create: (_) => KehadiranProvider(),
        ),
        ChangeNotifierProvider<CapaianProvider>(
          create: (_) => CapaianProvider(),
        ),
        ChangeNotifierProvider<BundelSoalProvider>(
          create: (_) => BundelSoalProvider(),
        ),
        ChangeNotifierProvider<PaketSoalProvider>(
          create: (_) => PaketSoalProvider(),
        ),
        ChangeNotifierProvider<TOBProvider>(
          create: (_) => TOBProvider(),
        ),
        ChangeNotifierProvider<SolusiProvider>(
          create: (_) => SolusiProvider(),
        ),
        ChangeNotifierProvider<PtnProvider>(
          create: (_) => PtnProvider(),
        ),
        ChangeNotifierProvider<JadwalProvider>(
          create: (_) => JadwalProvider(),
        ),
        Provider<StandbyProvider>(
          create: (_) => StandbyProvider(),
        ),
        ChangeNotifierProvider<VideoProvider>(
          create: (_) => VideoProvider(),
        ),
        ChangeNotifierProvider<NotificationProvider>(
          create: (_) => NotificationProvider(),
        ),
        ChangeNotifierProvider<DataProvider>(
          create: (_) => DataProvider(),
        ),
        ChangeNotifierProvider<ProfileProvider>(
          create: (_) => ProfileProvider(),
        ),
        ChangeNotifierProvider<AuthOtpProvider>(
          create: (_) => AuthOtpProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'GO Kreasi',
        themeMode: ThemeMode.light,
        theme: CustomTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        onGenerateRoute: MyRouter.generateRoute,
        navigatorKey: _navigatorKey,
        // ignore: prefer_const_constructors
        locale: Locale('in', 'ID'),
        // ignore: prefer_const_literals_to_create_immutables, prefer_const_constructors
        supportedLocales: [Locale('in', 'ID')],
        // ignore: prefer_const_literals_to_create_immutables
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        builder: (context, child) {
          ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
            return buildErrorUI(context, errorDetails);
          };

          // if (!context.isMobile) {
          //   gSetDeviceOrientations(isLandscape: true);
          // }

          // Men-setting text scale factor Media Query.
          // Jika ini dihapus, maka text scale factor akan mengikuti System.
          return MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaleFactor: context.textScale14),
            child: child!,
          );
        },
        home: const SplashScreen(),
      ),
    );
  }

  Widget buildErrorUI(BuildContext context, FlutterErrorDetails error) {
    Widget errorWidget = Container(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const LogoImageWidget(height: 80.0),
          Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
            child: Text(
              'Terjadi kesalahan di dalam GO Kreasi.',
              textAlign: TextAlign.center,
              style: context.text.bodyLarge,
            ),
          ),
          Text(
            '${kDebugMode ? error.summary : 'Maaf atas ketidaknyamanan ini, kami akan memperbaiki secepatnya. Mohon hubungi petugas kami.'}',
            textAlign: TextAlign.center,
            style: context.text.labelSmall?.copyWith(color: context.hintColor),
          ),
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraint) =>
          (constraint.maxHeight > (context.dh * 0.9))
              ? Scaffold(body: Center(child: errorWidget))
              : SizedBox(
                  width: constraint.maxWidth,
                  height: constraint.maxHeight,
                  child: SingleChildScrollView(child: errorWidget),
                ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
