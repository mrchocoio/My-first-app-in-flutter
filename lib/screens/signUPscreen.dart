import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'terms_privacy.dart';

import '../constants/colors.dart';
import 'SelectionLogin_SignUp.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool agreeToTerms = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty';
    } else if (value.length < 6) {
      return 'Password must be at least 6 characters';
    } else if (!RegExp(r'[!@#$%^&*(),_.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (!agreeToTerms) {
        _showSnackBar('Please agree to Terms & Conditions');
        return;
      }
      try {
        //creating user with email and pwd
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        //saving extra info with role field
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
          'role': 'user', //default role: user
          'createdAt': DateTime.now(),
        });

        _showSnackBar('User Registered Successfully');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SelectionLogin_SignUp(),
          ),
        );
      } on FirebaseAuthException catch (e) {
        _showSnackBar('Error: ${e.message}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
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
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.15),
              Center(
                child: Container(
                  height: 200,
                  width: 200,
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/images/darazLogo.png',
                    height: 200,
                  ),
                ),
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: buildTextField(_firstNameController, 'First Name'),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: buildTextField(_lastNameController, 'Last Name'),
                        ),
                      ],
                    ),
                    buildTextField(
                      _emailController,
                      'Email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    buildTextField(
                      _phoneController,
                      'Phone Number',
                      keyboardType: TextInputType.phone,
                    ),
                    buildTextField(_addressController, 'Address'),

                    buildTextField(
                      _passwordController,
                      'Password',
                      obscureText: obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                      validator: _validatePassword,
                    ),

                    buildTextField(
                      _confirmPasswordController,
                      'Confirm Password',
                      obscureText: obscureConfirmPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            obscureConfirmPassword = !obscureConfirmPassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 10),

                    CheckboxListTile(
                      title: Row(
                        children: [
                          const Text("I agree to the "),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const TermsPrivacy()),
                              );
                            },
                            child: const Text(
                              "Terms & Conditions",
                              style: TextStyle(
                                color: Colors.deepOrange,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      value: agreeToTerms,
                      onChanged: (value) {
                        setState(() {
                          agreeToTerms = value ?? false;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        minimumSize: const Size(200, 50),
                      ),
                      child: Text(
                        'Sign Up',
                        style: GoogleFonts.lato(
                          textStyle: const TextStyle(
                            fontSize: 20,
                            color: AppColors.textBlack,
                          ),
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

  // reusable text field builder
  Widget buildTextField(
      TextEditingController controller,
      String label, {
        bool obscureText = false,
        TextInputType keyboardType = TextInputType.text,
        Widget? suffixIcon,
        String? Function(String?)? validator,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: suffixIcon,
        ),
        validator: validator ??
                (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter $label';
              }
              if (label == 'Email' &&
                  !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              if (label == 'Phone Number' &&
                  !RegExp(r'^\+92\d{10}$').hasMatch(value)) {
                return 'Enter a valid Pakistani phone number (+92XXXXXXXXXX )';
              }
              return null;
            },
      ),
    );
  }
}
