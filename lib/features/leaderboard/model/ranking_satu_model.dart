class RankingSatuModel {
  final String noRegistrasi;
  final String namaLengkap;
  final String score;
  final String tipe;
  final String? photoUrl;

  RankingSatuModel({
    required this.noRegistrasi,
    required this.namaLengkap,
    required this.score,
    required this.tipe,
    this.photoUrl,
  });

  factory RankingSatuModel.fromJson(Map<String, dynamic> json) =>
      RankingSatuModel(
          noRegistrasi: json['noRegistrasi'],
          namaLengkap: json['namaLengkap'],
          score: json['score'],
          tipe: json['tipe'],
          photoUrl: json['url']);

  Map<String, dynamic> toJson() => {
        'noRegistrasi': noRegistrasi,
        'namaLengkap': namaLengkap,
        'score': score,
        'tipe': tipe,
        'url': photoUrl
      };
}

class UndefinedRankingSatu extends RankingSatuModel {
  UndefinedRankingSatu({required String tipe})
      : super(
            noRegistrasi: '-', namaLengkap: '......', score: '...', tipe: tipe);
}
