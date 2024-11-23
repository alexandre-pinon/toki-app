import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toki_app/providers/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Login screen"),
            ElevatedButton(
              onPressed: () => {context.read<AuthProvider>().login()},
              child: Text("login"),
            )
          ],
        ),
      ),
    );
  }
}
