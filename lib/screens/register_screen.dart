import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../database/profile.dart'; // adjust the path as needed

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _bioController = TextEditingController();
  bool _isLoading = false;
  String _errorCode = "";

  void navigateLogin() {
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, 'login');
  }

  void navigateHome() {
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, 'home');
  }

  void register() async {
    setState(() {
      _isLoading = true;
      _errorCode = "";
    });

    try {
      // Create the Firebase Auth user
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Create Firestore profile for the user
      await ProfileService().createProfile(
        email: _emailController.text.trim(),
        first: _firstNameController.text.trim(),
        lastname: _lastNameController.text.trim(),
        bio: _bioController.text.trim(),
      );

      navigateLogin();
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorCode = e.code;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ListView(
            children: [
              const SizedBox(height: 48),
              Icon(Icons.lock_outline, size: 100, color: Colors.blue[200]),
              const SizedBox(height: 48),
              TextField(
                controller: _firstNameController,
                decoration: const InputDecoration(label: Text('First name')),
              ),
              TextField(
                controller: _lastNameController,
                decoration: const InputDecoration(label: Text('Last name')),
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(label: Text('Email')),
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(label: Text('Password')),
              ),
              TextField(
                controller: _bioController,
                obscureText: false,
                decoration: const InputDecoration(label: Text('Bio')),
              ),
              const SizedBox(height: 24),
              _errorCode != ""
                  ? Column(
                    children: [Text(_errorCode), const SizedBox(height: 24)],
                  )
                  : const SizedBox(height: 0),
              OutlinedButton(
                onPressed: register,
                child:
                    _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Register'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account?'),
                  TextButton(
                    onPressed: navigateLogin,
                    child: const Text('Login'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
