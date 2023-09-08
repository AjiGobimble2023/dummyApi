import 'package:equatable/equatable.dart';

class CapaianScore extends Equatable {
  final int totalScore;
  final int totalSoal;
  final int targetJumlahSoal;
  final int totalSoalBenar;
  final int totalSoalSalah;
  final int rankingGedung;
  final int rankingKota;
  final int rankingNasional;

  const CapaianScore({
    required this.totalScore,
    required this.totalSoal,
    required this.targetJumlahSoal,
    required this.totalSoalBenar,
    required this.totalSoalSalah,
    required this.rankingGedung,
    required this.rankingKota,
    required this.rankingNasional,
  });

  factory CapaianScore.fromJson(Map<String, dynamic> json) => CapaianScore(
        totalScore: json['totalScore'] ?? 0,
        totalSoal: json['totalSoal'] ?? 0,
        targetJumlahSoal: json['targetJumlahSoal'] ?? 0,
        totalSoalBenar: json['totalSoalBenar'] ?? 0,
        totalSoalSalah: json['totalSoalSalah'] ?? 0,
        // rankingGedung: int.parse(json['rankgedung'] ?? '0'),
        rankingGedung: json['rankGedung'] ?? 0,
        rankingKota: json['rankKota'] ?? 0,
        rankingNasional: json['rankNasional'] ?? 0,
      );

  @override
  List<Object?> get props => [
        totalScore,
        totalSoal,
        totalSoalBenar,
        rankingGedung,
        rankingKota,
        rankingNasional
      ];
}
