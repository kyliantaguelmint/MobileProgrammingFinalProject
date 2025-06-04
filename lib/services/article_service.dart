import 'package:firebase/database/article.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class ArticleService {
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /* Future<void> addArticleFromInput({
    required String title,
    required String content,
    File? imageFile,
  }) async {
    String? imageUrl;

    if (imageFile != null) {

      print('Image path: ${imageFile.path}');
      if (!imageFile.existsSync()) {
        print('ERROR: Image file does not exist!');
        return; 
      }

      final ref = _storage
          .ref()
          .child('article_images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      final uploadTask = ref.putFile(imageFile);

      final snapshot = await uploadTask.whenComplete(() {});
      final imageUrl = await snapshot.ref.getDownloadURL();

    }

    // Lagre artikkelen i Firestore med eventuell bilde-URL
    await _firestore.collection('articles').add({
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  } */
  Future<void> addArticleFromInput({
    required String title,
    required String content,
    File? imageFile,
  }) async {
    String? imageUrl;

    if (imageFile != null) {
      if (!imageFile.existsSync()) {
        print('Image file does not exist at path: ${imageFile.path}');
        return;
      }

      final ref = _storage
          .ref()
          .child('article_images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      final uploadTask = ref.putFile(imageFile);

      try {
        final snapshot = await uploadTask.whenComplete(() {});
        imageUrl = await snapshot.ref.getDownloadURL();
      } catch (e) {
        print('Error uploading image: $e');
        return; // Håndter feilen på en god måte
      }
    }

    await _firestore.collection('articles').add({
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Article>> fetchLatestArticles() async {
    final querySnapshot =
        await FirebaseFirestore.instance
            .collection('articles')
            .orderBy('createdAt', descending: true)
            .limit(10)
            .get();

    return querySnapshot.docs
        .map((doc) => Article.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> updateArticle(Article article) async {
    final docRef = FirebaseFirestore.instance
        .collection('articles')
        .doc(article.id);
    await docRef.update(article.toMap());
  }

  Future<void> deleteArticle(String articleId) async {
    final docRef = FirebaseFirestore.instance
        .collection('articles')
        .doc(articleId);
    await docRef.delete();
  }
}
