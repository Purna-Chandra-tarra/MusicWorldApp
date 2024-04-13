class Audio {
  final String id;
  final String name;
  final String url;
  final List<String> downloadUrl;

  Audio({
    required this.id,
    required this.name,
    required this.url,
    required this.downloadUrl,
  });

  
  factory Audio.fromJson(Map<String, dynamic> json) {
  // Parse downloadUrl as a list of strings
  List<String> downloadUrls = [];
  if (json['downloadUrl'] is List) {
    downloadUrls = List<String>.from(json['downloadUrl']);
  } else if (json['downloadUrl'] is String) {
    downloadUrls.add(json['downloadUrl']);
  }
  
  return Audio(
    id: json['id'],
    name: json['name'],
    url: json['url'],
    downloadUrl: downloadUrls, // Corrected: Removed quotes around downloadUrls
  );
}

}
