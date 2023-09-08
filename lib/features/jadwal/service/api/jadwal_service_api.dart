import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';

import '../../../../core/helper/api_helper.dart';
import '../../../../core/util/app_exceptions.dart';

class JadwalServiceApi {
  final ApiHelper _apiHelper = ApiHelper();

  Future<dynamic> fetchJadwal({
    required String noRegistrasi,
    required String userType,
    required String feedbackTime,
  }) async {
    if (kDebugMode) {
      logger.log(
          'JADWAL_SERVICE_API-FetchJadwal: START with params($noRegistrasi, $userType, $feedbackTime)');
    }
    final response = await _apiHelper.requestPost(
      pathUrl: '/jadwal/siswa',
      bodyParams: {
        'jenis': userType,
        'noRegistrasi': noRegistrasi,
        'feedbackTime': feedbackTime
      },
    );

    if (kDebugMode) {
      logger.log('JADWAL_SERVICE_API-FetchJadwal: response >> $response');
    }

    if (!response['status']) throw DataException(message: response['message']);

    return response['data'];
    // return response['data'] ??
    //     {
    //       "2022-10-11": [
    //         {
    //           "classId": "255274",
    //           "date": "2022-10-11",
    //           "start": "15:04",
    //           "finish": "15:04",
    //           "lesson": "MATEMATIKA",
    //           "package": "1",
    //           "info": "Paket Ke",
    //           "id": "9202500003",
    //           "fullName": "MUHAMAD ACHYA ARIFUDIN",
    //           "activity": "KBM JPMP",
    //           "planId": "6227508",
    //           "placeName": "PW 36-B",
    //           "remainingMeeting": "-",
    //           "available": "yes",
    //           "feedbackPermission": false,
    //           "session": 1
    //         }
    //       ],
    //       "2022-10-12": [
    //         {
    //           "classId": "255274",
    //           "date": "2022-10-12",
    //           "start": "12:30",
    //           "finish": "14:00",
    //           "lesson": "BIOLOGI",
    //           "package": "2",
    //           "info": "Paket Ke",
    //           "id": "0702500115",
    //           "fullName": "ANENG WIDANINGSIH, S.PD",
    //           "activity": "Responsi",
    //           "planId": "6227581",
    //           "placeName": "PW 36-B",
    //           "remainingMeeting": "-",
    //           "available": "yes",
    //           "feedbackPermission": false,
    //           "session": 2
    //         },
    //         {
    //           "classId": "242745",
    //           "date": "2022-10-12",
    //           "start": "14:00",
    //           "finish": "15:30",
    //           "lesson": "MATEMATIKA",
    //           "package": "1",
    //           "info": "Paket Ke",
    //           "id": "0702500115",
    //           "fullName": "ANENG WIDANINGSIH, S.PD",
    //           "activity": "Kegiatan Pengarahan Kelas Awal",
    //           "planId": "6227581",
    //           "placeName": "PW 36-B",
    //           "remainingMeeting": "-",
    //           "available": "yes",
    //           "feedbackPermission": false,
    //           "session": 1
    //         }
    //       ],
    //       "2022-10-13": [
    //         {
    //           "classId": "255274",
    //           "date": "2022-10-13",
    //           "start": "13:00",
    //           "finish": "14:30",
    //           "lesson": "FISIKA",
    //           "package": "2",
    //           "info": "Paket Ke",
    //           "id": "0702500115",
    //           "fullName": "ANENG WIDANINGSIH, S.PD",
    //           "activity": "Sosialisasi MGM di kelas (Seminar)",
    //           "planId": "6227581",
    //           "placeName": "PW 36-B",
    //           "remainingMeeting": "-",
    //           "available": "yes",
    //           "feedbackPermission": false,
    //           "session": 2
    //         }
    //       ]
    //     };
  }

  Future<dynamic> setPresensiSiswa(Map<String, dynamic> dataPresensi) async {
    if (kDebugMode) {
      logger.log(
          'JADWAL_SERVICE_API-SetPresensiSiswa: START with params$dataPresensi');
    }

    final response = await _apiHelper.requestPost(
      bodyParams: dataPresensi,
      pathUrl: '/jadwal/student/hadirjwt',
    );

    if (kDebugMode) {
      logger.log('JADWAL_SERVICE_API-SetPresensiSiswa: response >> $response');
    }

    if (!response['status']) throw DataException(message: response['message']);

    return response['message'];
  }

  Future<dynamic> setPresensiSiswaTst(Map<String, dynamic> dataPresensi) async {
    if (kDebugMode) {
      logger.log(
          'JADWAL_SERVICE_API-SetPresensiSiswaTST: START with params$dataPresensi');
    }

    final response = await _apiHelper.requestPost(
      bodyParams: dataPresensi,
      jwt: true,
      pathUrl: '/jadwal/student/hadir/tstjwt',
    );

    if (kDebugMode) {
      logger
          .log('JADWAL_SERVICE_API-SetPresensiSiswaTST: response >> $response');
    }

    if (!response['status']) throw DataException(message: response['message']);
    return response['message'];
  }
}
