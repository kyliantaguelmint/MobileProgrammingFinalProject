class Comment {
  final String id;
  final String articleId;
  final String content;

  Comment({required this.id, required this.articleId, required this.content});

  Map<String, dynamic> toMap() {
    return {
      'articleId': articleId,
      'content': content,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map, String id) {
    return Comment(
      id: id,
      articleId: map['articleId'] ?? '',
      content: map['content'] ?? '',
    );
  }
}
