import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toki_app/errors/auth_error.dart';
import 'package:toki_app/models/user.dart';
import 'package:toki_app/providers/auth_provider.dart';
import 'package:toki_app/providers/user_provider.dart';
import 'package:toki_app/widgets/full_name_input.dart';

class ChangeUserNameScreen extends StatelessWidget {
  final User user;

  const ChangeUserNameScreen({super.key, required this.user});

  Future<void> _editName(BuildContext context, String name) async {
    final userProvider = context.read<UserProvider>();
    final authProvider = context.read<AuthProvider>();
    final navigator = Navigator.of(context);

    try {
      await userProvider.updateName(name);
      navigator.pop();
    } on Unauthenticated {
      await authProvider.logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final fullNameController = TextEditingController(text: user.name);

    return Scaffold(
      appBar: AppBar(
        title: Text('Change name'),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FullNameInput(fullNameController: fullNameController),
            FilledButton(
              onPressed: () async {
                await _editName(context, fullNameController.text.trim());
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
