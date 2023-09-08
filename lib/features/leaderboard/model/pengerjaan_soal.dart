import 'package:equatable/equatable.dart';

class PengerjaanSoal extends Equatable {
  final int idMapel;
  final int targetHarian;
  final int pengerjaanHarian;
  final int benarHarian;
  final int salahHarian;
  final int targetMingguan;
  final int pengerjaanMingguan;
  final int benarMingguan;
  final int salahMingguan;
  final int targetBulanan;
  final int pengerjaanBulanan;
  final int benarBulanan;
  final int salahBulanan;

  const PengerjaanSoal({
    required this.idMapel,
    required this.targetHarian,
    required this.pengerjaanHarian,
    required this.benarHarian,
    required this.salahHarian,
    required this.targetMingguan,
    required this.pengerjaanMingguan,
    required this.benarMingguan,
    required this.salahMingguan,
    required this.targetBulanan,
    required this.pengerjaanBulanan,
    required this.benarBulanan,
    required this.salahBulanan,
  });

  //             "benarharian": "0",
  //             "salahharian": "0",
  //             "benarmingguan": "0",
  //             "salahmingguan": "0",
  //             "benarbulanan": "0",
  //             "salahbulanan": "0"
  //         },
  //
  factory PengerjaanSoal.fromJson(Map<String, dynamic> json) => PengerjaanSoal(
        idMapel: (json['cidmapel'] is int)
            ? json['cidmapel']
            : (json['cidmapel'] == null)
                ? 0
                : int.tryParse(json['cidmapel'].toString()) ?? 0,
        targetHarian: (json['targetharian'] is int)
            ? json['targetharian']
            : (json['targetharian'] == null)
                ? 0
                : int.tryParse(json['targetharian'].toString()) ?? 0,
        pengerjaanHarian: (json['pengerjaanharian'] is int)
            ? json['pengerjaanharian']
            : (json['pengerjaanharian'] == null)
                ? 0
                : int.tryParse(json['pengerjaanharian'].toString()) ?? 0,
        benarHarian: (json['benarharian'] is int)
            ? json['benarharian']
            : (json['benarharian'] == null)
                ? 0
                : int.tryParse(json['benarharian'].toString()) ?? 0,
        salahHarian: (json['salahharian'] is int)
            ? json['salahharian']
            : (json['salahharian'] == null)
                ? 0
                : int.tryParse(json['salahharian'].toString()) ?? 0,
        targetMingguan: (json['targetmingguan'] is int)
            ? json['targetmingguan']
            : (json['targetmingguan'] == null)
                ? 0
                : int.tryParse(json['targetmingguan'].toString()) ?? 0,
        pengerjaanMingguan: (json['pengerjaanmingguan'] is int)
            ? json['pengerjaanmingguan']
            : (json['pengerjaanmingguan'] == null)
                ? 0
                : int.tryParse(json['pengerjaanmingguan'].toString()) ?? 0,
        benarMingguan: (json['benarmingguan'] is int)
            ? json['benarmingguan']
            : (json['benarmingguan'] == null)
                ? 0
                : int.tryParse(json['benarmingguan'].toString()) ?? 0,
        salahMingguan: (json['salahmingguan'] is int)
            ? json['salahmingguan']
            : (json['salahmingguan'] == null)
                ? 0
                : int.tryParse(json['salahmingguan'].toString()) ?? 0,
        targetBulanan: (json['targetbulanan'] is int)
            ? json['targetbulanan']
            : (json['targetbulanan'] == null)
                ? 0
                : int.tryParse(json['targetbulanan'].toString()) ?? 0,
        pengerjaanBulanan: (json['pengerjaanbulanan'] is int)
            ? json['pengerjaanbulanan']
            : (json['pengerjaanbulanan'] == null)
                ? 0
                : int.tryParse(json['pengerjaanbulanan'].toString()) ?? 0,
        benarBulanan: (json['benarbulanan'] is int)
            ? json['benarbulanan']
            : (json['benarbulanan'] == null)
                ? 0
                : int.tryParse(json['benarbulanan'].toString()) ?? 0,
        salahBulanan: (json['salahbulanan'] is int)
            ? json['salahbulanan']
            : (json['salahbulanan'] == null)
                ? 0
                : int.tryParse(json['salahbulanan'].toString()) ?? 0,
      );

  @override
  List<Object?> get props => [
        idMapel,
        targetHarian,
        pengerjaanHarian,
        targetMingguan,
        pengerjaanMingguan,
        targetBulanan,
        pengerjaanBulanan,
      ];
}
