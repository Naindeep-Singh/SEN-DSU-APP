import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:sen_app_latest/new_structure/sen_ui/sen_ui.dart'; // Import SENPage

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool isSignUp = false;
  bool isHovering = false;
  bool isTeacher = true;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String errorMessage = '';

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: _usernameController.text)
          .where('password', isEqualTo: _passwordController.text)
          .where('type', isEqualTo: isTeacher ? "teacher" : "student")
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userData = querySnapshot.docs.first.data() as Map<String, dynamic>;
        final String username = userData['username'];
        final String userType = userData['type'];

        debugPrint('Login successful');

        // Redirect to SENPage with appropriate userType
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => SENPage(username: username, userType: userType),
          ),
        );
      } else {
        setState(() {
          errorMessage = 'Invalid username or password';
        });
      }
    } catch (e) {
      debugPrint('$e');
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  Future<void> signUp() async {
    try {
      await FirebaseFirestore.instance.collection('users').add({
        'username': _usernameController.text,
        'password': _passwordController.text,
        'email': _emailController.text,
        'type': isTeacher ? 'teacher' : 'student',
      });
      debugPrint('Sign up successful');
    } catch (e) {
      debugPrint('$e');
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  Future<User?> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        final String userType = isTeacher ? "teacher" : "student";
        final String username = user.displayName ?? "User";

        // Redirect based on user type
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => SENPage(username: username, userType: userType),
          ),
        );

        return user;
      }
    } catch (e) {
      print(e);
      setState(() {
        errorMessage = e.toString();
      });
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'SEN Login',
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Colors.cyan.shade800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Lottie.network(
                      'https://lottie.host/bf54bc22-5ef0-44db-872f-6c859e16384d/OXWwJtv9g5.json',
                      height: 50,
                      width: 50,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isTeacher = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isTeacher ? Colors.cyan.shade700 : Colors.grey[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.person,
                            color: isTeacher ? Colors.white : Colors.grey,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Teacher',
                            style: TextStyle(
                              color: isTeacher ? Colors.white : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isTeacher = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !isTeacher ? Colors.cyan.shade700 : Colors.grey[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.person,
                            color: !isTeacher ? Colors.white : Colors.grey,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Student',
                            style: TextStyle(
                              color: !isTeacher ? Colors.white : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (!isSignUp) ...[
                          TextFormField(
                            controller: _usernameController,
                            keyboardType: TextInputType.name,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              labelText: 'Username',
                              hintText: 'Enter your username',
                              prefixIcon: const Icon(Icons.person, color: Colors.cyan),
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              labelStyle: const TextStyle(color: Colors.cyan),
                              hintStyle: const TextStyle(color: Colors.grey),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your username';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _passwordController,
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: true,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Enter your password',
                              prefixIcon: const Icon(Icons.lock, color: Colors.cyan),
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              labelStyle: const TextStyle(color: Colors.cyan),
                              hintStyle: const TextStyle(color: Colors.grey),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                        ],
                        if (isSignUp) ...[
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'Enter your email',
                              prefixIcon: const Icon(Icons.email, color: Colors.cyan),
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              labelStyle: const TextStyle(color: Colors.cyan),
                              hintStyle: const TextStyle(color: Colors.grey),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _usernameController,
                            keyboardType: TextInputType.name,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              labelText: 'Username',
                              hintText: 'Enter your username',
                              prefixIcon: const Icon(Icons.person, color: Colors.cyan),
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              labelStyle: const TextStyle(color: Colors.cyan),
                              hintStyle: const TextStyle(color: Colors.grey),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your username';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _passwordController,
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: true,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Enter your password',
                              prefixIcon: const Icon(Icons.lock, color: Colors.cyan),
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              labelStyle: const TextStyle(color: Colors.cyan),
                              hintStyle: const TextStyle(color: Colors.grey),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _confirmPasswordController,
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: true,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              hintText: 'Confirm your password',
                              prefixIcon: const Icon(Icons.lock, color: Colors.cyan),
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              labelStyle: const TextStyle(color: Colors.cyan),
                              hintStyle: const TextStyle(color: Colors.grey),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please confirm your password';
                              }
                              return null;
                            },
                          ),
                        ],
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          child: SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  if (isSignUp) {
                                    await signUp();
                                  } else {
                                    await login();
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.cyan,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                isSignUp ? 'Sign Up' : 'Login',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (errorMessage.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Text(
                            errorMessage,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isSignUp = !isSignUp;
                      errorMessage = '';
                    });
                  },
                  child: MouseRegion(
                    onEnter: (event) => setState(() => isHovering = true),
                    onExit: (event) => setState(() => isHovering = false),
                    child: Text(
                      isSignUp
                          ? 'Already have an account? Login.'
                          : 'Need an account? Sign up',
                      style: TextStyle(
                        color: isHovering ? Colors.blue : Colors.cyan,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () async {
                    User? user = await _signInWithGoogle();
                    if (user != null) {
                      final String userType = isTeacher ? "teacher" : "student";
                      final String username = user.displayName ?? "User";
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => SENPage(username: username, userType: userType),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.login),
                  label: const Text("Sign in with Google"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
