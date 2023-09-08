import '../entity/info.dart';

class InfoModel extends Info {
  InfoModel({
    int? jumlah,
    int? tahun,
  }) : super(
          jumlah: jumlah!,
          tahun: tahun!,
        );

  factory InfoModel.fromJson(Map<String, dynamic> json) => InfoModel(
        jumlah: (json['jml'] is double)
            ? (json['jml'] as double).round()
            : json['jml'],
        tahun: (json['tahun'] is double)
            ? (json['tahun'] as double).round()
            : json['tahun'],
      );
}
