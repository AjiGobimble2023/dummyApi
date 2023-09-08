import 'package:equatable/equatable.dart';

class Carousel extends Equatable {
  final String namaFile;
  final String keterangan;
  final dynamic link;
  final String status;
  final String tanggal;

  const Carousel({
    required this.namaFile,
    required this.keterangan,
    required this.link,
    required this.status,
    required this.tanggal,
  });

  @override
  List<Object> get props => [namaFile, keterangan, link, status, tanggal];
}
