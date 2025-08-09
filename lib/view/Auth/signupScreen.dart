import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:namaz_timing/controller/UserController.dart';
import 'package:namaz_timing/models/userModel.dart';
import 'package:namaz_timing/view/home/home_screen.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  File? imageFile;
  bool isLoading = false;

  final UserController userController = Get.put(UserController());

  // Cloudinary configuration
  static const String cloudinaryUrl =
      'https://api.cloudinary.com/v1_1/de6xls9fs/image/upload';
  static const String uploadPreset = 'namaz-timing';

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  Future<String?> uploadImageToCloudinary(File imageFile) async {
    try {
      print("Starting Cloudinary image upload...");

      var request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl));
      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = 'islamic_community/profiles';

      var multipartFile =
          await http.MultipartFile.fromPath('file', imageFile.path);
      request.files.add(multipartFile);

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print("Cloudinary Status Code: ${response.statusCode}");
      print("Cloudinary Response Body: $responseBody");

      if (response.statusCode == 200) {
        var jsonData = json.decode(responseBody);
        return jsonData['secure_url'];
      } else {
        var errorData = json.decode(responseBody);
        String errorMsg =
            errorData['error']?['message'] ?? 'Unknown error';
        throw Exception('Cloudinary upload failed: $errorMsg');
      }
    } catch (e) {
      print('Cloudinary upload error: $e');
      return null;
    }
  }

  Future<void> signup() async {
    if (imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a profile picture'),
          backgroundColor: Colors.red[400],
        ),
      );
      return;
    }

    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red[400],
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;

    try {
      String? imageUrl = await uploadImageToCloudinary(imageFile!);

      if (imageUrl == null) {
        throw Exception('Failed to upload image');
      }

      UserCredential userCred = await auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passController.text.trim(),
      );

      print("✅ UserCredential Response:");
      print("UID: ${userCred.user?.uid}");
      print("Email: ${userCred.user?.email}");

      final uid = userCred.user!.uid;

      final userModel = UserModel(
        uid: uid,
        email: emailController.text.trim(),
        name: nameController.text.trim(),
        photoUrl: imageUrl,
      );

      await firestore.collection('users').doc(uid).set(userModel.toMap());

      // Store in GetX Controller
      userController.setUserData(
        nameController.text.trim(),
        imageUrl,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Account created successfully!'),
          backgroundColor: Colors.green[400],
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => IslamicHomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red[400],
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Create Account",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.teal[800],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              GestureDetector(
                onTap: pickImage,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withOpacity(0.2),
                        spreadRadius: 3,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: imageFile != null
                      ? ClipOval(
                          child: Image.file(
                            imageFile!,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.teal[50],
                          ),
                          child: Icon(
                            Icons.add_a_photo,
                            color: Colors.teal[800],
                            size: 40,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Tap to select profile picture',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 40),
              _buildTextField(nameController, "Full Name", Icons.person),
              SizedBox(height: 20),
              _buildTextField(emailController, "Email Address", Icons.email,
                  isEmail: true),
              SizedBox(height: 20),
              _buildTextField(passController, "Password", Icons.lock,
                  isPassword: true),
              SizedBox(height: 40),
              Container(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : signup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                  ),
                  child: isLoading
                      ? CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : Text(
                          "Create Account",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon,
      {bool isPassword = false, bool isEmail = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.teal[800]),
          prefixIcon: Icon(icon, color: Colors.teal[800]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.teal[800]!, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
