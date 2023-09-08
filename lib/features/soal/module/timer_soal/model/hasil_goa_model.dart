import '../entity/hasil_goa.dart';

class HasilGOAModel extends HasilGOA {
  HasilGOAModel({
    required super.isRemedial,
    required super.jumlahPercobaanRemedial,
    required super.detailHasilGOA,
  });

  factory HasilGOAModel.fromJson(Map<String, dynamic> json) {
    List<DetailHasilGOA> detailHasilGOA = (json['hasil'] as List)
        .map<DetailHasilGOA>((hasil) => DetailHasilGOAModel.fromJson(hasil))
        .toList();

    int isRemedial = 0;
    for (var detailHasil in detailHasilGOA) {
      if (!detailHasil.isLulus) {
        isRemedial++;
      }
    }
    return HasilGOAModel(
      isRemedial: isRemedial > 0,
      jumlahPercobaanRemedial: json['jumRemedial'],
      detailHasilGOA: detailHasilGOA,
    );
  }
}

class DetailHasilGOAModel extends DetailHasilGOA {
  DetailHasilGOAModel({
    required super.isLulus,
    required super.benar,
    required super.salah,
    required super.kosong,
    required super.targetLulus,
    required super.idKelompokUjian,
    required super.namaKelompokUjian,
  });

  factory DetailHasilGOAModel.fromJson(Map<String, dynamic> json) =>
      DetailHasilGOAModel(
        isLulus: json['isLulus'] == 1,
        benar: json['benar'],
        salah: json['salah'],
        kosong: json['kosong'],
        targetLulus: json['targetLulus'],
        idKelompokUjian: json['idKelompokUjian'],
        namaKelompokUjian: json['namaKelompokUjian'],
      );
}
