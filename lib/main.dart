import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:practice/pages/homepage.dart';
import 'package:practice/pages/other/intro.dart';
import 'package:practice/pages/auth/login.dart';
import 'package:practice/pages/auth/signup.dart';
import 'package:practice/provider/homeProvider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: const Color.fromRGBO(6, 148, 132, 1),
        hintColor: const Color.fromARGB(255, 94, 94, 94),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
          elevation: 4,
          titleTextStyle: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            fontSize: 16,
            color: Color.fromARGB(255, 52, 52, 52),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w400),
          bodyMedium: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w400),
          displayLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w900),
          displayMedium: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800),
          displaySmall: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700),
          headlineMedium: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
          headlineSmall: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500),
          titleLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w400),
          titleMedium: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w300),
          titleSmall: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w200),
          bodySmall: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w100),
          labelLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700),
          labelSmall: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
        colorScheme: ColorScheme.fromSwatch().copyWith(primary: const Color.fromRGBO(6, 148, 132, 1)),
      ),
      home: Consumer<HomeProvider>(
        builder: (context, homeProvider, child) {
          if (homeProvider.currentUser == null) {
            return IntroPage();
          } else {
            return StorePage();
          }
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late LocalAuthentication auth;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    auth = LocalAuthentication();
    _authenticate();
  }

  Future<void> _authenticate() async {
    try {
      bool authenticated = await auth.authenticate(
        localizedReason: 'Biometric authentication is required to access the app',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      if (authenticated) {
        setState(() {
          _isAuthenticated = true;
        });
        Future.delayed(Duration(milliseconds: 50), () {
          Navigator.pushAndRemoveUntil(
            context,
            _createRoute(),
            ModalRoute.withName('/'),
          );
        });
      } else {
        // If biometric authentication fails or is not available, directly show StorePage
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => StorePage(),
            transitionsBuilder: (_, animation, __, child) {
              const begin = 0.0;
              const end = 1.0;
              const curve = Curves.ease;

              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return FadeTransition(
                opacity: animation.drive(tween),
                child: child,
              );
            },
          ),
        );
      }
    } on PlatformException catch (e) {
      print('Error: ${e.message}');
      // Handle errors
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => StorePage(),
          transitionsBuilder: (_, animation, __, child) {
            const begin = 0.0;
            const end = 1.0;
            const curve = Curves.ease;

            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return FadeTransition(
              opacity: animation.drive(tween),
              child: child,
            );
          },
        ),
      );
    }
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => StorePage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.0;
        const end = 1.0;
        const curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return FadeTransition(
          opacity: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'lib/images/logo.png', // Replace with your logo asset
              height: 150,
              color: const Color.fromRGBO(6, 148, 132, 1),
            ),
          ],
        ),
      ),
    );
  }
}

class IntroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IntroForm(), // Replace with your intro page content
    );
  }
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LoginForm(), // Replace with your login page content
    );
  }
}

class SignUpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SignUpForm(), // Replace with your signup page content
    );
  }
}
