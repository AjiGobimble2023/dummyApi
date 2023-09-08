import '../../../../../../core/helper/api_helper.dart';
import '../../../../../../core/util/app_exceptions.dart';

class LeaderboardFriendsServiceApi {
  final _apiHelper = ApiHelper();

  Future<dynamic> fetchLeaderboardFriends(String userId) async {
    final response = await _apiHelper.requestPost(
      pathUrl: "/friend/leaderboard",
      bodyParams: {"userId": userId},
    );

    if (!response['status']) throw DataException(message: response['message']);

    return response['data'];
  }
}
