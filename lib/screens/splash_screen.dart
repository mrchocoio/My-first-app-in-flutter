import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/colors.dart';
import 'SelectionLogin_SignUp.dart';
import 'dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), _checkUserStatus);
  }

  void _checkUserStatus() {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SelectionLogin_SignUp()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenSize = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.primaryPurple,
      body: Stack(
        children: [
          // Top wave
          Align(
            alignment: Alignment.topCenter,
            child: ClipPath(
              clipper: WaveClipperOne(),
              child: Container(
                height: screenSize * 0.3,
                color: AppColors.background2,
              ),
            ),
          ),
          // Bottom wave
          Align(
            alignment: Alignment.bottomCenter,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationX(pi),
              child: ClipPath(
                clipper: WaveClipperOne(),
                child: Container(
                  height: screenSize * 0.3,
                  color: AppColors.background2,
                ),
              ),
            ),
          ),
          // Center logo
          Center(
            child: Container(
              height: 300,
              width: 300,
              decoration: BoxDecoration(
                color: AppColors.background2,
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/images/darazLogo.png',
                height: 200,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
