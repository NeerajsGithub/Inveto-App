import 'package:flutter/material.dart';
import 'package:practice/main.dart';

class IntroForm extends StatelessWidget {
  const IntroForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: TextButton.icon(
              onPressed: () => {},
              label: Text(
                "Exit",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(255, 94, 94, 94),
                ),
              ),
              icon: Icon(
                Icons.exit_to_app_sharp,
                color: Color.fromRGBO(6, 148, 132, 1),
              ),
              iconAlignment: IconAlignment.end,
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;
          final double height = constraints.maxHeight;
          final bool isPortrait = height > width;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.06, vertical: height * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: height * 0.02),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.03),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'lib/images/logo.png',
                        height: isPortrait ? height * 0.1 : width * 0.1,
                        color: Color.fromRGBO(6, 148, 132, 1),
                      ),
                      SizedBox(height: height * 0.05),
                      Text(
                        'Welcome to \npractice by Meteo',
                        style: TextStyle(
                          fontSize: height * 0.045,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                          color: Color.fromARGB(255, 75, 73, 73),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: height * 0.04),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(40, 189, 189, 189),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextButton.icon(
                        onPressed: () => {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) => SignUpPage(),
                              transitionsBuilder: (_, animation, __, child) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(1, 0),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                );
                              },
                            ),
                          )
                        },
                        label: Text(
                          'Open a new account       ',
                          style: TextStyle(
                            fontSize: height * 0.028,
                            fontWeight: FontWeight.w400,
                            color: Color.fromARGB(255, 100, 100, 100),
                          ),
                        ),
                        icon: Icon(
                          Icons.person_outline,
                          color: Color.fromRGBO(6, 148, 132, 1),
                        ),
                        iconAlignment: IconAlignment.start,
                      ),
                    ),
                    SizedBox(height: height * 0.02),
                    Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(40, 189, 189, 189),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextButton.icon(
                        onPressed: () => {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) => LoginPage(),
                              transitionsBuilder: (_, animation, __, child) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(1, 0),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                );
                              },
                            ),
                          )
                        },
                        label: Text(
                          'Login to practice                ',
                          style: TextStyle(
                            fontSize: height * 0.028,
                            fontWeight: FontWeight.w400,
                            color: Color.fromARGB(255, 100, 100, 100),
                          ),
                        ),
                        icon: Icon(
                          Icons.exit_to_app,
                          color: Color.fromRGBO(6, 148, 132, 1),
                        ),
                        iconAlignment: IconAlignment.start,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.03, vertical: height * 0.05),
                      child: Text(
                        'practice is a game-changing inventory management app designed to streamline stock processes, optimize logistics, and boost efficiency for businesses. With real-time tracking, insightful analytics.\nService Number: +1 (555) 123-4567',
                        style: TextStyle(
                          fontSize: isPortrait ? 12 : 10,
                          color: Color.fromARGB(255, 104, 104, 104),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
