class FeedComments {
  /// [feedId] merupakan variabel yang berisi id Feed dari komentar tersebut
  final String feedId;

  /// [creatorId] merupakan variabel yang berisi No Registrasi siswa pembuat komentar
  final String creatorId;

  /// [creatorName] merupakan variabel yang berisi Nama siswa pembuat komentar
  final String creatorName;

  /// [creatorRole] merupakan variabel yang berisi role siswa pembuat komentar
  final String creatorRole;

  /// [content] merupakan variabel yang berisi komentar siswa
  final String content;

  /// [isLike] merupakan variabel state like siswa
  bool isLike;

  /// [totalLike] merupakan variabel yang berisi total like dari komentar tersebut
  int totalLike;

  /// [date] merupkan variabel yang berisi tanggal komentar dibuat
  final String date;

  /// [parentId] merupakan variabel yang berisi feedId dari komentar
  /// siswa lainya
  String? parentId;

  FeedComments({
    required this.feedId,
    required this.creatorId,
    required this.creatorName,
    required this.creatorRole,
    required this.content,
    required this.isLike,
    required this.totalLike,
    required this.date,
    this.parentId,
  });

  factory FeedComments.fromJson(Map<String, dynamic> json) {
    return FeedComments(
      feedId: json['feedId'].toString(),
      creatorId: json['creatorId'],
      creatorName: json['fullname'] ?? "Nama Tidak Ditemukan",
      creatorRole: json['role'] ?? "SISWA",
      content: json['content'],
      isLike: int.parse(json['isLike'].toString()) == 0 ? false : true,
      totalLike: int.parse(json['totalLike'].toString()),
      date: json['tanggal'],
      parentId: json['parentId'],
    );
  }
}
