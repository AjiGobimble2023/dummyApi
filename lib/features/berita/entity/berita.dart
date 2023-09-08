import 'package:equatable/equatable.dart';

class Berita extends Equatable {
  final String id;
  final String title;
  final String description;
  final String image;
  final String date;
  final String url;
  final String summary;
  final String viewer;

  const Berita({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.date,
    required this.url,
    required this.summary,
    required this.viewer,
  });

  @override
  List<Object> get props =>
      [id, title, description, image, date, url, summary, viewer];
}
