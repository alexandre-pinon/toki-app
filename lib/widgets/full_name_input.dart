import 'package:flutter/material.dart';

class FullNameInput extends StatelessWidget {
  final TextEditingController fullNameController;

  const FullNameInput({super.key, required this.fullNameController});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: fullNameController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        filled: true,
        prefixIcon: Icon(Icons.account_circle),
        labelText: 'Full name',
      ),
      validator: (value) => (value == null || value.isEmpty)
          ? 'Please enter your full name'
          : null,
    );
  }
}
