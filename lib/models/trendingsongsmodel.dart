class TrendSong {
  final String id;
  final String name;
  final String type;
  final Map<String, dynamic> album;
  final String year;
  final String releaseDate;
  final String duration;
  final String label;
  final List<Map<String, dynamic>> primaryArtists;
  final List<Map<String, dynamic>> featuredArtists;
  final String explicitContent;
  final String playCount;
  final String language;
  final String url;
  final List<Map<String, dynamic>> image;
  final List<Map<String, dynamic>> downloadUrl;

  TrendSong({
    required this.id,
    required this.name,
    required this.type,
    required this.album,
    required this.year,
    required this.releaseDate,
    required this.duration,
    required this.label,
    required this.primaryArtists,
    required this.featuredArtists,
    required this.explicitContent,
    required this.playCount,
    required this.language,
    required this.url,
    required this.image,
    required this.downloadUrl,
  });

  factory TrendSong.fromJson(Map<String, dynamic> json) {
    return TrendSong(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      album: json['album'] ?? {},
      year: json['year'] ?? '',
      releaseDate: json['releaseDate'] ?? '',
      duration: json['duration'] ?? '',
      label: json['label'] ?? '',
      primaryArtists: List<Map<String, dynamic>>.from(json['primaryArtists'] ?? []),
      featuredArtists: List<Map<String, dynamic>>.from(json['featuredArtists'] ?? []),
      explicitContent: json['explicitContent'] ?? '',
      playCount: json['playCount'] ?? '',
      language: json['language'] ?? '',
      url: json['url'] ?? '',
      image: List<Map<String, dynamic>>.from(json['image'] ?? []),
       downloadUrl: (json['downloadUrl'] != null)
        ? List<Map<String, dynamic>>.from(json['downloadUrl'])
        : [],
    );
    
  }

  String getProperty(String propertyName) {
    switch (propertyName) {
      case 'id':
        return id;
      case 'name':
        return name;
      case 'type':
        return type;
      case 'album':
        return album.toString(); // Convert to String for demonstration
      case 'year':
        return year;
      case 'releaseDate':
        return releaseDate;
      case 'duration':
        return duration;
      case 'label':
        return label;
      case 'explicitContent':
        return explicitContent;
      case 'playCount':
        return playCount;
      case 'language':
        return language;
      case 'url':
        return url;
      default:
        throw ArgumentError('Invalid property name: $propertyName');
    }
  }
}

