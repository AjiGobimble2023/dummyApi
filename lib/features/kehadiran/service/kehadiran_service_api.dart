import 'dart:convert';

import '../../../../core/helper/api_helper.dart';
import '../../../../core/util/app_exceptions.dart';

/// [KehadiranServiceApi] merupakan service class penghubung provider dengan request api.
class KehadiranServiceApi {
  final _apiHelper = ApiHelper();

  Future<dynamic> fetchKehadiranMingguIni({
    required String noRegistrasi,
  }) async {
    var response = await _apiHelper.requestPost(
      pathUrl: '/presence/getkehadiran',
      bodyParams: {'nis': noRegistrasi},
    );

    if (response is String) {
      response = jsonDecode(response);
    }

    if (!response['status']) throw DataException(message: response['message']);

    return response['data'];
  }
}
