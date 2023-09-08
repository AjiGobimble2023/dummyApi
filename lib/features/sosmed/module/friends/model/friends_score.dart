class FriendsScore {
  final String tryoutName;
  final String tryoutCode;
  final String tryoutScore;
  final String rank;

  FriendsScore(
      {required this.tryoutName,
      required this.tryoutCode,
      required this.tryoutScore,
      required this.rank});

  factory FriendsScore.fromJson(Map<String, dynamic> json) => FriendsScore(
        tryoutName: json['namaTOB'],
        tryoutCode: json['kodeTOB'],
        tryoutScore: json['score'].toString(),
        rank: json['rank'].toString(),
      );
}

class MyScore {
  final String total;

  MyScore({required this.total});

  factory MyScore.fromJson(Map<String, dynamic> json) => MyScore(
        total: json['total'],
      );
}
