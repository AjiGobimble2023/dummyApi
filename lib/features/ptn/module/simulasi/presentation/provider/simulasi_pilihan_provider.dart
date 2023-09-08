import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';

import '../../model/pilihan_model.dart';
import '../../model/universitas_model.dart';
import '../../service/api/simulasi_service_api.dart';
import '../../../../../../core/util/app_exceptions.dart';

class SimulasiPilihanProvider with ChangeNotifier {
  final _apiService = SimulasiServiceAPI();

  List<UniversitasModel> _listUniversitas = [];
  bool _isLoading = false;
  final List<PilihanModel> _listPilihan = [];

  String? _selectedPrioritas, _selectedStatus;
  bool get isLoading => _isLoading;
  List<PilihanModel> get listPilihan => _listPilihan;

  String get selectedPrioritas => _selectedPrioritas!;

  /// [loadPilihan] is used to load data Pilihan PTN UTBK the data from the API.
  ///
  /// Args:
  ///   noRegistrasi (String): The registration number of the student.
  ///
  /// Returns:
  ///   A list of PilihanModel
  Future<List<PilihanModel>> loadPilihan({
    required String noRegistrasi,
  }) async {
    if (kDebugMode) {
      logger.log(
          'SIMULASI_PILIHAN_PROVIDER-LoadPilihan: START with params($noRegistrasi)');
    }
    try {
      _isLoading = true;
      _listPilihan.clear();
      notifyListeners();
      final responseData =
          await _apiService.fetchPilihan(noRegistrasi: noRegistrasi);

      /// Used to check if the responseData is null or not. If it is not null, then it will loop through
      /// the responseData and add it to the listPilihan.
      if (responseData != null) {
        for (int i = 0; i < responseData.length; i++) {
          if (kDebugMode) {
            logger.log("$i ${responseData[i]}");
          }
          if (responseData[i] != null) {
            _listPilihan.add(PilihanModel.fromJson((responseData[i])));
          }
        }
      }

      if (kDebugMode) {
        logger.log(
            'SIMULASI_PILIHAN_PROVIDER-LoadPilihan: List Pilihan >> $listPilihan');
      }
      _isLoading = false;

      notifyListeners();
      return [..._listPilihan];
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-LoadPilihan: $e');
      }
      rethrow;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-LoadPilihan: $e');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        logger.log('Exception-LoadPilihan: $e');
      }
      throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti.';
    }
  }

  /// [loadDataPilihan] is used to load the data of the university that has been selected by the user.
  ///
  /// Args:
  ///   idJurusan (String): The ID of the selected major.
  ///   prioritas (String): 1, 2, 3, 4
  ///   status (String): The status of the number of changes
  ///   idSekolahKelas (String): The ID of the school class.
  ///   idPilihanPtn1 (String): The first choice of the university
  ///   idPilihanPtn2 (String): The ID of the second choice of the university.
  ///
  /// Returns:
  ///   A list of UniversitasModel.
  Future<List<UniversitasModel>> loadDataPilihan({
    String? idJurusan,
    String? prioritas,
    String? status,
    required String idSekolahKelas,
    String? idPilihanPtn1,
    String? idPilihanPtn2,
  }) async {
    if (kDebugMode) {
      logger.log('SIMULASI_PILIHAN_PROVIDER-LoadDataPilihan: START with '
          'params($idJurusan, $prioritas, $status, $idSekolahKelas, $idPilihanPtn1, $idPilihanPtn2)');
    }
    try {
      final listUniversitas = await loadUniversitas(
        idSekolahKelas: idSekolahKelas,
      );
      _selectedPrioritas = prioritas;
      _selectedStatus = status;

      if (kDebugMode) {
        if (kDebugMode) {
          logger.log('SIMULASI_PILIHAN_PROVIDER-LoadDataPilihan: '
              'Selected Prioritas >> $_selectedPrioritas');
          logger.log('SIMULASI_PILIHAN_PROVIDER-LoadDataPilihan: '
              'Selected Status >> $_selectedStatus');

          logger.log(
              'SIMULASI_PILIHAN_PROVIDER-LoadDataPilihan: List Universitas >> $listUniversitas');
        }
      }

      notifyListeners();
      return [...listUniversitas];
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-LoadDataPilihan: $e');
      }
      if (_listUniversitas.isNotEmpty) return _listUniversitas;
      rethrow;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-LoadDataPilihan: $e');
      }
      if (_listUniversitas.isNotEmpty) return _listUniversitas;
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-LoadDataPilihan: $e');
      }
      if (_listUniversitas.isNotEmpty) return _listUniversitas;
      throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti.';
    }
  }

  /// [loadUniversitas] is a function that is used to load the list of universities from the API.
  ///
  /// Args:
  ///   idSekolahKelas (String): The ID of the school class.
  ///
  /// Returns:
  ///   A list of UniversitasModel.
  Future<List<UniversitasModel>> loadUniversitas({
    required String idSekolahKelas,
  }) async {
    if (kDebugMode) {
      logger.log('SIMULASI_PILIHAN_PROVIDER-LoadUniversitas: START with '
          'params($idSekolahKelas)');
    }
    try {
      final responseData = await _apiService.fetchUniversitas(
        idSekolahKelas: idSekolahKelas,
      );

      if (_listUniversitas.isNotEmpty) _listUniversitas = [];

      if (responseData != null) {
        for (int i = 0; i < responseData.length; i++) {
          _listUniversitas.add(UniversitasModel.fromJson(responseData[i]));
        }
      }

      if (kDebugMode) {
        logger.log(
            'SIMULASI_PILIHAN_PROVIDER-LoadUniversitas: List Universitas >> $_listUniversitas');
      }

      return [..._listUniversitas];
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-LoadUniversitas: $e');
      }
      if (_listUniversitas.isNotEmpty) return _listUniversitas;
      rethrow;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-LoadUniversitas: $e');
      }
      if (_listUniversitas.isNotEmpty) return _listUniversitas;
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-LoadUniversitas: $e');
      }
      if (_listUniversitas.isNotEmpty) return _listUniversitas;
      throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti.';
    }
  }

  /// [savePilihan] is a function that is used to saves the user's choice of study program.
  ///
  /// Args:
  ///   noRegistrasi (String): The registration number of the user.
  ///   prioritas (String): The priority of the choice.
  ///   status (String): '1' = Pilihan 1, '2' = Pilihan 2, '3' = Pilihan 3
  ///   jurusanId (String): The ID of the major you want to choose.
  Future<void> savePilihan({
    required String noRegistrasi,
    required String prioritas,
    required String status,
    required String jurusanId,
  }) async {
    if (kDebugMode) {
      logger.log(
          'SIMULASI_PILIHAN_PROVIDER-SavePilihan: START with params($noRegistrasi, $prioritas, $status, $jurusanId)');
    }
    try {
      await _apiService.setPilihan(
        noRegistrasi: noRegistrasi,
        prioritas: prioritas,
        status: status,
        idJurusan: jurusanId,
      );
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-SavePilihan: $e');
      }
      rethrow;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-SavePilihan: $e');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-SavePilihan: $e');
      }
      throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti.';
    }
  }
}
