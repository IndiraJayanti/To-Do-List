import 'package:flutter/material.dart';
import 'package:flutter_app/features/authentication/screens/login_screen.dart';
import 'package:flutter_app/features/authentication/screens/register_screen.dart';
import 'package:flutter_app/features/authentication/widgets/action_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final Color pastelGreen = const Color(0xFFCDEAC0);
    final Color greenText = const Color(0xFF3F6B3F);

    return Scaffold(
      backgroundColor: pastelGreen,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 20.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: screenHeight * 0.25,
                    child: Image.asset('assets/imagetodo.png'),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Plan Paw',
                    style: TextStyle(
                      fontSize: 30,
                      color: greenText,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 70),
                  ActionButton(
                    label: 'SIGN IN',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    isPrimary: false,
                    greenText: greenText,
                  ),
                  const SizedBox(height: 25),
                  ActionButton(
                    label: 'SIGN UP',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    isPrimary: true,
                    greenText: greenText,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
