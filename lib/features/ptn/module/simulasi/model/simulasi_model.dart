
import '../entity/simulasi.dart';

class SimulasiModel extends Simulasi {
  const SimulasiModel({
    required String id,
    required String label,
    required bool prevStep,
  }) : super(
          id: id,
          label: label,
          prevStep: prevStep,
        );

  factory SimulasiModel.fromJson(Map<String, dynamic> json) => SimulasiModel(
        id: json['menuId'],
        label: json['menuTitle'],
        prevStep: json['prevStep'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'prevStep': prevStep,
      };
}
