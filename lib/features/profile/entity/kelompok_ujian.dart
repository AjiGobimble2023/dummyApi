import 'package:hive/hive.dart';

part 'kelompok_ujian.g.dart';

@HiveType(typeId: 3)
class KelompokUjian extends HiveObject {
  @HiveField(0)
  final int idKelompokUjian;
  @HiveField(1)
  final String namaKelompokUjian;
  @HiveField(2)
  final String initial;

  KelompokUjian({
    required this.idKelompokUjian,
    required this.namaKelompokUjian,
    required this.initial,
  });

  factory KelompokUjian.fromJson(
          {int? idKelompokUjian, required Map<String, dynamic> json}) =>
      KelompokUjian(
        idKelompokUjian: idKelompokUjian ?? json['idKelompokUjian'],
        namaKelompokUjian: json['nama'] ?? json['namaKelompokUjian'],
        initial: json['initial'],
      );

  Map<String, dynamic> toJson() => {
        'idKelompokUjian': idKelompokUjian,
        'namaKelompokUjian': namaKelompokUjian,
        'initial': initial
      };

  @override
  String toString() => 'BookmarkMapel('
      'idKelompokUjian: $idKelompokUjian, '
      'namaKelompokUjian: $namaKelompokUjian, '
      'initial: $initial), ';
}
