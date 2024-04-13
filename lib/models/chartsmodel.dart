class Chart {
  final String id;
  final String title;
  final String subtitle;
  final String type;
  final List<Map<String, dynamic>> image;
  final String url;
  final String firstname;
  final String explicitContent;
  final String language;

  Chart({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.image,
    required this.url,
    required this.firstname,
    required this.explicitContent,
    required this.language,
  });

  factory Chart.fromJson(Map<String, dynamic> json) {
  return Chart(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    subtitle: json['subtitle'],
    type: json['type'],
    image: List<Map<String, dynamic>>.from(json['image'] ?? []),
    url: json['url'] ?? '',
    firstname: json['firstname'],
    explicitContent: json['explicitContent'],
    language: json['language'],
  );
}

}
