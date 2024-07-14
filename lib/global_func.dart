import 'package:flutter/material.dart';
import 'package:practice/pages/homepage.dart';
import 'package:http/http.dart' as http;
import 'package:practice/provider/homeProvider.dart';
import 'dart:convert';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget imageLoader(String imageUrl, double width) {
  return Container(
    width: width,
    child: Image.network(
      imageUrl,
      width: width,
      fit: BoxFit.cover,
      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) {
          return child;
        } else {
          return Container(
            width: width,
            height: width,
            child: Center(
              child: CircularProgressIndicator(
                color: Color.fromRGBO(6, 148, 132, 1),
              ),
              
            ),
          );
        }
      },
      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
        return Container(
          width: width,
          height: width,
          child: Icon(
            Icons.error,
            color: Color.fromARGB(212, 117, 117, 117),
            size: 50.0,
          ),
        );
      },
    ),
  );
}

void SignUp(String email, String password, String confirmedPassword, BuildContext context) async {
 if (email.isEmpty) {
  invalidMessenger(context, "Email can't be empty");
  return;
} else if (!email.contains('@')) {
  invalidMessenger(context, "Email must contain '@'");
  return;
}else if (!email.contains('.com')) {
  invalidMessenger(context, "Email must contain '.com'");
  return;
} else if (password.isEmpty) {
  invalidMessenger(context, "Password can't be empty");
  return;
} else if (password.length < 8) {
  invalidMessenger(context,"Password must be at least 8 characters long",);
  return;
} else if (password != confirmedPassword) {
  invalidMessenger(context, "Confirmed Password doesn't match");
  return;
}

  try {
    final url = Uri.parse('https://clever-shape-81254.pktriot.net/users/');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      Provider.of<HomeProvider>(context, listen: false).login();
      Navigator.pop(context);
    } else if (response.statusCode == 401) {
      invalidMessenger(context, "Email already in use");
    } else {
      invalidMessenger(context, 'Registration failed. Please try again later.');
    }
  } catch (e) {
    print('Error during sign-up: $e');
    invalidMessenger(context, "An error occured please try again later");
  }
}

void Login(String email, String password, BuildContext context) async {
  if (email.isEmpty) {
    invalidMessenger(context, "Email can't be empty");
    return;
  } else if (password.isEmpty) {
    invalidMessenger(context, "Password can't be empty");
    return;
  }

  try {

    final url = Uri.parse('https://clever-shape-81254.pktriot.net/users/$email');

    final response = await http.get(url);
    print(response);

    if (response.statusCode == 404) {
     invalidMessenger(context, 'Incorrect email. Please try again.');
      return;
    }

    if (response.statusCode == 200) {
      final user = jsonDecode(response.body);

      if (user.isNotEmpty) {
        final storedPassword = user['password'];
        if (password.trim() == storedPassword) {
          final provider = Provider.of<HomeProvider>(context, listen: false);
          provider.setCurrentUser(user);
          await provider.login();
          
          // Save user data to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('currentUser', jsonEncode(user));

          // Check if SharedPreferences data is saved
          final savedUserData = prefs.getString('currentUser');
          if (savedUserData != null) {
            print('User data saved in SharedPreferences: $savedUserData');
          } else {
            print('Failed to save user data in SharedPreferences.');
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => StorePage()),
          );
        } else {
          invalidMessenger(context, 'Incorrect password. Please try again.');
        }
      } else {
        invalidMessenger(context, 'User not found. Please sign up.');
      }
    } else {
     invalidMessenger(context, 'Error retrieving user details. Please try again later.');
    }
  } catch (e) {
    print(e);
    invalidMessenger(context, 'An error occurred. Please try again later.');
  }
}

void validMessenger(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.white), // Change text color
      ),
      backgroundColor: Color.fromRGBO(7, 103, 92, 1).withOpacity(0.7),
      duration: Duration(seconds: 1),
    ),
  );
}

void invalidMessenger(BuildContext context , String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Color.fromARGB(223, 82, 79, 79),
    ),
  );
}
