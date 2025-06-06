import 'package:cloud_firestore/cloud_firestore.dart';

class Article {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String? email;
  final Timestamp createdAt;
  final List<String> likes;
  final String? imageUrl; // <-- nytt valgfritt felt for bilde-URL

  Article({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.email,
    required this.createdAt,
    required this.likes,
    this.imageUrl, // valgfritt
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'authorId': authorId,
      'createdAt': createdAt,
      'likes': likes,
      if (imageUrl != null) 'imageUrl': imageUrl, // legg til hvis ikke null
    };
  }

  factory Article.fromMap(Map<String, dynamic> data, String id) {
    try {
      return Article(
        id: id,
        title: data['title'] as String? ?? 'No title',
        content: data['content'] as String? ?? '',
        authorId: data['authorId'] as String? ?? 'Unknown',
        createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
        email: data['email'] as String? ?? 'Unknown email',
        likes: List<String>.from(data['likes'] ?? []),
        imageUrl: data['imageUrl'] as String?,
      );
    } catch (e) {
      print('Feil i fromMap for dokument $id: $e');
      rethrow;
    }
  }
}
