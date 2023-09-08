import '../../model/data_ranking.dart';

/// [DataRanking] digunakan untuk mengubah data JSON menjadi objek DART.
class DataRanking {
  List<Myrank>? topfive;
  List<Myrank>? myrank;

  DataRanking({this.topfive, this.myrank});

  /// Proses mengubah data JSON ke objek DART.
  DataRanking.fromJson(Map<String, dynamic> json) {
    if (json['topfive'] != null) {
      List<dynamic> body = json['topfive'];
      topfive = body.map((dynamic item) => Myrank.fromJson(item)).toList();
    }
    if (json['myrank'] != null) {
      List<dynamic> body = json['myrank'];
      myrank = body.map((dynamic item) => Myrank.fromJson(item)).toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (topfive != null) {
      data['topfive'] = topfive!.map((v) => v.toJson()).toList();
    }
    if (myrank != null) {
      data['myrank'] = myrank!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
