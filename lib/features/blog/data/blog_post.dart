class BlogPost {
  final String id;
  final String title;
  final String description;
  final String? image;
  final DateTime? createdAt;
  final String? authorName;

  BlogPost({
    required this.id,
    required this.title,
    required this.description,
    this.image,
    this.createdAt,
    this.authorName,
  });

  factory BlogPost.fromJson(Map<String, dynamic> json) {
    final user = json['userId'];
    String? author;
    if (user is Map<String, dynamic>) {
      author = user['full_name'] ?? user['username'];
    }
    return BlogPost(
      id: json['_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      image: json['image'] as String?,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      authorName: author,
    );
  }
}
