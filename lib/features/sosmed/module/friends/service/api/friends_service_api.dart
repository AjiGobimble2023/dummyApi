import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';

import '../../../../../../core/helper/api_helper.dart';
import '../../../../../../core/util/app_exceptions.dart';

class FriendsServiceApi {
  final _apiHelper = ApiHelper();

  Future<dynamic> fetchFriend(String userId) async {
    final response = await _apiHelper.requestPost(
      pathUrl: "/friend",
      bodyParams: {"userId": userId},
    );

    return response['data'];
  }

  Future<dynamic> fetchFriendMore(String userId, int lastIndex) async {
    final response = await _apiHelper.requestPost(
      pathUrl: "/friend/loadmore",
      bodyParams: {"userId": userId, "lastIndex": lastIndex},
    );
    if (!response['status']) throw DataException(message: response['message']);

    return response['data'];
  }

  Future<dynamic> getFriendFeed(String noregistrasi) async {
    final response = await _apiHelper.requestPost(
      pathUrl: "/friend/feed",
      bodyParams: {
        "noregistrasi": noregistrasi,
      },
    );

    if (!response['status']) throw DataException(message: response['message']);

    return response['data'];
  }

  Future<dynamic> deleteFriend(
      {required String asal, required String tujuan}) async {
    final response = await _apiHelper.requestPost(
      pathUrl: "/friend/delete",
      bodyParams: {"nis_asal": asal, "nis_tujuan": tujuan},
    );

    if (!response['status']) throw DataException(message: response['message']);

    return response;
  }

  Future<dynamic> fetchFriendPending(
      {required String userId, required String type}) async {
    final response = await _apiHelper.requestPost(
      pathUrl: "/friend/pending",
      bodyParams: {"userId": userId, "type": type},
    );

    if (!response['status']) throw DataException(message: response['message']);

    return response['data'];
  }

  Future<dynamic> fetchFriendDetail(String friendId) async {
    final response = await _apiHelper.requestPost(
      pathUrl: "/friend/detail",
      bodyParams: {"friendId": friendId},
    );

    if (!response['status']) throw DataException(message: response['message']);

    return response['data'];
  }

  Future<dynamic> searchFriend(
      {required String userId, required String searchFriends}) async {
    final response = await _apiHelper.requestPost(
      pathUrl: "/friend/search",
      bodyParams: {"userId": userId, "search": searchFriends},
    );
    if (kDebugMode) {
      logger.log("response searchFriend : $response");
    }
    return response['data'];
  }

  Future<dynamic> searchFriendMore(
      {required String userId,
      required String searchFriends,
      required int lastIndex}) async {
    final response = await _apiHelper.requestPost(
      pathUrl: "/friend/search/loadmore",
      bodyParams: {
        "userId": userId,
        "search": searchFriends,
        "lastIndex": lastIndex
      },
    );
    if (kDebugMode) {
      logger.log("response searchFriend : $response");
    }
    if (!response['status']) throw DataException(message: response['message']);
    return response['data'];
  }

  Future<void> responseFriend(
      {required String sourceId,
      required String destId,
      required String status}) async {
    final response = await _apiHelper.requestPost(
      pathUrl: "/friend/response",
      bodyParams: {"nisAsal": sourceId, "nisTujuan": destId, "status": status},
    );

    if (!response['status']) throw DataException(message: response['message']);
  }

  Future<void> requestFriend(
      {required String sourceId, required String destId}) async {
    final response = await _apiHelper.requestPost(
      pathUrl: "/friend/request",
      bodyParams: {"nisAsal": sourceId, "nisTujuan": destId},
    );

    if (!response['status']) throw DataException(message: response['message']);
  }

  Future<dynamic> fetchFriendsTryout(
      {required String friendId,
      required String classLevelId,
      required String jenis}) async {
    final response = await _apiHelper.requestPost(
      pathUrl: "/friend/tryout/last",
      bodyParams: {
        "friendId": friendId,
        "idSekolahKelas": classLevelId,
        "jenis": jenis
      },
    );

    if (!response['status']) throw DataException(message: response['message']);

    return response['data'];
  }

  Future<dynamic> fetchListCompare(
      {required String userId, required String friendId}) async {
    final response = await _apiHelper.requestPost(
      pathUrl: "/friend/compare",
      bodyParams: {"userId": userId, "friendId": friendId},
    );

    if (!response['status']) throw DataException(message: response['message']);

    return response['data'];
  }

  Future<dynamic> fetchScoreCompare(
      {required String userId,
      required String friendId,
      required String kodeSoal,
      required String idSekolahKelas}) async {
    final response = await _apiHelper.requestPost(
      pathUrl: "/friend/compare/score",
      bodyParams: {
        "userId": userId,
        "friendId": friendId,
        "kodesoal": kodeSoal,
        "idSekolahKelas": idSekolahKelas
      },
    );

    if (!response['status']) throw DataException(message: response['message']);

    return response['data'];
  }

  Future<dynamic> fetchMyScore(
      {required String userId, required String idSekolahKelas}) async {
    final response = await _apiHelper.requestPost(
      pathUrl: "/friend/score",
      bodyParams: {"noregistrasi": userId, "idsekolahkelas": idSekolahKelas},
    );

    return response;
  }
}
