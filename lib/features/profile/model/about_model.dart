class AboutModel {
  final String judul;
  final List<String> deskripsi;
  final List<AboutModel> subData;

  const AboutModel({
    required this.judul,
    required this.deskripsi,
    required this.subData,
  });

  factory AboutModel.fromJson(Map<String, dynamic> json) {
    List<AboutModel> visiMisi = [];

    if (json['visiMisi'] != null) {
      for (var data in json['visiMisi']) {
        visiMisi.add(AboutModel.fromJson(data));
      }
    }

    return AboutModel(
        judul: json['title'],
        deskripsi: (json['description'] != null)
            ? json['description'].cast<String>()
            : const [],
        subData: visiMisi);
  }
}
