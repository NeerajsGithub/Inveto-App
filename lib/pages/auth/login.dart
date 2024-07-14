import 'package:flutter/material.dart';
import 'package:practice/global_func.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Define a GlobalKey

  LoginForm({Key? key}) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: LayoutBuilder(
          builder: (context, constraints) {
            final bool isPortrait = constraints.maxHeight > constraints.maxWidth;
            final double fontSize = isPortrait ? 21.0 : 18.0; // Adjust font size based on orientation
            return Text(
              'Login',
              style: TextStyle(fontSize: fontSize),
            );
          },
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;
          final double height = constraints.maxHeight;
          final bool isPortrait = height > width;

          return Padding(
            padding: EdgeInsets.all(width * 0.06),
            child: Center(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey, // Assign the GlobalKey to the Form widget
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Image.asset(
                        'lib/images/logo.png',
                        height: isPortrait ? height * 0.15 : width * 0.15,
                        color: Color.fromRGBO(6, 148, 132, 1),
                      ),
                      SizedBox(height: height * 0.05),
                      TextFormField(
                        style: TextStyle(fontSize: isPortrait ? 15 : 13),
                        controller: emailController,
                        cursorColor: Color.fromRGBO(6, 148, 132, 1),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(fontSize: isPortrait ? 15 : 13, color: Color.fromARGB(255, 92, 92, 92)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 20),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color.fromARGB(255, 167, 167, 167)),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color.fromARGB(255, 167, 167, 167)),
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: height * 0.02),
                      TextFormField(
                        style: TextStyle(fontSize: isPortrait ? 16 : 14),
                        controller: passwordController,
                        cursorColor: Color.fromRGBO(6, 148, 132, 1),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(fontSize: isPortrait ? 15 : 13, color: Color.fromARGB(255, 92, 92, 92)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 20),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color.fromARGB(255, 167, 167, 167)),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color.fromARGB(255, 167, 167, 167)),
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        obscureText: true, 
                      ),
                      SizedBox(height: height * 0.02),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(6, 148, 132, 1),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final email = emailController.text.trim();
                            final password = passwordController.text.trim();
                            Login (email, password, context);
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.all(22.0),
                          child: Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: isPortrait ? 16 : 14,
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Don\'t have an account? Sign Up',
                          style: TextStyle(
                            fontSize: isPortrait ? 14 : 12,
                            fontWeight: FontWeight.w500,
                            color: Color.fromARGB(255, 100, 100, 100),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
