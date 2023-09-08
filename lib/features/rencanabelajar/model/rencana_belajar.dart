import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'rencana_menu.dart';
import '../../../core/config/extensions.dart';
import '../../../core/util/data_formatter.dart';

class RencanaBelajar extends Equatable {
  final String idRencana;
  final String noRegistrasi;
  final String menuLabel;
  final String keterangan;
  final bool isDone;
  final DateTime startRencana;
  final DateTime endRencana;
  final DateTime createdDate;
  final DateTime? lastUpdate;
  final Map<String, dynamic> argument;
  final int idJenisProduk;
  final String namaJenisProduk;
  final Color backgroundColor;

  bool get isFittedBox =>
      menuLabel != 'TOBK' &&
      menuLabel != 'Video' &&
      menuLabel != 'Kuis' &&
      menuLabel != 'Tes VAK' &&
      menuLabel != 'Buku Teori';

  String get displayWeek {
    String initial = menuLabel;

    switch (menuLabel) {
      case 'Tes VAK':
        initial = '-VAK-';
        break;
      case 'TOBK':
        initial = '-TOBK-';
        break;
      case 'Kuis':
        initial = '-Kuis-';
        break;
      case 'GO Assessment':
        initial = '-GOA-';
        break;
      case 'Paket Soal Koding':
        initial = 'Soal Koding';
        break;
      case 'Pendalaman Materi':
        initial = 'Pend. Mater..';
        break;
      case 'Soal Referensi':
        initial = 'Soal Refer..';
        break;
    }

    return initial;
  }

  const RencanaBelajar({
    required this.idRencana,
    required this.noRegistrasi,
    required this.menuLabel,
    required this.keterangan,
    required this.startRencana,
    required this.endRencana,
    required this.createdDate,
    required this.isDone,
    required this.idJenisProduk,
    required this.namaJenisProduk,
    required this.backgroundColor,
    required this.argument,
    this.lastUpdate,
  });

  factory RencanaBelajar.fromJson(
    Map<String, dynamic> json, [
    List<RencanaMenu> menuRencana = const [],
  ]) {
    int indexMenu = menuRencana
        .indexWhere((rencanaMenu) => rencanaMenu.label == json['c_Menu']);

    Color backgroundColor =
        (indexMenu >= 0) ? menuRencana[indexMenu].warna : Colors.black26;
    int idJenisProduk =
        (indexMenu >= 0) ? menuRencana[indexMenu].idJenisProduk : 0;
    String namaJenisProduk =
        (indexMenu >= 0) ? menuRencana[indexMenu].namaJenisProduk : 'Undefined';

    return RencanaBelajar(
      idRencana: json['c_Id'],
      noRegistrasi: json['c_NoRegister'],
      menuLabel: json['c_Menu'],
      keterangan: json['c_Keterangan'],
      startRencana: DataFormatter.stringToDate(json['c_Awal']),
      endRencana: DataFormatter.stringToDate(json['c_Akhir']),
      createdDate: DataFormatter.stringToDate(json['c_TglBuat']),
      isDone: (json['c_isdone'] != null) ? json['c_isdone'] == 'y' : false,
      lastUpdate: (json['c_LastUpdate'] != null)
          ? DataFormatter.stringToDate(json['c_LastUpdate'])
          : null,
      argument: (json['c_argument'] is String)
          ? jsonDecode(json['c_argument'])
          : json['c_argument'],
      idJenisProduk: idJenisProduk,
      namaJenisProduk: namaJenisProduk,
      backgroundColor: backgroundColor,
    );
  }

  Map<String, dynamic> toJson() => {
        'c_Id': idRencana,
        'c_NoRegister': noRegistrasi,
        'c_Menu': menuLabel,
        'c_Keterangan': keterangan,
        'c_Awal': startRencana.sqlFormat,
        'c_Akhir': endRencana.sqlFormat,
        'c_TglBuat': createdDate.sqlFormat,
        'c_LastUpdate': lastUpdate?.sqlFormat,
        'c_isdone': isDone ? 'y' : 'n',
        'c_argument': argument,
      };

  RencanaBelajar copyWith({
    String? idRencana,
    String? noRegistrasi,
    String? menuLabel,
    String? keterangan,
    bool? isDone,
    DateTime? startRencana,
    DateTime? endRencana,
    Map<String, dynamic>? argument,
  }) =>
      RencanaBelajar(
        idRencana: idRencana ?? this.idRencana,
        noRegistrasi: noRegistrasi ?? this.noRegistrasi,
        menuLabel: menuLabel ?? this.menuLabel,
        keterangan: keterangan ?? this.keterangan,
        startRencana: startRencana ?? this.startRencana,
        endRencana: endRencana ?? this.endRencana,
        isDone: isDone ?? this.isDone,
        argument: argument ?? this.argument,
        createdDate: createdDate,
        lastUpdate: lastUpdate,
        idJenisProduk: idJenisProduk,
        namaJenisProduk: namaJenisProduk,
        backgroundColor: backgroundColor,
      );

  @override
  List<Object?> get props => [
        idRencana,
        noRegistrasi,
        idJenisProduk,
        namaJenisProduk,
        menuLabel,
        keterangan,
        startRencana,
        endRencana,
        backgroundColor,
        isDone,
        createdDate,
        lastUpdate,
        argument,
      ];
}

/// An object to set the appointment collection data source to calendar, which
/// used to map the custom appointment data to the calendar appointment, and
/// allows to add, remove or reset the appointment collection.
class RencanaBelajarDataSource extends CalendarDataSource {
  /// Creates a meeting data source, which used to set the appointment
  /// collection to the calendar
  RencanaBelajarDataSource(List<RencanaBelajar> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) =>
      _getRencanaBelajar(index)?.startRencana ?? DateTime.now();

  @override
  DateTime getEndTime(int index) =>
      _getRencanaBelajar(index)?.endRencana ??
      DateTime.now().add(const Duration(hours: 1));

  @override
  String getSubject(int index) => _getRencanaBelajar(index)?.menuLabel ?? 'N/a';

  @override
  Color getColor(int index) =>
      _getRencanaBelajar(index)?.backgroundColor ?? Colors.black26;

  @override
  String getNotes(int index) =>
      _getRencanaBelajar(index)?.keterangan ?? 'Undefined Rencana Belajar';

  @override
  Object getId(int index) => _getRencanaBelajar(index)?.idRencana ?? '-1';

  @override
  bool isAllDay(int index) => false;

  @override
  String getStartTimeZone(int index) => 'Singapore Standard Time';

  @override
  String getEndTimeZone(int index) => 'Singapore Standard Time';

  RencanaBelajar? _getRencanaBelajar(int index) {
    final dynamic appointment = appointments![index];

    RencanaBelajar? rencanaBelajar;
    if (appointment is RencanaBelajar) {
      rencanaBelajar = appointment;
    }

    return rencanaBelajar;
  }
}
