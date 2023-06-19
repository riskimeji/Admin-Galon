import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:umkm_galon/main.dart';
import 'package:umkm_galon/screen/login.dart';
import 'package:umkm_galon/screen/testlogin.dart';
import 'package:page_transition/page_transition.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    playSound(); // Memutar suara saat splash screen dibuka

    return AnimatedSplashScreen(
      splash: Column(
        children: [
          Image.asset('assets/galon_logo.png'),
          const Text(
            'Selamat Datang',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
              color: Colors.white,
            ),
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 104, 154, 196),
      splashIconSize: 400,
      duration: 3000,
      splashTransition: SplashTransition.slideTransition,
      pageTransitionType: PageTransitionType.bottomToTop,
      nextScreen: const LoginPage(),
    );
  }

  void playSound() async {
    AudioPlayer audioPlayer = AudioPlayer();
    await audioPlayer.setAsset('assets/galon_sound.mp3');
    await audioPlayer.play();
  }
}
