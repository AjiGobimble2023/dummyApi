import 'package:equatable/equatable.dart';

import '../entity/video.dart';

/// Object dari e-Video Ekstra (id: 57) + e-Video Teori (id: 88)
/// pada menu Jadwal & Video.<br>
/// Response:
///<br> {
///         babutama,
///         info => aray of VideoJadwal,
///<br> }
/// <br>
/// Source: /v4/video/getbab
class BabUtamaVideoJadwal extends Equatable {
  final String namaBabUtama;
  final List<VideoJadwal> daftarVideo;

  const BabUtamaVideoJadwal(
      {required this.namaBabUtama, required this.daftarVideo});

  factory BabUtamaVideoJadwal.fromJson(Map<String, dynamic> json) {
    List<VideoJadwal> daftarVideo = [];

    if (json['info'] != null) {
      for (var dataVideo in json['info']) {
        daftarVideo.add(VideoJadwal.fromJson(dataVideo));
      }
      daftarVideo.sort((a, b) => a.judulVideo.compareTo(b.judulVideo));
    }

    return BabUtamaVideoJadwal(
      namaBabUtama: json['babutama'],
      daftarVideo: daftarVideo,
    );
  }

  @override
  List<Object?> get props => [namaBabUtama, daftarVideo];
}

/// Object dari e-Video Ekstra (id: 57) + e-Video Teori (id: 88)
/// pada menu Jadwal & Video.<br>
/// Response:
///<br> {
///         c_namabab,
///         c_kodebab,
///         c_IdVideo,
///         c_Deskripsi,
///         c_JudulVideo,
///         c_LinkVideo,
///<br> }
/// <br>
/// Source: /v4/video/getbab
class VideoJadwal extends Video {
  final String kodeBab;
  final String namaBab;

  const VideoJadwal({
    required this.namaBab,
    required this.kodeBab,
    required super.idVideo,
    required super.linkVideo,
    required super.judulVideo,
    required super.deskripsi,
    required super.keywords,
  });

  factory VideoJadwal.fromJson(Map<String, dynamic> json) {
    List<String> keywords = [];

    if (json['c_Keyword'] != null) {
      keywords = '${json['c_Keyword']}'.split(',');
    }

    return VideoJadwal(
      kodeBab: json['c_kodebab'],
      namaBab: json['c_namabab'],
      idVideo: json['c_IdVideo'],
      linkVideo: json['c_LinkVideo'],
      judulVideo: json['c_JudulVideo'],
      deskripsi: json['c_Deskripsi'],
      keywords: keywords,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'c_kodebab': kodeBab,
      'c_namabab': namaBab,
      'c_IdVideo': idVideo,
      'c_LinkVideo': linkVideo,
      'c_JudulVideo': judulVideo,
      'c_Deskripsi': deskripsi,
    };
  }
}
