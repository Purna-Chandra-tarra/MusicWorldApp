
class Playlist {
  final String id;
  final String userId;
  final String title;
  final String subtitle;
  final String type;
  final List<Map<String, dynamic>> image;
  final String url;
  final String songCount;
  final String firstname;
  final String followerCount;
  final String lastUpdated;
  final String explicitContent;

  Playlist({
    required this.id,
    required this.userId,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.image,
    required this.url,
    required this.songCount,
    required this.firstname,
    required this.followerCount,
    required this.lastUpdated,
    required this.explicitContent,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      subtitle: json['subtitle'],
      type: json['type'],
      image: (json['image'] as List<dynamic>).cast<Map<String, dynamic>>(),
      url: json['url'],
      songCount: json['songCount'],
      firstname: json['firstname'],
      followerCount: json['followerCount'],
      lastUpdated: json['lastUpdated'],
      explicitContent: json['explicitContent'],
    );
  }
}

