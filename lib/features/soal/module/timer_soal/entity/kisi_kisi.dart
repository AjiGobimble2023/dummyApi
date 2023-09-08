import 'package:equatable/equatable.dart';

class KisiKisi extends Equatable {
  final String kelompokUjian;
  final List<KisiKisiBab> daftarBab;

  const KisiKisi({
    required this.kelompokUjian,
    required this.daftarBab,
  });

  @override
  List<Object?> get props => [kelompokUjian, daftarBab];
}

class KisiKisiBab extends Equatable {
  final String kodeBab;
  final String namaBab;
  final String levelTeori;
  final String idMapel;
  final String initialMapel;

  const KisiKisiBab({
    required this.kodeBab,
    required this.namaBab,
    required this.levelTeori,
    required this.idMapel,
    required this.initialMapel,
  });

  @override
  List<Object?> get props => [
        kodeBab,
        namaBab,
        levelTeori,
        idMapel,
        initialMapel,
      ];
}
