import 'package:firebase/services/profile_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../services/quote_service.dart'; // adjust path

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedScreen = 2;
  ProfileData? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final data = await fetchProfileData(user.email!);
    setState(() {
      _profile = data;
      _isLoading = false;
    });
  }

  void _onButtonTapped(int i) {
    if (i == _selectedScreen) return;
    setState(() {
      _selectedScreen = i;
    });

    if (i == 0) {
      Navigator.pushReplacementNamed(context, 'articles');
    } else if (i == 1) {
      Navigator.pushReplacementNamed(context, 'plus');
    } else if (i == 2) {
      Navigator.pushReplacementNamed(context, 'profile');
    }
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, 'login');
  }

  void _showEditDialog(BuildContext context) {
    final bioController = TextEditingController(text: _profile?.bio ?? '');
    final firstNameController = TextEditingController(text: _profile?.first ?? '');
    final lastNameController = TextEditingController(text: _profile?.lastname ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool isLoadingQuote = false;

            return AlertDialog(
              title: const Text('Edit Profile'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: firstNameController,
                      decoration: const InputDecoration(hintText: 'First name'),
                    ),
                    TextField(
                      controller: lastNameController,
                      decoration: const InputDecoration(hintText: 'Last name'),
                    ),
                    TextField(
                      controller: bioController,
                      decoration: const InputDecoration(hintText: 'Bio'),
                    ),
                    const SizedBox(height: 10),
                    isLoadingQuote
                        ? const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          )
                        : ElevatedButton.icon(
                            onPressed: () async {
                              setState(() => isLoadingQuote = true);
                              try {
                                final quote = await QuoteService().fetchRandomQuote();
                                setState(() {
                                  bioController.text = '${quote.content} — ${quote.author}';
                                });
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Erreur : ${e.toString()}')),
                                );
                              } finally {
                                setState(() => isLoadingQuote = false);
                              }
                            },
                            icon: const Icon(Icons.format_quote),
                            label: const Text("Générer une citation"),
                          ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      await ProfileService().updateProfileByEmail(user.email!, {
                        'first': firstNameController.text.trim(),
                        'lastname': lastNameController.text.trim(),
                        'bio': bioController.text.trim(),
                      });

                      await _loadProfile(); // 🔁 refresh from Firestore
                    }

                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber[100]),
        ),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _profile == null
              ? const Center(child: Text('Profile not found.'))
              : ProfileContent(profile: _profile!, onLogout: _signOut),
      bottomNavigationBar: NavigationSection(
        currentSection: _selectedScreen,
        onTap: _onButtonTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showEditDialog(context);
        },
        child: const Icon(Icons.edit),
        backgroundColor: Colors.amber[700],
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
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Article'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}

class ProfileData {
  final String email;
  final String first;
  final String lastname;
  final String bio;

  ProfileData({
    required this.email,
    required this.first,
    required this.lastname,
    required this.bio,
  });
}

Future<ProfileData?> fetchProfileData(String email) async {
  final profileService = ProfileService();
  final doc = await profileService.getProfileByEmail(email);
  if (doc != null && doc.exists) {
    final data = doc.data() as Map<String, dynamic>;
    return ProfileData(
      email: data['email'] ?? '',
      first: data['first'] ?? '',
      lastname: data['lastname'] ?? '',
      bio: data['bio'] ?? 'No bio',
    );
  }
  return null;
}

class ProfileContent extends StatelessWidget {
  final ProfileData profile;
  final VoidCallback onLogout;

  const ProfileContent({
    super.key,
    required this.profile,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(color: Colors.amber[100]),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 30),
            const CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(
                'https://mymodernmet.com/wp/wp-content/uploads/2019/09/100k-ai-faces-6.jpg'),
            ),
            const SizedBox(height: 100),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(profile.first,
                    style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                Text(profile.lastname,
                    style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            Text(profile.email,
                style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: AutoSizeText(
                profile.bio,
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 3,
                minFontSize: 12,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onLogout,
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
