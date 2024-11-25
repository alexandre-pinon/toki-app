import 'package:flutter/material.dart';

class PasswordInput extends StatelessWidget {
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onVisibilityToggle;

  const PasswordInput({
    super.key,
    required this.passwordController,
    required this.obscurePassword,
    required this.onVisibilityToggle,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: obscurePassword,
      decoration: InputDecoration(
        filled: true,
        prefixIcon: Icon(Icons.lock_outline),
        labelText: 'Password',
        suffixIcon: IconButton(
          onPressed: onVisibilityToggle,
          icon: Icon(obscurePassword ? Icons.visibility : Icons.visibility_off),
        ),
      ),
      controller: passwordController,
      validator: validate,
    );
  }

  String? validate(value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }

    final passwordRegex = RegExp(
        r'^(?=.*[0-9])(?=.*[!@#$%^&*])(?=.*[A-Za-z])[A-Za-z\d!@#$%^&*]{8,}$');
    if (!passwordRegex.hasMatch(value)) {
      return 'Password must be at least 8 characters, include a number, and a special character';
    }

    return null;
  }
}
