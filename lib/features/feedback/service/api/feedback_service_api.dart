import '../../../../core/helper/api_helper.dart';
import '../../../../core/util/app_exceptions.dart';

class FeedbackServiceApi {
  final ApiHelper _apiHelper = ApiHelper();

  Future<dynamic> fetchFeedbackQuestion({
    required String userId,
    required String idRencana,
  }) async {
    final response = await _apiHelper.requestPost(
      pathUrl: "/feedback/question",
      bodyParams: {'userId': userId, 'idRencana': idRencana},
    );

    if (!response['status']) throw DataException(message: response['message']);

    return response['data'];
  }

  Future<void> setFeedback({
    required Map<String, dynamic> params,
  }) async {
    final response = await _apiHelper.requestPost(
      pathUrl: '/2109/feedback/save',
      bodyParams: params,
    );

    if (!response['status']) throw DataException(message: response['message']);
  }
}
