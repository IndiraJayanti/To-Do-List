import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onVisibilityToggle;
  final TextInputType keyboardType;

  const AuthTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.hintText,
    this.isPassword = false,
    this.obscureText = false,
    this.onVisibilityToggle,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final Color greenText = const Color(0xFF3F6B3F);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: greenText,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: onVisibilityToggle,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
