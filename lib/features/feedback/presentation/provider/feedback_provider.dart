import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../../../core/util/app_exceptions.dart';
import '../../model/feedback_question.dart';
import '../../service/api/feedback_service_api.dart';

class FeedbackProvider with ChangeNotifier {
  final FeedbackServiceApi _apiService = FeedbackServiceApi();

  final List<FeedbackQuestion> _listPertanyaan = [];

  List<FeedbackQuestion> get listPertanyaan => _listPertanyaan;

  int get monthNow {
    var now = DateTime.now();
    var formatter = DateFormat('M');
    int month = int.parse(formatter.format(now));

    return month;
  }

  void setJawaban(int idx, dynamic value) {
    _listPertanyaan[idx].answer = value;
  }

  Future<List<FeedbackQuestion>> loadFeedbackQuestion(
      String userId, String idRencana) async {
    try {
      final responseData = await _apiService.fetchFeedbackQuestion(
          userId: userId, idRencana: idRencana);

      for (var i = 0; i < (responseData as List).length; i++) {
        _listPertanyaan.add(FeedbackQuestion.fromJson(responseData[i]));
      }

      return _listPertanyaan;
    } on NoConnectionException {
      rethrow;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-FeedbackQuestion: $e');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-FeedbackQuestion: $e');
      }
      throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti.';
    }
  }

  Future<void> saveFeedback(String userId, String idRencana) async {
    try {
      Map<String, dynamic> bodyParams = {
        'userId': userId,
        'idRencana': idRencana
      };
      for (var i = 0; i < _listPertanyaan.length; i++) {
        bodyParams[_listPertanyaan[i].column] = _listPertanyaan[i].answer;
      }

      await _apiService.setFeedback(params: bodyParams);
    } on NoConnectionException {
      rethrow;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-SetFeedback: $e');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-SetFeedback: $e');
      }
      throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti.';
    }
  }
}
