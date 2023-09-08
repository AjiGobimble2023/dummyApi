import 'package:equatable/equatable.dart';

import '../../../core/config/extensions.dart';

// ignore: must_be_immutable
class PesertaTO extends Equatable {
  final String noRegistrasi;
  final String kodePaket;

  /// [tanggalSiswaSubmit] merupakan tanggal Siswa mengumpulkan TO.<br>
  /// Format tanggal: belum tahu
  DateTime? tanggalSiswaSubmit;

  /// [isSelesai] Apakah paket TO ini sudah selesai dikerjakan atau belum.
  bool isSelesai;

  /// [isPernahMengerjakan] Apakah siswa sudah pernah memasuki Halaman Pengerjaan Soal.
  bool isPernahMengerjakan;

  /// [kapanMulaiMengerjakan] merupakan tanggal kapan siswa mulai mengerjakan TO pertama kali.<br>
  /// Format tanggal: 2022-08-23 10:41:19
  DateTime? kapanMulaiMengerjakan;

  /// [deadlinePengerjaan] merupakan tanggal deadline pengerjaan dihitung dari
  /// kapan dia mulai mengerjakan ditambah durasi paket.
  /// Maksimal deadline mengikuti tanggal kedaluwarsa TOB.
  /// Format tanggal: 2022-08-20 23:59:00
  DateTime? deadlinePengerjaan;

  /// Keterangan merupakan informasi device yang di gunakan untuk Tryout
  Map<String, dynamic>? keterangan;

  /// Pilihan siswa merupakan pilihan jurusan dan pilihan mata ujian (jika format merdeka).
  Map<String, dynamic>? pilihanSiswa;

  /// Status flag, untuk pengecekan backend tentang apakah
  /// jawaban siswa sudah di pindah ke server lokal atau belum.
  final int flagFirebase;

  /// Field pada db, kegunaan di V2 masih tidak di ketahui.
  final int persetujuan;

  PesertaTO({
    required this.noRegistrasi,
    required this.kodePaket,
    this.tanggalSiswaSubmit,
    required this.isSelesai,
    required this.isPernahMengerjakan,
    this.kapanMulaiMengerjakan,
    this.deadlinePengerjaan,
    this.keterangan,
    this.pilihanSiswa,
    this.flagFirebase = 0,
    this.persetujuan = 0,
  });

  Map<String, dynamic> toJson() => {
        'cNoRegister': noRegistrasi,
        'cKodeSoal': kodePaket,
        'cTanggalTO': tanggalSiswaSubmit?.sqlFormat,
        'cSudahSelesai': isSelesai ? 'y' : 'n',
        'cOK': isPernahMengerjakan ? 'y' : 'n',
        'cTglMulai': kapanMulaiMengerjakan?.sqlFormat,
        'cTglSelesai': deadlinePengerjaan?.sqlFormat,
        'cKeterangan': keterangan,
        'cPersetujuan': persetujuan,
        'cFlag': flagFirebase,
        'cPilihanSiswa': pilihanSiswa,
      };

  @override
  List<Object?> get props => [
        noRegistrasi,
        kodePaket,
      ];
}
