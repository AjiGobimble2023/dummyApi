import '../../../../../core/helper/api_helper.dart';
import '../../../core/util/app_exceptions.dart';

class NotificationServiceApi {
  final _apiHelper = ApiHelper();

  Future<dynamic> fetchNotification(String userId) async {
    final response = await _apiHelper.requestPost(
      pathUrl: "/notif",
      bodyParams: {"userId": userId},
    );
    return response['data'];
  }

  Future<void> deleteNotification(String notifId) async {
    final response = await _apiHelper.requestPost(
      pathUrl: "/notif/delete",
      bodyParams: {"notifId": notifId},
    );

    if (!response['status']) throw DataException(message: response['message']);
  }
}
