import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool
  isPrimary; // true untuk gaya ElevatedButton, false untuk OutlinedButton
  final Color greenText;

  const ActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isPrimary = true,
    required this.greenText,
  });

  @override
  Widget build(BuildContext context) {
    const buttonSize = Size(320, 53);
    final textStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: isPrimary
          ? Colors.white
          : greenText,
    );

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    );

    return SizedBox(
      width: buttonSize.width,
      height: buttonSize.height,
      child: isPrimary
          // Jika isPrimary true, gunakan ElevatedButton
          ? ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: greenText,
                shape: buttonShape,
                elevation: 0,
              ),
              child: Text(label, style: textStyle),
            )
          // Jika isPrimary false, gunakan OutlinedButton
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: greenText),
                shape: buttonShape,
              ),
              child: Text(label, style: textStyle),
            ),
    );
  }
}
