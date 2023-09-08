import 'dart:io';

import 'package:equatable/equatable.dart';

class UpdateVersion extends Equatable {
  final bool isWajib;
  final String title;
  final String description;
  final List<String> releaseNote;
  final AppVersion ios;
  final AppVersion android;

  const UpdateVersion({
    required this.isWajib,
    required this.title,
    required this.description,
    required this.releaseNote,
    required this.ios,
    required this.android,
  });

  factory UpdateVersion.fromJson(Map<String, dynamic> json) {
    bool? isWajib =
        (Platform.isIOS) ? json['isWajibIOS'] : json['isWajibANDRO'];
    return UpdateVersion(
      isWajib: isWajib ?? json['isWajib'],
      title: json['title'],
      description: json['description'],
      releaseNote: (json['notes'] as List).cast<String>(),
      ios: AppVersion.fromJson(json['ios']),
      android: AppVersion.fromJson(json['android']),
    );
  }

  @override
  List<Object?> get props => [
        isWajib,
        title,
        description,
        releaseNote,
        ios,
        android,
      ];
}

class AppVersion extends Equatable {
  final String url;
  final String altUrl;
  final String version;
  final int versionNumber;
  final int buildNumber;

  const AppVersion({
    required this.url,
    required this.altUrl,
    required this.version,
    required this.versionNumber,
    required this.buildNumber,
  });

  factory AppVersion.fromJson(Map<String, dynamic> json) => AppVersion(
        url: json['url'],
        altUrl: json['altUrl'],
        version: json['version'],
        versionNumber: json['versionNumber'],
        buildNumber: json['buildNumber'],
      );

  @override
  List<Object?> get props => [
        url,
        altUrl,
        version,
        buildNumber,
      ];
}
