import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase/services/article_service.dart';
import 'package:image_picker/image_picker.dart';

class PlusScreen extends StatefulWidget {
  const PlusScreen({super.key});

  @override
  State<PlusScreen> createState() => _PlusScreenState();
}

class _PlusScreenState extends State<PlusScreen> {
  int _selectedScreen = 1;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final ArticleService _articleService = ArticleService();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Articles',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.amber[100],
          ),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      backgroundColor: Colors.amber[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Name of the article ....',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  //todo
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text(
                  'Choose image',
                  style: TextStyle(fontSize: 18, color: Colors.amber),
                ),
              ),
              if (_selectedImage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Image.file(
                    _selectedImage!,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 16),
              Container(
                height: 200,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  expands: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Text Area',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  // TODO: implement create article logic
                  final title = _titleController.text.trim();
                  final content = _contentController.text.trim();

                  if (title.isEmpty || content.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fyll inn både tittel og innhold'),
                      ),
                    );
                    return;
                  }

                  try {
                    await _articleService.addArticleFromInput(
                      title: title,
                      content: content,
                      imageFile: _selectedImage,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ Artikkel opprettet!')),
                    );

                    _titleController.clear();
                    _contentController.clear();
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('❌ Feil: $e')));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text(
                  'Create',
                  style: TextStyle(fontSize: 18, color: Colors.amber),
                ),
              ),
            ],
          ),
        ),
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
