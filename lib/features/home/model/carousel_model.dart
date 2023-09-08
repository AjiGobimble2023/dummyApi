import '../entity/carousel.dart';

class CarouselModel extends Carousel {
  const CarouselModel({
    required String namaFile,
    required String keterangan,
    required dynamic link,
    required String status,
    required String tanggal,
  }) : super(
          namaFile: namaFile,
          keterangan: keterangan,
          link: link,
          status: status,
          tanggal: tanggal,
        );

  factory CarouselModel.fromJson(Map<String, dynamic> json) => CarouselModel(
        namaFile: json['nama_file'],
        keterangan: json['keterangan'],
        link: json['link'],
        status: json['status'],
        tanggal: json['tanggal'],
      );

  Map<String, dynamic> toJson() => {
        'nama_file': namaFile,
        'keterangan': keterangan,
        'link': link,
        'status': status,
        'tanggal': tanggal,
      };
}
