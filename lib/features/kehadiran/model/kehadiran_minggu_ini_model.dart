import '../entity/kehadiran_minggu_ini.dart';

class KehadiranMingguIniModel extends KehadiranMingguIni {
  const KehadiranMingguIniModel({
    required int jumlahHadir,
    required int jumlahPertemuan,
  }) : super(
          jumlahHadir: jumlahHadir,
          jumlahPertemuan: jumlahPertemuan,
        );

  factory KehadiranMingguIniModel.fromJson(Map<String, dynamic> json) =>
      KehadiranMingguIniModel(
        jumlahHadir: int.parse(json['jumhadir']),
        jumlahPertemuan: int.parse(json['jumharus']),
      );
}
