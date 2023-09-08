import '../entity/laporan_aktivitas.dart';

class LaporanAktivitasModel extends LaporanAktivitas {
  LaporanAktivitasModel({
    /// [id] merupakan variable Id LogAktivitas
    required String id,

    /// [menu] merupakan variable yang berisi menu yang di akses
    required String menu,

    /// [detail] merupakan variable yang berisi detail menu yang diakses
    required String detail,

    /// [masuk] merupakan variable yang berisi timestamp akses menu tersebut
    required String masuk,

    /// [keluar] merupakan variable yang berisi timestamp keluar dari menu tersebut
    String? keluar,
  }) : super(
          id: id,
          menu: menu,
          detail: detail,
          masuk: masuk,
          keluar: keluar!,
        );

  factory LaporanAktivitasModel.fromJson(Map<String, dynamic> json) =>
      LaporanAktivitasModel(
        id: json['id'],
        menu: json['menu'],
        detail: json['detail'],
        masuk: json['masuk'],
        keluar: json['keluar'] ?? "",
      );
}
