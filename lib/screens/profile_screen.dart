//import 'package:firebase/database/profile.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase/database/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

//to do : Fetching Profile data.


class ProfileScreen extends StatefulWidget {
  const ProfileScreen ({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedScreen = 1;

  void _onButtonTapped (int i) {
    if (i == _selectedScreen) return;
    setState(() {
      _selectedScreen = i;
    });

    if (i == 0) {
      Navigator.pushReplacementNamed(context, 'home');
    }
    else if (i == 1){
      // profile
      Navigator.pushReplacementNamed(context, 'profile');
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text (
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.amber[100]),
        ),
        backgroundColor: Colors.blue,
        ),
      body: ProfileContent(),
      bottomNavigationBar: NavigationSection(
        currentSection: _selectedScreen,
        onTap: _onButtonTapped),
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
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'profile'),
      ],
    );
  }
}

final user = FirebaseAuth.instance.currentUser;
final email = user?.email;

class ProfileData {
  final String email;
  final String first;
  final String lastname;

  ProfileData({
    required this.email,
    required this.first,
    required this.lastname,
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
    );
  }
  return null;
}


class ProfileContent extends StatelessWidget {
  const ProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;

    if (email == null) {
      return const Center(child: Text('Not logged in.'));
    }

    return FutureBuilder<ProfileData?>(
      future: fetchProfileData(email),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData && snapshot.data != null) {
          final profile = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Email: ${profile.email}'),
              Text('First Name: ${profile.first}'),
              Text('Last Name: ${profile.lastname}'),
            ],
          );
        } else {
          return const Center(child: Text('Profile not found.'));
        }
      },
    );
  }
}