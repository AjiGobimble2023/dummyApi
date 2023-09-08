import 'dart:convert';
import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';

import '../../../../core/helper/api_helper.dart';
import '../../../../core/util/app_exceptions.dart';
import '../../entity/bookmark.dart';

class BookmarkServiceAPI {
  final _apiHelper = ApiHelper();

  Future<dynamic> fetchBookmark({required String noRegistrasi}) async {
    final response = await _apiHelper.requestPost(
      pathUrl: '/bookmark/shortcut',
      bodyParams: {'nis': noRegistrasi},
    );

    if (kDebugMode) {
      logger.log("BOOKMARK_SERVICE_API-FetchBookmark: response >> $response");
    }

    if (!response['status']) throw DataException(message: response['message']);

    return response['data'];
  }

  Future<bool> updateBookmark(
      {required String noRegistrasi,
      required List<BookmarkMapel> daftarBookmark}) async {
    final response = await _apiHelper.requestPost(
      pathUrl: '/bookmark/save',
      bodyParams: {
        'nis': noRegistrasi,
        'bookmark': jsonEncode(daftarBookmark),
      },
    );

    if (kDebugMode) {
      logger.log("BOOKMARK_SERVICE_API-UpdateBookmark: response >> $response");
    }

    return response['status'];
  }
}
