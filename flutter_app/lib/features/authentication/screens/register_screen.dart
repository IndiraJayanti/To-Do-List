import 'package:flutter/material.dart';
import '../widgets/register_form.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color pastelGreen = const Color(0xFFCDEAC0);

    return Scaffold(
      backgroundColor: pastelGreen,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 40.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                Text(
                  'Create Your\nAccount',
                  style: TextStyle(
                    fontSize: 30,
                    color: Color(0xFF3F6B3F),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 40),
                RegisterForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
