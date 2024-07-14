import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:practice/provider/homeProvider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  File? _imageFile;
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController genderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<HomeProvider>(context, listen: false);
    final currentUser = provider.currentUser;

    nameController.text = currentUser != null ? currentUser['name'] ?? '' : '';
    emailController.text = currentUser != null ? currentUser['email'] ?? '' : '';
    genderController.text = currentUser != null ? currentUser['gender'] ?? '' : '';

    if (currentUser != null && currentUser['image'] != null) {
      _imageFile = File(currentUser['image']);
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Future<void> _submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        final url = Uri.parse('https://clever-shape-81254.pktriot.net/users/update');
        var request = http.MultipartRequest('POST', url);

        var provider = Provider.of<HomeProvider>(context, listen: false);
        var currentUser = provider.currentUser;

        if (currentUser == null) {
          print('Current user is null');
          return;
        }

        String userEmail = currentUser['email'] ?? '';

        if (userEmail.isEmpty) {
          print('User email is empty');
          return;
        }

        request.fields['email'] = userEmail;
        request.fields['name'] = nameController.text;
        request.fields['gender'] = genderController.text;

        if (_imageFile != null) {
          request.files.add(await http.MultipartFile.fromPath('image', _imageFile!.path));
        }

        final response = await request.send();
        print("sent");

        if (response.statusCode == 200) {
          Navigator.pop(context); // Optionally, fetch the updated user details here to refresh the local state
          print('User details updated successfully');
          await provider.fetchUserDetails();
        } else {
          print('Failed to update user details: ${response.statusCode}');
        }
      } catch (e) {
        print('Error updating user details: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Account Page',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Color.fromARGB(187, 53, 53, 53),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            children: <Widget>[
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  backgroundColor: Color.fromRGBO(6, 148, 132, 1).withOpacity(0.8),
                  backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                  child: _imageFile == null ? Icon(Icons.camera_alt, color: Colors.white) : null,
                  radius: 50,
                ),
              ),
              SizedBox(height: 30),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: nameController,
                      style: TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: TextStyle(
                          fontSize: 15,
                          color: Color.fromARGB(255, 92, 92, 92),
                        ),
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
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      style: TextStyle(fontSize: 15),
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(
                          fontSize: 15,
                          color: Color.fromARGB(255, 92, 92, 92),
                        ),
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
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: genderController,
                      style: TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        labelText: 'Gender',
                        labelStyle: TextStyle(
                          fontSize: 15,
                          color: Color.fromARGB(255, 92, 92, 92),
                        ),
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
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(6, 148, 132, 1),
                        padding: EdgeInsets.all(16.0),
                      ),
                      onPressed: () {
                        _submitForm(context);
                      },
                      child: Text(
                        'Submit',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
