import 'package:flutter/material.dart';

class TermsPrivacy extends StatefulWidget {
  const TermsPrivacy({super.key});

  @override
  State<TermsPrivacy> createState() => _TermsPrivacyState();
}

class _TermsPrivacyState extends State<TermsPrivacy> {
  @override
  Widget build(BuildContext context) {
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
        backgroundColor: Colors.transparent, // transparent to show gradient
        appBar: AppBar(
          title: const Text("Terms & Privacy Policy"),
          backgroundColor: Colors.deepOrange,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Terms & Conditions",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                """
Welcome to our app! Please read these terms carefully:

1. You agree to use this app responsibly.
2. You must not engage in illegal activities using this app.
3. We are not liable for misuse of your account.
4. You must provide accurate personal information.

""",
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              SizedBox(height: 20),
              Text(
                "Privacy Policy",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                """
Your privacy is important to us:

1. We collect data only to improve user experience.
2. Your data will never be shared without consent.
3. We use secure methods to store your information.
4. You may request deletion of your account at any time.

""",
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
