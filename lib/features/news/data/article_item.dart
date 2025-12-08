class ArticleItem {
  final String id;
  final String title;
  final String description;
  final String? mediaUrl;
  final String publishDate;
  final String? sportName;

  ArticleItem({
    required this.id,
    required this.title,
    required this.description,
    this.mediaUrl,
    required this.publishDate,
    this.sportName,
  });

  factory ArticleItem.fromJson(Map<String, dynamic> json) {
    return ArticleItem(
      id: json['@id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      mediaUrl: json['media_url']?.toString(),
      publishDate: json['publishedDate']?.toString() ?? '',
    );
  }
}
