import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sen_app_latest/new_structure/student/studentlanding.dart';
import 'package:sen_app_latest/new_structure/teacher/teacherlanding.dart';


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
        debugPrint('Login successful');
        // Ensure navigation is done in a context where Navigator is available
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => isTeacher
                ? const TeacherLanding() // Pass the appropriate data here
                : StudentLanding(
                    username: _usernameController.text,
                  ), // Pass the appropriate data here
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
        'type': isSignUp ? 'student' : 'teacher', // Example type
      });
      debugPrint('Sign up successful');
    } catch (e) {
      debugPrint('$e');
      setState(() {
        errorMessage = e.toString();
      });
    }
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
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
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
            ],
          ),
        ),
      ),
    );
  }
}
