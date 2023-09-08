import 'dart:developer' as logger show log;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import 'global.dart';
import 'constant.dart';
import 'enum.dart';
import '../util/data_formatter.dart';
import '../shared/screen/main_screen.dart';
import '../shared/screen/page_not_found.dart';
import '../shared/provider/log_provider.dart';
import '../shared/screen/story_board_screen.dart';
import '../../features/auth/presentation/screen/otp_screen.dart';
import '../../features/auth/presentation/screen/auth_screen.dart';
import '../../features/ptn/presentation/screen/snbt_screen.dart';
import '../../features/sosmed/presentation/screen/sosial_screen.dart';
import '../../features/profile/presentation/screen/about_screen.dart';
import '../../features/jadwal/presentation/screen/jadwal_screen.dart';
import '../../features/berita/presentation/screen/go_news_screen.dart';
import '../../features/soal/presentation/screen/profiling_screen.dart';
import '../../features/buku/presentation/screen/bab_teori_screen.dart';
import '../../features/soal/presentation/screen/buku_soal_screen.dart';
import '../../features/laporan/presentation/screen/laporan_screen.dart';
import '../../features/buku/presentation/screen/buku_teori_screen.dart';
import '../../features/profile/presentation/screen/profile_screen.dart';
import '../../features/profile/presentation/screen/bantuan_screen.dart';
import '../../features/soal/presentation/screen/soal_basic_screen.dart';
import '../../features/soal/presentation/screen/soal_timer_screen.dart';
import '../../features/bookmark/presentation/screen/bookmark_screen.dart';
import '../../features/feedback/presentation/screen/feedback_screen.dart';
import '../../features/auth/presentation/provider/auth_otp_provider.dart';
import '../../features/buku/presentation/screen/teori_content_screen.dart';
import '../../features/video/presentation/screen/video_player_screen.dart';
import '../../features/profile/presentation/screen/tata_tertib_screen.dart';
import '../../features/profile/presentation/screen/edit_profile_screen.dart';
import '../../features/berita/presentation/screen/detail_go_news_screen.dart';
import '../../features/notifikasi/presentation/screen/notifikasi_screen.dart';
import '../../features/profile/presentation/screen/bantuan_webview_screen.dart';
import '../../features/soal/module/timer_soal/presentation/screen/tobk_screen.dart';
import '../../features/leaderboard/presentation/screen/juara_buku_sakti_screen.dart';
import '../../features/ptn/module/simulasi/presentation/screen/simulasi_screen.dart';
import '../../features/video/presentation/screen/jadwal/video_jadwal_bab_screen.dart';
import '../../features/rencanabelajar/presentation/screens/rencana_editor_screen.dart';
import '../../features/rencanabelajar/presentation/screens/rencana_belajar_screen.dart';
import '../../features/sosmed/module/feed/presentation/screen/feed_comment_screen.dart';
import '../../features/laporan/module/quiz/presentation/screen/laporan_quiz_screen.dart';
import '../../features/soal/module/timer_soal/presentation/screen/paket_to_screen.dart';
import '../../features/soal/module/bundel_soal/presentation/screen/bab_soal_screen.dart';
import '../../features/laporan/module/tobk/presentation/screen/laporan_tryout_screen.dart';
import '../../features/ptn/module/ptnclopedia/presentation/screen/kampus_impian_screen.dart';
import '../../features/sosmed/module/friends/presentation/screen/friends_profile_screen.dart';
import '../../features/laporan/module/tobk/presentation/screen/laporan_tryout_epb_screen.dart';
import '../../features/laporan/module/tobk/presentation/screen/laporan_tryout_share_screen.dart';
import '../../features/laporan/module/presensi/presentation/screen/laporan_presensi_screen.dart';
import '../../features/laporan/module/tobk/presentation/screen/laporan_tryout_nilai_screen.dart';
import '../../features/leaderboard/leaderboardracing/presentation/screen/racing_leaderboard.dart';
import '../../features/ptn/module/simulasi/presentation/screen/simulasi_pilihan_form_screen.dart';
import '../../features/laporan/module/aktivitas/presentation/screen/laporan_aktivitas_screen.dart';
import '../../features/ptn/module/ptnclopedia/presentation/screen/kampus_impian_picker_screen.dart';

class MyRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    late Widget Function(BuildContext) screenTujuan;
    Map<String, dynamic>? arguments;

    if (settings.arguments != null) {
      arguments = settings.arguments as Map<String, dynamic>;
    }

    switch (settings.name) {
      /// Route AuthScreen
      case Constant.kRouteAuthScreen:
        AuthMode authMode = AuthMode.login;
        if (settings.arguments != null) authMode = arguments?['authMode'];
        screenTujuan = (_) => AuthScreen(authMode: authMode);
        break;
      case Constant.kRouteOTPScreen:
        screenTujuan = (_) => OtpScreen(isLogin: arguments!['isLogin']);
        break;

      /// Route MainScreen
      case Constant.kRouteMainScreen:
        if (settings.arguments == null) {
          arguments = {
            'idSekolahKelas': gUser?.idSekolahKelas,
            'userModel': gUser
          };
        }
        screenTujuan = (_) => MainScreen(
              idSekolahKelas: arguments!['idSekolahKelas'],
              userModel: arguments['userModel'],
            );
        break;
      case Constant.kRouteNotifikasi:
        screenTujuan = (_) => const NotifikasiScreen();
        break;
      case Constant.kRouteStoryBoardScreen:
        screenTujuan = (_) => StoryBoardScreen(
            imgUrl: arguments!['imgUrl'],
            title: arguments['title'],
            subTitle: arguments['subTitle'],
            storyText: arguments['storyText']);
        break;

      /// Route Profile
      case Constant.kRouteProfileScreen:
        screenTujuan = (_) => const ProfileScreen();
        break;
      case Constant.kRouteEditProfileScreen:
        screenTujuan = (_) => const EditProfileScreen();
        break;
      case Constant.kRouteAboutScreen:
        screenTujuan = (_) => const AboutScreen();
        break;
      case Constant.kRouteTataTertibScreen:
        screenTujuan = (_) => const TataTertibScreen();
        break;
      case Constant.kRouteBantuanScreen:
        screenTujuan = (_) => const BantuanScreen();
        break;
      case Constant.kRouteBantuanWebViewScreen:
        screenTujuan = (_) => BantuanWebViewScreen(
              title: arguments!['title'],
              url: arguments['url'],
            );
        break;

      /// Route Menu Soal
      case Constant.kRouteBukuSoalScreen:
        if (arguments != null) {
          screenTujuan = (_) => BukuSoalScreen(
                idJenisProduk: arguments!['idJenisProduk'],
                kodeTOB: arguments['kodeTOB'],
                kodePaket: arguments['kodePaket'],
                diBukaDari: arguments['diBukaDari'],
              );
        } else {
          screenTujuan = (_) => const BukuSoalScreen();
        }
        break;
      case Constant.kRouteBabBukuSoalScreen:
        screenTujuan = (_) => BabSoalScreen(
              kodeTOB: arguments?['kodeTOB'],
              kodePaket: arguments?['kodePaket'],
              idBundel: arguments?['idBundel'],
              idJenisProduk: arguments?['idJenisProduk'],
              namaJenisProduk: arguments?['namaJenisProduk'],
              namaKelompokUjian: arguments?['namaKelompokUjian'],
              jumlahSoal: arguments?['jumlahSoal'],
              isRencanaPicker: arguments?['isRencanaPicker'] ?? false,
            );
        break;

      /// Route Menu Profiling
      case Constant.kRouteProfilingScreen:
        if (arguments != null) {
          screenTujuan = (_) =>
              ProfilingScreen(idJenisProduk: arguments?['idJenisProduk']);
        } else {
          screenTujuan = (_) => const ProfilingScreen();
        }
        break;

      /// Route Menu TOBK
      case Constant.kRouteTobkScreen:
        screenTujuan = (_) {
          return TobkScreen(
            idJenisProduk: arguments!['idJenisProduk'],
            namaJenisProduk: arguments['namaJenisProduk'],
            selectedKodeTOB: arguments['kodeTOB'],
            selectedNamaTOB: arguments['namaTOB'],
            diBukaDari: arguments['diBukaDari'],
          );
        };
        break;
      case Constant.kRoutePaketTOScreen:
        screenTujuan = (context) {
          final authOtpProvider = context.read<AuthOtpProvider>();
          context.read<LogProvider>().saveLog(
              userId: authOtpProvider.userData?.noRegistrasi,
              userType: authOtpProvider.userData?.siapa,
              menu: "TOBK",
              accessType: 'Masuk',
              info: arguments!['namaTOB']);
          context
              .read<LogProvider>()
              .sendLogActivity(authOtpProvider.userData?.siapa.toString());

          return PaketToScreen(
            idJenisProduk: arguments['idJenisProduk'],
            namaJenisProduk: arguments['namaJenisProduk'],
            kodeTOB: arguments['kodeTOB'],
            noRegistrasi: arguments['noRegistrasi'],
            namaTOB: arguments['namaTOB'],
            jarakAntarPaket: arguments['interval'],
            tanggalMulaiTO: arguments['tanggalMulai'],
            tanggalBerakhirTO: arguments['tanggalBerakhir'],
            daftarMataUjiPilihan: arguments['daftarMataUjiPilihan'],
            isFormatTOMerdeka: arguments['isFormatTOMerdeka'],
            isBolehLihatKisiKisi: arguments['isBolehLihatKisiKisi'],
            isTOBRunning: arguments['isTOBRunning'],
            isMemenuhiSyarat: arguments['isMemenuhiSyarat'],
            paramsLaporan: arguments['paramsLaporan'],
          );
        };
        break;
      case Constant.kRouteSoalBasicScreen:
        if (kDebugMode) {
          logger.log('ROUTE-SoalBasicScreen: arg-exp >> '
              '${arguments?['tanggalKedaluwarsa']}');
          if ((arguments?['tanggalKedaluwarsa'] != null)) {
            logger.log('ROUTE-SoalBasicScreen: exp to date time >>'
                ' ${DataFormatter.stringToDate(arguments?['tanggalKedaluwarsa'])}');
          }
        }
        screenTujuan = (context) {
          String? jenisProduk;
          switch (arguments!['idJenisProduk']) {
            case 65:
              jenisProduk = 'VAK';
              break;
            case 71:
              jenisProduk = 'Empati Mandiri';
              break;
            case 72:
              jenisProduk = 'Empati Wajib';
              break;
            case 76:
              jenisProduk = 'Latihan Extra';
              break;
            case 77:
              jenisProduk = 'Paket Intensif';
              break;
            case 78:
              jenisProduk = 'Paket Soal Koding';
              break;
            case 79:
              jenisProduk = 'Pendalaman Materi';
              break;
            case 82:
              jenisProduk = 'Soal Referensi';
              break;
            default:
              break;
          }
          final authOtpProvider = context.read<AuthOtpProvider>();
          context.read<LogProvider>().saveLog(
              userId: authOtpProvider.userData?.noRegistrasi,
              userType: authOtpProvider.userData?.siapa,
              menu: jenisProduk,
              accessType: 'Masuk',
              info:
                  "${(arguments['namaKelompokUjian'] != null) ? arguments['namaKelompokUjian'] : ''}"
                  "${(arguments['namaKelompokUjian'] != null) ? ', ' : ''}${arguments['kodePaket']}"
                  "${(arguments['namaBab'] != null) ? ', ' : ''}"
                  "${(arguments['namaBab'] != null) ? arguments['namaBab'] : ''}");
          context
              .read<LogProvider>()
              .sendLogActivity(authOtpProvider.userData?.siapa.toString());

          return SoalBasicScreen(
            opsiUrutBundel: arguments['opsiUrut'],
            idJenisProduk: arguments['idJenisProduk'],
            namaJenisProduk: arguments['namaJenisProduk'],
            diBukaDariRoute: arguments['diBukaDariRoute'],
            kodeTOB: arguments['kodeTOB'],
            kodePaket: arguments['kodePaket'],
            idBundel: arguments['idBundel'],
            kodeBab: arguments['kodeBab'],
            namaBab: arguments['namaBab'],
            namaKelompokUjian: arguments['namaKelompokUjian'],
            mulaiDariSoalNomor: arguments['mulaiDariSoalNomor'] ?? 1,
            tanggalKedaluwarsa: (arguments['tanggalKedaluwarsa'] != null)
                ? DataFormatter.stringToDate(arguments['tanggalKedaluwarsa'])
                : null,
            isPaket: arguments['isPaket'] ?? false,
            isBisaBookmark: arguments['isBisaBookmark'] ?? true,
            isSimpan: arguments['isSimpan'] ?? true,
          );
        };
        break;
      case Constant.kRouteSoalTimerScreen:
        screenTujuan = (_) => SoalTimerScreen(
              kodeTOB: arguments?['kodeTOB'],
              kodePaket: arguments?['kodePaket'],
              idJenisProduk: arguments?['idJenisProduk'],
              namaJenisProduk: arguments?['namaJenisProduk'],
              waktuPengerjaan: arguments?['waktu'],
              tanggalSelesai: arguments?['tanggalSelesai'],
              tanggalSiswaSubmit: arguments?['tanggalSiswaSubmit'],
              tanggalKedaluwarsaTOB: arguments?['tanggalKedaluwarsaTOB'],
              isBlockingTime: arguments?['isBlockingTime'] ?? true,
              isPernahMengerjakan: arguments?['isPernahMengerjakan'] ?? false,
              isRandom: arguments?['isRandom'] ?? false,
              isBolehLihatSolusi: arguments?['isBolehLihatSolusi'] ?? false,
              isRemedialGOA: (arguments?['idJenisProduk'] == 12)
                  ? (arguments?['isRemedialGOA'] ?? false)
                  : false,
            );
        break;

      /// Route Leaderboard
      // Route Leaderboard Buku Sakti
      case Constant.kRouteJuaraBukuSaktiScreen:
        screenTujuan =
            (_) => JuaraBukuSaktiScreen(juaraType: arguments!['juaraType']);
        break;

      // Route Leaderboard Racing Soal
      case Constant.kRouteLeaderBoardRacing:
        screenTujuan = (_) => const RacingLeaderboard();
        break;

      /// Route Berita
      case Constant.kRouteDetailGoNews:
        screenTujuan = (_) => DetailGoNewsScreen(berita: arguments!['berita']);
        break;
      case Constant.kRouteGoNews:
        screenTujuan = (_) => const GoNewsScreen();
        break;

      /// Route Menu Buku Teori & Buku Rumus
      case Constant.kRouteBukuTeoriScreen:
        screenTujuan = (_) => const BukuTeoriScreen();
        break;
      // Route list Bab Buku Teori/Rumus
      case Constant.kRouteBabTeoriScreen:
        screenTujuan = (_) => BabTeoriScreen(
              jenisBuku: arguments!['jenisBuku'],
              buku: arguments['buku'],
              isRencanaPicker: arguments['isRencanaPicker'],
            );
        break;
      // Route Content Buku Teori/Rumus
      case Constant.kRouteBukuTeoriContent:
        screenTujuan = (context) {
          final authOtpProvider = context.read<AuthOtpProvider>();
          context.read<LogProvider>().saveLog(
                userId: authOtpProvider.userData?.noRegistrasi,
                userType:
                    authOtpProvider.userData?.siapa ?? authOtpProvider.userType,
                menu: (arguments?['jenisBuku'] == 'teori')
                    ? 'Buku Teori'
                    : 'Buku Rumus',
                accessType: 'Masuk',
                info:
                    '${arguments?['namaMataPelajaran']}, ${arguments?['namaBabSubBab']}',
              );
          context
              .read<LogProvider>()
              .sendLogActivity(authOtpProvider.userData?.siapa.toString());

          return TeoriContentScreen(
            kodeBab: arguments!['kodeBab'],
            jenisBuku: arguments['jenisBuku'],
            namaBabUtama: arguments['namaBabUtama'],
            daftarIsi: arguments['daftarIsi'],
            levelTeori: arguments['levelTeori'],
            kelengkapan: arguments['kelengkapan'],
            namaMataPelajaran: arguments['namaMataPelajaran'],
            // listIdTeoriBabAwal: arguments['listIdTeoriBabAwal'],
          );
        };
        break;

      /// Route Bookmark
      case Constant.kRouteBookmark:
        screenTujuan = (_) => BookmarkScreen(
            idKelompokUjian: arguments!['idKelompokUjian'],
            namaKelompokUjian: arguments['namaKelompokUjian']);
        break;

      /// Route Menu Rencana Belajar
      case Constant.kRouteRencanaBelajar:
        screenTujuan = (_) => const RencanaBelajarScreen();
        break;

      /// Route Rencana Belajar Editor
      case Constant.kRouteRencanaEditor:
        if (kDebugMode) {
          logger.log('ROUTE-GoToRencanaEditor: with arg >> $arguments');
        }
        screenTujuan = (_) =>
            RencanaEditorScreen(rencanaBelajar: arguments!['rencanaBelajar']);
        break;

      /// Route Kampus Impian
      case Constant.kRouteImpian:
        screenTujuan = (_) => const KampusImpianScreen();
        break;

      /// Route Kampus Impian Picker
      case Constant.kRouteImpianPicker:
        screenTujuan = (_) => KampusImpianPickerScreen(
              pilihanKe: arguments?['pilihanKe'] ?? 1,
              kampusPilihan: arguments?['kampusPilihan'],
            );
        break;

      /// Route Menu SNBT
      case Constant.kRouteSNBT:
        screenTujuan = (_) => const SNBTScreen();
        break;
      // Route Simulasi SNBT
      case Constant.kRouteSimulasiPilihanForm:
        screenTujuan = (_) =>
            SimulasiPilihanFormScreen(pilihanModel: arguments!['pilihanModel']);
        break;
      case Constant.kRouteSimulasi:
        screenTujuan = (_) => const SimulasiScreen();
        break;
      // Route Video Teori dan Video Rumus
      case Constant.kRouteVideoPlayer:
        screenTujuan = (context) {
          final video = arguments!['video'];
          final authOtpProvider = context.read<AuthOtpProvider>();
          context.read<LogProvider>().saveLog(
                userId: authOtpProvider.userData?.noRegistrasi,
                userType:
                    authOtpProvider.userData?.siapa ?? authOtpProvider.userType,
                menu: "Video",
                accessType: 'Masuk',
                info: "${arguments['namaMataPelajaran']}, ${video.judulVideo}",
              );
          context
              .read<LogProvider>()
              .sendLogActivity(authOtpProvider.userData?.siapa.toString());

          return VideoPlayerScreen(
            video: arguments['video'],
            daftarVideo: arguments['daftarVideo'],
            kodeBab: arguments['kodeBab'],
            namaBab: arguments['namaBab'],
            namaMataPelajaran: arguments['namaMataPelajaran'],
          );
        };
        break;
      // Route Menu Jadwal
      case Constant.kRouteJadwal:
        screenTujuan = (_) => const JadwalScreen();
        break;
      // Route List Bab Video Jadwal
      case Constant.kRouteVideoJadwalBab:
        screenTujuan = (_) => BabVideoJadwalScreen(
              idMataPelajaran: arguments!['idMataPelajaran'],
              namaMataPelajaran: arguments['namaMataPelajaran'],
              tingkatSekolah: arguments['tingkatSekolah'],
              isRencanaPicker: arguments['isRencanaPicker'],
            );
        break;
      // Route Menu Laporan
      case Constant.kRouteLaporan:
        screenTujuan = (_) => const MenuLaporanScreen();
        break;
      // Laporan Kuis
      case Constant.kRouteLaporanQuiz:
        screenTujuan = (_) => const LaporanQuizScreen();
        break;
      // Laporan TOBK
      case Constant.kRouteLaporanTryOut:
        screenTujuan = (_) => const LaporanTryoutScreen();
        break;
      // Laporan Presensi
      case Constant.kRouteLaporanPresensi:
        screenTujuan = (_) => const LaporanPresensiScreen();
        break;
      // Laporan Aktivitas
      case Constant.kRouteLaporanAktivitas:
        screenTujuan = (_) => const LaporanAktivitasScreen();
        break;
      // Laporan Feedback
      case Constant.kRouteFeedback:
        screenTujuan = (_) => FeedbackScreen(
            idRencana: arguments!['idRencana'],
            namaPengajar: arguments['namaPengajar'],
            tanggal: arguments['tanggal'],
            kelas: arguments['kelas'],
            mapel: arguments['mapel'],
            flag: arguments['flag'],
            done: arguments['done']);
        break;
      // Laporan Tryout Detail Nilai
      case Constant.kRouteLaporanTryOutNilai:
        screenTujuan = (_) => LaporanTryoutNilaiScreen(
              penilaian: arguments!['penilaian'],
              kodeTOB: arguments['kodeTOB'],
              namaTOB: arguments['namaTOB'],
              isExist: arguments['isExists'],
              link: arguments['link'],
              jenisTO: arguments['jenisTO'],
              showEPB: arguments['showEPB'],
            );
        break;
      // Laporan EPB
      case Constant.kRouteLaporanTryOutViewer:
        screenTujuan = (_) => LaporanTryoutEPBScreen(
              title: arguments!['title'],
              link: arguments['link'],
            );
        break;
      // Share Laporan Hasil Tryout
      case Constant.kRouteLaporanTryOutShare:
        screenTujuan = (_) => LaporanTryoutShareScreen(
              chart: arguments!['chart'],
              pilihan: arguments['pilihan'],
            );
        break;

      /// Route Sosial
      case Constant.kRouteSosial:
        screenTujuan = (_) => const SosialScreen();
        break;
      // Route Feed Comment
      case Constant.kRouteFeedComment:
        screenTujuan = (_) => FeedCommentScreen(
              feed: arguments!['feed'],
              noRegistrasi: arguments['noRegistrasi'],
              namaLengkap: arguments['namaLengkap'],
              userType: arguments['userType'],
            );
        break;
      // Route Friends
      case Constant.kRouteFriendsProfile:
        screenTujuan = (_) => FriendsProfileScreen(
              namaLengkap: arguments!['nama'],
              noRegistrasi: arguments['noregistrasi'],
              userType: arguments['role'],
              kelas: arguments['kelas'],
              status: arguments['status'],
              score: arguments['score'],
            );
        break;
      default:
        // Sama dengan 404 not found.
        // Jika ada route name yg tidak terdaftar maka akan memicu halaman ini.
        screenTujuan = (_) => PageNotFound(route: settings.name ?? 'undefined');
    }
    // Execute methodChannel for prevent screenshot in specific page.
    // Jangan lupa mematikan secure screen saat On Will Pop Scope.
    // dengan cara menjalankan PlatformChannel.setSecureScreen('RANDOM STRING')
    // PlatformChannel.setSecureScreen(settings.name);
    // Future.delayed(Duration(milliseconds: 200));
    if (kDebugMode) {
      logger.log('SCREEN-NAME: ${settings.name}');
      logger.log('GENERATE ROUTE: arguments >> $arguments');
    }
    return MaterialPageRoute(builder: screenTujuan, settings: settings);
  }
}
