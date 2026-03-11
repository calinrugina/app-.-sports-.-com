/// Tag model (e.g. from taxonomy or asset tags).
class Tag {
  const Tag({
    required this.id,
    required this.slug,
    this.name,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: (json['id'] as num).toInt(),
      slug: json['slug'] as String? ?? '',
      name: json['name'] as String?,
    );
  }

  final int id;
  final String slug;
  final String? name;

  Map<String, dynamic> toJson() => {'id': id, 'slug': slug, 'name': name};
}
