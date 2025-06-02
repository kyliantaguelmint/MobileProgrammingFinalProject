//import 'package:firebase/database/profile.dart';
//import 'package:firebase_auth/firebase_auth.dart';
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
      body: const Text('Profile Data'),
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