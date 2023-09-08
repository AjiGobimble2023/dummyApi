import 'package:equatable/equatable.dart';

import '../../../../../core/util/data_formatter.dart';

/// [Tob] Merupakan Entitas Try Out Berpasangan.
/// Terdiri atas 1 atau lebih Try Out (Jika 1 masuk kategori Try Out Tunggal).<br><br>
///
/// Daftar TOB didapatkan dari WHERE c\_IdKomponenProduk = c\_IdProduk yang dibeli Siswa. <br><br>
///
/// Untuk menentukan Jenis Produknya (Paket Intensif, Racing, dll),
/// itu dari hasil join antara db\_banksoalV2.t\_TOB, db\_GOIconsV2.t\_Produk,
/// dan db\_GOIconsV2.t\_MKT\_JenisProduk. <br><br>
///
/// Cara mengetahui produk yang dibeli:<br>
/// 1) db\_GOKasirV2.t\_SiswaBeliProduk USING c\_IdBundling dengan db\_GOIconsV2.t\_Bundling <br>
/// 2) db\_GOIconsV2.t\_Bundling USING c\_IdProdukMix dengan db\_GOIconsV2.t\_IsiProdukMix <br>
/// 3) Daftar c\_IdProduk yang di dapat merupakan daftar komponen produk yang dibeli siswa.
///    Join dengan db\_GOIconsV2.t\_Produk. <br><br>
///
/// Langkah - langkah di atas akan di singkat menjadi join ke db\_GOKreasi.t\_ProdukDibeliSiswa.
class Tob extends Equatable {
  final String kodeTOB;
  final String namaTOB;
  final String jenisTOB;
  // contoh format: 2022-07-16 15:07:41
  // Display jadwal dimulainya TryOut
  final String tanggalMulai;
  // contoh format: 2022-07-19 23:59:00
  // Display jadwal berakhirnya TryOut
  final String tanggalBerakhir;

  /// [jarakAntarPaket] merupakan selang waktu (menit) istirahat dari Paket Soal A ke
  /// Paket Soal B Jika isBlockingTime TRUE.
  final int jarakAntarPaket;

  /// [isBersyarat] Apakah TOBK ini memerlukan syarat Empati Wajib atau tidak.
  final bool isBersyarat;

  /// [isFormatTOMerdeka] Apakah TOB ini menggunakan format TOB Kurikulum merdeka atau tidak.
  final bool isFormatTOMerdeka;

  /// [isTeaser] Apakah produk ini merupakan produk Teaser atau bukan.
  final bool isTeaser;

  const Tob({
    required this.kodeTOB,
    required this.namaTOB,
    required this.jenisTOB,
    required this.tanggalMulai,
    required this.tanggalBerakhir,
    required this.jarakAntarPaket,
    this.isFormatTOMerdeka = false,
    this.isBersyarat = false,
    this.isTeaser = false,
  });

  bool get needConfirmJurusan => jenisTOB == 'UTBK';

  /// [displayTanggalMulai] tanggal mulai dengan format indo
  String get displayTanggalMulai =>
      DataFormatter.formatDate(tanggalMulai, '[HH:mm] dd MMM yyyy');

  /// [displayTanggalBerakhir] tanggal berakhir dengan format indo
  String get displayTanggalBerakhir =>
      DataFormatter.formatDate(tanggalBerakhir, '[HH:mm] dd MMM yyyy');

  /// [isBolehLihatKisiKisi] masa kisi-kisi boleh dilihat dari
  /// 1 minggu sebelum tanggal mulai, hingga masa TO berakhir.
  bool isBolehLihatKisiKisi(DateTime currentServerTime) =>
      currentServerTime
          .isAfter(tanggalMulaiDateTime.subtract(const Duration(days: 7))) &&
      currentServerTime.isBefore(tanggalBerakhirDateTime);

  /// [isBolehKumpulkan] apakah masa TOB sudah berakhir atau belum,
  /// maksimal mengumpulkan 1 jam setelah masa TO berakhir.
  bool isBolehKumpulkan(DateTime currentServerTime) =>
      currentServerTime.isAfter(tanggalBerakhirDateTime) &&
      currentServerTime
          .isBefore(tanggalBerakhirDateTime.add(const Duration(hours: 1)));

  /// [isTOBBerakhir] apakah masa TOB sudah berakhir atau belum.
  bool isTOBBerakhir(DateTime currentServerTime) =>
      currentServerTime.isAfter(tanggalBerakhirDateTime);

  /// [isTOBRunning] apakah masa TOB sedang berjalan.
  bool isTOBRunning(DateTime currentServerTime) =>
      currentServerTime.isAfter(tanggalMulaiDateTime) &&
      currentServerTime.isBefore(tanggalBerakhirDateTime);

  /// [isTOBPending] apakah masa TOB belum berjalan.
  bool isTOBPending(DateTime currentServerTime) =>
      currentServerTime.isBefore(tanggalMulaiDateTime);

  DateTime get tanggalMulaiDateTime => DataFormatter.stringToDate(tanggalMulai);

  DateTime get tanggalBerakhirDateTime =>
      DataFormatter.stringToDate(tanggalBerakhir);

  @override
  List<Object?> get props => [
        kodeTOB,
        namaTOB,
        tanggalMulai,
        tanggalBerakhir,
        jarakAntarPaket,
        isBersyarat,
        isTeaser
      ];
}
