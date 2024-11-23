import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toki_app/providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Home screen"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to toki app user!'),
            ElevatedButton(
              onPressed: () => {context.read<AuthProvider>().logout()},
              child: Text("logout"),
            )
          ],
        ),
      ),
    );
  }
}
