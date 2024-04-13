class TrendAlbum {
  final String id;
  final String name;
  final String type;
  final String year;
  final String releaseDate;
  final String playCount;
  final String language;
  final String explicitContent;
  final String songCount;
  final String url;
  final List<Map<String, dynamic>> artists;
  final List<Map<String, dynamic>> image;

  TrendAlbum({
    required this.id,
    required this.name,
    required this.type,
    required this.year,
    required this.releaseDate,
    required this.playCount,
    required this.language,
    required this.explicitContent,
    required this.songCount,
    required this.url,
    required this.artists,
    required this.image,
  });

  factory TrendAlbum.fromJson(Map<String, dynamic> json) {
    return TrendAlbum(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      year: json['year'] ?? '',
      releaseDate: json['releaseDate'] ?? '',
      playCount: json['playCount'] ?? '',
      language: json['language'] ?? '',
      explicitContent: json['explicitContent'] ?? '',
      songCount: json['songCount'] ?? '',
      url: json['url'] ?? '',
      artists: List<Map<String, dynamic>>.from(json['artists'] ?? []),
      image: List<Map<String, dynamic>>.from(json['image'] ?? []),
    );
  }
}
