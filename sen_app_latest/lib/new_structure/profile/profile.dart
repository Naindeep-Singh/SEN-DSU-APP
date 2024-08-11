import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:sen_app_latest/new_structure/login/login.dart';

class ProfilePage extends StatelessWidget {
  final String userType; // Can be "Teacher" or "Student"
  final String username;

  const ProfilePage({Key? key, required this.userType, required this.username})
      : super(key: key);

  Future<void> _signOut(BuildContext context) async {
    try {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Delete from Firestore
        final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: username)
            .where('type', isEqualTo: userType.toLowerCase())
            .get();

        for (var doc in querySnapshot.docs) {
          await doc.reference.delete();
        }

        // Delete from Firebase Auth
        await user.delete();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } catch (e) {
      print("Error deleting account: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting account: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          "$userType Profile",
          style: const TextStyle(
            color: Colors.teal,
            fontSize: 24, // Slightly reduced font size
            fontWeight: FontWeight.bold,
            fontFamily: 'NothingTechFont', // Use the custom font
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.teal),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0), // Adjusted padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, // Move content slightly higher
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Lottie.network(
                'https://lottie.host/4b04c32e-e75f-49b9-8d25-1621db551bd1/QQ3HFlHOtJ.json',
                height: 150, // Adjust the height to fit the profile image
                width: 150,
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color.fromARGB(255, 50, 50, 50), Color(0xFF333333)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.7),
                      spreadRadius: 4,
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20), // Reduced padding to make it smaller
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50, // Reduced size of the avatar
                      backgroundImage: user?.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : null,
                      child: user?.photoURL == null
                          ? const Icon(Icons.person, size: 50, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(height: 20), // Adjusted spacing
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: username.substring(0, 1), // First letter
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 24, // Slightly reduced font size
                              fontWeight: FontWeight.bold,
                              fontFamily: 'NothingTechFont', // Use the custom font
                            ),
                          ),
                          TextSpan(
                            text: username.substring(1), // Rest of the letters
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24, // Slightly reduced font size
                              fontWeight: FontWeight.bold,
                              fontFamily: 'NothingTechFont', // Use the custom font
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10), // Adjusted spacing
                    if (user != null && user.email != null)
                      Text(
                        "Email: ${user.email}",
                        style: const TextStyle(
                          fontSize: 16, // Reduced font size for email
                          color: Colors.grey,
                          fontFamily: 'NothingTechFont', // Use the custom font
                        ),
                      ),
                    const SizedBox(height: 10), // Adjusted spacing
                    Text(
                      "Role: $userType",
                      style: const TextStyle(
                        fontSize: 16, // Reduced font size for role
                        color: Colors.white,
                        fontFamily: 'NothingTechFont', // Use the custom font
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _signOut(context),
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text("Sign Out", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF444444), // Darker shade for the button
                        padding: const EdgeInsets.symmetric(vertical: 15), // Reduced padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        elevation: 5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _deleteAccount(context),
                      icon: const Icon(Icons.delete, color: Colors.white),
                      label: const Text("Delete Account", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF880000), // Dark red for delete button
                        padding: const EdgeInsets.symmetric(vertical: 15), // Reduced padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        elevation: 5,
                      ),
                    ),
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
