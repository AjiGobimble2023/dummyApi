import 'package:hive/hive.dart';

import '../../../../../core/util/data_formatter.dart';

part 'kampus_impian.g.dart';

// @HiveType(typeId: 4)
// class KampusImpian extends HiveObject {
//   @HiveField(0)
//   final DetailJurusan pilihan1;
//   @HiveField(1)
//   final DetailJurusan pilihan2;
//   @HiveField(2)
//   List<DetailJurusan> riwayatPilihan;
//
//   KampusImpian({
//     required this.pilihan1,
//     this.pilihan2,
//     this.riwayatPilihan,
//   });
//
//   factory KampusImpian.fromJson(Map<String, dynamic> json) {
//     return KampusImpian(
//       idPTN: json['idPTN'],
//       namaPTN: json['namaPTN'],
//       aliasPTN: json['aliasPTN'],
//       idJurusan: json['idJurusan'],
//       namaJurusan: json['namaJurusan'],
//       kelompok: json['kelompok'],
//       rumpun: json['rumpun'],
//       peminat: json['info']?['peminat'] ?? [],
//       tampung: json['info']?['tampung'] ?? [],
//       passGrade: json['passgrade'],
//       lintas: (json['lintas'] == 'Y') ? true : false,
//       deskripsi: json['deskripsi'],
//       lapanganPekerjaan: json['lapker'],
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//         'pilihan1': pilihan1,
//         'pilihan2': pilihan2,
//         'riwayatPilihan': riwayatPilihan,
//       };
//
//   @override
//   String toString() => '\nKampusImpian('
//       'pilihan1: $pilihan1, '
//       'pilihan2: $pilihan2, '
//       'riwayatPilihan: $riwayatPilihan, '
//       ')\n\n';
// }

@HiveType(typeId: 4)
class KampusImpian extends HiveObject {
  @HiveField(0)
  final int pilihanKe;
  @HiveField(1)
  final DateTime tanggalPilih;
  @HiveField(2)
  final int idPTN;
  @HiveField(3)
  final String namaPTN;
  @HiveField(4)
  final String aliasPTN;
  @HiveField(5)
  final int idJurusan;
  @HiveField(6)
  final String namaJurusan;
  @HiveField(7)
  final String peminat;
  @HiveField(8)
  final String tampung;

  KampusImpian({
    required this.pilihanKe,
    required this.tanggalPilih,
    required this.idPTN,
    required this.namaPTN,
    required this.aliasPTN,
    required this.idJurusan,
    required this.namaJurusan,
    required this.peminat,
    required this.tampung,
  });

  factory KampusImpian.fromJson(Map<String, dynamic> json) {
    return KampusImpian(
      pilihanKe: json['pilihan'],
      tanggalPilih: DataFormatter.stringToDate(json['tanggal']),
      idPTN: json['idPTN'],
      namaPTN: json['namaPTN'],
      aliasPTN: json['aliasPTN'],
      idJurusan: json['idJurusan'],
      namaJurusan: json['namaJurusan'],
      peminat: json['peminat'],
      tampung: json['tampung'],
    );
  }

  Map<String, dynamic> toJson() => {
        'pilihan': pilihanKe,
        'tanggal': DataFormatter.dateTimeToString(tanggalPilih),
        'idPTN': idPTN,
        'namaPTN': namaPTN,
        'aliasPTN': aliasPTN,
        'idJurusan': idJurusan,
        'namaJurusan': namaJurusan,
        'peminat': peminat,
        'tampung': tampung,
      };

  @override
  String toString() => '\nKampusImpian('
      'pilihanKe: $pilihanKe,'
      'tanggalPilih: $tanggalPilih,'
      'idPTN: $idPTN, '
      'namaPTN: $namaPTN, '
      'aliasPTN: $aliasPTN, '
      'idJurusan: $idJurusan, '
      'namaJurusan: $namaJurusan, '
      'peminat: $peminat, '
      'tampung: $tampung'
      ')';
}
