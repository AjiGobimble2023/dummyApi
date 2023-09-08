import 'package:equatable/equatable.dart';

class LaporanTryoutPilihan extends Equatable {
  /// [kelompok] Variabel untuk menyimpan data kode kelompok.
  final String kelompok;

  /// [namakelompok] Variabel untuk menyimpan data nama kelompok.
  final String namakelompok;

  /// [ptn] Variabel untuk menyimpan data nama PTN.
  final String ptn;

  /// [jurusan] Variabel untuk menyimpan data nama jurusan.
  final String jurusan;

  /// [pg] Variabel untuk menyimpan data passing grade.
  final String pg;

  /// [nilai] Variabel untuk menyimpan data nilai siswa.
  final String nilai;

  const LaporanTryoutPilihan({
    required this.kelompok,
    required this.namakelompok,
    required this.ptn,
    required this.jurusan,
    required this.pg,
    required this.nilai,
  });

  @override
  List<Object> get props => [kelompok, namakelompok, ptn, jurusan, pg, nilai];
}
