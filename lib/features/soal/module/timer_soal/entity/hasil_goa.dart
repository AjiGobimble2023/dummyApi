class BelumMengerjakanGOA extends HasilGOA {
  BelumMengerjakanGOA()
      : super(
          isRemedial: false,
          jumlahPercobaanRemedial: 0,
          detailHasilGOA: [],
        );
}

class HasilGOA {
  bool isRemedial;
  int jumlahPercobaanRemedial;
  final List<DetailHasilGOA> detailHasilGOA;

  HasilGOA({
    required this.isRemedial,
    required this.jumlahPercobaanRemedial,
    required this.detailHasilGOA,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HasilGOA &&
          runtimeType == other.runtimeType &&
          detailHasilGOA == other.detailHasilGOA;

  @override
  int get hashCode => detailHasilGOA.hashCode;
}

class DetailHasilGOA {
  /// [targetLulus] merupakan minimum jumlah benar agar GOA dianggap lulus.
  final int targetLulus;
  final int idKelompokUjian;
  final String namaKelompokUjian;
  bool isLulus;
  int benar;
  int salah;
  int kosong;

  DetailHasilGOA({
    required this.isLulus,
    required this.benar,
    required this.salah,
    required this.kosong,
    required this.targetLulus,
    required this.idKelompokUjian,
    required this.namaKelompokUjian,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DetailHasilGOA &&
          runtimeType == other.runtimeType &&
          targetLulus == other.targetLulus &&
          idKelompokUjian == other.idKelompokUjian &&
          namaKelompokUjian == other.namaKelompokUjian;

  @override
  int get hashCode =>
      Object.hash(targetLulus, idKelompokUjian, namaKelompokUjian);
}
