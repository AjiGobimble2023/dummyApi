class LaporanKuisModel {
  String? cnamamapel;

  List<Info>? info;

  LaporanKuisModel({this.cnamamapel, this.info});

  LaporanKuisModel.fromJson(Map<String, dynamic> json) {
    cnamamapel = json['cnamamapel'];
    if (json['info'] != null) {
      info = <Info>[];
      json['info'].forEach((v) {
        info!.add(Info.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cnamamapel'] = cnamamapel;
    if (info != null) {
      data['info'] = info!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Info {
  String? cKodeSoal;

  Info({this.cKodeSoal});

  Info.fromJson(Map<String, dynamic> json) {
    cKodeSoal = json['cKodeSoal'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cKodeSoal'] = cKodeSoal;
    return data;
  }
}
