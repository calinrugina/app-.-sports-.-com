/// Category model (e.g. from taxonomy or asset categories).
class Category {
  const Category({
    required this.id,
    required this.slug,
    this.name,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
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
