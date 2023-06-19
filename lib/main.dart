import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:page_transition/page_transition.dart';
import 'package:umkm_galon/admin/dashboard.dart';
import 'package:umkm_galon/admin/home.dart';
import 'package:umkm_galon/screen/login.dart';
import 'package:umkm_galon/screen/redirect_dashboard.dart';
import 'package:umkm_galon/screen/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  dynamic token = await SessionManager().get("token");
  runApp(token == 'logout' ? const Home() : const HomesDashboard());
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Galon Admin',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}

class HomesDashboard extends StatelessWidget {
  const HomesDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Galon Admin',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RedirectDashboard(),
    );
  }
}

// class SplashScreen extends StatelessWidget {
//   const SplashScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedSplashScreen(
//       splash: Column(
//         children: [
//           Image.asset('assets/galon_logo.png'),
//           const Text(
//             'Selamat Datang',
//             style: TextStyle(
//                 fontWeight: FontWeight.bold, fontSize: 30, color: Colors.white),
//           )
//         ],
//       ),
//       backgroundColor: const Color.fromARGB(255, 110, 159, 199),
//       nextScreen: const MyApp(),
//       splashIconSize: 400,
//       duration: 3000,
//       splashTransition: SplashTransition.slideTransition,
//       pageTransitionType: PageTransitionType.bottomToTop,
//       animationDuration: const Duration(seconds: 1),
//     );
//   }
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text('Home'),
      ),
    );
  }
}
