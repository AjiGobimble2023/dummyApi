import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';

import '../../../../../../core/helper/api_helper.dart';
import '../../../../../../core/util/app_exceptions.dart';

class FeedServiceApi {
  final _apiHelper = ApiHelper();

  Future<dynamic> fetchFeed(String userId) async {
    final response = await _apiHelper.requestPost(
      pathUrl: "/feed",
      bodyParams: {"userId": userId},
    );
    return response['data'];
  }

  Future<dynamic> fetchMoreFeed(
      String userId, String accessDate, int lastIndex) async {
    final response = await _apiHelper.requestPost(
      pathUrl: "/feed/more",
      bodyParams: {
        "userId": userId,
        "accessDate": accessDate,
        "lastIndex": lastIndex
      },
    );
    if (kDebugMode) {
      logger.log("cek data $userId $accessDate $lastIndex");
    }

    if (!response['status']) throw DataException(message: response['message']);

    return response['data'];
  }

  Future<void> responseFeed(String userId, String feedId, String type) async {
    final response = await _apiHelper.requestPost(
      pathUrl: "/feed/response",
      bodyParams: {"userId": userId, "feedId": feedId, "type": type},
    );

    if (!response['status']) throw DataException(message: response['message']);
  }

  Future<void> deleteFeed(String feedId) async {
    final response = await _apiHelper.requestPost(
      pathUrl: "/feed/status/deletefeed",
      bodyParams: {"feedId": feedId},
    );

    if (!response['status']) throw DataException(message: response['message']);
  }

  Future<void> setFeedPrivat(String feedId) async {
    final response = await _apiHelper.requestPost(
      pathUrl: "/feed/status/setfeedprivat",
      bodyParams: {"feedId": feedId},
    );

    if (!response['status']) throw DataException(message: response['message']);
  }

  Future<void> setFeedPublik(String feedId) async {
    final response = await _apiHelper.requestPost(
      pathUrl: "/feed/status/setfeedpublik",
      bodyParams: {"feedId": feedId},
    );

    if (!response['status']) throw DataException(message: response['message']);
  }

  Future<void> saveFeed(
      {String? userId,
      String? tob,
      String? empatiId,
      String? file64,
      String? content}) async {
    final response = await _apiHelper.requestPost(
      pathUrl: '/feed/upload',
      bodyParams: {
        'nis': userId,
        'tob': tob,
        'kodeEmpati': empatiId,
        'file64': file64,
        'konten': content
      },
    );

    if (!response['status']) throw DataException(message: response['message']);
  }

  Future<dynamic> fetchComment(String userId, String feedId) async {
    final response = await _apiHelper.requestPost(
      pathUrl: "/feed/comment",
      bodyParams: {"userId": userId, "feedId": feedId},
    );
    if (kDebugMode) {
      logger.log("response Reply ${response['reply']}");
    }
    return response;
  }

  Future<void> saveComment(
      String userId, String feedId, String feedCreator, String text) async {
    final response = await _apiHelper.requestPost(
      pathUrl: "/feed/comment/add",
      bodyParams: {
        "userId": userId,
        "feedId": feedId,
        "feedCreator": feedCreator,
        "text": text
      },
    );

    if (!response['status']) throw DataException(message: response['message']);
  }

  Future<void> deleteComment(String feedId) async {
    final response = await _apiHelper.requestPost(
      pathUrl: "/feed/comment/delete",
      bodyParams: {"feedId": feedId},
    );

    if (!response['status']) throw DataException(message: response['message']);
  }
}
