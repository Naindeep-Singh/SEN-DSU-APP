import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sen_app_latest/documentupload/documentupload.dart';
import 'package:sen_app_latest/new_structure/login/login.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Column(
        children: [
          Center(
            child: Lottie.network(
              'https://lottie.host/f0e9ece1-31d6-419e-b542-f89ccd7ba188/2zcbQS1OR0.json',
            ),
          ),
        ],
      ),
      nextScreen: const LoginPage(),
      splashIconSize: 400,
    );
  }
}
