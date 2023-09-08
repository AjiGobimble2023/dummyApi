import 'package:equatable/equatable.dart';

import '../../../../../core/config/constant.dart';
import '../../../../../core/util/data_formatter.dart';

/// [PaketTO] sebenarnya sama dengan PaketSoal, berasal dari tabel t\_PaketSoal pada db\_banksoalV2.<br>
/// Hanya saja modeling ini di peruntukan untuk TryOut TOB.<br>
/// Di buat karena perbedaan response data.<br>
///
/// [PaketTO] di gunakan untuk Produk yang memerlukan halaman Soal Timer.
/// Module Soal yang menggunakan [PaketTO]:<br>
/// 1) GOA (id: 12).<br>
/// 2) Racing (id: 80).<br>
/// 3) Kuis (id: 16).<br>
/// 4) TOBK (id: 25).
// ignore: must_be_immutable
class PaketTO extends Equatable {
  final String kodeTOB;
  final String kodePaket;
  final String deskripsi;
  final String idSekolahKelas;
  final int idKelompokUjian;
  String merekHp;
  final int jumlahSoal;

  /// [nomorUrut] merupakan urutan Pengerjaan Paket, Pengerjaan Paket harus sesuai urutan.
  final int nomorUrut;

  /// [idJenisProduk] merupakan idJenisProduk dari Paket.
  final String idJenisProduk;

  /// [totalWaktu] merupakan durasi waktu pengerjaan Paket TO dalam satuan menit.
  final int totalWaktu;

  /// [tanggalBerlaku] merupakan tanggal berlaku paket.<br>
  /// Format tanggal: 2022-08-11 00:00:00
  final String? tanggalBerlaku;

  /// [tanggalKedaluwarsa] merupakan tanggal kedaluwarsa paket.<br>
  /// Format tanggal: 2022-08-19 23:59:59
  final String? tanggalKedaluwarsa;

  /// [kapanMulaiMengerjakan] merupakan tanggal kapan siswa mulai mengerjakan TO pertama kali.<br>
  /// Format tanggal: 2022-08-23 10:41:19
  DateTime? kapanMulaiMengerjakan;

  /// [deadlinePengerjaan] merupakan tanggal deadline pengerjaan dihitung dari
  /// kapan dia mulai mengerjakan ditambah durasi paket.
  /// Maksimal deadline mengikuti tanggal kedaluwarsa TOB.
  /// Format tanggal: 2022-08-20 23:59:00
  DateTime? deadlinePengerjaan;

  /// [tanggalSiswaSubmit] merupakan tanggal Siswa mengumpulkan TO.<br>
  /// Format tanggal: belum tahu
  DateTime? tanggalSiswaSubmit;

  /// [isBlockingTime] TRUE: maka soal tidak dapat di-submit sebelum waktu habis.
  final bool isBlockingTime;

  /// [isRandom] TRUE: maka soal pada setiap bundel yang ada akan di acak.
  final bool isRandom;

  /// [isSelesai] Apakah paket TO ini sudah selesai dikerjakan atau belum.
  bool isSelesai;

  /// [isWaktuHabis] Apakah waktu mengerjakan paket TO ini sudah habis atau belum.
  bool isWaktuHabis;

  /// [isPernahMengerjakan] Apakah siswa sudah pernah memasuki Halaman Pengerjaan Soal.
  bool isPernahMengerjakan;

  /// [isTeaser] Apakah paket ini merupakan teaser atau bukan.<br>
  /// Akan selalu bernilai false di TOBK.
  bool isTeaser;

  /// [isWajib] Apakah paket ini harus di kerjakan sesuai urutan atau tidak.<br>
  /// Akan selalu bernilai true selain di TOBK.
  bool isWajib;

  PaketTO({
    required this.kodeTOB,
    required this.kodePaket,
    required this.deskripsi,
    this.idKelompokUjian = 0,
    required this.nomorUrut,
    required this.idJenisProduk,
    required this.idSekolahKelas,
    required this.merekHp,
    required this.totalWaktu,
    required this.jumlahSoal,
    this.tanggalBerlaku,
    this.tanggalKedaluwarsa,
    this.kapanMulaiMengerjakan,
    this.deadlinePengerjaan,
    this.tanggalSiswaSubmit,
    required this.isBlockingTime,
    required this.isRandom,
    required this.isSelesai,
    required this.isWaktuHabis,
    required this.isPernahMengerjakan,
    required this.isTeaser,
    required this.isWajib,
  });

  String get sekolahKelas =>
      Constant.kDataSekolahKelas.singleWhere(
        (sekolah) => sekolah['id'] == idSekolahKelas,
        orElse: () => {
          'id': '0',
          'kelas': 'Undefined',
          'tingkat': 'Other',
          'tingkatKelas': '0'
        },
      )['kelas'] ??
      'Undefined';

  int get tingkatKelas {
    String tingkatKelas = Constant.kDataSekolahKelas.singleWhere(
          (sekolah) => sekolah['id'] == idSekolahKelas,
          orElse: () => {
            'id': '0',
            'kelas': 'Undefined',
            'tingkat': 'Other',
            'tingkatKelas': '0'
          },
        )['tingkatKelas'] ??
        '0';

    return int.tryParse(tingkatKelas) ?? 0;
  }

  /// [displayTanggalMulai] tanggal mulai dengan format indo
  String? get displayTanggalMulai => (tanggalBerlaku != null)
      ? DataFormatter.formatDate(tanggalBerlaku!, '[HH:mm] dd MMM yyyy')
      : null;

  /// [displayTanggalBerakhir] tanggal Kedaluwarsa dengan format indo
  String? get displayTanggalBerakhir => (tanggalKedaluwarsa != null)
      ? DataFormatter.formatDate(tanggalKedaluwarsa!, '[HH:mm] dd MMM yyyy')
      : null;

  String get displayDeadlinePengerjaan {
    if (deadlinePengerjaan == null) return '';
    String date = DataFormatter.dateTimeToString(deadlinePengerjaan!);
    return DataFormatter.formatDate(date, '[HH:mm] dd MMM yyyy');
  }

  String get displayTanggalSiswaSubmit {
    if (tanggalSiswaSubmit == null) return '';
    String date = DataFormatter.dateTimeToString(tanggalSiswaSubmit!);
    return DataFormatter.formatDate(date, '[HH:mm] dd MMM yyyy');
  }

  String get displayDurasiLengkap {
    String display = '';
    int jam = totalWaktu ~/ 60;
    int sisaMenit = totalWaktu % 60;

    if (jam > 0) {
      display += '$jam jam';
      if (sisaMenit > 0) {
        display += ' $sisaMenit menit';
      }
    } else {
      display += '$totalWaktu menit';
    }

    return display;
  }

  String get displayDurasiSingkat {
    String display = '';
    int jam = totalWaktu ~/ 60;
    int sisaMenit = totalWaktu % 60;

    if (jam > 0) {
      display += '${jam}j';
      if (sisaMenit > 0) {
        display += ' ${sisaMenit}m';
      }
    } else {
      display += '${totalWaktu}m';
    }

    return display;
  }

  void setTanggalMulaiMengerjakan(
      DateTime tanggalKedaluwarsa, DateTime currentServerTime) {
    if (!isPernahMengerjakan && kapanMulaiMengerjakan == null) {
      isPernahMengerjakan = true;
      kapanMulaiMengerjakan = currentServerTime;
      deadlinePengerjaan =
          kapanMulaiMengerjakan!.add(Duration(minutes: totalWaktu));
      if (deadlinePengerjaan!.isAfter(tanggalKedaluwarsa)) {
        deadlinePengerjaan = tanggalKedaluwarsa;
      } else {
        deadlinePengerjaan!.add(const Duration(seconds: 5));
      }
    }
  }

  /// [isBolehLanjutNomorUrut] apakah paket ini sudah melewati [jarakAntarPaket] waktu TOB?
  /// Jika sudah melewati [jarakAntarPaket], boleh melanjutkan ke nomor urut selanjutnya.
  bool isBolehLanjutNomorUrut(
          {required DateTime currentServerTime,
          required int jarakAntarPaket}) =>
      (tanggalSiswaSubmit != null)
          ? currentServerTime.isAfter(
              tanggalSiswaSubmit!.add(Duration(minutes: jarakAntarPaket)))
          : false;

  /// [isBolehLihatKisiKisi] masa kisi-kisi boleh dilihat dari
  /// 1 minggu sebelum tanggal mulai, hingga masa Paket berakhir.
  /// <br><br> JANGAN GUNAKAN PADA TOBK!! AKAN SELALU BERNILAI FALSE.
  bool isBolehLihatKisiKisi(DateTime currentServerTime) =>
      (tanggalBerlaku != null || tanggalKedaluwarsa != null)
          ? currentServerTime.isAfter(
                  tanggalBerlakuDateTime!.subtract(const Duration(days: 7))) &&
              currentServerTime.isBefore(tanggalKedaluwarsaDateTime!)
          : false;

  /// [isHarusKumpulkan] apakah masa Paket sudah berakhir atau belum,
  /// maksimal mengumpulkan 1 jam setelah masa Paket berakhir.
  /// <br><br> JANGAN GUNAKAN PADA TOBK!! AKAN SELALU BERNILAI FALSE.
  bool isHarusKumpulkan(DateTime currentServerTime) =>
      (deadlinePengerjaan != null)
          ? currentServerTime.isAfter(deadlinePengerjaan!) &&
              currentServerTime.isBefore(
                  tanggalKedaluwarsaDateTime!.add(const Duration(hours: 1)))
          : false;

  /// [isBolehKumpulkan] apakah masa Paket sudah berakhir atau belum,
  /// maksimal mengumpulkan 1 jam setelah masa Paket berakhir.
  /// <br><br> JANGAN GUNAKAN PADA TOBK!! AKAN SELALU BERNILAI FALSE.
  bool isBolehKumpulkan(DateTime currentServerTime) =>
      (tanggalBerlaku != null || tanggalKedaluwarsa != null)
          ? currentServerTime.isAfter(tanggalKedaluwarsaDateTime!) &&
              currentServerTime.isBefore(
                  tanggalKedaluwarsaDateTime!.add(const Duration(hours: 1)))
          : false;

  /// [isTOBBerakhir] apakah masa Paket sudah berakhir atau belum.
  /// <br><br> JANGAN GUNAKAN PADA TOBK!! AKAN SELALU BERNILAI FALSE.
  bool isTOBBerakhir(DateTime currentServerTime) => (tanggalKedaluwarsa != null)
      ? currentServerTime.isAfter(tanggalKedaluwarsaDateTime!)
      : false;

  /// [isTOBRunning] apakah masa Paket sedang berjalan.
  /// <br><br> JANGAN GUNAKAN PADA TOBK!! AKAN SELALU BERNILAI FALSE.
  bool isTOBRunning(DateTime currentServerTime) =>
      (tanggalBerlaku != null || tanggalKedaluwarsa != null)
          ? currentServerTime.isAfter(tanggalBerlakuDateTime!) &&
              currentServerTime.isBefore(tanggalKedaluwarsaDateTime!)
          : false;

  /// [isTOBPending] apakah masa Paket belum berjalan.
  /// <br><br> JANGAN GUNAKAN PADA TOBK!! AKAN SELALU BERNILAI FALSE.
  bool isTOBPending(DateTime currentServerTime) => (tanggalBerlaku != null)
      ? currentServerTime.isBefore(tanggalBerlakuDateTime!)
      : false;

  /// [tanggalBerlaku] dalam format DateTime
  /// <br><br> JANGAN GUNAKAN PADA TOBK!! AKAN SELALU BERNILAI NULL.
  DateTime? get tanggalBerlakuDateTime => (tanggalBerlaku != null)
      ? DataFormatter.stringToDate(tanggalBerlaku!)
      : null;

  /// [tanggalKedaluwarsa] dalam format DateTime
  /// <br><br> JANGAN GUNAKAN PADA TOBK!! AKAN SELALU BERNILAI NULL.
  DateTime? get tanggalKedaluwarsaDateTime => (tanggalKedaluwarsa != null)
      ? DataFormatter.stringToDate(tanggalKedaluwarsa!)
      : null;

  @override
  List<Object?> get props => [
        kodeTOB,
        kodePaket,
        nomorUrut,
        idJenisProduk,
        idSekolahKelas,
        merekHp,
        totalWaktu,
        jumlahSoal,
        tanggalBerlaku,
        tanggalKedaluwarsa,
        kapanMulaiMengerjakan,
        deadlinePengerjaan,
        tanggalSiswaSubmit,
        isBlockingTime,
        isRandom,
        isSelesai,
        isWaktuHabis,
        isPernahMengerjakan
      ];
}
