import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/profile_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.amber[100],
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: const HomeContent(),
      backgroundColor: Colors.amber[100],
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
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Article'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;

    if (email == null) {
      return const Center(child: Text('Not logged in.'));
    }

    final profileService = ProfileService();

    return FutureBuilder(
      future: profileService.getProfileByEmail(email),
      builder: (context, profileSnapshot) {
        if (profileSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!profileSnapshot.hasData || !profileSnapshot.data!.exists) {
          return const Center(child: Text('Profile not found.'));
        }

        final profile = profileSnapshot.data!.data() as Map<String, dynamic>;

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [],
          ),
        );
      },
    );
  }
}
