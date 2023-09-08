import 'package:equatable/equatable.dart';

import 'wacana.dart';

/// [Soal] merupakan model dari tabel t\_Soal pada db\_banksoalV2.<br>
/// Kumpulan [Soal] didapat berdasarkan c\_IdBundel dari db\_banksoalV2.t\_IsiSoalBundel.
// ignore: must_be_immutable
class Soal extends Equatable {
  final String idSoal;
  final int nomorSoal;

  /// [nomorSoalSiswa] merupakan generate nomor soal untuk siswa.
  /// Didapat dari firebase.
  int nomorSoalSiswa;

  /// [textSoal] merupakan String Text Soal dengan format HTML.
  final String textSoal;

  /// [tingkatKesulitan] merupakan level kesulitan pada tiap soal (1-5).
  final int tingkatKesulitan;

  /// [tipeSoal] enum('PBS','PBK','PBCT','PBM','PBT','ESSAY','ESSAY MAJEMUK','PBB')
  final String tipeSoal;

  /// [opsi] merupakan json Jawaban (opsi, kunci, nilai)
  final String opsi;

  /// [idVideo] wacana pada soal.
  final String? idVideo;

  /// [idWacana] wacana pada soal.
  final String? idWacana;

  /// [wacana] merupakan wacana soal seperti cerita panjang.
  final Wacana? wacana;

  /// [namaKelompokUjian] di gunakan untuk soal dengan Timer dan Paket
  final String namaKelompokUjian;

  /// [idKelompokUjian] di gunakan untuk soal dengan Timer dan Paket
  final String idKelompokUjian;

  /// [kodePaket] di gunakan untuk soal dengan Timer
  final String? kodePaket;

  /// [idBundle] di gunakan untuk soal dengan Timer
  final String? idBundle;

  /// [kodeBab] di gunakan untuk soal bundel
  final String? kodeBab;

  /// [kunciJawaban] di generate saat getDaftarSoal
  final dynamic kunciJawaban;

  /// [translatorEPB] di generate saat getDaftarSoal.
  /// Berfungsi sebagai bahan tranlate json soal ke [kunciJawabanEPB].
  final dynamic translatorEPB;

  /// [kunciJawabanEPB] di generate saat getDaftarSoal.
  /// Berfungsi sebagai display kunci jawaban pada EPB
  final dynamic kunciJawabanEPB;

  // Mutable variable
  double nilai;
  bool isBookmarked;
  bool isRagu;
  bool sudahDikumpulkan;
  int? kesempatanMenjawab;
  dynamic jawabanSiswa;
  dynamic jawabanSiswaEPB;
  String? lastUpdate;

  Soal(
      {required this.idSoal,
      required this.nomorSoal,
      required this.nomorSoalSiswa,
      required this.textSoal,
      required this.tingkatKesulitan,
      required this.tipeSoal,
      required this.opsi,
      required this.kunciJawaban,
      required this.translatorEPB,
      required this.kunciJawabanEPB,
      this.idVideo,
      this.idWacana,
      this.wacana,
      required this.idKelompokUjian,
      required this.namaKelompokUjian,
      this.kodePaket,
      this.idBundle,
      this.kodeBab,
      this.nilai = 0,
      this.kesempatanMenjawab,
      this.isBookmarked = false,
      this.isRagu = false,
      this.sudahDikumpulkan = false,
      this.jawabanSiswa,
      this.jawabanSiswaEPB,
      this.lastUpdate});

  @override
  List<Object?> get props => [
        idSoal,
        nomorSoal,
        textSoal,
        tingkatKesulitan,
        tipeSoal,
        opsi,
        kunciJawaban,
        translatorEPB,
        kunciJawabanEPB,
        kodePaket,
        idBundle,
        idVideo,
        idWacana,
        wacana,
        idKelompokUjian,
        namaKelompokUjian,
      ];
}
