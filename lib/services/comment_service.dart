import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../database/comment.dart'; // Assure-toi que ce chemin est correct

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final logger = Logger();

  Future<void> addComment({
    required String articleId,
    required String content,
  }) async {
    logger.i("Ajout d'un commentaire pour l'article : $articleId");

    await _firestore.collection('comments').add({
      'articleId': articleId,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Comment>> fetchCommentsForArticle(String articleId) async {
    final querySnapshot = await _firestore
        .collection('comments')
        .where('articleId', isEqualTo: articleId)
        .orderBy('createdAt', descending: true)
        .get();

    logger.i("Nombre de commentaires récupérés pour $articleId : ${querySnapshot.docs.length}");

    return querySnapshot.docs
        .map((doc) => Comment.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> updateComment(Comment comment) async {
    final docRef = _firestore.collection('comments').doc(comment.id);
    await docRef.update(comment.toMap());
    logger.i("Commentaire mis à jour : ${comment.id}");
  }

  Future<void> deleteComment(String commentId) async {
    final docRef = _firestore.collection('comments').doc(commentId);
    await docRef.delete();
    logger.i("Commentaire supprimé : $commentId");
  }
}
