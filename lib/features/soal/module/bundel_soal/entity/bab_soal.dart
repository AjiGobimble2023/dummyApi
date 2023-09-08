import 'package:equatable/equatable.dart';

class BabSoal extends Equatable {
  final String kodeBab;
  final String namaBab;
  final String idBundel;
  final String jumlahSoal;

  const BabSoal({
    required this.kodeBab,
    required this.namaBab,
    required this.idBundel,
    required this.jumlahSoal,
  });

  @override
  List<Object?> get props => [kodeBab, namaBab, idBundel, jumlahSoal];
}

class BabUtamaSoal extends Equatable {
  final String namaBabUtama;
  final List<BabSoal> daftarBab;

  const BabUtamaSoal({required this.namaBabUtama, required this.daftarBab});

  @override
  List<Object?> get props => [namaBabUtama, daftarBab];
}
