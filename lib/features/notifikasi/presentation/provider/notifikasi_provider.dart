import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';

import '../../../../../core/util/app_exceptions.dart';
import '../../../sosmed/module/feed/model/feed.dart';
import '../../model/notifikasi.dart';
import '../../service/notifikasi_service_api.dart';

class NotificationProvider extends ChangeNotifier {
  final _apiService = NotificationServiceApi();

  List<Notification> currentListNotification = [];
  List<Feed> currentListNotificationInfo = [];
  bool isLoading = false;

  int get notificationCount =>
      currentListNotification.where((notif) => !notif.isSeen).length;

  /// [loadNotification] is used to load the notification data from the API.
  Future<List<Notification>> loadNotification(String? noRegistrasi) async {
    if (noRegistrasi == null) return currentListNotification;
    try {
      currentListNotification.clear();
      currentListNotificationInfo.clear();
      isLoading = true;
      notifyListeners();
      if (noRegistrasi.isEmpty) return currentListNotification;
      final responseData = await _apiService.fetchNotification(noRegistrasi);
      if (responseData != null) {
        List<Notification> listNotification = [];
        List<Feed> listNotificationInfo = [];

        for (var i = 0; i < responseData.length; i++) {
          listNotification.add(
            Notification.fromJson(responseData[i]),
          );

          listNotificationInfo.add(
            Feed.fromJson(responseData[i]['info']),
          );
        }
        currentListNotification = listNotification;
        currentListNotificationInfo = listNotificationInfo;
      }
      isLoading = false;
      notifyListeners();
      return currentListNotification;
    } on NoConnectionException {
      return currentListNotification;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-FetchFeed: $e');
      }
      return currentListNotification;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-FetchFeed: $e');
      }
      return currentListNotification;
    }
  }

  /// [deleteNotifikasi] is used to delete a notification.
  Future<void> deleteNotifikasi(String feedId) async {
    try {
      await _apiService.deleteNotification(feedId);
    } on NoConnectionException {
      rethrow;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-ResponseDeleteNotifikasi: $e');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-ResponseDeleteNotifikasi: $e');
      }
      throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti.';
    }
  }
}
