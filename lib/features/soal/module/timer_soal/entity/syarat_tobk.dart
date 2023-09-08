import 'package:equatable/equatable.dart';

class SyaratTOBK extends Equatable {
  final bool isLulus;
  final bool sudahMengerjakan;
  final int jumlahSoalKumulatif;
  final int jumlahBenarKumulatif;
  final int jumlahSalahKumulatif;
  final int jumlahKosongKumulatif;
  final List<HasilEMWA> listEmpati;

  const SyaratTOBK({
    required this.isLulus,
    required this.sudahMengerjakan,
    required this.jumlahSoalKumulatif,
    required this.jumlahBenarKumulatif,
    required this.jumlahSalahKumulatif,
    required this.jumlahKosongKumulatif,
    required this.listEmpati,
  });

  double get percentHasilEmwa => (jumlahBenarKumulatif / jumlahSoalKumulatif) * 100;
  //   String checkInteger = hasil.toStringAsFixed(2);
  //
  //   if (checkInteger.contains('.0') || checkInteger.contains(',0')) {
  //     return '${hasil.toInt()}%';
  //   }
  //   return '${hasil.toStringAsFixed(2)}%';
  // }

  factory SyaratTOBK.fromJson(Map<String, dynamic> json) {
    List<HasilEMWA> listEmpati = [];

    if (json.containsKey('listEmpati')) {
      for (var empati in json['listEmpati']) {
        listEmpati.add(HasilEMWA.fromJson(empati));
      }
    }

    return SyaratTOBK(
      isLulus: json['isLulus'],
      sudahMengerjakan: json['sudahMengerjakan'],
      jumlahSoalKumulatif: json['jumlahSoal'],
      jumlahBenarKumulatif: json['jumlahBenar'],
      jumlahSalahKumulatif: json['jumlahSalah'],
      jumlahKosongKumulatif: json['jumlahKosong'],
      listEmpati: listEmpati,
    );
  }

  @override
  List<Object?> get props => [
        isLulus,
        sudahMengerjakan,
        jumlahSoalKumulatif,
        jumlahBenarKumulatif,
        jumlahSalahKumulatif,
        jumlahKosongKumulatif,
        listEmpati,
      ];
}

class HasilEMWA extends Equatable {
  final String kodeTOB;
  final String kodePaket;
  final int jumlahSoal;
  final int? jumlahBenar;
  final int jumlahSalah;
  final bool isLulus;

  bool get sudahMengerjakan => jumlahBenar != null;
  int get totalPengerjaan => (jumlahBenar ?? 0) + jumlahSalah;
  int get jumlahKosong => jumlahSoal - ((jumlahBenar ?? 0) + jumlahSalah);

  const HasilEMWA({
    required this.kodeTOB,
    required this.kodePaket,
    required this.jumlahSoal,
    this.jumlahBenar,
    required this.jumlahSalah,
    required this.isLulus,
  });

  factory HasilEMWA.fromJson(Map<String, dynamic> json) => HasilEMWA(
        kodeTOB: json['c_KodeTOB'],
        kodePaket: json['c_KodePaket'],
        jumlahSoal: json['c_JumlahSoal'],
        jumlahBenar: json['c_JumlahBenar'],
        jumlahSalah: json['c_JumlahSalah'],
        isLulus: json['c_IsBoleh'],
      );

  @override
  List<Object?> get props => [
        kodeTOB,
        kodePaket,
        jumlahSoal,
        jumlahBenar,
        jumlahSalah,
        isLulus,
      ];
}
