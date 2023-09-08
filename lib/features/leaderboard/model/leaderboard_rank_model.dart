import 'package:equatable/equatable.dart';

class LeaderboardRankModel extends Equatable {
  final String noRegistrasi;
  final String namaLengkap;
  final String level;
  final String sort;
  final int rank;
  final String score;

  const LeaderboardRankModel({
    required this.noRegistrasi,
    required this.namaLengkap,
    required this.level,
    required this.sort,
    required this.rank,
    required this.score,
  });

  bool get isJuaraSatu => rank == 1;
  bool get isJuaraDua => rank == 2;
  bool get isJuaraTiga => rank == 3;
  bool get isBigThree => rank > 0 && rank <= 3;
  bool get isBigFive => rank > 0 && rank <= 5;

  factory LeaderboardRankModel.fromJson(Map<String, dynamic> json) => LeaderboardRankModel(
        noRegistrasi: json['id'],
        namaLengkap: json['fullName'],
        level: json['level'],
        sort: json['sort'],
        rank: int.parse(json['rank']),
        score: json['total'],
      );

  @override
  List<Object> get props => [noRegistrasi, namaLengkap, level, sort, rank, score];
}
