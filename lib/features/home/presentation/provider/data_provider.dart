import 'dart:collection';
import 'dart:developer' as logger;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../model/carousel_model.dart';
import '../../model/update_version.dart';
import '../../service/home_service_api.dart';
import '../../../../core/util/app_exceptions.dart';

// ilustrasi_min_go.png
class DataProvider with ChangeNotifier {
  final _apiService = HomeServiceAPI();

  bool updateAvailable = false;
  String _currentVersion = '';
  String _versionAvailable = '';
  UpdateVersion? _updateVersion;
  final List<CarouselModel> _items = [];

  String get currentVersion => _currentVersion;
  String get versionAvailable => _versionAvailable;
  UpdateVersion? get updateVersion => _updateVersion;
  UnmodifiableListView<CarouselModel> get items => UnmodifiableListView(_items);

  Future<bool> checkUpdateVersion() async {
    try {
      final responseData = await _apiService.fetchVersion();

      if (responseData != null) {
        _updateVersion = UpdateVersion.fromJson(responseData);
      }

      if (_updateVersion != null) {
        PackageInfo packageInfo = await PackageInfo.fromPlatform();

        String responseVersion = (Platform.isIOS)
            ? _updateVersion!.ios.version
            : _updateVersion!.android.version;
        int responseVersionNumber = (Platform.isIOS)
            ? _updateVersion!.ios.versionNumber
            : _updateVersion!.android.versionNumber;
        int responseBuildNumber = (Platform.isIOS)
            ? _updateVersion!.ios.buildNumber
            : _updateVersion!.android.buildNumber;

        String version = packageInfo.version;
        int versionNumber = int.tryParse(version.replaceAll('.', '')) ?? 0;
        int buildNumber = int.parse(packageInfo.buildNumber);

        _currentVersion = '$version ($buildNumber)';
        _versionAvailable = '$responseVersion ($responseBuildNumber)';

        updateAvailable = (versionNumber == responseVersionNumber)
            ? buildNumber < responseBuildNumber
            : versionNumber < responseVersionNumber;

        if (kDebugMode) {
          logger.log('DATA_PROVIDER-CheckUpdateVersion: '
              'Response >> $responseVersionNumber || $responseVersion ($responseBuildNumber)');
          logger.log('DATA_PROVIDER-CheckUpdateVersion: '
              'Current >> $versionNumber || $version ($buildNumber)');
          logger.log('DATA_PROVIDER-CheckUpdateVersion: '
              'Update Available >> $updateAvailable || $_currentVersion >> $_versionAvailable');
        }
      } else {
        updateAvailable = false;
      }

      return updateAvailable;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-CheckUpdateVersion: $e');
      }
      updateAvailable = false;
      return false;
    }
  }

  Future<List<CarouselModel>> loadCarousel() async {
    if (kDebugMode) {
      logger.log('LOAD_CAROUSEL_PROVIDER: Carousel length ${_items.length}');
    }
    if (_items.isNotEmpty) {
      return items;
    }
    try {
      final responseData = await _apiService.fetchCarousel();

      if (responseData.length > 0) {
        for (int i = 0; i < responseData.length; i++) {
          _items.add(CarouselModel.fromJson(responseData[i]));
        }
      }

      return items;
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-FetchCarouselImage: $e');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-FetchCarouselImage: $e');
      }
      throw 'Terjadi kesalahan saat mengambil data.\nMohon coba kembali nanti.';
    }
  }
}
