import 'package:equatable/equatable.dart';

import '../model/standby_model.dart';

class Standby extends Equatable {
  final String? date;
  final List<StandbyTeacherModel>? teachers;

  const Standby({this.date, this.teachers});

  @override
  List<Object> get props => [date!, teachers!];
}

class StandbyTeacher extends Equatable {
  final String? name;
  final String? lesson;
  final List<StandbyScheduleModel>? schedule;

  const StandbyTeacher({this.name, this.lesson, this.schedule});

  @override
  List<Object> get props => [name!, lesson!, schedule!];
}

class StandbySchedule extends Equatable {
  final String? planId;
  final String? activity;
  final String? teacherId;
  final String? buildingName;
  final String? start;
  final String? finish;
  final bool? isTST;
  final bool? available;
  final String? registered;

  const StandbySchedule(
      {this.planId,
      this.activity,
      this.teacherId,
      this.buildingName,
      this.start,
      this.finish,
      this.isTST,
      this.available,
      this.registered});

  @override
  List<Object> get props => [planId!, start!, finish!];
}
