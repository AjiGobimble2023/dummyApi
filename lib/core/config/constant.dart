import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:base32/base32.dart';

import 'extensions.dart';
import '../../features/profile/model/about_model.dart';

class Constant {
  /// Base API Section
  /// [kKreasiBaseHost] merupakan host url dari API GO Kreasi.
  /// [kKreasiBasePath] merupakan base path dari API GO Kreasi V3.
  /// Adapun opsi key pada dot ENV sebagai berikut:
  /// 1) http://kreasi.ganeshaoperation.com/apigokreasiios/api/v3
  /// --- ['BASE_URL_KREASI'] = kreasi.ganeshaoperation.com
  /// --- ['BASE_PATH_V3'] = /apigokreasiios/api/v3
  ///
  /// 2) http://kreasi.ganeshaoperation.com/apigokreasiios/api/
  /// --- ['BASE_URL_KREASI'] = kreasi.ganeshaoperation.com
  /// --- ['BASE_PATH_21'] = /apigokreasiios/api
  ///
  /// 3) http://kreasi.ganeshaoperation.com:8081/apigokreasiios/api/
  /// --- ['BASE_URL_KREASI_8081'] = kreasi.ganeshaoperation.com:8081
  /// --- ['BASE_PATH_8081'] = /apigokreasiios/api/kreasi/v4
  /// Jika ingin mengubah sumber Host API tinggal ikuti list di atas.
  /// Jika ingin menambahkan opsi, tambahkan pada file .env project ini.
  static final String kKreasiBaseHost = dotenv.env['BASE_URL_KREASI_8081']!;
  static final String kKreasiBasePath = '${dotenv.env['BASE_PATH_8081']}';

  /// [kCarouselBaseHost] + [kCarouselBasePath] merupakan API untuk get Carousal Image GO Kreasi.
  /// http://go-learn.web.id/KreasiNew/slider/data.php
  /// [kCarouselBaseHost] = go-learn.web.id
  /// [kCarouselBasePath] = /KreasiNew/slider/data.php
  static final String kCarouselBaseHost = dotenv.env['CAROUSEL_BASE_URL']!;

  /// [kCarouselBasePath] = /KreasiNew/slider/data.php
  static final String kCarouselBasePath = dotenv.env['CAROUSEL_BASE_PATH']!;

  static final String kVideoCredential = dotenv.env['CREDENTIAL_AUTH']!;
  static final String kStreamTokenBaseHost =
      dotenv.env['STREAM_TOKEN_BASE_URL']!;
  static final String kStreamTokenBasePath =
      dotenv.env['STREAM_TOKEN_BASE_PATH']!;

  // Assets Path
  static const String kImageAssetsPath = 'assets/images';
  static const String kImageLocalAssetsPath = 'assets/img';

  // Routes Section
  static const String kRouteUpdateScreen = '/update';
  static const String kRouteMainScreen = '/main';
  static const String kRouteNotifikasi = '/notifikasi';
  static const String kRouteAuthScreen = '/auth';
  static const String kRouteOTPScreen = '/otp';
  static const String kRouteStoryBoardScreen = '/story-board';
  static const String kRouteProfileScreen = '/profile';
  static const String kRouteEditProfileScreen = '/profile/edit';
  static const String kRouteAboutScreen = '/about';
  static const String kRouteTataTertibScreen = '/tata-tertib';
  static const String kRouteBantuanScreen = '/pusat-bantuan';
  static const String kRouteBantuanWebViewScreen = '/bantuan-web-view';
  static const String kRouteGoNews = '/go-news';
  static const String kRouteDetailGoNews = '/go-news/detail';
  static const String kRouteJuaraBukuSaktiScreen = '/juara/buku-sakti';
  static const String kRouteBookmark = '/bookmark';
  static const String kRouteBukuSoalScreen = '/buku-soal';
  static const String kRouteBabBukuSoalScreen = '/buku-soal/bab';
  static const String kRouteProfilingScreen = '/profiling';
  static const String kRouteTobkScreen = '/tobk';
  static const String kRouteSoalBasicScreen = '/soal-screen/basic';
  static const String kRouteSoalTimerScreen = '/soal-screen/timer';
  static const String kRouteVideoSolusi = '/video/solusi';
  static const String kRoutePaketTOScreen = '/paket-to';
  static const String kRouteBukuTeoriScreen = '/buku-teori';
  static const String kRouteBabTeoriScreen = '/buku-teori/bab';
  static const String kRouteBukuTeoriContent = '/buku-teori/content';
  static const String kRouteRencanaBelajar = '/rencana/calendar';
  static const String kRouteRencanaEditor = '/rencana/editor';
  static const String kRouteRencanaPicker = '/rencana/picker';
  static const String kRouteImpian = '/impian';
  static const String kRouteImpianPicker = '/impian/picker';

  /// SNBT (Seleksi Nasional Berbasis Tes), pengganti SBMPTN.
  static const String kRouteSNBT = '/snbt';
  static const String kRouteSimulasi = '/simulasi';
  static const String kRouteSimulasiNilai = '/simulasi/nilai';
  static const String kRouteSimulasiSimulasi = '/simulasi/simulasi';
  static const String kRouteSimulasiPilihan = '/simulasi/pilihan';
  static const String kRouteSimulasiPilihanForm = '/simulasi/pilihan/form';
  static const String kRouteJadwal = '/jadwal';
  static const String kRouteVideoPlayer = '/video-player';
  static const String kRouteVideoJadwalBab = '/video-jadwal/bab';
  static const String kRouteFeedback = '/feedback';
  static const String kRouteLaporan = '/laporan';
  static const String kRouteLaporanVak = '/laporan/vak';
  static const String kRouteLaporanQuiz = '/laporan/quiz';
  static const String kRouteLaporanPresensi = '/laporan/presensi';
  static const String kRouteLaporanAktivitas = '/laporan/aktivitas';
  static const String kRouteLaporanTryOut = '/laporan/tryout';
  static const String kRouteLaporanTryOutNilai = '/laporan/tryout/nilai';
  static const String kRouteLaporanTryOutViewer = '/laporan/tryout/viewer';
  static const String kRouteLaporanTryOutShare = '/laporan/tryout/share';
  static const String kRouteFeedComment = '/feed-comment';
  static const String kRouteLeaderBoardRacing = '/leaderboard-racing';
  static const String kRouteFriendsProfile = '/friends/profile';
  static const String kRouteSosial = '/sosial';

  static final String secretOTP =
      base32.encodeHexString(dotenv.env['SECRET_OTP']!);

  // Static Values
  static const List<Map<String, dynamic>> kUserRole = [
    {
      'label': 'Siswa',
      'value': 'SISWA',
    },
    {
      'label': 'Orang Tua Siswa',
      'value': 'ORTU',
    },
    {
      'label': 'Tamu',
      'value': 'TAMU',
    },
  ];

  // Static Value Tahun Ajaran
  static const String kTahunAjaran = '2023/2024';

  // Story Board
  static final Map<String, Map<String, dynamic>> kStoryBoard = {
    'Profiling': {
      'imgUrl': 'ilustrasi_profiling.png'.illustration,
      'title': 'Profiling',
      'subTitle':
          'GOA (GO Assessment) dan\nVAK (Visual, Auditori, dan Kinestetik)',
      'storyText':
          'Dengan profiling, Sobat bisa tau kelemahan kamu ada di mata pelajaran mana. Sobat juga bisa tau gaya belajar seperti apasih yang cocok untuk Sobat. Jadi proses belajar Sobat bisa lebih maksimal lagi.',
    },
    'Jadwal': {
      'imgUrl': 'ilustrasi_jadwal_belajar.png'.illustration,
      'title': 'Jadwal Belajar',
      'subTitle':
          'Daftar jadwal KBM dan TST Sobat ada di sini, jangan sampai terlewat ya!',
      'storyText':
          'Dengan TST, kamu bisa janjian dengan pengajar favorit kamu untuk mendalami materi yang belum dipahami Sobat! Oyaa, jangan lupa berikan masukan melalui Feedback Pengajaran supaya pelayanan yang SobatGO terima jadi semakin memuaskan!',
    },
    'Rencana': {
      'imgUrl': 'ilustrasi_rencana_belajar.png'.illustration,
      'title': 'Rencana Belajar',
      'subTitle':
          'Rencana belajar Sobat untuk persiapan maksimal saat bertanding!',
      'storyText':
          'SobatGO bisa membuat jadwal rencana belajar mulai dari waktu belajar hingga materi apa yang akan SobatGO pelajari, nanti GOKreasi akan bantu ingatkan waktu-waktu belajar SobatGO.',
    },
    'Laporan': {
      'imgUrl': 'ilustrasi_laporan_aktivitas.png'.illustration,
      'title': 'Laporan',
      'subTitle': 'Semua hasil belajar kamu bisa dilihat disini Sobat!',
      'storyText':
          'Segala jenis laporan akan ditampilkan dengan sederhana dan mudah dipahami. '
              'Kamu bisa cek mulai dari Laporan Presensi, Juara Racing, Pembayaran, hingga Log Aktivitas kamu loh Sobat.',
    },
    'SNBT': {
      'imgUrl': 'ilustrasi_sbmptn.png'.illustration,
      'title': 'SNBT',
      'subTitle': 'Seleksi Nasional Berbasis Tes',
      'storyText':
          'Di sini kamu bisa memilih jurusan-PTN yang kamu idamkan dan cek seberapa besar '
              'kemungkinan kamu lulus ke sana. Jadi kampus impian kamu bisa lebih terukur Sobat.',
    },
    'Impian': {
      'imgUrl': 'ilustrasi_kampus_impian.png'.illustration,
      'title': 'Kampus Impian',
      'subTitle': 'Yuk atur target kampus impian kamu!',
      'storyText':
          'Sobat bisa mengatur target kampus yang Sobat mau. Dan dengan PTN-Clopedia, Sobat bisa tau akan seperti apasih jurusan yang Sobat impikan itu? Jadi Sobat tidak perlu takut salah jurusan.',
    },
    'Bookmark': {
      'imgUrl': 'ilustrasi_bookmark.png'.illustration,
      'title': 'My Bookmark',
      'subTitle': 'Sobat pernah kesulitan saat ingin\nmenanyakan soal latihan?',
      'storyText':
          'Dengan fitur ini, Sobat bisa menyimpan soal yang sulit loh. Jadi Sobat tidak perlu khawatir akan lupa saat ada kesempatan bertanya kepada Pengajar.',
    },
    'Nilaimu': {
      'imgUrl': 'ilustrasi_nilaimu.png'.illustration,
      'title': 'Capaian dan Grafik',
      'subTitle': 'Yuk penuhi target dan lihat progres latihan kamu Sobat!',
      'storyText':
          'Sobat bisa melihat progres pengerjaan soal tiap bidang studi. Progress pengerjaan soal dihitung dari menu Buku Sakti yaitu Empati Wajib, Empati Mandiri, dan Latihan Ekstra.',
    },
    'Juara Buku Sakti': {
      'imgUrl': 'ilustrasi_leaderboard.png'.illustration,
      'title': 'Juara Buku Sakti',
      'subTitle': 'Kamu peringkat berapa sobat?',
      'storyText':
          'Sobat bisa melihat Ranking di tingkat Gedung, Kota, dan Nasional untuk lebih memotivasi kamu dalam belajar.',
    }
  };

  static const List<Map<String, String>> kDataSekolahKelas = [
    {'id': '1', 'kelas': '1 SD DASAR', 'tingkat': 'SD', 'tingkatKelas': '1'},
    {'id': '2', 'kelas': '2 SD DASAR', 'tingkat': 'SD', 'tingkatKelas': '2'},
    {'id': '3', 'kelas': '3 SD DASAR', 'tingkat': 'SD', 'tingkatKelas': '3'},
    {'id': '4', 'kelas': '4 SD DASAR', 'tingkat': 'SD', 'tingkatKelas': '4'},
    {'id': '5', 'kelas': '5 SD DASAR', 'tingkat': 'SD', 'tingkatKelas': '5'},
    {'id': '6', 'kelas': '6 SD DASAR', 'tingkat': 'SD', 'tingkatKelas': '6'},
    {'id': '7', 'kelas': '7 SMP UMUM', 'tingkat': 'SMP', 'tingkatKelas': '7'},
    {'id': '8', 'kelas': '8 SMP UMUM', 'tingkat': 'SMP', 'tingkatKelas': '8'},
    {'id': '9', 'kelas': '9 SMP UMUM', 'tingkat': 'SMP', 'tingkatKelas': '9'},
    {'id': '10', 'kelas': '10 SMA MIA', 'tingkat': 'SMA', 'tingkatKelas': '10'},
    {'id': '34', 'kelas': '11 SMA MIA', 'tingkat': 'SMA', 'tingkatKelas': '11'},
    {'id': '35', 'kelas': '12 SMA MIA', 'tingkat': 'SMA', 'tingkatKelas': '12'},
    {'id': '12', 'kelas': '11 SMA IPA', 'tingkat': 'SMA', 'tingkatKelas': '11'},
    {'id': '14', 'kelas': '12 SMA IPA', 'tingkat': 'SMA', 'tingkatKelas': '12'},
    {'id': '13', 'kelas': '11 SMA IPS', 'tingkat': 'SMA', 'tingkatKelas': '11'},
    {'id': '15', 'kelas': '12 SMA IPS', 'tingkat': 'SMA', 'tingkatKelas': '12'},
    {'id': '11', 'kelas': '10 SMA IIS', 'tingkat': 'SMA', 'tingkatKelas': '10'},
    {'id': '36', 'kelas': '11 SMA IIS', 'tingkat': 'SMA', 'tingkatKelas': '11'},
    {'id': '37', 'kelas': '12 SMA IIS', 'tingkat': 'SMA', 'tingkatKelas': '12'},
    {'id': '39', 'kelas': '12 SMA IPC', 'tingkat': 'SMA', 'tingkatKelas': '12'},
    {
      'id': '18',
      'kelas': '10 SMK AKUNTANSI',
      'tingkat': 'SMA',
      'tingkatKelas': '10'
    },
    {
      'id': '38',
      'kelas': '11 SMK AKUNTANSI',
      'tingkat': 'SMA',
      'tingkatKelas': '11'
    },
    {
      'id': '32',
      'kelas': '12 SMK AKUNTANSI',
      'tingkat': 'SMA',
      'tingkatKelas': '12'
    },
    {
      'id': '16',
      'kelas': '10 SMK TEKNOLOGI',
      'tingkat': 'SMA',
      'tingkatKelas': '10'
    },
    {
      'id': '19',
      'kelas': '11 SMK TEKNOLOGI',
      'tingkat': 'SMA',
      'tingkatKelas': '11'
    },
    {
      'id': '22',
      'kelas': '12 SMK TEKNOLOGI',
      'tingkat': 'SMA',
      'tingkatKelas': '12'
    },
    {
      'id': '17',
      'kelas': '10 SMK PARIWISATA',
      'tingkat': 'SMA',
      'tingkatKelas': '10'
    },
    {
      'id': '20',
      'kelas': '11 SMK PARIWISATA',
      'tingkat': 'SMA',
      'tingkatKelas': '11'
    },
    {
      'id': '23',
      'kelas': '12 SMK PARIWISATA',
      'tingkat': 'SMA',
      'tingkatKelas': '12'
    },
    {
      'id': '25',
      'kelas': '10 SMA UMUM',
      'tingkat': 'SMA',
      'tingkatKelas': '10'
    },
    {
      'id': '41',
      'kelas': '12 SMA UMUM',
      'tingkat': 'SMA',
      'tingkatKelas': '12'
    },
    {
      'id': '26',
      'kelas': '11 UMUM UMUM',
      'tingkat': 'SMA',
      'tingkatKelas': '11'
    },
    {
      'id': '27',
      'kelas': '12 UMUM UMUM',
      'tingkat': 'SMA',
      'tingkatKelas': '12'
    },
    {
      'id': '28',
      'kelas': '13 ALUMNI IPA',
      'tingkat': 'ALUMNI',
      'tingkatKelas': '13'
    },
    {
      'id': '29',
      'kelas': '13 ALUMNI IPS',
      'tingkat': 'ALUMNI',
      'tingkatKelas': '13'
    },
    {
      'id': '30',
      'kelas': '13 UMUM UMUM',
      'tingkat': 'Other',
      'tingkatKelas': '13'
    },
    {
      'id': '31',
      'kelas': '0 UMUM UMUM',
      'tingkat': 'Other',
      'tingkatKelas': '0'
    },
  ];

  static const List<int> kSemester = [1, 2, 3];

  // static const List<String> kTicketCriteria = [
  //   'Lain-lain',
  //   'Pembayaran',
  //   'Pengajaran',
  //   'Fasilitas',
  //   'Informasi Produk',
  // ];

  static const List<String> kKelompok = ['SAINTEK', 'SOSHUM', 'CAMPURAN'];

  // TODO: Ganti sesuai kebutuhan dari BPPPS / BMP.
  /// [kKelompokUjianPilihan] merupakan list dari kelompok ujian pilihan masing-masing tingkat.
  static const Map<String, List<int>> kKelompokUjianPilihan = {
    'SD': [],
    'SMP': [],
    'SMA': [6, 32, 35, 36, 48, 51, 50, 114, 123],
  };

  // TODO: Mengikuti perubahan dari db_bhanksoalV2.t_MataPelajaran.
  static const Map<int, Map<String, String>> kInitialMapel = {
    1: {'nama': 'Matematika', 'initial': 'MAT'},
    2: {'nama': 'Fisika', 'initial': 'FIS'},
    3: {'nama': 'Kimia', 'initial': 'KIM'},
    4: {'nama': 'Biologi', 'initial': 'BIO'},
    5: {'nama': 'Bahasa Inggris', 'initial': 'ING'},
    6: {'nama': 'Bahasa Indonesia', 'initial': 'IND'},
    7: {'nama': 'Sejarah', 'initial': 'SEJ'},
    8: {'nama': 'Geografi', 'initial': 'GEO'},
    9: {'nama': 'Ekonomi', 'initial': 'EKO'},
    10: {'nama': 'Sosiologi', 'initial': 'SOS'},
    11: {'nama': 'Ilmu Pengetahuan Alam', 'initial': 'IPA'},
    12: {'nama': 'Tes Potensi Skolastik', 'initial': 'TPS'},
    13: {'nama': 'Ilmu Pengetahuan Sosial', 'initial': 'IPS'},
    14: {'nama': 'Bahasa Sunda', 'initial': 'SUN'},
    15: {'nama': 'Pendidikan Pancasila dan Kewarganegaraan', 'initial': 'PPKn'},
    16: {'nama': 'Matematika Wajib', 'initial': 'MAW'},
    17: {'nama': 'Matematika Peminatan', 'initial': 'MAP'},
    18: {'nama': 'Matematika 1', 'initial': 'MAT1'},
    19: {'nama': 'Fisika 1', 'initial': 'FIS1'},
    20: {'nama': 'Kimia 1', 'initial': 'KIM1'},
    21: {'nama': 'Biologi 1', 'initial': 'BIO1'},
    22: {'nama': 'Bahasa Inggris 1', 'initial': 'ING1'},
    23: {'nama': 'Bahasa Indonesia 1', 'initial': 'IND1'},
    24: {'nama': 'Sejarah 1', 'initial': 'SEJ1'},
    25: {'nama': 'Geografi 1', 'initial': 'GEO1'},
    26: {'nama': 'Ekonomi 1', 'initial': 'EKO1'},
    27: {'nama': 'Sosiologi 1', 'initial': 'SOS1'},
    28: {'nama': 'IPA (Fisika)', 'initial': 'FIS'},
    29: {'nama': 'IPA (Kimia)', 'initial': 'KIM'},
    30: {'nama': 'IPA (Biologi)', 'initial': 'BIO'},
    31: {'nama': 'TPS Indonesia', 'initial': 'TPS'},
    32: {'nama': 'IPS (Sejarah)', 'initial': 'SEJ'},
    33: {'nama': 'IPS (Ekonomi)', 'initial': 'EKO'},
    34: {'nama': 'IPS (Geografi)', 'initial': 'GEO'},
    35: {'nama': 'IPS (Sosiologi)', 'initial': 'SOS'},
    36: {'nama': 'Pendidikan Kewarganegaraan', 'initial': 'PKN'},
    37: {'nama': 'Matemetika Saintek', 'initial': 'MSA'},
    38: {'nama': 'Matematika Soshum', 'initial': 'MSOS'},
    39: {'nama': 'TPS Matematika', 'initial': 'TPSM'},
    40: {'nama': 'TPS Inggris', 'initial': 'TPSI'},
    41: {'nama': 'TPS Komputer', 'initial': 'TPSK'},
    42: {'nama': 'Tes Potensi Akademik', 'initial': 'TPA'},
    43: {'nama': 'TPA Verbal', 'initial': 'TPAV'},
    44: {'nama': 'TPA Numerik', 'initial': 'TPAN'},
    45: {'nama': 'TPA Logika', 'initial': 'TPAL'},
    46: {'nama': 'TPS IND-TM', 'initial': 'TPSIN'},
    47: {'nama': 'TPS ING-TM', 'initial': 'TPSIG'},
    48: {'nama': 'TPS KOM-TM', 'initial': 'TPSK'},
    49: {'nama': 'TPS MAT-TM', 'initial': 'TPSM'},
    50: {'nama': 'Pengarahan', 'initial': 'PE'},
    51: {'nama': 'AKM Literasi Membaca', 'initial': 'AKMB'},
    52: {'nama': 'AKM Literasi Numerasi', 'initial': 'AKMN'},
    53: {'nama': 'AKM Literasi Sains', 'initial': 'AKMS'},
    54: {'nama': 'TPS PU', 'initial': 'TPSPU'},
    55: {'nama': 'TPS PPU', 'initial': 'TPSP'},
    56: {'nama': 'TPS PBM', 'initial': 'TPSB'},
    57: {'nama': 'TPS PK', 'initial': 'TPSP'},
    58: {'nama': 'Informatika', 'initial': 'INF'},
    59: {'nama': 'Antropologi', 'initial': 'ANT'},
    60: {'nama': 'Tes Karakteristik Pribadi', 'initial': 'TKP'},
    61: {'nama': 'Psikotes', 'initial': 'PSI'},
    62: {'nama': 'Pengetahuan Umum', 'initial': 'PEU'},
    63: {'nama': 'Pendidikan Agama', 'initial': 'PAG'},
    64: {'nama': 'Penjaskes', 'initial': 'PJKS'},
    65: {'nama': 'Seni Budaya', 'initial': 'SBDP'},
    66: {'nama': 'VAK-Visual', 'initial': 'VAKV'},
    67: {'nama': 'VAK-Auditori', 'initial': 'VAKA'},
    68: {'nama': 'VAK-Kinestetik', 'initial': 'VAKK'},
    69: {'nama': 'MBTI Bagian I', 'initial': 'MBTI1'},
    70: {'nama': 'MBTI Bagian II', 'initial': 'MBTI2'},
    71: {'nama': 'MBTI Bagian III', 'initial': 'MBTI3'},
    72: {'nama': 'Seni Tari', 'initial': 'ST'},
    73: {'nama': 'Informatika', 'initial': 'INF'},
    74: {
      'nama': 'Kemampuan Kuantitatif dan Penalaran Matematika 2',
      'initial': 'KK+PM2'
    },
    75: {
      'nama': 'Kemampuan Penalaran Umum dan Penalaran Matematika 1',
      'initial': 'KPU+PM'
    },
    76: {'nama': 'Literasi Dalam Bahasa Indonesia', 'initial': 'LND'},
    77: {'nama': 'Literasi Dalam Bahasa Inggris', 'initial': 'LNG'},
    78: {'nama': 'BAHASA INDONESIA - UTBK', 'initial': 'INDO-U'},
    79: {'nama': 'TES POTENSI AKADEMIK', 'initial': 'TPA'},
  };

  // TODO: Mengikuti perubahan dari db_bhanksoalV2.t_KelompokUjian.
  static const Map<int, Map<String, String>> kInitialKelompokUjian = {
    1: {'nama': 'MATEMATIKA', 'initial': 'MAT'},
    2: {'nama': 'MATEMATIKA WAJIB', 'initial': 'MAW'},
    3: {'nama': 'MATEMATIKA PEMINATAN', 'initial': 'MAP'},
    4: {'nama': 'MATEMATIKA SAINTEK', 'initial': 'MATSAIN'},
    5: {'nama': 'MATEMATIKA SOSHUM', 'initial': 'MATSOS'},
    6: {'nama': 'MATEMATIKA TINGKAT LANJUT', 'initial': 'MATLAN'},
    7: {'nama': 'MATEMATIKA TEKNOLOGI', 'initial': 'MATTEK'},
    8: {'nama': 'MATEMATIKA PARIWISATA', 'initial': 'MATPAR'},
    9: {'nama': 'MATEMATIKA AKUNTANSI', 'initial': 'MATAKT'},
    10: {'nama': 'MATEMATIKA DASAR', 'initial': 'MADAS'},
    11: {'nama': 'AKM NUMERASI', 'initial': 'AKMNUM'},
    12: {'nama': 'TPS - PENALARAN UMUM', 'initial': 'TPSPU'},
    13: {'nama': 'TPS - PENGETAHUAN KUANTITATIF', 'initial': 'TPSPK'},
    14: {'nama': 'TKD: TES INTELEGENSI UMUM', 'initial': 'TIU'},
    15: {'nama': 'KEMAMPUAN PENALARAN', 'initial': 'KPEN'},
    16: {'nama': 'NUMERIK/KUANTITATIF', 'initial': 'NUM'},
    17: {'nama': 'LOGIKA', 'initial': 'LOG'},
    18: {'nama': 'PENALARAN VERBAL', 'initial': 'PVER'},
    19: {'nama': 'PENALARAN NON VERBAL', 'initial': 'PNVER'},
    20: {'nama': 'FIGURAL & SPASIAL', 'initial': 'FIG'},
    21: {'nama': 'GOA - BAGIAN A', 'initial': 'GOAA'},
    22: {'nama': 'GOA - BAGIAN B', 'initial': 'GOAB'},
    23: {'nama': 'GOA - BAGIAN C', 'initial': 'GOAC'},
    24: {'nama': 'GOA - BAGIAN D', 'initial': 'GOAD'},
    25: {'nama': 'GOA - BAGIAN E', 'initial': 'GOAE'},
    26: {'nama': 'GOA - BAGIAN F', 'initial': 'GOAF'},
    27: {'nama': 'GOA - BAGIAN G', 'initial': 'GOAG'},
    28: {'nama': 'GOA - BAGIAN H', 'initial': 'GOAH'},
    29: {'nama': 'GOA - BAGIAN I', 'initial': 'GOAI'},
    30: {'nama': 'GOA - BAGIAN J', 'initial': 'GOAJ'},
    31: {'nama': 'IPA TERPADU', 'initial': 'IPAT'},
    32: {'nama': 'FISIKA', 'initial': 'FIS'},
    33: {'nama': 'ASTRONOMI', 'initial': 'AST'},
    34: {'nama': 'AKM SAINS', 'initial': 'AKMSAINS'},
    35: {'nama': 'KIMIA', 'initial': 'KIMIA'},
    36: {'nama': 'BIOLOGI', 'initial': 'BIO'},
    37: {'nama': 'BAHASA INGGRIS', 'initial': 'ING'},
    38: {'nama': 'BAHASA INGGRIS (KEDINASAN)', 'initial': 'INGKED'},
    39: {'nama': 'TES BAHASA INGGRIS', 'initial': 'TBI'},
    40: {'nama': 'BAHASA INDONESIA', 'initial': 'IND'},
    41: {'nama': 'AKM LITERASI', 'initial': 'AKMLIT'},
    42: {'nama': 'KEMAMPUAN VERBAL', 'initial': 'VER'},
    43: {'nama': 'TPS - PEMAHAMAN BACAAN DAN MENULIS', 'initial': 'TPSPBM'},
    44: {'nama': 'TPS - PENGETAHUAN DAN PEMAHAMAN UMUM', 'initial': 'TPSPPU'},
    45: {'nama': 'SEJARAH', 'initial': 'SEJ'},
    46: {'nama': 'TES WAWASAN KEBANGSAAN', 'initial': 'TWK'},
    47: {'nama': 'IPS TERPADU', 'initial': 'IPST'},
    48: {'nama': 'GEOGRAFI', 'initial': 'GEO'},
    49: {'nama': 'KEBUMIAN', 'initial': 'KEBUM'},
    50: {'nama': 'EKONOMI', 'initial': 'EKO'},
    51: {'nama': 'SOSIOLOGI', 'initial': 'SOS'},
    52: {'nama': 'IPA', 'initial': 'IPA'},
    53: {'nama': 'IPS', 'initial': 'IPS'},
    54: {'nama': 'IPAS', 'initial': 'IPAS'},
    55: {'nama': 'TKD: TES KARAKTERISTIK PRIBADI', 'initial': 'TKP'},
    56: {'nama': 'PSIKOTES', 'initial': 'PSI'},
    57: {'nama': 'PENGETAHUAN UMUM', 'initial': 'PENGU'},
    58: {'nama': 'PENDIDIKAN AGAMA', 'initial': 'PAG'},
    59: {'nama': 'PENJASKES', 'initial': 'PJKS'},
    60: {'nama': 'SENI BUDAYA', 'initial': 'SBD'},
    61: {'nama': 'VAK-VISUAL', 'initial': 'VAKV'},
    62: {'nama': 'VAK-AUDITORI', 'initial': 'VAKA'},
    63: {'nama': 'VAK-KINESTETIK', 'initial': 'VAKK'},
    64: {'nama': 'MBTI BAGIAN I', 'initial': 'MBTI1'},
    65: {'nama': 'MBTI BAGIAN II', 'initial': 'MBTI2'},
    66: {'nama': 'MBTI BAGIAN III', 'initial': 'MBTI3'},
    67: {'nama': 'PPKN', 'initial': 'PPKN'},
    68: {'nama': 'KEWARGANEGARAAN', 'initial': 'KWR'},
    69: {'nama': 'PENGARAHAN', 'initial': 'PENG'},
    70: {'nama': 'TEKNIK INFORMATIKA KOMPUTER', 'initial': 'TIK'},
    71: {'nama': 'ANTROPOLOGI', 'initial': 'ANTRO'},
    72: {'nama': 'TKD: TES KARAKTERISTIK PRIBADI', 'initial': 'TKP'},
    73: {'nama': 'PSIKOTES', 'initial': 'PSI'},
    74: {'nama': 'TPS', 'initial': 'TPS'},
    75: {'nama': 'BAHASA SUNDA', 'initial': 'B.SUN'},
    76: {'nama': 'IPA (FISIKA)', 'initial': 'FIS'},
    77: {'nama': 'IPA (KIMIA)', 'initial': 'KIM'},
    78: {'nama': 'IPA (BIOLOGI)', 'initial': 'BIO'},
    79: {'nama': 'TPS IND', 'initial': 'TPS'},
    80: {'nama': 'IPS (SEJARAH)', 'initial': 'SEJ'},
    81: {'nama': 'IPS (EKONOMI)', 'initial': 'EKO'},
    82: {'nama': 'IPS (GEOGRAFI)', 'initial': 'GEO'},
    83: {'nama': 'IPS (SOSIOLOGI)', 'initial': 'SOS'},
    84: {'nama': 'TPS MAT', 'initial': 'TPS MAT'},
    85: {'nama': 'TPS ING', 'initial': 'TPS ING'},
    86: {'nama': 'TPS KOM', 'initial': 'TPS KOM'},
    87: {'nama': 'TPA', 'initial': 'TPA'},
    88: {'nama': 'TPA (VER)', 'initial': 'TPA (VER)'},
    89: {'nama': 'TPA (NUM)', 'initial': 'TPA (NUM)'},
    90: {'nama': 'TPA (LOG)', 'initial': 'TPA (LOG)'},
    91: {'nama': 'TPS IND-TM', 'initial': 'TPS IND'},
    92: {'nama': 'TPS ING-TM', 'initial': 'TPS ING'},
    93: {'nama': 'TPS KOM-TM', 'initial': 'TPS KOM'},
    94: {'nama': 'TPS MAT-TM', 'initial': 'TPS MAT'},
    95: {'nama': 'AKM LITERASI MEMBACA', 'initial': 'AKM LIT'},
    96: {'nama': 'AKM LITERASI NUMERASI', 'initial': 'AKM NUM'},
    97: {'nama': 'AKM LITERASI SAINS', 'initial': 'AKM SAIN'},
    98: {'nama': 'TPS PU', 'initial': 'TPS PU'},
    99: {'nama': 'TPS PPU', 'initial': 'TPS PPU'},
    100: {'nama': 'TPS PBM', 'initial': 'TPS PBM'},
    101: {'nama': 'TPS PK', 'initial': 'TPS PK'},
    102: {'nama': 'BAHASA JEPANG', 'initial': 'B.JPG'},
    103: {'nama': 'AKM LITERASI', 'initial': 'AKMLIT'},
    104: {'nama': 'AKM SAINS', 'initial': 'AKM SAINS'},
    105: {'nama': 'TES KEMAMPUAN PRIBADI', 'initial': 'TKP'},
    106: {'nama': 'ILMU PENGETAHUAN ALAM', 'initial': 'IPA'},
    107: {'nama': 'POTENSI KOGNITIF', 'initial': 'PS'},
    108: {'nama': 'PENALARAN MATEMATIKA', 'initial': 'PM'},
    109: {'nama': 'LITERASI DALAM BAHASA INDONESIA', 'initial': 'LBI'},
    110: {'nama': 'LITERASI DALAM BAHASA INGGRIS', 'initial': 'LBING'},
    111: {'nama': 'MATEMATIKA UMUM', 'initial': 'MATUM'},
    112: {'nama': 'BAHASA INGGRIS UMUM', 'initial': 'INGUM'},
    113: {'nama': 'BAHASA INGGRIS TINGKAT LANJUT', 'initial': 'INGLAN'},
    114: {'nama': 'INFORMATIKA', 'initial': 'INF'},
    115: {'nama': 'MATEMATIKA 1', 'initial': 'MAT 1'},
    116: {'nama': 'MATEMATIKA 2', 'initial': 'MAT 2'},
    117: {'nama': 'PENALARAN MATEMATIKA 1', 'initial': 'PM 1'},
    118: {'nama': 'PENALARAN MATEMATIKA 2', 'initial': 'PM 2'},
    119: {'nama': 'Kemampuan Memahami Bacaan dan Menulis', 'initial': 'PMM'},
    120: {'nama': 'Bahasa Inggris Tingkat Lanjut', 'initial': 'INGLAN'},
    121: {'nama': 'KPU+PM 1', 'initial': 'KPU+PM1'},
    122: {'nama': 'KK+PM 2', 'initial': 'KK+PM 2'},
    123: {'nama': 'BAHASA INGGRIS TINGKAT LANJUT', 'initial': 'INGLAN'},
    124: {'nama': 'KEMAMPUAN PENALARAN UMUM', 'initial': 'KPU'},
    125: {'nama': 'PENGETAHUAN KUANTITATIF', 'initial': 'PK'},
    126: {'nama': 'KPU - PENALARAN INDUKTIF', 'initial': 'KPI'},
    127: {'nama': 'KPU - PENALARAN DEDUKTIF', 'initial': 'KPD'},
    128: {'nama': 'KPU - PENALARAN KUANTITATIF', 'initial': 'KPK'},
    129: {'nama': 'BAHASA INDONESIA - UTBK', 'initial': 'INDO - UTB'},
    130: {'nama': 'MATEMATIKA IPA', 'initial': 'MAIPA'},
    131: {'nama': 'TES POTENSI AKADEMIK', 'initial': 'TPA'},
    132: {'nama': 'KEMAMPUAN LOGIKA', 'initial': 'KLOG'},
    133: {'nama': 'KEMAMPUAN SPASIAL', 'initial': 'KSPA'},
    134: {'nama': 'KEMAMPUAN KUANTITATIF', 'initial': 'KKUAN'},
  };

  /// [kIconMataPelajaran] merupakan alamat icon pelajaran
  /// berdasarkan id mata pelajaran dan id kelompok ujian.
  static final Map<String, Map<String, List<int>>> kIconMataPelajaran = {
    // AKM
    'mapel_akm.webp'.mapel: {
      'idMapel': [51, 52, 53],
      'idKelompokUjian': [11, 34, 41, 95, 96, 97, 103, 104]
    },
    // BIOLOGI
    'mapel_biologi.webp'.mapel: {
      'idMapel': [4, 21, 30],
      'idKelompokUjian': [36, 78]
    },
    // EKONOMI
    'mapel_ekonomi.webp'.mapel: {
      'idMapel': [9, 26, 33],
      'idKelompokUjian': [50, 81]
    },
    // FISIKA
    'mapel_fisika.webp'.mapel: {
      'idMapel': [2, 19, 28],
      'idKelompokUjian': [32, 76]
    },
    // GEOGRAFI
    'mapel_geografi.webp'.mapel: {
      'idMapel': [8, 25, 34],
      'idKelompokUjian': [48, 82]
    },
    // BAHASA INDO
    'mapel_indo.webp'.mapel: {
      'idMapel': [6, 23, 31, 46, 78],
      'idKelompokUjian': [40, 79, 91, 109, 129]
    },
    // BAHASA INGGRIS
    'mapel_inggris.webp'.mapel: {
      'idMapel': [5, 22],
      'idKelompokUjian': [37, 38, 39, 110, 112, 113, 120, 123]
    },
    // IPA
    'mapel_ipa.webp'.mapel: {
      'idMapel': [11, 28, 29, 30],
      'idKelompokUjian': [31, 52, 54, 106]
    },
    // IPS & SEJARAH
    'mapel_ips.webp'.mapel: {
      'idMapel': [7, 13, 24, 32],
      'idKelompokUjian': [45, 47, 53, 80]
    },
    // KIMIA
    'mapel_kimia.webp'.mapel: {
      'idMapel': [3, 20, 29],
      'idKelompokUjian': [35, 77]
    },
    // SOSIOLOGI
    'mapel_sosiologi.webp'.mapel: {
      'idMapel': [10, 27, 35],
      'idKelompokUjian': [51, 83]
    },
    // TPS Kuantitatif
    'tps_%20kuantitatif.webp'.mapel: {
      'idMapel': [],
      'idKelompokUjian': [74, 86, 93, 101, 134]
    },
    // TPS Inggris
    'tps_inggris.webp'.mapel: {
      'idMapel': [40, 47],
      'idKelompokUjian': [85, 92]
    },
    // TPS PBM
    'tps_pemahaman_membaca_dan_menulis.webp'.mapel: {
      'idMapel': [56],
      'idKelompokUjian': [43, 100, 119]
    },
    // TPS Penalaran Umum
    'tps_penalaran_umum.webp'.mapel: {
      'idMapel': [54, 55],
      'idKelompokUjian': [12, 44, 98, 99]
    },
    // MATEMATIKA
    'mapel_matematika.webp'.mapel: {
      'idMapel': [1, 16, 17, 18, 37, 38, 39, 49],
      'idKelompokUjian': [
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        10,
        84,
        94,
        108,
        115,
        116,
        117,
        118,
        130,
        132
      ]
    },
  };

  static const String defaultAturan =
      '<html><body><div class="main"><h3>PERATURAN DAN TATA TERTIB SISWA GANESHA OPERATION TP 2023/2024</h3><ol><li>Siswa Ganesha Operation (GO) wajib hadir Kegiatan Belajar Mengajar (KBM) dan kegiatan GO lainnya selambat-lambatnya 10 (sepuluh) menit sebelum kegiatan dimulai. Siswa GO yang terlambat, dilarang masuk kelas kecuali mendapatkan izin tertulis dari Kepala Unit/<i>Customer Service </i>sesuai dengan peraturan GO setempat.</li><li>Siswa GO diwajibkan melakukan presensi sebagai bukti kehadiran selama mengikuti pembelajaran di GO. Presensi dilakukan setiap sesi jam belajar sesuai hari belajar menggunakan scan <i>Quick Response</i>(QR) Code ke Pengajar.</li><li>Siswa GO tidak diperbolehkan pindah kelas (mutasi) kecuali jika mendapat persetujuan dari Kepala Unit/Kepala Sekretariat GO setempat dan harus sesuai aturan yang berlaku.</li><li>Selama berada di lingkungan GO, Siswa GO diwajibkan selalu:<ol type="a"><li>Berpakaian rapi, sopan, tidak memakai sandal jepit.</li><li>Tidak membawa senjata tajam, dan/atau membawa Narkoba jenis apapun.</li><li>Menggunakan masker selama berada di lingkungan GO.</li><li>Tidak saling meminjamkan alat tulis, HP, dll.</li></ol></li><li>Siswa GO dilarang merokok di lingkungan Ganesha Operation.</li><li>Siswa GO boleh membawa alat komunikasi (<i>handphone, tablet, dan gadget</i>) selama proses KBM GO, alat komunikasi wajib dalam keadaan <i>silent mode</i>.</li><li>Siswa wajib men-<i>download</i> GO Kreasi untuk sarana pembelajaran secara online.</li><li>Siswa GO wajib mengikuti dan menaati seluruh peraturan GO termasuk jadwal belajar, jadwal Try Out, SiagaPTS, Siaga PAS, dan Siaga PAT/US.</li><li>Ganesha Operation (GO) berhak mempublikasikan kelulusan dan/atau prestasi siswa.</li></ol></br></br></div></body></html>';

  static const List<AboutModel> defaultAbout = [
    AboutModel(judul: 'Apa itu Aplikasi GO Kreasi?', deskripsi: [
      '   Aplikasi ini hanya dapat digunakan oleh siswa aktif Ganesha Operation di seluruh indonesia, tidak terbuka untuk pengguna di luar Ganesha Operation. Aplikasi yang bertujuan untuk membantu pengguna dalam mengontrol dan melaporkan prestasi siswa tersebut, salah satunya membantu untuk melihat jadwal kelas, video pembelajaran, buku soal, buku teori, hasil tryout, hasil quiz, hasil VAK, hasil presensi dan lain-lain. Aplikasi ini dibuat oleh Ganesha Operation (IT APP DEVELOPER) pada tahun 2018.'
    ], subData: []),
    AboutModel(judul: 'Sejarah singkat Ganesha Operation?', deskripsi: [
      '   Di tengah-tengah persaingan yang tajam dalam industri bimbingan belajar, pada tanggal 1 Mei 1984 Ganesha Operation didirikan di Kota Bandung. Seiring dengan perjalanan waktu, berkat keuletan dan konsistensinya dalam menjaga kualitas, kini Ganesha Operation telah tumbuh bagai remaja tambun dengan 728 outlet yang tersebar di 251 kota besar se Indonesia. Latar belakang pendirian lembaga ini adalah adanya mata rantai yang terputus dari link informasi Sekolah Menengah Atas (SMA) dengan dunia Perguruan Tinggi Negeri (PTN). Posisi inilah yang diisi oleh Ganesha Operation untuk berfungsi sebagai jembatan dunia SMA terhadap dunia PTN mengenai informasi jurusan PTN (prospek dan tingkat persaingannya), pemberian materi pelajaran yang sesuai dengan ruang lingkup bahan uji seleksi penerimaan mahasiswa baru dan pemberian metode-metode inovatif dan kreatif menyelesaikan soal-soal tes masuk PTN sehingga membantu para siswa lulusan SMA memenuhi keinginan mereka memasuki PTN.',
      '   Meskipun pada awalnya hingga tahun 1992 Ganesha Operation hanya ada di Bandung, pada tahun 1993 dibuka cabang pertama di Denpasar, dan pengembangan secara serius dilakukan mulai tahun 1995. Sejak itu pertumbuhan cabang-cabang Ganesha Operation benar-benar tidak terbendung. Image Ganesha Operation yang sangat kuat telah merambah ke seluruh Nusantara sehingga setiap cabang baru dibuka langsung diserbu oleh para siswa. Kalau pada saat pertama kali berdiri siswa Ganesha Operation masih sedikit dan hanya mencakup program kelas 3 SMA, kemudian dari tahun ke tahun jumlah siswanya terus bertambah. Sesuai dengan tuntutan masyarakat, saat ini Ganesha Operation tidak hanya membuka program di kelas 3 SMA saja tetapi dari kelas 3 SD hingga 12 SMA bahkan alumni. Saat ini untuk 1 (satu) tahun pelajaran jumlah seluruh siswa Ganesha Operation dapat mencapai ratusan ribu siswa, suatu jumlah yang sangat besar. Khusus untuk kelas 3 SMA, tahun 2022 ini Ganesha Operation berhasil meluluskan lebih dari 45.000 siswanya di berbagai PTN dan PT Kedinasan terkemuka di Indonesia. Bahkan Ganesha Operation mencatatkan 2 rekor MURI sekaligus, yaitu: Sebagai bimbel terbaik dengan meluluskan siswa terbanyak ke PTN dan PT Kedinasan dan sebagai bimbel terbesar dengan 692 gedung yang tersebar dari Aceh hingga Ambon yang dikelolah secara terpusat (no franchise), itulah mengapa reputasi Ganesha Operation begitu spektakuler.'
    ], subData: []),
    AboutModel(
      judul: 'Visi Dan Misi Ganesha Operation?',
      deskripsi: [],
      subData: [
        AboutModel(judul: 'Visi', deskripsi: [
          'Menjadi lembaga bimbingan belajar yang terbaik dan terbesar di-Indonesia.'
        ], subData: []),
        AboutModel(judul: 'Misi', deskripsi: [
          '1. Mendidik siswa agar berprestasi tingkat sekolah, kota/kabupaten, provinsi, nasional, dan internasional.',
          '2. Melakukan inovasi pembelajaran melalui terobosan revolusi belajar dan Teknologi informasi.',
          '3. Meningkatkan budaya belajar siswa.',
          '4. Meningkatkan mutu pendidikan.',
          '5. Mencerdaskan kehidupan bangsa.'
        ], subData: []),
      ],
    ),
  ];
}
