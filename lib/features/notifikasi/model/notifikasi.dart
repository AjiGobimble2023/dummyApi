class Notification {
  final String notifId;
  final String sourceId;
  final String sourceName;
  final String classLevelId;
  final String className;
  final String role;
  final String notifType;
  final bool isSeen;
  final String date;

  Notification({
    required this.notifId,
    required this.sourceId,
    required this.sourceName,
    required this.classLevelId,
    required this.className,
    required this.role,
    required this.notifType,
    required this.isSeen,
    required this.date,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      notifId: json['notifId'],
      sourceId: json['sourceId'],
      sourceName: json['sourceName'],
      classLevelId: json['classlevelid'] ?? "-",
      className: json['className'] ?? "-",
      role: json['role'] ?? "-",
      notifType: json['notifType'],
      isSeen: json["isSeen"],
      date: json["date"],
    );
  }
}
