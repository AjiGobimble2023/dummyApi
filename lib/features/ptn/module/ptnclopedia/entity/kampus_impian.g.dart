// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kampus_impian.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KampusImpianAdapter extends TypeAdapter<KampusImpian> {
  @override
  final int typeId = 4;

  @override
  KampusImpian read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KampusImpian(
      pilihanKe: fields[0] as int,
      tanggalPilih: fields[1] as DateTime,
      idPTN: fields[2] as int,
      namaPTN: fields[3] as String,
      aliasPTN: fields[4] as String,
      idJurusan: fields[5] as int,
      namaJurusan: fields[6] as String,
      peminat: fields[7] as String,
      tampung: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, KampusImpian obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.pilihanKe)
      ..writeByte(1)
      ..write(obj.tanggalPilih)
      ..writeByte(2)
      ..write(obj.idPTN)
      ..writeByte(3)
      ..write(obj.namaPTN)
      ..writeByte(4)
      ..write(obj.aliasPTN)
      ..writeByte(5)
      ..write(obj.idJurusan)
      ..writeByte(6)
      ..write(obj.namaJurusan)
      ..writeByte(7)
      ..write(obj.peminat)
      ..writeByte(8)
      ..write(obj.tampung);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KampusImpianAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
