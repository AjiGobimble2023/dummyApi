class Myrank {
  /// [id] merupakan variabel yang berisi No Registrasi Siswa
  String? id;

  /// [fullName] merupakan variabel yang berisi Nama Lengkap Siswa
  String? fullName;

  /// [level] merupakan variabel yang berisi idSekolahKelas Siswa
  String? level;

  /// [sort] merupakan variabel yang berisi data list ranking
  /// dan tidak ada menampilkan ranking kembar walaupun nilainya sama ex: (1,2,3,4,5)
  String? sort;

  /// [rank] merupakan variabel yang berisi data list ranking
  /// dan akan menampilkan ranking kembar jika nilainya sama ex: (1,2,2,3,4)
  String? rank;

  /// [total] merupakan variabel yang berisi total skor nilai racing siswa
  String? total;
  Myrank(
      {this.id, this.fullName, this.level, this.sort, this.rank, this.total});

  Myrank.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fullName = json['fullName'];
    level = json['level'];
    sort = json['sort'];
    rank = json['rank'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['fullName'] = fullName;
    data['level'] = level;
    data['sort'] = sort;
    data['rank'] = rank;
    data['total'] = total;
    return data;
  }
}
