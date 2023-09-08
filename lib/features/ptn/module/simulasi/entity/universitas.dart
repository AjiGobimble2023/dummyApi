import 'package:equatable/equatable.dart';

import '../model/info_model.dart';

class Universitas extends Equatable {
  final String? ptn;
  final String? jurusanId;
  final String? jurusan;
  final String? kelompok;
  final String? rumpun;
  final String? pg;
  final InfoModel? peminat;
  final InfoModel? tampung;

  const Universitas({
    this.ptn,
    this.jurusanId,
    this.jurusan,
    this.kelompok,
    this.rumpun,
    this.pg,
    this.peminat,
    this.tampung,
  });

  @override
  List<Object> get props => [
        ptn!,
        jurusanId!,
        jurusan!,
        kelompok!,
        rumpun!,
        pg!,
        peminat!,
        tampung!,
      ];
}
