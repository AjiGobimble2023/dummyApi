class Friends {
  final String friendId;
  final String fullName;
  final String classLevelId;
  final String classLevel;
  final String className;
  final String role;
  final String score;
  final String status;

  Friends({
    required this.friendId,
    required this.fullName,
    required this.classLevelId,
    required this.classLevel,
    required this.className,
    required this.role,
    required this.score,
    required this.status,
  });

  factory Friends.fromJson(json) => Friends(
        friendId: json['idTeman'],
        fullName: json['fullname'] ?? "Tidak ada Nama",
        classLevelId: json['classlevelid'].toString(),
        classLevel: json['class'] ?? "Tidak ada kelas",
        className: json['className'] ?? "-",
        role: json['role'] ?? "SISWA",
        score: json['ctotal'] ?? "0",
        status: json['status'],
      );
}
