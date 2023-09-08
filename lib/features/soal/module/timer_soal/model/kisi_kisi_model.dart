import '../entity/kisi_kisi.dart';

class KisiKisiModel extends KisiKisi {
  const KisiKisiModel({required super.kelompokUjian, required super.daftarBab});

  factory KisiKisiModel.fromJson(Map<String, dynamic> json) {
    List<KisiKisiBabModel> listKisiKisiBab = [];

    if (json['info'] != null) {
      for (var dataBab in json['info']) {
        listKisiKisiBab.add(KisiKisiBabModel.fromJson(dataBab));
      }
      listKisiKisiBab.sort((a, b) => a.kodeBab.compareTo(b.kodeBab));
    }

    return KisiKisiModel(
      kelompokUjian: json['kelompokUjian'],
      daftarBab: (json['info'] != null)
          ? (json['info'] as List)
              .map<KisiKisiBabModel>((info) => KisiKisiBabModel.fromJson(info))
              .toList()
          : [],
    );
  }
}

class KisiKisiBabModel extends KisiKisiBab {
  const KisiKisiBabModel(
      {required super.kodeBab,
      required super.namaBab,
      required super.levelTeori,
      required super.idMapel,
      required super.initialMapel});

  factory KisiKisiBabModel.fromJson(Map<String, dynamic> json) =>
      KisiKisiBabModel(
        kodeBab: json['kodeBab'],
        namaBab: json['namaBab'],
        levelTeori: json['levelTeori'],
        idMapel: json['idMapel'],
        initialMapel: json['initialMapel'],
      );
}
