class Feed {
  /// [feedId] merupakan variabel yang berisi id feed dari postingan tersebut
  final String? feedId;

  /// [creatorId] merupakan variabel yang berisi No Registrasi Siswa Pembuat Feed
  final String? creatorId;

  /// [creatorName] merupakan variabel yang berisi Nama Siswa Pembuat Feed
  final String? creatorName;

  /// [creatorRole] merupakan variabel yang berisi Role Siswa Pembuat Feed
  final String? creatorRole;

  /// [image] merupakan variabel yang berisi url image feed tersebut
  final String? image;

  /// [content] merupakan variabel yang berisi caption dari feed tersebut
  final String? content;

  /// [status] merupakan variabel yang berisi type jenis penayangan feed (publik/private)
  final String? status;

  /// [isLike] merupakan variabel yang berisi state like dari siswa
  bool? isLike;

  /// [totalLike] merupakan variabel yang berisi total like dari feed tersebut
  int? totalLike;

  /// [date] merupakan variabel yang berisi tanggal feed tersebut dibuat
  final String? date;

  Feed({
    this.feedId,
    this.creatorId,
    this.creatorName,
    this.creatorRole,
    this.image,
    this.content,
    this.isLike,
    this.totalLike,
    this.date,
    this.status,
  });

  factory Feed.fromJson(Map<String, dynamic> json) {
    return Feed(
      feedId: json['feedId'].toString(),
      creatorId: json['creatorId'] ?? '',
      creatorName: json['fullname'] ?? "Nama Tidak Ditemukan",
      creatorRole: json['role'] ?? "SISWA",
      image: json['image'] ?? "",
      content: json['content'] ?? '',
      isLike: int.parse((json['isLike'] ?? 0).toString()) == 0 ? false : true,
      totalLike: int.parse((json['totalLike'] ?? 0).toString()),
      date: json['tanggal'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
