import 'package:hive/hive.dart';

part 'scanner_type.g.dart';

@HiveType(typeId: 0)
enum ScannerType {
  @HiveField(0, defaultValue: true)
  mobileScanner,
  @HiveField(1)
  flutterBarcodeScanner,
}