import '../entity/sobat_tips_bab.dart';

class SobatTipsBabModel extends SobatTipsBab {
  const SobatTipsBabModel({
    required super.kodeBab,
    required super.namaBab,
    required super.idTeoriBab,
    required super.levelTeori,
    required super.kelengkapan,
    required super.idMataPelajaran,
    required super.mataPelajaran,
  });

  factory SobatTipsBabModel.fromJson(Map<String, dynamic> json) {
    // List<String> listIdTeori = [];
    //
    // if (json['c_idteoribab'] != null) {
    //   listIdTeori = '${json['c_idteoribab']}'.split(',');
    //   listIdTeori.sort((a, b) => a.compareTo(b));
    // }

    return SobatTipsBabModel(
      kodeBab: json['c_KodeBab'],
      namaBab: '${json['c_NamaBab']} (Teori ${json['kelengkapan']})',
      idTeoriBab: json['c_IdTeoriBab'],
      levelTeori: json['levelTeori'],
      kelengkapan: json['kelengkapan'],
      idMataPelajaran: json['c_IdMataPelajaran'],
      mataPelajaran: json['c_NamaMataPelajaran'],
      // listIdTeoriBab: listIdTeori,
    );
  }
}
