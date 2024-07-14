import 'package:flutter/material.dart';
import 'package:practice/global_func.dart';


class SignUpForm extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('SignUp', style: TextStyle(fontSize: 20)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;
          final double height = constraints.maxHeight;

          return Padding(
            padding: EdgeInsets.all(width * 0.06),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Image.asset(
                      'lib/images/logo.png',
                      height:  height * 0.15 ,
                      color: Color.fromRGBO(6, 148, 132, 1),
                    ),
                    SizedBox(height: width * 0.1),
                    TextField(
                      cursorColor: Color.fromRGBO(6, 148, 132, 1),       
                      style: TextStyle(fontSize: width < 400 ? 14 : 16),
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(fontSize: width < 400 ? 14 : 15, color: Color.fromARGB(255, 92, 92, 92)),
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
                    SizedBox(height: width * 0.04),
                    TextField(
                      cursorColor: Color.fromRGBO(6, 148, 132, 1),       
                      style: TextStyle(fontSize: width < 400 ? 14 : 16, color: Color.fromARGB(255, 92, 92, 92)),
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(fontSize: width < 400 ? 14 : 15 , color:Color.fromARGB(255, 92, 92, 92) ),
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
                      keyboardType: TextInputType.visiblePassword,
                    ),
                    
                    SizedBox(height: width * 0.04),

                    TextField(
                      cursorColor: Color.fromRGBO(6, 148, 132, 1),       
                      style: TextStyle(fontSize: width < 400 ? 14 : 16, color: Color.fromARGB(255, 92, 92, 92)),
                      controller: confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        labelStyle: TextStyle(fontSize: width < 400 ? 14 : 15 , color:Color.fromARGB(255, 92, 92, 92) ),
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
                      keyboardType: TextInputType.visiblePassword,
                    ),
                    SizedBox(height: width * 0.04),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(6,148,132,1),
                      ),
                      onPressed: () {
                        final email = emailController.text.trim();;
                        final password = passwordController.text.trim();;
                        final confirmedPassword = confirmPasswordController.text.trim();
                        SignUp( email , password , confirmedPassword , context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(22.0),
                        child: Text(
                          'SignUp',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Already have an account? Login',
                        style: TextStyle(
                          fontSize: width < 400 ? 14 : 16,
                          fontWeight: FontWeight.w500,
                          color: Color.fromARGB(255, 100, 100, 100),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
