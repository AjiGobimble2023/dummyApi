import 'package:equatable/equatable.dart';

class DetailBundel extends Equatable {
  final String idBundel;
  final String namaKelompokUjian;
  final int jumlahSoal;
  final int indexSoalPertama;
  final int indexSoalTerakhir;
  final int waktuPengerjaan;

  const DetailBundel({
    required this.idBundel,
    required this.namaKelompokUjian,
    required this.jumlahSoal,
    required this.indexSoalPertama,
    required this.indexSoalTerakhir,
    required this.waktuPengerjaan,
  });

  @override
  List<Object?> get props => [
        idBundel,
        namaKelompokUjian,
        jumlahSoal,
        indexSoalPertama,
        indexSoalTerakhir,
        waktuPengerjaan,
      ];
}
