import '../entity/berita.dart';

class BeritaModel extends Berita {
  const BeritaModel(
      {required String id,
      required String title,
      required String description,
      required String image,
      required String date,
      required String url,
      required String summary,
      required String viewer})
      : super(
            id: id,
            title: title,
            description: description,
            image: image,
            date: date,
            url: url,
            summary: summary,
            viewer: viewer);

  factory BeritaModel.fromJson(Map<String, dynamic> json) => BeritaModel(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        image: json['image'],
        date: json['date'],
        url: json['url'],
        summary: json['summary'],
        viewer: json['jmlhviewer'],
      );
}
