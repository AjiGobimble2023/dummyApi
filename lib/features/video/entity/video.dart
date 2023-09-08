import 'package:equatable/equatable.dart';

/// [Video] merupakan Parent dari entitas Video Teori, Soal, dan Ekstra.<br><br>
///
/// Id Jenis Produk Video:
/// 1) e-Video Ekstra (id: 57).<br>
/// 2) e-Video Soal (id: 87).<br>
/// 3) e-Video Teori (id: 88).<br><br>
class Video extends Equatable {
  final String idVideo;
  final String linkVideo;
  final String judulVideo;
  final String deskripsi;
  final List<String> keywords;

  const Video({
    required this.idVideo,
    required this.linkVideo,
    required this.judulVideo,
    required this.deskripsi,
    required this.keywords,
  });

  @override
  List<Object> get props =>
      [idVideo, judulVideo, linkVideo, keywords, deskripsi];
}