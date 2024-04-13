import 'package:audioapp/models/songsmodel.dart';

class Album {
  final String type;
  final String id;
  final String name;
  final String year;
  final String playCount;
  final List<Map<String, dynamic>> image;
  final List<Map<String, dynamic>> artists;
  final List<Song> songs;


  Album({
    required this.type,
    required this.id,
    required this.name,
    required this.year,
    required this.playCount,
    required this.image,
    required this.artists,
    required this.songs,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> artistsData =
        (json['artists'] as List<dynamic>).cast<Map<String, dynamic>>();
    List<Map<String, dynamic>> songsData =
        (json['songs'] as List<dynamic>).cast<Map<String, dynamic>>(); // Parse songs data

    List<Song> songs = songsData.map((data) => Song.fromJson(data)).toList();

    return Album(
      type: json['type'],
      id: json['id'],
      name: json['name'],
      year: json['year'] ?? '',
      playCount: json['playCount'] ?? '',
      image: (json['image'] as List<dynamic>).cast<Map<String, dynamic>>(),
      artists: artistsData,
      songs: songs,
    );
  }
}
