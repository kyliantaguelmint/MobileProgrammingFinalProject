import 'login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../database/profile.dart'; // adjust path as needed

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final ProfileService profileService = ProfileService();
  void logout(context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, 'login');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Account Information'),
              centerTitle: true,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                            FutureBuilder(
                              future: profileService.getProfileByEmail(snapshot.data!.email!), // or by UID if that's what you use
                              builder: (context, profileSnapshot) {
                                if (profileSnapshot.connectionState == ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                }
                                if (!profileSnapshot.hasData || !profileSnapshot.data!.exists) {
                                  return Text('Profile not found');
                                }

                                final profile = profileSnapshot.data!.data() as Map<String, dynamic>;
                                return Column(
                                  children: [
                                    Text('Email: ${profile['email'] ?? ''}'),
                                    Text('Name: ${profile['first'] ?? ''} ${profile['lastname'] ?? ''}'),
                                  ],
                                );
                              },
                            ),
                  OutlinedButton(
                    onPressed: () async {
                      await NotificationService.createNotification(
                        id: 1,
                        title: 'Default Notification',
                        body: 'This is the body of the notification',
                        summary: 'Small summary',
                      );
                    },
                    child: const Text('Default Notification'),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: () => logout(context),
                    child: const Text('Logout'),
                  )
                ],
              ),
            ),
          );
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}