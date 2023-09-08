import '../entity/solusi.dart';

class SolusiModel extends Solusi {
  const SolusiModel({
    required super.solusi,
    super.theKing,
    super.idVideo,
  });

  factory SolusiModel.fromJson(Map<String, dynamic> json) {
    return SolusiModel(
      solusi: json['c_Solusi'],
      theKing: json['c_TheKing'],
      idVideo: json['c_IdVideo'],
    );
  }
}

class VideoSolusiModel extends VideoSolusi {
  const VideoSolusiModel({
    required super.idVideo,
    required super.judulVideo,
    required super.keyword,
    required super.deskripsi,
    required super.videoUrl,
  });

  factory VideoSolusiModel.fromJson(Map<String, dynamic> json) =>
      VideoSolusiModel(
        idVideo: json['c_idVideo'],
        judulVideo: json['c_judulVideo'],
        keyword: json['c_Keyword'],
        deskripsi: json['c_Deskripsi'],
        videoUrl: json['c_LinkVideo'],
      );
}
