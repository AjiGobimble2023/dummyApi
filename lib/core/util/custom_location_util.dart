import 'package:geolocator/geolocator.dart';

import 'app_exceptions.dart';

class CustomLocationUtil {
  static Future<Position> getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationException(message: "Layanan lokasi dinonaktifkan");
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      throw LocationException(
          message:
              'Izin lokasi ditolak secara permanen, kami tidak dapat meminta izin.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        throw LocationException(
            message: 'Izin lokasi ditolak (status izin: $permission).');
      }
    }

    final coordinate = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);

    // ignore: unnecessary_null_comparison
    if (coordinate.latitude == null || coordinate.longitude == null) {
      throw LocationException(
          message: 'Gagal mendapatkan data koordinat device, '
              'mohon pastikan service GPS/Location '
              'aktif dan coba kembali');
    }

    return coordinate;
  }
}
