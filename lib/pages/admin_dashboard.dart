import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controllers for student registration
  final TextEditingController studentEmailController = TextEditingController();
  final TextEditingController studentNameController = TextEditingController();

  // Controllers for adding course
  final TextEditingController courseTitleController = TextEditingController();
  final TextEditingController courseDescriptionController = TextEditingController();
  final TextEditingController courseThumbnailController = TextEditingController();
  final TextEditingController courseVideoController = TextEditingController();

  bool loadingStudent = false;
  bool loadingCourse = false;

  /// Register a new student
  void registerStudent() async {
    if (studentEmailController.text.trim().isEmpty ||
        studentNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Fill all fields")));
      return;
    }

    setState(() => loadingStudent = true);

    try {
      await _firestore.collection('students').add({
        'name': studentNameController.text.trim(),
        'email': studentEmailController.text.trim(),
        'isRegistered': true,
        'uid': "", // filled after student signs up
      });

      studentNameController.clear();
      studentEmailController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Student registered successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    setState(() => loadingStudent = false);
  }

  /// Add new course
  void addCourse() async {
    if (courseTitleController.text.isEmpty ||
        courseDescriptionController.text.isEmpty ||
        courseThumbnailController.text.isEmpty ||
        courseVideoController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Fill all fields")));
      return;
    }

    setState(() => loadingCourse = true);

    try {
      await _firestore.collection('courses').add({
        'title': courseTitleController.text.trim(),
        'description': courseDescriptionController.text.trim(),
        'thumbnailUrl': courseThumbnailController.text.trim(),
        'videoUrl': courseVideoController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      courseTitleController.clear();
      courseDescriptionController.clear();
      courseThumbnailController.clear();
      courseVideoController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Course added successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    setState(() => loadingCourse = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Register Student
            const Text("Register New Student",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            TextField(
              controller: studentNameController,
              decoration: const InputDecoration(hintText: "Student Name"),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: studentEmailController,
              decoration: const InputDecoration(hintText: "Student Email"),
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: loadingStudent ? null : registerStudent,
              child: loadingStudent
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Register Student"),
            ),

            const Divider(height: 40, thickness: 2),

            /// Add Course
            const Text("Add New Course",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            TextField(
              controller: courseTitleController,
              decoration: const InputDecoration(hintText: "Course Title"),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: courseDescriptionController,
              decoration: const InputDecoration(hintText: "Course Description"),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: courseThumbnailController,
              decoration: const InputDecoration(hintText: "Thumbnail Image URL"),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: courseVideoController,
              decoration: const InputDecoration(hintText: "Video URL"),
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: loadingCourse ? null : addCourse,
              child: loadingCourse
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Add Course"),
            ),

            const Divider(height: 40, thickness: 2),

            const Text("All Courses",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('courses')
                  .orderBy("createdAt", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final courses = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final course = courses[index];

                    return ListTile(
                      leading: Image.network(
                        course['thumbnailUrl'],
                        width: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                        const Icon(Icons.image_not_supported),
                      ),
                      title: Text(course['title']),
                      subtitle: Text(course['description']),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
