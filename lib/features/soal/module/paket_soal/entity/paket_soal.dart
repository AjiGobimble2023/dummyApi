import 'package:equatable/equatable.dart';

import '../../../../../core/config/global.dart';
import '../../../../../core/config/constant.dart';
import '../../../../../core/util/data_formatter.dart';

/// [PaketSoal] merupakan model dari tabel t\_PaketSoal pada db\_banksoalV2.<br>
/// Kumpulan [PaketSoal] didapat berdasarkan c\_KodeTOB dari db\_banksoalV2.t\_IsiTOB ORDER BY c_NomorUrut ASC.<br><br>
///
/// [PaketSoal] di gunakan untuk Produk yang tidak memerlukan halaman Soal Timer.
/// Module Soal yang menggunakan [PaketSoal]:<br>
/// 1) Empati Mandiri (id: 71).<br>
/// 2) Empati Wajib (id: 72).<br>
/// 3) VAK (id: 65).
class PaketSoal extends Equatable {
  final String kodeTOB;
  final String kodePaket;
  final String deskripsi;
  final String idJenisProduk;
  final String idSekolahKelas;

  /// [totalWaktu] merupakan durasi waktu pengerjaan soal dengan satuan menit.
  final int totalWaktu;
  final int jumlahSoal;

  /// [tanggalBerlaku] merupakan display tanggal berlaku Paket Soal.<br>
  /// Format Tanggal API: 2022-07-16 15:30:00
  /// Format Tanggal: 16 Juli 2022
  final String? tanggalBerlaku;

  /// [tanggalKedaluwarsa] merupakan display tanggal berakhirnya Paket Soal.<br>
  /// Format Tanggal API: 2022-07-19 23:59:59
  /// Format Tanggal Display: 19 Juli 2022
  final String? tanggalKedaluwarsa;

  /// [isBlockingTime] TRUE: maka soal tidak dapat disubmit sebelum waktu habis.
  final bool isBlockingTime;

  /// [isTeaser] apakah paket ini merupakan Teaser atau bukan.
  final bool isTeaser;

  const PaketSoal({
    required this.kodeTOB,
    required this.kodePaket,
    required this.deskripsi,
    required this.idJenisProduk,
    required this.idSekolahKelas,
    required this.totalWaktu,
    required this.jumlahSoal,
    this.tanggalBerlaku,
    this.tanggalKedaluwarsa,
    required this.isBlockingTime,
    this.isTeaser = false,
  });

  bool get isKedaluwarsa {
    if (tanggalKedaluwarsa != null && gOffsetServerTime != null) {
      DateTime kedaluwarsa = DataFormatter.stringToDate(tanggalKedaluwarsa!);
      return DateTime.now()
          .add(Duration(milliseconds: gOffsetServerTime!))
          .isAfter(kedaluwarsa);
    }
    return true;
  }

  String get displayTanggalKedaluwarsa => (tanggalKedaluwarsa != null)
      ? DataFormatter.formatDate(tanggalKedaluwarsa!, '[H:m] dd MMM y')
      : 'Undefined';

  String get displayTanggalBerlaku => (tanggalBerlaku != null)
      ? DataFormatter.formatDate(tanggalBerlaku!, '[H:m] dd MMM y')
      : 'Undefined';

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

  String get tingkat =>
      Constant.kDataSekolahKelas.singleWhere(
        (sekolah) => sekolah['id'] == idSekolahKelas,
        orElse: () => {
          'id': '0',
          'kelas': 'Undefined',
          'tingkat': 'Other',
          'tingkatKelas': '0'
        },
      )['tingkat'] ??
      'Undefined';

  @override
  List<Object?> get props => [
        kodeTOB,
        kodePaket,
        deskripsi,
        idJenisProduk,
        idSekolahKelas,
        totalWaktu,
        jumlahSoal,
        tanggalBerlaku,
        tanggalKedaluwarsa,
        isBlockingTime,
        isTeaser,
      ];
}
