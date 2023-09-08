import '../entity/video.dart';

/// Object dari e-Video Soal (id: 87).<br>
/// Response:
///<br> {
///         c_Keyword,
///         c_IdVideo,
///         c_Deskripsi,
///         c_JudulVideo,
///         c_LinkVideo,
///<br> }
/// <br>
/// Source: /v4/solusi/getvideo
class VideoSoal extends Video {
  const VideoSoal({
    required super.idVideo,
    required super.linkVideo,
    required super.judulVideo,
    required super.deskripsi,
    required super.keywords,
  });

  factory VideoSoal.fromJson(Map<String, dynamic> json) {
    List<String> keywords = [];

    if (json['c_Keyword'] != null) {
      keywords = '${json['c_Keyword']}'.split(',');
    }

    return VideoSoal(
      idVideo: json['c_idVideo'],
      linkVideo: json['c_LinkVideo'],
      judulVideo: json['c_JudulVideo'],
      deskripsi: json['c_Deskripsi'],
      keywords: keywords,
    );
  }
}
