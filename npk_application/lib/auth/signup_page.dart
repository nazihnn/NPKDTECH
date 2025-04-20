import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    String? errorMessage;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Sign Up", style: TextStyle(fontSize: 28)),
            TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email')),
            TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true),
            if (errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.createUserWithEmailAndPassword(
                    email: emailController.text.trim(),
                    password: passwordController.text.trim(),
                  );
                  Navigator.pop(context); // Go back to login page
                } on FirebaseAuthException catch (e) {
                  switch (e.code) {
                    case 'weak-password':
                      errorMessage =
                          'Password should be at least 6 characters.';
                      break;
                    case 'email-already-in-use':
                      errorMessage = 'This email is already in use.';
                      break;
                    default:
                      errorMessage = 'Signup failed: ${e.message}';
                  }
                } catch (e) {
                  errorMessage = 'An unexpected error occurred: $e';
                }
                // Trigger a rebuild to show the error message
                (context as Element).markNeedsBuild();
              },
              child: const Text("Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
