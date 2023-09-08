import '../../../../../../core/helper/api_helper.dart';
import '../../../../../../core/util/app_exceptions.dart';

class LaporanAktifitasServiceAPI {
  final ApiHelper _apiHelper = ApiHelper();

  /// [fetchAktifitas] digunakan untuk mengambil data aktivitas dari server.
  ///
  /// Args:
  ///   userId (String): Nomor registrasi siswa.
  ///   type (String): tipe data log aktivitas Hari ini/Minggu ini
  Future<dynamic> fetchAktifitas({
    required String userId,
    required String type,
  }) async {
    final response = await _apiHelper.requestPost(
      pathUrl: '/log',
      bodyParams: {'nis': userId, 'type': type},
    );
    if (!response['status']) throw DataException(message: response['message']);

    return response['data'];
  }
}
