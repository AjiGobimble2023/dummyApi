import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';

import '../../model/nilai_model.dart';
import '../../service/api/simulasi_service_api.dart';
import '../../../../../../core/util/app_exceptions.dart';

class SimulasiNilaiProvider with ChangeNotifier {
  final _apiService = SimulasiServiceAPI();

  /// [_listNilai] is used to store the list of NilaiModel.
  late final List<NilaiModel> _listNilai = [];

  /// Used to store the index of the selected NilaiModel.
  int _selectedIndex = 0;

  /// Used to store the value of the `isFix` property.
  bool _isFix = false;

  /// Used to store the value of the `isLoading` property.
  bool _isLoading = false;

  /// Used to get the value of the variable.
  int get selectedIndex => _selectedIndex;
  bool get isFix => _isFix;
  bool get isLoading => _isLoading;
  List<NilaiModel> get listNilai => _listNilai;
  NilaiModel get nilaiModel {
    NilaiModel dataNilai = NilaiModel(
        kodeTob: '-',
        tob: '-',
        isSelected: false,
        isFix: false,
        detailNilai: const {});
    if (_listNilai.isNotEmpty) dataNilai = _listNilai[_selectedIndex];
    return dataNilai;
  }

  void setFixValue(value) async {
    _isFix = value;
    notifyListeners();
  }

  void setSelectedIndex(int selectedIndex) async {
    _selectedIndex = selectedIndex;
    _isFix = false;
    notifyListeners();
  }

  /// [loadNilai] is used to load the data of the student's grades.
  ///
  /// Args:
  ///   noRegistrasi (String): The registration number of the student.
  ///   idSekolahKelas (String): The id of the school class.
  ///
  /// Returns:
  ///   A list of NilaiModel.
  Future<List<NilaiModel>> loadNilai({
    required String noRegistrasi,
    required String idSekolahKelas,
  }) async {
    if (kDebugMode) {
      logger.log('SIMULASI_NILAI_PROVIDER-LoadNilai: START with '
          'params($noRegistrasi, $idSekolahKelas)');
    }
    try {
      _isLoading = true;
      _listNilai.clear();
      notifyListeners();
      final responseData = await _apiService.fetchNilai(
        noRegistrasi: noRegistrasi,
        idSekolahKelas: idSekolahKelas,
      );

      /// Used to check if the responseData is not null, then it will loop through the responseData and
      /// add it to the listNilai.
      if (responseData != null) {
        for (int i = 0; i < responseData.length; i++) {
          final snbtNilaiModel = NilaiModel.fromJson(responseData[i]);
          _selectedIndex = snbtNilaiModel.isSelected ? i : _selectedIndex;
          _isFix = snbtNilaiModel.isSelected ? snbtNilaiModel.isFix : _isFix;
          _listNilai.add(snbtNilaiModel);
        }
      }

      if (kDebugMode) {
        logger.log(
            'SIMULASI_NILAI_PROVIDER-LoadNilai: List Nilai >> $_listNilai');
      }
      _isLoading = false;
      notifyListeners();
      return [..._listNilai];
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-LoadNilai: $e');
      }
      rethrow;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-LoadNilai: $e');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-LoadNilai: $e');
      }
      throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti.';
    }
  }

  /// [saveNilai] is used to save the value of the score that has been entered by the user.
  ///
  /// Args:
  ///   noRegistrasi (String): The registration number of the student.
  ///   kodeTOB (String): The code of the subject.
  ///   detailNilai (Map<String, dynamic>): Map<String, dynamic>?
  Future<void> saveNilai({
    required String noRegistrasi,
    required String kodeTOB,
    Map<String, dynamic>? detailNilai,
  }) async {
    try {
      List<Map<String, dynamic>> listNilai = [];

      /// Used to convert the data from the map to the list.
      if (detailNilai != null) {
        detailNilai.forEach((mapel, v) {
          final nilai = v != null ? int.parse(v.toString()) : 0;
          listNilai.add(DetailNilaiModel(mapel: mapel, nilai: nilai).toJson());
        });
      }

      final status = _isFix == true ? 'fix' : 'awal';

      await _apiService.setNilai(
        noRegistrasi: noRegistrasi,
        kodeTOB: kodeTOB,
        status: status,
        listNilai: listNilai,
      );
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-SaveNilai: $e');
      }
      rethrow;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-SaveNilai: $e');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-SaveNilai: $e');
      }
      throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti.';
    }
  }
}
