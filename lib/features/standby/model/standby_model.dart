import '../entity/standby.dart';

class StandbyModel extends Standby {
  const StandbyModel(
      {required String date, required List<StandbyTeacherModel> teachers})
      : super(
          date: date,
          teachers: teachers,
        );

  factory StandbyModel.fromJson(Map<String, dynamic> json) => StandbyModel(
        date: json['date'],
        teachers: (json['teachers'] as List)
            .map((teacher) => StandbyTeacherModel.fromJson(teacher))
            .toList(),
      );
}

class StandbyTeacherModel extends StandbyTeacher {
  const StandbyTeacherModel(
      {required String name,
      required String lesson,
      required List<StandbyScheduleModel> schedule})
      : super(
          name: name,
          lesson: lesson,
          schedule: schedule,
        );

  factory StandbyTeacherModel.fromJson(Map<String, dynamic> json) =>
      StandbyTeacherModel(
        name: json['teacher'],
        lesson: json['lesson'],
        schedule: (json['schedule'] as List)
            .map((schedule) => StandbyScheduleModel.fromJson(schedule))
            .toList(),
      );
}

class StandbyScheduleModel extends StandbySchedule {
  const StandbyScheduleModel(
      {required String planId,
      String? activity,
      String? teacherId,
      String? buildingName,
      required String start,
      required String finish,
      required bool isTST,
      required bool available,
      required String registered})
      : super(
          planId: planId,
          activity: activity,
          teacherId: teacherId,
          buildingName: buildingName,
          start: start,
          finish: finish,
          isTST: isTST,
          available: available,
          registered: registered,
        );

  factory StandbyScheduleModel.fromJson(Map<String, dynamic> json) =>
      StandbyScheduleModel(
        planId: json['planId'],
        activity: json['activity'],
        teacherId: json['teacherId'],
        buildingName: json['buildingName'],
        start: json['start'],
        finish: json['finish'],
        isTST: json['isTST'] ?? false,
        available: json['available'] ?? false,
        registered: json['registered'],
      );
}
