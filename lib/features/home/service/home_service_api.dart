import '../../../core/helper/api_helper.dart';
import '../../../core/util/app_exceptions.dart';

class HomeServiceAPI {
  final ApiHelper _apiHelper = ApiHelper();

  static final HomeServiceAPI _instance = HomeServiceAPI._internal();

  factory HomeServiceAPI() => _instance;

  HomeServiceAPI._internal();

  Future<dynamic> fetchVersion() async {
    final response = await _apiHelper.requestPost(
      jwt: false,
      pathUrl: '/version',
    );

    if (!response['status']) throw DataException(message: 'Tidak ada update');

    return response['data'];
  }

  Future<dynamic> fetchCarousel() async {
    final response = await _apiHelper.requestPost(
      jwt: false,
      pathUrl: '/carousel',
    );

    return response['data'];
  }
}
