import 'package:flutter/material.dart';

class GoogleLoginButton extends StatelessWidget {
  final String text;

  const GoogleLoginButton(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
      ),
      icon: Image.asset(
        'assets/google_logo.png',
        height: 24,
        width: 24,
      ),
      label: Text(text),
    );
  }
}
