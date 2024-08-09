import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sen_app_latest/new_structure/sen_ui/sen_ui.dart'; // Import SEN UI

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
        // Retrieve the username and userType from Firestore
        final userData = querySnapshot.docs.first.data() as Map<String, dynamic>;
        final String username = userData['username'];
        final String userType = userData['type'];

        debugPrint('Login successful');
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
        // Assume the userType is derived from Firestore based on the email or some other method
        final String userType = isTeacher ? "teacher" : "student";
        final String username = user.displayName ?? "User";

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
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 35,
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                ),
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
                    child: Row(
                      children: [
                        Icon(
                          Icons.person,
                          color: isTeacher ? Colors.teal : Colors.grey,
                        ),
                        Text(
                          'Teacher',
                          style: TextStyle(
                            color: isTeacher ? Colors.teal : Colors.grey,
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
                    child: Row(
                      children: [
                        Icon(
                          Icons.person,
                          color: !isTeacher ? Colors.teal : Colors.grey,
                        ),
                        Text(
                          'Student',
                          style: TextStyle(
                            color: !isTeacher ? Colors.teal : Colors.grey,
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
                          decoration: InputDecoration(
                            labelText: 'Username',
                            hintText: 'Enter your username',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
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
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Enter your password',
                            prefixIcon: const Icon(Icons.password),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
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
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'Enter your email',
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
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
                          decoration: InputDecoration(
                            labelText: 'Username',
                            hintText: 'Enter your username',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
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
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Enter your password',
                            prefixIcon: const Icon(Icons.password),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
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
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            hintText: 'Confirm your password',
                            prefixIcon: const Icon(Icons.password),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
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
                        padding: const EdgeInsets.symmetric(horizontal: 140),
                        child: MaterialButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              if (isSignUp) {
                                await signUp();
                              } else {
                                await login();
                              }
                            }
                          },
                          color: Colors.teal,
                          textColor: Colors.white,
                          child: Text(isSignUp ? 'Sign Up' : 'Login'),
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
                      color: isHovering ? Colors.blue : Colors.teal,
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
                icon: const Icon(Icons.login),
                label: const Text("Sign in with Google"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
