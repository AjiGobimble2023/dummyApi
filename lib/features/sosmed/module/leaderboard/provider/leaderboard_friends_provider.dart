import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';

import '../../../../../core/util/app_exceptions.dart';
import '../../friends/model/friends.dart';
import '../service/api/leaderboard_friend_service.dart';

class LeaderboardFriendsProvider extends ChangeNotifier {
  ///[currentListFriends] list untuk menampung data teman
  ///[listFriendsSearch] list untuk menampung data orang yang dicari
  ///[friendlastIndex] var data index terakhir list  data teman
  ///[searchLastIndex] var data index terakhir list data orang yang dicari
  final _apiService = LeaderboardFriendsServiceApi();
  List<Friends> currentListLeaderboard = [];
  int friendlastIndex = 0;
  int searchLastIndex = 0;
  bool isLoading = false;

  /// The above function is used to load the friend leaderboard.
  ///
  /// Args:
  ///   userId (String): Nomor Registrasi.
  ///
  /// Returns:
  ///   List of Friends
  Future<List<Friends>> loadFriendLeaderboard(String userId) async {
    try {
      currentListLeaderboard.clear();
      isLoading = true;
      notifyListeners();
      final responseData = await _apiService.fetchLeaderboardFriends(userId);
      final List listData = responseData['list'];
      final Map info = responseData['info'];
      friendlastIndex = info['lastIndex'];
      for (var i = 0; i < listData.length; i++) {
        currentListLeaderboard.add(Friends.fromJson(listData[i]));
      }
      isLoading = false;
      notifyListeners();
      return currentListLeaderboard;
    } on NoConnectionException {
      isLoading = false;
      notifyListeners();
      rethrow;
    } on DataException catch (e) {
      isLoading = false;
      notifyListeners();
      if (kDebugMode) {
        logger.log('Exception-FetchFriend: $e');
      }
      rethrow;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      if (kDebugMode) {
        logger.log('FatalException-FetchFriend: $e');
      }
      isLoading = false;
      notifyListeners();
      throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti.';
    }
  }
}
