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
    } else if (value.length < 8) {
      return 'Password must be at least 8 characters';
    } else if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must include a number';
    } else if (!RegExp(r'[!@#\$&*~]').hasMatch(value)) {
      return 'Password must include a special character';
    }
    return null;
  }
}
