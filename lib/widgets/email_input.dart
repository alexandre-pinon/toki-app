import 'package:flutter/material.dart';

class EmailInput extends StatelessWidget {
  final TextEditingController emailController;

  const EmailInput({super.key, required this.emailController});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        filled: true,
        prefixIcon: Icon(Icons.email_outlined),
        labelText: 'Email',
      ),
      controller: emailController,
      validator: validate,
    );
  }

  String? validate(value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }

    return null;
  }
}
