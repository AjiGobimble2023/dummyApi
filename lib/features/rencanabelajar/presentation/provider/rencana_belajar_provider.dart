import 'dart:collection';
import 'dart:convert';
import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../model/rencana_menu.dart';
import '../../model/rencana_belajar.dart';
import '../../service/api/rencana_service_api.dart';
import '../../service/notifikasi/local_notification_service.dart';
import '../../../../core/config/enum.dart';
import '../../../../core/config/global.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/util/app_exceptions.dart';
import '../../../../core/shared/provider/disposable_provider.dart';

class RencanaBelajarProvider extends DisposableProvider {
  final _apiService = RencanaBelajarServiceAPI();

  final _notificationService = LocalNotificationService();

  final List<RencanaMenu> _listMenuRencana = [];
  final List<RencanaBelajar> _listRencanaBelajar = [];

  @override
  void disposeValues() {
    // Dispose data provider when logout.
    _listRencanaBelajar.clear();
  }

  UnmodifiableListView<RencanaMenu> get listMenuRencana =>
      UnmodifiableListView<RencanaMenu>(_listMenuRencana);

  List<RencanaBelajar> get listRencanaBelajar => _listRencanaBelajar;

  CalendarView calendarView = CalendarView.schedule;
  RencanaBelajar? _selectedRencana;

  int _selectedMenuIndex = 0;

  /// nama variable sebelumnya _namaJenisMenu
  String selectedMenuRencana = 'pilih';

  DateTime _startRencanaDate = DateTime.now();
  DateTime _endRencanaDate = DateTime.now().add(const Duration(hours: 1));

  RencanaBelajar? get selectedRencana => _selectedRencana;

  int get selectedMenuIndex => _selectedMenuIndex;
  int get indexMenu => (_selectedRencana?.menuLabel.isEmpty ?? true)
      ? 0
      : listMenuRencana
          .indexWhere((menu) => menu.namaJenisProduk == selectedMenuRencana);

  String get editorTitle {
    if (kDebugMode) {
      logger.log('RENCANA_BELAJAR_PROVIDER-EditorTitle: Selected Rencana '
          'isNull >> ${_selectedRencana == null}');
    }
    return (_selectedRencana?.menuLabel.isEmpty ?? true)
        ? 'Rencana Baru'
        : 'Detail Rencana';
  }

  DateTime get startRencanaDate => _startRencanaDate;
  DateTime get endRencanaDate => _endRencanaDate;

  set selectedMenuIndex(int menuIndex) {
    _selectedMenuIndex = menuIndex;
    selectedMenuRencana = listMenuRencana[selectedMenuIndex].namaJenisProduk;
    notifyListeners();
  }

  set startRencanaDate(DateTime tanggalBaru) {
    _startRencanaDate = tanggalBaru;

    if (tanggalBaru.isAfter(_endRencanaDate) ||
        tanggalBaru.isAtSameMomentAs(_endRencanaDate)) {
      _endRencanaDate = tanggalBaru.add(const Duration(hours: 1));
    }
    notifyListeners();
  }

  set endRencanaDate(DateTime tanggalBaru) {
    _endRencanaDate = tanggalBaru;

    if (tanggalBaru.isBefore(_startRencanaDate) ||
        tanggalBaru.isAtSameMomentAs(_startRencanaDate)) {
      _startRencanaDate = tanggalBaru.subtract(const Duration(hours: 1));
    }

    notifyListeners();
  }

  set selectedRencana(RencanaBelajar? rencana) {
    _selectedRencana = rencana;

    if (rencana != null) {
      _startRencanaDate = rencana.startRencana;
      _endRencanaDate = rencana.endRencana;

      selectedMenuRencana =
          (rencana.idJenisProduk == 0) ? 'pilih' : rencana.menuLabel;

      _selectedMenuIndex = _listMenuRencana.indexWhere(
        (menu) => menu.idJenisProduk == rencana.idJenisProduk,
      );

      if (_selectedMenuIndex < 0) _selectedMenuIndex = 0;
    } else {
      selectedMenuRencana = 'pilih';
      _selectedMenuIndex = 0;
    }
    if (kDebugMode) {
      logger.log('RENCANA_BELAJAR_PROVIDER-SetSelectedRencana: '
          'Selected Menu Rencana (i: $_selectedMenuIndex) >> $selectedMenuRencana\n'
          'Selected Rencana >> $_selectedRencana');
    }
    notifyListeners();
  }

  Future<void> bukaScreen(
      {required Map<String, dynamic> argumentRencana}) async {
    await _notificationService.bukaScreen(argument: argumentRencana);
  }

  Future<List<RencanaMenu>> getListMenu({
    bool isRefresh = false,
  }) async {
    if (kDebugMode) {
      logger.log('RENCANA_BELAJAR_PROVIDER-GetListMenu: START');
    }

    if (!isRefresh && listMenuRencana.isNotEmpty) {
      if (kDebugMode) {
        logger.log('RENCANA_BELAJAR_PROVIDER-GetListMenu: '
            'List Menu >> $listMenuRencana');
      }
      return listMenuRencana;
    }
    try {
      final response = await _apiService.fetchListMenu();

      if (kDebugMode) {
        logger.log('RENCANA_BELAJAR_PROVIDER-GetListMenu: '
            'Response >> $response');
      }

      if (response['status'] && response['data'] != null) {
        List<dynamic> responseData = response['data'];

        if (isRefresh) _listMenuRencana.clear();

        if (_listMenuRencana.isEmpty) {
          for (var data in responseData) {
            _listMenuRencana.add(RencanaMenu.fromJson(data));
          }
        }
      }

      if (kDebugMode) {
        logger.log(
            'RENCANA_BELAJAR_PROVIDER-GetListMenu: List Rencana Menu >> $listMenuRencana');
      }
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-GetListMenu: $e');
      }
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-GetListMenu: $e');
      }
    }

    _selectedMenuIndex = indexMenu;
    notifyListeners();
    return listMenuRencana;
  }

  Future<List<RencanaBelajar>> getDataRencanaBelajar({
    required String noRegistrasi,
    bool isRefresh = false,
  }) async {
    if (kDebugMode) {
      logger.log('RENCANA_BELAJAR_PROVIDER-GetDataRencanaBelajar: '
          'START with params($noRegistrasi)');
    }

    if (!isRefresh && listRencanaBelajar.isNotEmpty) {
      return listRencanaBelajar;
    }
    try {
      final response = await _apiService.fetchDataRencanaBelajar(
        noRegistrasi: noRegistrasi,
      );

      if (response['status']) {
        List<dynamic> data = response['data'];

        if (isRefresh) _listRencanaBelajar.clear();

        if (_listRencanaBelajar.isEmpty) {
          for (var rencana in data) {
            _listRencanaBelajar
                .add(RencanaBelajar.fromJson(rencana, listMenuRencana));
          }
          notifyListeners();
        }

        if (kDebugMode) {
          logger.log('RENCANA_BELAJAR_PROVIDER-GetDataRencanaBelajar: '
              'Daftar Rencana Belajar >> $listRencanaBelajar');
        }
      }
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-GetDataRencanaBelajar: $e');
      }
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-GetDataRencanaBelajar: $e');
      }
    }

    // if (listRencanaBelajar.isNotEmpty) notifyListeners();

    return listRencanaBelajar;
  }

  Future<Map<String, dynamic>> simpanRencanaBelajar({
    required String noRegistrasi,
    required bool isSimpan,
  }) async {
    Map<String, dynamic> returnResult = {
      'status': false,
      'listRencanaBelajar': _listRencanaBelajar
    };

    if (kDebugMode) {
      logger.log(
          'RENCANA_BELAJAR_PROVIDER-SimpanRencanaBelajar: START with params($noRegistrasi)\n'
          'RENCANA_BELAJAR_PROVIDER-SimpanRencanaBelajar: '
          'Rencana Belajar Selected >> $selectedRencana');
    }

    if (selectedRencana == null) {
      gShowTopFlash(gNavigatorKey.currentState!.context,
          'Pilih menu rencana terlebih dahulu');
      return returnResult;
    }

    try {
      final response = await _apiService.simpanRencanaBelajar(
        noRegistrasi: noRegistrasi,
        idRencana: (selectedRencana!.idRencana == 'Temp-Rencana')
            ? null
            : selectedRencana!.idRencana,
        menu: listMenuRencana[selectedMenuIndex].label,
        keterangan: selectedRencana!.keterangan,
        awalRencanaDate: startRencanaDate.sqlFormat,
        akhirRencanaDate: endRencanaDate.sqlFormat,
        jenisSimpan: isSimpan ? 'simpan' : 'update',
        argument: selectedRencana!.argument,
      );

      if (response['status']) {
        _selectedRencana =
            selectedRencana!.copyWith(idRencana: '${response['data']}');

        if (kDebugMode) {
          logger.log('RENCANA_BELAJAR_PROVIDER-SimpanRencanaBelajar: '
              'Rencana Belajar New Created >> $selectedRencana');
        }

        if (_listRencanaBelajar.any(
            (rencana) => rencana.idRencana == selectedRencana!.idRencana)) {
          int indexSelectedRencana = _listRencanaBelajar.indexWhere(
              (rencana) => rencana.idRencana == selectedRencana!.idRencana);

          _listRencanaBelajar.removeAt(indexSelectedRencana);
          _listRencanaBelajar.insert(indexSelectedRencana, selectedRencana!);
        } else {
          _listRencanaBelajar.add(selectedRencana!);
        }

        if (kDebugMode) {
          logger.log('RENCANA_BELAJAR_PROVIDER-SimpanRencanaBelajar: '
              'List Rencana Belajar(${_listRencanaBelajar.length}) >> $_listRencanaBelajar');
        }

        // if (kDebugMode) {
        //   final localNotif1 = LocalNotificationService();
        //   bool isIdentical = identical(_notificationService, gLocalNotif);
        //   logger.log(
        //       'SPLASH_SCREEN-InitState: $isIdentical || ${_notificationService == gLocalNotif} || ${localNotif1 == _notificationService}');
        // }

        // Buat Notifikasi
        _notificationService.showScheduledNotificationWithPayload(
          id: int.parse(selectedRencana!.idRencana),
          body: selectedRencana!.keterangan,
          payload: json.encode(selectedRencana!.argument),
          startRencana: selectedRencana!.startRencana,
        );

        gShowTopFlash(gNavigatorKey.currentContext!,
            'Rencana belajar ${listMenuRencana[selectedMenuIndex].label} berhasil disimpan',
            dialogType: DialogType.success);

        notifyListeners();
        returnResult = {
          'status': true,
          'listRencanaBelajar': listRencanaBelajar,
          'newAppointment': selectedRencana,
        };
      }
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-SimpanRencanaBelajar: $e');
      }
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-SimpanRencanaBelajar: $e');
      }
      throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti';
    }
    return returnResult;
  }
}
