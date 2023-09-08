// ignore_for_file: prefer_collection_literals

class DetailNilai {
  String? cIdsoal;
  String? cSoal;
  String? cSolusi;
  String? cBab;
  String? cJawaban;
  String? jawabanSiswa;
  int? nomorSiswa;

  DetailNilai(
      {this.cIdsoal,
      this.cSoal,
      this.cSolusi,
      this.cBab,
      this.cJawaban,
      this.jawabanSiswa,
      this.nomorSiswa});

  DetailNilai.fromJson(Map<String, dynamic> json) {
    cIdsoal = json['c_idsoal'] ?? "";
    cSoal = json['c_soal'] ?? "";
    cSolusi = json['c_solusi'] ?? "";
    cBab = json['c_bab'] ?? "";
    cJawaban = json['c_jawaban'] ?? "";
    jawabanSiswa = json['jawaban_siswa'] ?? "";
    nomorSiswa = json['nomor_siswa'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['c_idsoal'] = cIdsoal;
    data['c_soal'] = cSoal;
    data['c_solusi'] = cSolusi;
    data['c_bab'] = cBab;
    data['c_jawaban'] = cJawaban;
    data['jawaban_siswa'] = jawabanSiswa;
    data['nomor_siswa'] = nomorSiswa;
    return data;
  }
}
