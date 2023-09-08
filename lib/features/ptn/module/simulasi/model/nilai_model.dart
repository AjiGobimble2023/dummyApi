import '../entity/nilai.dart';

class NilaiModel extends Nilai {
  NilaiModel({
    required String kodeTob,
    required String tob,
    required bool isSelected,
    required bool isFix,
    Map<String, dynamic>? detailNilai,
  }) : super(
          kodeTob: kodeTob,
          tob: tob,
          isSelected: isSelected,
          isFix: isFix,
          detailNilai: detailNilai!,
        );

  factory NilaiModel.fromJson(Map<String, dynamic> json) => NilaiModel(
        kodeTob: json['kodeTob'],
        tob: json['tob'],
        isSelected: json['isSelected'],
        isFix: json['isFix'],
        detailNilai: json['detailNilai'],
      );
}

class DetailNilaiModel {
  String? mapel;
  int? nilai;
  String? kelompok;

  DetailNilaiModel({
    this.mapel,
    this.nilai,
    this.kelompok,
  });

  factory DetailNilaiModel.fromJson(Map<String, dynamic> json) =>
      DetailNilaiModel(
        mapel: json['mapel'],
        nilai: json['nilai'],
        kelompok: json['kelompok'],
      );

  Map<String, dynamic> toJson() => {
        'mapel': mapel,
        'nilai': nilai,
      };
}
