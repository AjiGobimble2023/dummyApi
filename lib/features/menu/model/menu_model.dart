import '../entity/menu.dart';

class MenuModel extends Menu {
  const MenuModel({
    required int idJenis,
    required String label,
    required String namaJenisProduk,
    String? iconPath,
    List<String>? permission,
  }) : super(
          idJenis: idJenis,
          label: label,
          namaJenisProduk: namaJenisProduk,
          iconPath: iconPath,
          permission: permission,
        );

  factory MenuModel.fromJson(Map<String, dynamic> json) => MenuModel(
        idJenis: int.parse(json['id']),
        label: json['label'],
        namaJenisProduk: json['jenisProduk'],
        permission: json.containsKey('permission')
            ? json['permission'].cast<String>().toList()
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': idJenis,
        'label': label,
        'jenisProduk': namaJenisProduk,
        'permission': permission
      };
}
