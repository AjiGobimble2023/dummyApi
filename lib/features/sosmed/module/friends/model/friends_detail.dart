class FriendsDetail {
  /// [friendId] merupakan variabel yang berisi No Registrasi
  final String friendId;

  /// [fullName] merupakan variabel yang berisi nama lengkap
  final String fullName;

  /// [classLevelId] merupakan variabel yang berisi idSekolahKelas Siswa
  final String classLevelId;

  /// [classLevel] merupakan variabel yang berisi tingkat kelas siswa
  final String classLevel;

  /// [city] merupakan variabel yang berisi nama kota siswa tersebut
  final String city;

  /// [school] merupakan variabel yang berisi nama sekolah deri siswa tersebut
  final String school;

  /// [score] merupakan variabel yang berisi score buku sakti dari siswa tersebut
  final int score;

  /// [status] merupakan variabel yang berisi status pertemanan user dengan siswa tersebut
  final String status;

  FriendsDetail({
    required this.friendId,
    required this.fullName,
    required this.classLevelId,
    required this.classLevel,
    required this.school,
    required this.city,
    required this.score,
    required this.status,
  });

  factory FriendsDetail.fromJson(json) => FriendsDetail(
        friendId: json['idTeman'],
        fullName: json['fullname'] ?? "Tidak ada Nama",
        classLevelId: json['classlevelid'].toString(),
        classLevel: json['class'] ?? "Tidak ada kelas",
        city: json['city'] ?? "Tidak ada kota",
        school: json['school'] ?? "Tidak ada sekolah",
        score: json['score'] != null ? int.parse(json['score']) : 0,
        status: json['status'] ?? "approved",
      );
}
