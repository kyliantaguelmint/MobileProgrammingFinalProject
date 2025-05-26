import 'package:firebase/databases/database_helper.dart';
import 'package:firebase/models/articles.dart';

class ArticlesCrud {

  Future<Articles> createArticles(Articles article) async {
    final db = await AppDatabase.instance.database;
    final id = await db.insert(tableName, article.toJson());
    return article.copyWith(id: id);
  }

  Future<List<Articles?>> readAllArticles() async {
    final db = await AppDatabase.instance.database;
    final result = await db.query(tableName, orderBy: "$lastEditField DESC");
    return result.map((json) => Articles.fromJson(json)).toList();
  }

  Future<int> updateArticle(Articles article) async {
    final db = await AppDatabase.instance.database;
    return await db.update(tableName, article.toJson(), where: '$idField = ?', whereArgs: [article.id],
    );
  }

  Future<int> deleteArticle(int id) async {
    final db = await AppDatabase.instance.database;
    return await db.delete(
      tableName,
      where: '$idField = ?',
      whereArgs: [id],
    );
  }

}