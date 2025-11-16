import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../pages/admin_dashboard.dart';
import '../pages/student_home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool loading = false;

  void login() async {
    setState(() => loading = true);

    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      // Sign in with Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user != null) {
        // 1) Check if the user is an Admin by email (admins collection)
        final adminQuery = await _firestore
            .collection('admins')
            .where('email', isEqualTo: email)
            .get();

        if (adminQuery.docs.isNotEmpty) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboard()),
          );
          return;
        }

        // 2) Check if user is a student by 'uid' field (since your students docs store uid as field)
        final studentQuery = await _firestore
            .collection('students')
            .where('uid', isEqualTo: user.uid)
            .get();

        if (studentQuery.docs.isNotEmpty) {
          final studentDoc = studentQuery.docs.first;
          // check the field you use when admin registers students
          if ((studentDoc.data()['isRegistered'] ?? false) == true) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const StudentHomePage()),
            );
            return;
          } else {
            // not registered/approved yet
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("You are not approved/registered by admin.")),
            );
            await _auth.signOut();
            return;
          }
        }

        // 3) Neither admin nor student
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Your account is not registered in the system.")),
        );
        await _auth.signOut();
      }
    } on FirebaseAuthException catch (e) {
      String message = "Login failed";
      if (e.code == 'user-not-found') message = "No user found with this email";
      if (e.code == 'wrong-password') message = "Incorrect password";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: login,
                child: const Text("Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
