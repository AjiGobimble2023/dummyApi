import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';

import '../../../../../../core/util/app_exceptions.dart';
import '../../model/feed.dart';
import '../../model/feed_comment.dart';
import '../../service/api/feed_service_api.dart';

class FeedProvider extends ChangeNotifier {
  final _apiService = FeedServiceApi();
  List<Feed> currentListFeed = [];
  int lastIndex = 0;
  String accessDate = "";
  bool _isLoading = false;
  bool _isEmpty = false;

  final List<FeedComments> _listFeed = [];
  final List<FeedComments> _listFeedReply = [];

  bool get isLoading => _isLoading;
  bool get isEmpty => _isEmpty;
  List<FeedComments> get listFeed => _listFeed;
  List<FeedComments> get listFeedReply => _listFeedReply;

  /// [loadFeed] adalah fungsi yang digunakan untuk memuat data feed.
  ///
  /// Args:
  ///   userId (String): nomor registrasi yang saat ini login.
  Future<List<Feed>> loadFeed(String userId) async {
    try {
      currentListFeed.clear();
      _isLoading = true;
      final responseData = await _apiService.fetchFeed(userId);
      if (responseData == null) {
        currentListFeed = [];
        _isLoading = false;
      } else {
        final List listData = responseData['list'];
        final Map info = responseData['info'];

        lastIndex = info['lastIndex'];
        accessDate = info['accessDate'];

        List<Feed> listFeed = [];
        int notPublic = 0;

        for (var i = 0; i < listData.length; i++) {
          listFeed.add(Feed.fromJson(listData[i]));
          if (listData[i]['status'] == 'pribadi' &&
              listData[i]['creatorId'] != userId) {
            notPublic++;
          }
        }
        if (notPublic == listData.length) {
          _isEmpty = true;
        } else {
          _isEmpty = false;
        }

        currentListFeed = listFeed;
        _isLoading = false;
      }
      notifyListeners();
      return currentListFeed;
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

  /// [loadmoreFeed] digunakan untuk memuat data feed lebih banyak dari API.
  ///
  /// Args:
  ///   userId (String): nomor registrasi yang saat ini login.
  Future<void> loadmoreFeed(String userId) async {
    try {
      final responseData =
          await _apiService.fetchMoreFeed(userId, accessDate, lastIndex);

      final List listData = responseData['list'];
      final Map info = responseData['info'];

      lastIndex = info['lastIndex'];

      List<Feed> listFeed = [];

      for (var i = 0; i < listData.length; i++) {
        listFeed.add(Feed.fromJson(listData[i]));
      }
      if (kDebugMode) {
        logger.log("cek $currentListFeed");
      }
      currentListFeed = [...currentListFeed, ...listFeed];
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

  /// [responseFeed] digunakan untuk menanggapi sebuah feed.
  ///
  /// Args:
  ///   userId (String): nomor registrasi yang saat ini login.
  ///   feedId (String): ID feed yang ingin Anda tanggapi.
  ///   type (String): 'like' atau 'dislike'
  Future<void> responseFeed(
      {String? userId, String? feedId, String? type}) async {
    try {
      await _apiService.responseFeed(userId!, feedId!, type!);
      // loadFeed(userId);
      notifyListeners();
    } on NoConnectionException {
      rethrow;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-ResponseFeed: $e');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-ResponseFeed: $e');
      }
      throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti.';
    }
  }

  /// [deleteFeed] digunakan untuk menghapus feed.
  ///
  /// Args:
  ///   feedId (String): ID feed yang akan dihapus.
  Future<void> deleteFeed({String? feedId}) async {
    try {
      await _apiService.deleteFeed(feedId!);
    } on NoConnectionException {
      rethrow;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-ResponseFeed: $e');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-ResponseFeed: $e');
      }
      throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti.';
    }
  }

  /// [setFeedPrivat] digunakan untuk mengatur feed ke privat.
  ///
  /// Args:
  ///   feedId (String): ID feed yang akan ditetapkan sebagai privat.
  Future<void> setFeedPrivat({String? feedId}) async {
    try {
      await _apiService.setFeedPrivat(feedId!);
    } on NoConnectionException {
      rethrow;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-ResponseFeed: $e');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-ResponseFeed: $e');
      }
      throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti.';
    }
  }

  /// [setFeedPublik] digunakan untuk mengatur feed untuk menjadi publik.
  ///
  /// Args:
  ///   feedId (String): ID feed yang akan ditetapkan sebagai publik.
  Future<void> setFeedPublik({String? feedId}) async {
    try {
      await _apiService.setFeedPublik(feedId!);
    } on NoConnectionException {
      rethrow;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-ResponseFeed: $e');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-ResponseFeed: $e');
      }
      throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti.';
    }
  }

  /// [loadComment] digunakan untuk memuat komentar.
  ///
  /// Args:
  ///   userId (String): nomor registrasi yang saat ini login.
  ///   feedId: ID feed dari feed yang ingin dimuat komentarnya.
  Future<List<FeedComments>> loadComment({String? userId, feedId}) async {
    try {
      final responseData = await _apiService.fetchComment(userId!, feedId!);
      _listFeed.clear();
      _listFeedReply.clear();
      _isLoading = true;
      if (kDebugMode) {
        logger.log("responseData $responseData");
      }
      for (var i = 0; i < responseData['data'].length; i++) {
        _listFeed.add(
          FeedComments.fromJson(responseData['data'][i]),
        );
      }
      for (var i = 0; i < responseData['reply'].length; i++) {
        if (kDebugMode) {
          logger.log(
              "responseData['reply'].length ${responseData['reply'].length}");
        }

        for (var j = 0; j < responseData['reply'][i].length; j++) {
          if (kDebugMode) {
            logger.log(
                "responseData['reply'][i][j] ${responseData['reply'][i][j]}");
          }
          _listFeedReply.add(
            FeedComments.fromJson(responseData['reply'][i][j]),
          );
        }
      }
      if (kDebugMode) {
        logger.log("listFeed $_listFeed");
        logger.log("listFeedReply $_listFeedReply");
      }
      _isLoading = false;
      notifyListeners();
      return _listFeed;
    } on NoConnectionException {
      _isLoading = false;
      rethrow;
    } on DataException catch (e) {
      _isLoading = false;
      if (kDebugMode) {
        logger.log('Exception-LoadComment: $e');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        _isLoading = false;
        logger.log('FatalException-LoadComment: $e');
      }
      _isLoading = false;
      throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti.';
    }
  }

  /// [saveComment] digunakan untuk menyimpan komentar.
  ///
  /// Args:
  ///   userId (String): nomor registrasi yang berkomentar.
  ///   feedId (String): ID feed yang dikomentari.
  ///   feedCreator (String): nomor registrasi pembuat feed.
  ///   text (String): Teks komentar.
  Future<void> saveComment(
      {String? userId,
      String? feedId,
      String? feedCreator,
      String? text}) async {
    try {
      _isLoading = true;
      await _apiService.saveComment(userId!, feedId!, feedCreator!, text!);
      _isLoading = false;
      notifyListeners();
    } on NoConnectionException {
      _isLoading = false;
      rethrow;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-SaveComment: $e');
      }
      _isLoading = false;
      rethrow;
    } catch (e) {
      _isLoading = false;
      if (kDebugMode) {
        logger.log('FatalException-SaveComment: $e');
      }
      _isLoading = false;
      throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti.';
    }
  }

  /// [deleteComment] digunakan untuk menghapus komentar.
  ///
  /// Args:
  ///   feedId (String): ID dari komentar yang akan dihapus.
  Future<void> deleteComment(String feedId) async {
    try {
      await _apiService.deleteComment(feedId);
    } on NoConnectionException {
      rethrow;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-ResponseDeleteComment: $e');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-ResponseDeleteComment: $e');
      }
      throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti.';
    }
  }
}
