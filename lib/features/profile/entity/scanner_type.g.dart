// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scanner_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScannerTypeAdapter extends TypeAdapter<ScannerType> {
  @override
  final int typeId = 0;

  @override
  ScannerType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ScannerType.mobileScanner;
      case 1:
        return ScannerType.flutterBarcodeScanner;
      default:
        return ScannerType.mobileScanner;
    }
  }

  @override
  void write(BinaryWriter writer, ScannerType obj) {
    switch (obj) {
      case ScannerType.mobileScanner:
        writer.writeByte(0);
        break;
      case ScannerType.flutterBarcodeScanner:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScannerTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
