import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../graphql/client.dart';
import '../../../graphql/query_mutation.dart';
import '../../home/screens/home_screen.dart';
import '../screens/register_screen.dart';
import 'auth_text_field.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  // State dan controller khusus untuk form login
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color greenText = const Color(0xFF3F6B3F);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthTextField(
          label: 'Email',
          controller: _emailController,
          hintText: 'Enter your email',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),

        AuthTextField(
          label: 'Password',
          controller: _passwordController,
          hintText: 'Enter your password',
          isPassword: true,
          obscureText: _obscurePassword,
          onVisibilityToggle: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
        ),
        const SizedBox(height: 15),
        _buildSignUpLink(context),
        const SizedBox(height: 25),

        Mutation(
          options: MutationOptions(
            document: gql(loginMutation),
            onCompleted: (resultData) async {
              setState(() => _isLoading = false);
              if (resultData != null && resultData['login'] != null) {
                final token = resultData['login']['token'];
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('jwt_token', token);

                MyGraphQLProvider.of(context).updateToken(token);

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (Route<dynamic> route) => false,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Login failed: Invalid credentials.'),
                  ),
                );
              }
            },
            onError: (error) {
              setState(() => _isLoading = false);
              final errorMessage =
                  error?.graphqlErrors.first.message ?? 'Unknown error';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('An error occurred: $errorMessage')),
              );
            },
          ),
          builder: (runMutation, result) {
            return Center(
              child: SizedBox(
                height: 55,
                width: 300,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          setState(() => _isLoading = true);
                          runMutation({
                            'email': _emailController.text,
                            'password': _passwordController.text,
                          });
                        },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [greenText, const Color(0xFF264D26)],
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'SIGN IN',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildSignUpLink(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RegisterScreen()),
          );
        },
        child: RichText(
          text: const TextSpan(
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            children: [
              TextSpan(text: "Don't have an account? "),
              TextSpan(
                text: "Sign up",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
