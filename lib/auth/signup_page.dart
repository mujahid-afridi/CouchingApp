import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';
import '../pages/student_home.dart';
import '../pages/admin_dashboard.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool loading = false;

  void signup() async {
    setState(() => loading = true);

    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      // 1. Check if student is pre-registered by admin
      final querySnapshot = await _firestore
          .collection('students')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You are not registered by admin.")),
        );
        return;
      }

      final studentDoc = querySnapshot.docs.first;

      // 2. Check if student is registered and not yet signed up
      if (studentDoc['isRegistered'] == true &&
          (studentDoc['uid'] == null || studentDoc['uid'] == "")) {
        // Sign up with Firebase Auth
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final user = userCredential.user;
        if (user != null) {
          // Save uid in Firestore
          await _firestore
              .collection('students')
              .doc(studentDoc.id)
              .update({'uid': user.uid});

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Signup successful! Redirecting...")),
          );

          // Navigate to student home
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const StudentHomePage()),
          );
        }
      }
      // 3. Student already signed up
      else if (studentDoc['uid'] != null && studentDoc['uid'] != "") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account already signed up.")),
        );
      }
      // 4. Student not approved by admin
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You are not approved yet by admin.")),
        );
      }
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
      appBar: AppBar(title: const Text("Signup"), backgroundColor: Colors.green),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: signup,
              child: const Text("Signup"),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              child: const Text("Already have an account? Login"),
            ),
          ],
        ),
      ),
    );
  }
}














// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'login_page.dart';
//
// class SignupPage extends StatefulWidget {
//   const SignupPage({super.key});
//
//   @override
//   State<SignupPage> createState() => _SignupPageState();
// }
//
// class _SignupPageState extends State<SignupPage> {
//   final _auth = FirebaseAuth.instance;
//   final _firestore = FirebaseFirestore.instance;
//
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//
//   bool loading = false;
//
//   void signup() async {
//     setState(() => loading = true);
//     try {
//       final email = emailController.text.trim();
//       final password = passwordController.text.trim();
//
//       // Check if student is pre-registered by admin
//       final querySnapshot = await _firestore
//           .collection('students')
//           .where('email', isEqualTo: email)
//           .get();
//
//       if (querySnapshot.docs.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("You are not registered by admin.")),
//         );
//       } else {
//         final studentDoc = querySnapshot.docs.first;
//         if (studentDoc['isRegistered'] == true && studentDoc['uid'] == null) {
//           // Sign up with Firebase Auth
//           final userCredential = await _auth.createUserWithEmailAndPassword(
//             email: email,
//             password: password,
//           );
//
//           final user = userCredential.user;
//           if (user != null) {
//             // Save uid in Firestore
//             await _firestore
//                 .collection('students')
//                 .doc(studentDoc.id)
//                 .update({'uid': user.uid});
//
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text("Signup successful! Please login.")),
//             );
//
//             // Navigate to Login
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (_) => const LoginPage()),
//             );
//           }
//         } else if (studentDoc['uid'] != null) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Account already signed up.")),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("You are not approved yet by admin.")),
//           );
//         }
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error: ${e.toString()}")),
//       );
//     } finally {
//       setState(() => loading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Signup"), backgroundColor: Colors.green),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextField(
//               controller: emailController,
//               decoration: const InputDecoration(labelText: "Email"),
//             ),
//             const SizedBox(height: 10),
//             TextField(
//               controller: passwordController,
//               decoration: const InputDecoration(labelText: "Password"),
//               obscureText: true,
//             ),
//             const SizedBox(height: 20),
//             loading
//                 ? const CircularProgressIndicator()
//                 : ElevatedButton(
//               onPressed: signup,
//               child: const Text("Signup"),
//             ),
//             const SizedBox(height: 10),
//             TextButton(
//               onPressed: () {
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (_) => const LoginPage()),
//                 );
//               },
//               child: const Text("Already have an account? Login"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
