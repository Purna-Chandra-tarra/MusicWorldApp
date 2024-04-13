class Song {
  final String id;
  final String name;
  bool isFavorite; 
  final List<Map<String, dynamic>> image;
  // final Album album;
  // final String year;
  // final String releaseDate;
  // final int duration;
  // final String label;
  // final String primaryArtists;
  // final String primaryArtistsId;
  // final String featuredArtists;
  // final String featuredArtistsId;
  // final int explicitContent;
  // final int playCount;
  // final String language;
  // final bool hasLyrics;
  // final String url;
  // final String copyright;
  final List<Map<String, dynamic>> downloadUrl;


  Song({
    required this.id,
    required this.name,
     required this.image,
     this.isFavorite = false,
    // required this.album,
    // required this.year,
    // required this.releaseDate,
    // required this.duration,
    // required this.label,
    // required this.primaryArtists,
    // required this.primaryArtistsId,
    // required this.featuredArtists,
    // required this.featuredArtistsId,
    // required this.explicitContent,
    // required this.playCount,
    // required this.language,
    // required this.hasLyrics,
    // required this.url,
    // required this.copyright,
    required this.downloadUrl,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'downloadUrl': downloadUrl,
      'isFavorite': isFavorite,
    };
  }
  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'],
      name: json['name'],
      
      image: (json['image'] as List<dynamic>).cast<Map<String, dynamic>>(),
      // album: Album.fromJson(json['album']),
      // year: json['year'],
      // releaseDate: json['releaseDate'],
      // duration: json['duration'],
      // label: json['label'],
      // primaryArtists: json['primaryArtists'],
      // primaryArtistsId: json['primaryArtistsId'],
      // featuredArtists: json['featuredArtists'],
      // featuredArtistsId: json['featuredArtistsId'],
      // explicitContent: json['explicitContent'],
      // playCount: json['playCount'],
      // language: json['language'],
      // hasLyrics: json['hasLyrics'],
      //url: json['url'],
      // copyright: json['copyright'],
       //downloadUrl: (json['downloadUrl'] as List<dynamic>).cast<Map<String, dynamic>>(),
       downloadUrl: (json['downloadUrl'] != null)
        ? List<Map<String, dynamic>>.from(json['downloadUrl'])
        : [],
    );
  }

  Object? toJson() {}
}
