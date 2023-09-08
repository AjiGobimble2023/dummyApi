// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmark.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BookmarkMapelAdapter extends TypeAdapter<BookmarkMapel> {
  @override
  final int typeId = 1;

  @override
  BookmarkMapel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BookmarkMapel(
      idKelompokUjian: fields[0] as String,
      namaKelompokUjian: fields[1] as String,
      iconMapel: fields[2] as String?,
      listBookmark:
          fields[4] == null ? [] : (fields[4] as List).cast<BookmarkSoal>(),
    );
  }

  @override
  void write(BinaryWriter writer, BookmarkMapel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.idKelompokUjian)
      ..writeByte(1)
      ..write(obj.namaKelompokUjian)
      ..writeByte(2)
      ..write(obj.iconMapel)
      ..writeByte(4)
      ..write(obj.listBookmark);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookmarkMapelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BookmarkSoalAdapter extends TypeAdapter<BookmarkSoal> {
  @override
  final int typeId = 2;

  @override
  BookmarkSoal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BookmarkSoal(
      idSoal: fields[0] as String,
      nomorSoal: fields[1] as int,
      nomorSoalSiswa: fields[2] as int,
      idBundel: fields[5] as String,
      kodeTOB: fields[3] as String,
      kodePaket: fields[4] as String,
      kodeBab: fields[6] as String?,
      namaBab: fields[7] as String?,
      idJenisProduk: fields[8] as int,
      namaJenisProduk: fields[9] as String,
      tanggalKedaluwarsa: fields[10] as String?,
      isPaket: fields[11] as bool,
      isSimpan: fields[12] as bool,
      lastUpdate: fields[13] as String,
    );
  }

  @override
  void write(BinaryWriter writer, BookmarkSoal obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.idSoal)
      ..writeByte(1)
      ..write(obj.nomorSoal)
      ..writeByte(2)
      ..write(obj.nomorSoalSiswa)
      ..writeByte(3)
      ..write(obj.kodeTOB)
      ..writeByte(4)
      ..write(obj.kodePaket)
      ..writeByte(5)
      ..write(obj.idBundel)
      ..writeByte(6)
      ..write(obj.kodeBab)
      ..writeByte(7)
      ..write(obj.namaBab)
      ..writeByte(8)
      ..write(obj.idJenisProduk)
      ..writeByte(9)
      ..write(obj.namaJenisProduk)
      ..writeByte(10)
      ..write(obj.tanggalKedaluwarsa)
      ..writeByte(11)
      ..write(obj.isPaket)
      ..writeByte(12)
      ..write(obj.isSimpan)
      ..writeByte(13)
      ..write(obj.lastUpdate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookmarkSoalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
