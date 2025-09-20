import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/colors.dart';
import 'dashboard.dart';
import 'signUPscreen.dart';
import 'admin_screen.dart';

class SelectionLogin_SignUp extends StatefulWidget {
  const SelectionLogin_SignUp({super.key});

  @override
  State<SelectionLogin_SignUp> createState() => _SelectionLogin_SignUpState();
}

class _SelectionLogin_SignUpState extends State<SelectionLogin_SignUp> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool obscurePassword = true;
  bool loading = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = userCredential.user;

      if (user == null) return;

      //checking roles from firestore
      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      final role = snapshot.data()?["role"] ?? "user";

      if (!mounted) return;

      if (role == "admin") {
        // admin goes to upload screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => AdminScreen()),
              (route) => false,
        );
      } else {
        // normal user goes to dashboard
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
              (route) => false,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Welcome ${user.email}! Role: $role")),
      );

    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Login failed")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Something went wrong. Try again.")),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF00897B),
            Color(0xFFB2EBF2),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.15),
              Center(
                child: Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/images/darazLogo.png',
                    height: 200,
                  ),
                ),
              ),
              SizedBox(height: 55),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      //email field
                      TextFormField(
                        controller: emailController,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.black),
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.deepOrange),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email cannot be empty';
                          } else if (!value.contains('@')) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),

                      //password
                      TextFormField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Colors.black),
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.deepOrange),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password cannot be empty';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),

                      //login button
                      ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          minimumSize: Size(double.infinity, 50),
                        ),
                        child: loading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                          'Login',
                          style: GoogleFonts.lato(
                            textStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: AppColors.textBlack,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),

                      //redirects to signup screen
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SignUpScreen()),
                          );
                        },
                        child: Text(
                          'Don’t have an account? Sign Up',
                          style: GoogleFonts.lato(
                            textStyle: TextStyle(
                              fontSize: 15,
                              color: Colors.deepOrange,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
