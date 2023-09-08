import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';
import '../../../../../../core/config/global.dart';
import '../../../../../../core/util/app_exceptions.dart';
import '../../../feed/model/feed.dart';

import '../../model/friends.dart';
import '../../model/friends_detail.dart';
import '../../model/friends_score.dart';
import '../../model/friends_tryout.dart';
import '../../service/api/friends_service_api.dart';

class FriendsProvider extends ChangeNotifier {
  final _apiService = FriendsServiceApi();

  /// [currentListFriends] list untuk menampung data teman
  List<Friends> currentListFriends = [];

  /// [currentListFriendsOfFriends] list untuk menampung list data teman dari teman
  List<Friends> currentListFriendsOfFriends = [];

  /// [listFriendsSearch] list untuk menampung data orang yang dicari
  List<Friends> listFriendsSearch = [];

  /// [listFriendsSearch] list untuk menampung data feed teman
  List<Feed> listFriendFeeds = [];

  /// [friendlastIndex] var data index terakhir list  data teman
  int friendlastIndex = 0;

  /// [searchLastIndex] var data index terakhir list data orang yang dicari
  int searchLastIndex = 0;

  /// [friendsOfFriendslastIndex] var data index terakhir list data teman dari teman
  int friendsOfFriendslastIndex = 0;

  /// [isLoading] var untuk set State loading fuction FriendsProvider
  bool isLoading = false;

  /// [isLoadingSearch] var untuk state loading pencarian teman
  bool isLoadingSearch = false;

  /// [myScore] variable yang menampung data score siswa
  String myScore = "0";

  Future<List<Friends>> loadFriend(String userId) async {
    try {
      currentListFriends.clear();
      isLoading = true;
      notifyListeners();
      final responseData = await _apiService.fetchFriend(userId);
      final List listData = responseData['list'];
      final Map info = responseData['info'];
      friendlastIndex = info['lastIndex'];

      for (var i = 0; i < listData.length; i++) {
        currentListFriends.add(Friends.fromJson(listData[i]));
      }
      isLoading = false;
      notifyListeners();
      return currentListFriends;
    } on NoConnectionException {
      rethrow;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-FetchFriend: $e');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-FetchFriend: $e');
      }
      throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti.';
    }
  }

  /// [loadFloadmoreFriendiend] is used to load the friend list.
  ///
  /// Args:
  ///   userId (String): The user's ID.
  Future<List<Friends>> loadFloadmoreFriendiend(String userId) async {
    try {
      currentListFriends.clear();
      isLoading = true;
      notifyListeners();
      final responseData = await _apiService.fetchFriend(userId);
      final List listData = responseData['list'];
      final Map info = responseData['info'];
      friendlastIndex = info['lastIndex'];

      for (var i = 0; i < listData.length; i++) {
        currentListFriends.add(Friends.fromJson(listData[i]));
      }
      isLoading = false;
      notifyListeners();
      return currentListFriends;
    } on NoConnectionException {
      rethrow;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-FetchFriend: $e');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-FetchFriend: $e');
      }
      throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti.';
    }
  }

  //Load more data teman (+10 teman)
  /// [loadmoreFriend] is used to load more data from the API.
  ///
  /// Args:
  ///   userId (String): user id
  Future<void> loadmoreFriend(String userId) async {
    try {
      final responseData =
          await _apiService.fetchFriendMore(userId, friendlastIndex);
      final List listData = responseData['list'];
      final Map info = responseData['info'];

      if (friendlastIndex < info['lastIndex']) {
        friendlastIndex = info['lastIndex'];
        for (var i = 0; i < listData.length; i++) {
          currentListFriends.add(Friends.fromJson(listData[i]));
        }
      }
      notifyListeners();
    } on NoConnectionException {
      rethrow;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-FetchFeed: $e');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-FetchFeed: $e');
      }
      throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti.';
    }
  }

  /// [loadFriendPending] Load data teman yang melakukan permintaan pertemanan
  /// The above function is used to fetch the list of friend requests from the server.
  ///
  /// Args:
  ///   userId (String): The user's ID.
  ///   type (String): 'pending'
  ///
  /// Returns:
  ///   List<Friends>
  Future<List<Friends>> loadFriendPending(
      {String? userId, String? type}) async {
    try {
      final responseData =
          await _apiService.fetchFriendPending(userId: userId!, type: type!);

      List<Friends> listFriendPending = [];

      for (var i = 0; i < responseData.length; i++) {
        listFriendPending.add(Friends.fromJson(responseData[i]));
      }

      return listFriendPending;
    } on NoConnectionException {
      rethrow;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-FetchFriendPending: $e');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-FetchFriendPending: $e');
      }
      throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti.';
    }
  }

  //Load detail data teman
  /// [loadFriendDetail] It fetches the friend detail from the API.
  ///
  /// Args:
  ///   friendId (String): The id of the friend you want to get the details of.
  ///
  /// Returns:
  ///   Future<FriendsDetail>
  Future<FriendsDetail> loadFriendDetail(String friendId) async {
    try {
      final responseData = await _apiService.fetchFriendDetail(friendId);

      return FriendsDetail.fromJson(responseData);
    } on NoConnectionException {
      rethrow;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-FetchFriendPending: $e');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-FetchFriendPending: $e');
      }
      throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti.';
    }
  }

  /// [searchFriend] is a function to search for friends.
  ///
  /// Args:
  ///   userId (String): The user's ID.
  ///   searchFriends (String): The search parameter.
  ///
  /// Returns:
  ///   The return type is a Future<List<Friends>>.
  Future<List<Friends>> searchFriend(
      {required String userId, required String searchFriends}) async {
    try {
      listFriendsSearch.clear();
      isLoadingSearch = true;
      notifyListeners();

      final responseData = await _apiService.searchFriend(
        userId: userId,
        searchFriends: searchFriends,
      );

      final List listData = responseData['list'];
      final Map info = responseData['info'];
      searchLastIndex = info['lastIndex'];

      if (responseData != null) {
        for (int i = 0; i < listData.length; i++) {
          listFriendsSearch.add(
            Friends.fromJson(listData[i]),
          );
        }
      }

      if (searchFriends.isEmpty) {
        listFriendsSearch.clear();
        notifyListeners();
      }
      isLoadingSearch = false;
      notifyListeners();
      return listFriendsSearch;
    } on NoConnectionException {
      gShowTopFlash(
          gNavigatorKey.currentState!.context, 'Data tidak ditemukan');
      isLoadingSearch = false;
      rethrow;
    } on DataException catch (e) {
      gShowTopFlash(
          gNavigatorKey.currentState!.context, 'Data tidak ditemukan');
      isLoadingSearch = false;
      if (kDebugMode) {
        logger.log('Exception-SearchFriend: $e');
      }
      rethrow;
    } catch (e) {
      gShowTopFlash(
          gNavigatorKey.currentState!.context, 'Data tidak ditemukan');
      isLoadingSearch = false;
      if (kDebugMode) {
        logger.log('FatalException-SearchFriend: $e');
      }
      isLoadingSearch = false;
      throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti.';
    }
  }

  /// [loadmoreSearchFriend] is a function to load more data from the search results.
  ///
  /// Args:
  ///   userId (String): user id
  ///   searchFriends (String): the name of the person you are looking for
  Future<void> loadmoreSearchFriend({
    required String userId,
    required String searchFriends,
  }) async {
    try {
      final responseData = await _apiService.searchFriendMore(
          userId: userId,
          searchFriends: searchFriends,
          lastIndex: friendlastIndex);

      final List listData = responseData['list'];
      final Map info = responseData['info'];

      if (friendlastIndex < info['lastIndex']) {
        friendlastIndex = info['lastIndex'];

        for (var i = 0; i < listData.length; i++) {
          listFriendsSearch.add(Friends.fromJson(listData[i]));
        }
      }
      notifyListeners();
    } on NoConnectionException {
      rethrow;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-FetchFeed: $e');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-FetchFeed: $e');
      }
      throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti.';
    }
  }

  Future<void> responseFriend(
      {String? sourceId, String? destId, String? status}) async {
    try {
      await _apiService.responseFriend(
        sourceId: sourceId!,
        destId: destId!,
        status: status!,
      );
    } on NoConnectionException {
      rethrow;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-ResponseFriend: $e');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-ResponseFriend: $e');
      }
      throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti.';
    }
  }

  //Request permintaan pertemanan
  /// `requestFriend` is a function that will call the `requestFriend` function in the `apiService` class
  ///
  /// Args:
  ///   sourceId (String): The id of the user who is sending the friend request.
  ///   destId (String): The id of the user that you want to send a friend request to.
  Future<void> requestFriend({String? sourceId, String? destId}) async {
    try {
      await _apiService.requestFriend(
        sourceId: sourceId!,
        destId: destId!,
      );
    } on NoConnectionException {
      rethrow;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-RequestFriend: $e');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-RequestFriend: $e');
      }
      throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti.';
    }
  }

  //Load Score Teman
  /// [loadFriendsScore] is used to fetch the score of the user's friends.
  ///
  /// Args:
  ///   friendId (String): The ID of the friend you want to see the score.
  ///   classLevelId (String): The class level id of the user.
  ///   jenis (String): 'tryout'
  ///
  /// Returns:
  ///   FriendsScore
  Future<FriendsScore> loadFriendsScore(
      {String? friendId, String? classLevelId, String? jenis}) async {
    try {
      final responseData = await _apiService.fetchFriendsTryout(
        friendId: friendId!,
        classLevelId: classLevelId!,
        jenis: jenis!,
      );

      return FriendsScore.fromJson(responseData);
    } on NoConnectionException {
      rethrow;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-FetchFriendsScore: $e');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-FetchFriendsScore: $e');
      }
      throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti.';
    }
  }

  /// [loadListCompare] is used to fetch the list of friends tryout from the API.
  ///
  /// Args:
  ///   userId (String): The user's ID.
  ///   friendId (String): The id of the friend you want to compare with.
  ///
  /// Returns:
  ///   List of FriendsTryout
  Future<List<FriendsTryout>> loadListCompare(
      {String? userId, String? friendId}) async {
    try {
      final responseData = await _apiService.fetchListCompare(
        userId: userId!,
        friendId: friendId!,
      );

      List<FriendsTryout> listFriendsTryout = [];

      for (var i = 0; i < (responseData as List).length; i++) {
        listFriendsTryout.add(
          FriendsTryout.fromJson(responseData[i]),
        );
      }

      return listFriendsTryout;
    } on NoConnectionException {
      rethrow;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-FetchListCompare: $e');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-FetchListCompare: $e');
      }
      throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti.';
    }
  }

  /// [loadScoreCompare] fetches the score comparison data from the server.
  ///
  /// Args:
  ///   userId (String): user id
  ///   friendId (String): The ID of the friend you want to compare scores with.
  ///   kodesoal (String): The code of the exam
  ///   idSekolahKelas (String): The class ID
  ///
  /// Returns:
  ///   Future<Map>
  Future<Map> loadScoreCompare(
      {String? userId,
      String? friendId,
      String? kodesoal,
      String? idSekolahKelas}) async {
    try {
      final responseData = await _apiService.fetchScoreCompare(
          userId: userId!,
          friendId: friendId!,
          kodeSoal: kodesoal!,
          idSekolahKelas: idSekolahKelas!);

      return responseData;
    } on NoConnectionException {
      rethrow;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-FetchScoreCompare: $e');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-FetchScoreCompare: $e');
      }
      throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti.';
    }
  }

  /// [deleteFriends] is used to delete a friend from the user's friend list.
  ///
  /// Args:
  ///   userId (String): The user's ID
  ///   friendId (String): The id of the friend you want to delete
  ///
  /// Returns:
  ///   Future<dynamic>
  Future<dynamic> deleteFriends(
      {required String userId, required String friendId}) async {
    try {
      final responseData =
          await _apiService.deleteFriend(asal: userId, tujuan: friendId);

      return responseData;
    } on NoConnectionException {
      rethrow;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-FetchScoreCompare: $e');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-FetchScoreCompare: $e');
      }
      throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti.';
    }
  }

  /// [getFriendFeeds]is a function that is used to get the data of the friend's feed.
  ///
  /// Args:
  ///   noregistrasi (String): The registration number of the user whose feed you want to see.
  ///
  /// Returns:
  ///   Future<List<Feed>>
  Future<List<Feed>> getFriendFeeds({required String noregistrasi}) async {
    try {
      listFriendFeeds.clear();
      notifyListeners();

      final responseData = await _apiService.getFriendFeed(
        noregistrasi,
      );

      if (responseData != null) {
        for (int i = 0; i < responseData.length; i++) {
          listFriendFeeds.add(
            Feed.fromJson(responseData[i]),
          );
        }
      }
      notifyListeners();
      return listFriendFeeds;
    } on NoConnectionException {
      rethrow;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-getFriendFeeds: $e');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-getFriendFeeds: $e');
      }
      throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti.';
    }
  }

  /// [loadFriendOfFriends] is used to load the list of friends of friends.
  ///
  /// Args:
  ///   userId (String): The user ID of the user whose friends you want to load.
  Future<void> loadFriendOfFriends(String userId) async {
    try {
      currentListFriendsOfFriends.clear();
      //notifyListeners();
      final responseData = await _apiService.fetchFriend(userId);
      final List listData = responseData['list'];
      final Map info = responseData['info'];
      friendsOfFriendslastIndex = info['lastIndex'];

      for (var i = 0; i < listData.length; i++) {
        currentListFriendsOfFriends.add(Friends.fromJson(listData[i]));
      }
      notifyListeners();
    } on NoConnectionException {
      rethrow;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-loadFriendOfFriends: $e');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-loadFriendOfFriends: $e');
      }
      throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti.';
    }
  }

  /// [loadMyScore] is used to load the score of the user.
  ///
  /// Args:
  ///   noregistrasi (String): The user's registration number.
  ///   classLevelId (String): The class level id of the user.
  Future<void> loadMyScore({
    String? noregistrasi,
    String? classLevelId,
  }) async {
    try {
      final response = await _apiService.fetchMyScore(
        userId: noregistrasi!,
        idSekolahKelas: classLevelId!,
      );
      if (response['status']) {
        myScore = MyScore.fromJson(response['data'][0]).total;
      } else {
        myScore = '0';
      }
      notifyListeners();
    } on NoConnectionException {
      rethrow;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-loadMyScore: $e');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-loadMyScore: $e');
      }
      throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti.';
    }
  }
}
