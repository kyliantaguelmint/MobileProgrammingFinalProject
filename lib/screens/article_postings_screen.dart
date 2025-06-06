import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/article_service.dart';
import 'article_detail_page.dart';
import 'plus_screen.dart';
import 'package:firebase/database/article.dart';

class ArticlePostingsPage extends StatefulWidget {
  const ArticlePostingsPage({super.key});

  @override
  State<ArticlePostingsPage> createState() => ArticlePostingsPageState();
}

class ArticlePostingsPageState extends State<ArticlePostingsPage> {
  //const ArticlePostingsPage({super.key});
  final ArticleService _articleService = ArticleService();
  List<Article> _articles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  void _loadArticles() async {
    final articles = await _articleService.fetchLatestArticles();
    setState(() {
      _articles = articles;
      _isLoading = false;
    });
  }

  int _selectedScreen = 0;

  void _onButtonTapped(int i) {
    if (i == _selectedScreen) return;
    setState(() {
      _selectedScreen = i;
    });

    if (i == 0) {
      Navigator.pushReplacementNamed(context, 'home');
    } else if (i == 1) {
      Navigator.pushReplacementNamed(context, 'plus');
    } else if (i == 2) {
      Navigator.pushReplacementNamed(context, 'profile');
    }
  }

  final List<Map<String, String>> articles = const [
    {
      'title': 'Title goes here',
      'author': 'Myself',
      'imageUrl': 'https://via.placeholder.com/300x200.png?text=Image+1',
    },
    {
      'title': 'Title goes here',
      'author': 'Not me',
      'imageUrl': 'https://via.placeholder.com/300x200.png?text=Image+2',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFECB3), // Lys gul bakgrunn
      appBar: AppBar(title: const Text('Blog'), backgroundColor: Colors.blue),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: _articles.length,
                itemBuilder: (context, index) {
                  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
                  final article = _articles[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ArticleDetailPage(
                                article: {
                                  'title': article.title,
                                  'author': article.email ?? 'dont know',
                                  'imageUrl': article.imageUrl ?? '',
                                },
                              ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey[300],
                            child:
                                article.imageUrl == null
                                    ? const Center(child: Text('No image'))
                                    : Image.network(
                                      article.imageUrl!,
                                      fit: BoxFit.cover,
                                    ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  article.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Author: ${article.email ?? 'Unknown'}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color:
                                      article.authorId == currentUserId
                                          ? Colors.white
                                          : Colors.white24,
                                ),
                                onPressed:
                                    article.authorId == currentUserId
                                        ? () {
                                          // Naviger til redigeringsside eller vis rediger-dialog
                                        }
                                        : null,
                              ),
                              const SizedBox(height: 10),
                              IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color:
                                      article.authorId == currentUserId
                                          ? Colors.yellow
                                          : Colors.yellow[200],
                                ),
                                onPressed:
                                    article.authorId == currentUserId
                                        ? () async {
                                          await _articleService.deleteArticle(
                                            article.id,
                                          );
                                          _loadArticles();
                                        }
                                        : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

      bottomNavigationBar: NavigationSection(
        currentSection: _selectedScreen,
        onTap: _onButtonTapped,
      ),
    );
  }
}

class NavigationSection extends StatelessWidget {
  final int currentSection;
  final ValueChanged<int> onTap;

  const NavigationSection({
    super.key,
    required this.currentSection,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.blue,
      currentIndex: currentSection,
      onTap: onTap,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      selectedItemColor: Colors.amber[100],
      unselectedItemColor: Colors.white,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Article'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
