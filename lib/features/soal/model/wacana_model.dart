import '../entity/wacana.dart';

class WacanaModel extends Wacana {
  const WacanaModel({
    required super.idWacana,
    required super.judulWacana,
    required super.wacanaText,
  });

  factory WacanaModel.fromJson(Map<String, dynamic> json) => WacanaModel(
        idWacana: json['c_IdWacana'] ?? json['c_idwacana'],
        judulWacana: json['c_JudulWacana'] ?? json['c_judulwacana'],
        wacanaText: json['c_Text'] ?? json['c_text'],
      );
}
