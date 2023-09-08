import '../entity/video_mapel.dart';

class VideoMapelModel extends VideoMapel {
  const VideoMapelModel({
    super.imageUrl,
    required super.idMataPelajaran,
    required super.namaMataPelajaran,
    required super.tingkatSekolah,
  });

  factory VideoMapelModel.fromJson(Map<String, dynamic> json,
          {String? imageUrl}) =>
      VideoMapelModel(
        imageUrl: imageUrl,
        idMataPelajaran: json['c_IdMataPelajaran'],
        namaMataPelajaran: json['c_NamaMataPelajaran'],
        tingkatSekolah: json['c_Level'],
      );
}
