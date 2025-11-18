import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'auth/login_page.dart';
import 'auth/signup_page.dart';
import 'pages/student_home.dart';
import 'pages/admin_dashboard.dart';
import 'pages/welcome_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyA54cwlo4ZT-jrw7nT10o5GAimT5MHT1M0",
      appId: "1:129483753104:android:262f1299db6b588169ba15",
      messagingSenderId: "129483753104",
      projectId: "courses-project-f1f48",
      storageBucket: "courses-project-f1f48.firebasestorage.app",
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Coaching App",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: const LandingPage(),
    );
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  Future<Widget> _determineHome(User user) async {
    final firestore = FirebaseFirestore.instance;

    // Check if admin
    final adminQuery = await firestore
        .collection('admins')
        .where("email", isEqualTo: user.email)
        .get();

    if (adminQuery.docs.isNotEmpty) {
      return const AdminDashboard();
    }

    // Check if student
    final studentQuery = await firestore
        .collection('students')
        .where("email", isEqualTo: user.email)
        .get();

    if (studentQuery.docs.isNotEmpty &&
        (studentQuery.docs.first['isRegistered'] == true)) {
      return const StudentHomePage();
    }

    // Otherwise logout
    await FirebaseAuth.instance.signOut();
    return const WelcomePage();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return FutureBuilder<Widget>(
            future: _determineHome(snapshot.data!),
            builder: (context, roleSnap) {
              if (roleSnap.connectionState == ConnectionState.done) {
                return roleSnap.data!;
              }
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            },
          );
        }

        // If user not logged in, show Welcome Page
        return const WelcomePage();
      },
    );
  }
}














