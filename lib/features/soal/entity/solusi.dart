import 'package:equatable/equatable.dart';

class Solusi extends Equatable {
  /// [solusi] merupakan penjelasan Solusi dari Soal.
  final String solusi;

  /// [theKing] merupakan solusi cerdas dari GO.
  final String? theKing;

  /// [idVideo] video soal.
  final int? idVideo;

  const Solusi({
    required this.solusi,
    this.theKing,
    this.idVideo,
  });

  @override
  List<Object?> get props => [
        solusi,
        theKing,
        idVideo,
      ];
}

class VideoSolusi extends Equatable {
  final String idVideo;
  final String judulVideo;
  final String keyword;
  final String deskripsi;
  final String videoUrl;

  const VideoSolusi(
      {required this.idVideo,
      required this.judulVideo,
      required this.keyword,
      required this.deskripsi,
      required this.videoUrl});

  @override
  List<Object?> get props =>
      [idVideo, judulVideo, keyword, deskripsi, videoUrl];
}
