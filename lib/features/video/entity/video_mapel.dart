import 'package:equatable/equatable.dart';

class VideoMapel extends Equatable {
  final String? imageUrl;
  final String idMataPelajaran;
  final String namaMataPelajaran;
  final String tingkatSekolah;

  const VideoMapel(
      {this.imageUrl,
      required this.idMataPelajaran,
      required this.namaMataPelajaran,
      required this.tingkatSekolah});

  @override
  List<Object?> get props => [idMataPelajaran, namaMataPelajaran];
}
