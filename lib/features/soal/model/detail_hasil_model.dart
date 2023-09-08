import '../entity/detail_hasil.dart';

class DetailHasilModel extends DetailHasil {
  const DetailHasilModel({
    required super.namaKelompokUjian,
    required super.benar,
    required super.salah,
    required super.kosong,
  });

  factory DetailHasilModel.fromJson(Map<String, dynamic> json) =>
      DetailHasilModel(
        namaKelompokUjian: json['namaKelompokUjian'],
        benar: json['benar'],
        salah: json['salah'],
        kosong: json['kosong'],
      );
}
