// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kelompok_ujian.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KelompokUjianAdapter extends TypeAdapter<KelompokUjian> {
  @override
  final int typeId = 3;

  @override
  KelompokUjian read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KelompokUjian(
      idKelompokUjian: fields[0] as int,
      namaKelompokUjian: fields[1] as String,
      initial: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, KelompokUjian obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.idKelompokUjian)
      ..writeByte(1)
      ..write(obj.namaKelompokUjian)
      ..writeByte(2)
      ..write(obj.initial);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KelompokUjianAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
