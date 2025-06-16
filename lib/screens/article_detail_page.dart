import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/services/comment_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase/database/article.dart';

class ArticleDetailPage extends StatelessWidget {
  final String articleId;
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;

  ArticleDetailPage({super.key, required this.articleId});

  @override
  Widget build(BuildContext context) {
    final articleRef = FirebaseFirestore.instance.collection('articles').doc(articleId);
    final commentsRef = FirebaseFirestore.instance
        .collection('comments')
        .where('articleId', isEqualTo: articleId)
        .orderBy('createdAt', descending: false)
        ;

    return Scaffold(
      appBar: AppBar(title: const Text('Article detail')),
      body: FutureBuilder<DocumentSnapshot>(
        future: articleRef.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("Article not found"));
          }

          final article = snapshot.data!.data() as Map<String, dynamic>;
          final articleAuthorId = article['authorId'];
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: (article['imageUrl'] != null && article['imageUrl'].toString().isNotEmpty)
                      ? Image.network(article['imageUrl'], fit: BoxFit.cover)
                      : const Center(child: Text('Pas d\'image')),
                ),
                const SizedBox(height: 10),
                Text(
                  'Auteur: ${article['email'] ?? 'Inconnu'}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  article['content'] ?? '',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                const Text('Comments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                StreamBuilder<QuerySnapshot>(
                  stream: commentsRef.snapshots(),
                  builder: (context, commentSnapshot) {
                    if (commentSnapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    final comments = commentSnapshot.data?.docs ?? [];

                    if (comments.isEmpty) {
                      return const Text("No comments");
                    }
                    final commentService = CommentService();
                    return Column(
                      children: 
                      comments.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return ListTile(
                          title: Text(data['content'] ?? ''),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['email'] ?? '',
                                style: const TextStyle(fontSize: 13, color: Colors.black54),
                                ),
                              Text(
                                (data['createdAt'] as Timestamp?)?.toDate().toString() ?? 'Unknown date',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          trailing: (currentUserId == articleAuthorId)
                              ? IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.yellow),
                                  onPressed: () async {
                                    await commentService.deleteComment(doc.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Comment deleted')),
                                    );
                                  },
                                )
                              : null,
                        );
                      }).toList(),
                    );
                  },
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
