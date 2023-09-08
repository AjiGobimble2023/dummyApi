import '../../buku/entity/bab_buku.dart';

class SobatTipsBab extends BabBuku {
  final String idMataPelajaran;
  final String mataPelajaran;
  final String levelTeori;
  final String kelengkapan;

  const SobatTipsBab({
    required this.idMataPelajaran,
    required this.mataPelajaran,
    required this.levelTeori,
    required this.kelengkapan,
    required super.kodeBab,
    required super.namaBab,
    required super.idTeoriBab,
    // required super.listIdTeoriBab,
  });
}
