import 'package:equatable/equatable.dart';

class LaporanVAK extends Equatable {
  final String noRegistrasi;
  final String scoreVisual;
  final String scoreAuditory;
  final String scoreKinesthetic;
  final String kecenderungan;
  final String initialKecenderungan;
  final String judul1;
  final String isi1;
  final String? judul2;
  final String? isi2;
  final String? judul3;
  final String? isi3;

  const LaporanVAK({
    required this.noRegistrasi,
    required this.scoreVisual,
    required this.scoreAuditory,
    required this.scoreKinesthetic,
    required this.kecenderungan,
    required this.initialKecenderungan,
    required this.judul1,
    required this.isi1,
    this.judul2,
    this.isi2,
    this.judul3,
    this.isi3,
  });

  @override
  List<Object> get props => [
        noRegistrasi,
        scoreVisual,
        scoreAuditory,
        scoreKinesthetic,
        kecenderungan,
        initialKecenderungan,
        judul1,
        isi1,
      ];
}
