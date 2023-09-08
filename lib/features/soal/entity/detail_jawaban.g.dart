// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detail_jawaban.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DetailJawabanAdapter extends TypeAdapter<DetailJawaban> {
  @override
  final int typeId = 5;

  @override
  DetailJawaban read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DetailJawaban(
      jenisProduk: fields[0] as String,
      kodePaket: fields[1] as String,
      idBundel: fields[2] as String,
      kodeBab: fields[3] as String?,
      idSoal: fields[4] as String,
      nomorSoalDatabase: fields[5] as int,
      nomorSoalSiswa: fields[6] as int,
      idKelompokUjian: fields[7] as String,
      namaKelompokUjian: fields[8] as String,
      tipeSoal: fields[9] as String,
      tingkatKesulitan: fields[10] as int,
      kesempatanMenjawab: fields[11] as int?,
      jawabanSiswa: fields[12] as dynamic,
      kunciJawaban: fields[13] as dynamic,
      translatorEPB: fields[14] as dynamic,
      jawabanSiswaEPB: fields[15] as dynamic,
      kunciJawabanEPB: fields[16] as dynamic,
      infoNilai: (fields[17] as Map?)?.cast<String, dynamic>(),
      nilai: fields[18] as double,
      isRagu: fields[19] as bool,
      sudahDikumpulkan: fields[20] as bool,
      lastUpdate: fields[21] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DetailJawaban obj) {
    writer
      ..writeByte(22)
      ..writeByte(0)
      ..write(obj.jenisProduk)
      ..writeByte(1)
      ..write(obj.kodePaket)
      ..writeByte(2)
      ..write(obj.idBundel)
      ..writeByte(3)
      ..write(obj.kodeBab)
      ..writeByte(4)
      ..write(obj.idSoal)
      ..writeByte(5)
      ..write(obj.nomorSoalDatabase)
      ..writeByte(6)
      ..write(obj.nomorSoalSiswa)
      ..writeByte(7)
      ..write(obj.idKelompokUjian)
      ..writeByte(8)
      ..write(obj.namaKelompokUjian)
      ..writeByte(9)
      ..write(obj.tipeSoal)
      ..writeByte(10)
      ..write(obj.tingkatKesulitan)
      ..writeByte(11)
      ..write(obj.kesempatanMenjawab)
      ..writeByte(12)
      ..write(obj.jawabanSiswa)
      ..writeByte(13)
      ..write(obj.kunciJawaban)
      ..writeByte(14)
      ..write(obj.translatorEPB)
      ..writeByte(15)
      ..write(obj.jawabanSiswaEPB)
      ..writeByte(16)
      ..write(obj.kunciJawabanEPB)
      ..writeByte(17)
      ..write(obj.infoNilai)
      ..writeByte(18)
      ..write(obj.nilai)
      ..writeByte(19)
      ..write(obj.isRagu)
      ..writeByte(20)
      ..write(obj.sudahDikumpulkan)
      ..writeByte(21)
      ..write(obj.lastUpdate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DetailJawabanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
