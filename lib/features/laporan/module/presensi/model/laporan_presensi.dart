class LaporanPresensiDate {
  /// [date] merupakan variabel yang berisi tanggal presensi siswa.
  final String date;

  /// [feedbackCount] merupakan variabel yang berisi jumlah feedback yang belum dikirimkan.
  final int feedbackCount;

  /// [listPresences] variabel untuk menampung data informasi ekstra dari presensi tersebut.
  final List<LaporanPresensiInfo> listPresences;

  LaporanPresensiDate(
      {required this.date,
      required this.feedbackCount,
      required this.listPresences});

  factory LaporanPresensiDate.fromJson(Map<String, dynamic> json) =>
      LaporanPresensiDate(
        date: json['date'],
        feedbackCount: (json['listPresences'] as List)
            .where((presence) =>
                presence['feedbackPermission'] && !presence['isFeedback'])
            .length,
        listPresences: (json['listPresences'] as List)
            .map((presence) => LaporanPresensiInfo.fromJson(presence))
            .toList(),
      );
}

class LaporanPresensiInfo {
  /// [planId] variabel yang berisi data rencana kerja.
  final String? planId;

  /// [classId] variabel yang berisi data id Kelas GO sesuai dengan id Kelas GO yang ada pada QR Presensi.
  final String? classId;

  /// [className] variabel yang berisi data nama Kelas GO.
  final String? className;

  /// [studentClassId] variabel yang berisi data id Kelas GO sesuai dengan id kelas dibeli.
  final String? studentClassId;

  /// [flag] variabel yang berisi keterangan (sama/tidak sama) berdasarkan data dari [classId] dan [studentClassId]
  final String? flag;

  /// [date] variabel yang berisi data tanggal dari kelas tersebut.
  final String? date;

  /// [presenceTime] variabel yang berisi data jadwal melakukan presensi.
  final String? presenceTime;

  /// [teacherId] variabel yang berisi data NIK pengajar.
  final String? teacherId;

  /// [teacherName] variabel yang berisi data nama pengajar.
  final String? teacherName;

  /// [scheduleStart] variabel yang berisi data jadwal mulai.
  final String? scheduleStart;

  /// [scheduleFinish] variabel yang berisi data jadwal akhir.
  final String? scheduleFinish;

  /// [buildingName] variabel yang berisi data nama gedung.
  final String? buildingName;

  /// [session] variabel yang berisi data sesi pembelajaran.
  final String? session;

  /// [lesson] variabel yang berisi data nama kelompok uji.
  final String? lesson;

  /// [activity] variabel yang berisi data jenis aktivitas.
  final String? activity;

  /// [isFeedback] variabel yang berisi data boolean untuk menentukan apakah sudah feedback atau belum.
  final bool? isFeedback;

  /// [feedbackPermission] variabel yang berisi data boolean untuk menentukan apakah masih bisa melakukan feedback atau tidak.
  final bool? feedbackPermission;

  LaporanPresensiInfo({
    this.planId,
    this.classId,
    this.className,
    this.studentClassId,
    this.flag,
    this.date,
    this.presenceTime,
    this.teacherId,
    this.teacherName,
    this.scheduleStart,
    this.scheduleFinish,
    this.buildingName,
    this.session,
    this.lesson,
    this.activity,
    this.isFeedback,
    this.feedbackPermission,
  });

  factory LaporanPresensiInfo.fromJson(Map<String, dynamic> json) =>
      LaporanPresensiInfo(
        planId: json['planId'],
        classId: json['classId'] ?? "-",
        className: json['className'] ?? "-",
        studentClassId: json['studentClassId'] ?? "-",
        flag: json['flag'] ?? "-",
        date: json['date'] ?? "-",
        presenceTime: json['presenceTime'] ?? "-",
        teacherId: json['teacherId'] ?? "-",
        teacherName: json['teacherName'] ?? "-",
        scheduleStart: json['scheduleStart'] ?? "-",
        scheduleFinish: json['scheduleFinish'] ?? "-",
        buildingName: json['buildingName'] ?? "-",
        session: json['session'] ?? "-",
        lesson: json['lesson'] ?? "-",
        activity: json['activity'] ?? "Responsi",
        isFeedback: json['isFeedback'],
        feedbackPermission: json['feedbackPermission'],
      );
}
