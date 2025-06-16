import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String articleId;
  final String content;
  final Timestamp createdAt;

  Comment({required this.id, required this.articleId, required this.content, required this.createdAt});

  Map<String, dynamic> toMap() {
    return {
      'articleId': articleId,
      'content': content,
      'createdAt': createdAt,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map, String id) {
    return Comment(
      id: id,
      articleId: map['articleId'] ?? '',
      content: map['content'] ?? '',
      createdAt: map['createdAt'] ?? '',
    );
  }
}
