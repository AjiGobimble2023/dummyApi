import 'dart:developer' as logger show log;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../presentation/provider/leaderboard_racing_provider.dart';

class ApiRanking {
  Future<Map<String, dynamic>> getranking(
      {required String nis,
      required String idSekolahKelas,
      required int number,
      required String level,
      required String ta,
      required String penanda,
      required String idgedung,
      required String jeniswaktu}) async {
    Map<String, Object> result;
    http.Response res = await http.post(
      Uri.parse(
          "http://kreasi.ganeshaoperation.com:8081/kreasi/v4/leaderboardracing/getleaderracing"),
      body: json.encode({
        'token': "YGfdsk3452355mj56uy",
        'nis': nis,
        'idSekolahKelas': idSekolahKelas,
        'number': number,
        'level': level,
        'tahunajaran': ta,
        'penanda': penanda,
        'idgedung': idgedung,
        'jeniswaktu': jeniswaktu,
      }),
      headers: {'Content-Type': 'application/json'},
    );
    if (kDebugMode) {
      logger.log(
          "number : $number ,level :$level,tahunajaran : $ta, jeniswaktu : $jeniswaktu, 'nis': $nis, 'penanda': $penanda, 'idgedung': $idgedung, 'idSekolahKelas': $idSekolahKelas,");
      logger.log("Parameter ${res.body}");
    }

    if (res.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(res.body);
      dynamic body = json.decode(jsonEncode(responseData['data']));
      logger.log(body.toString());
      DataRanking cases = DataRanking.fromJson(body);
      result = {'status': true, 'data': cases};
    } else {
      result = {'status': false, 'data': "gagal mendapatkan data"};
    }
    return result;
  }
}
