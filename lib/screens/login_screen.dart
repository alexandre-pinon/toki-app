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
          children: [LoginForm()],
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _loginFormKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _loginFormKey,
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 16,
          ),
          child: Column(
            children: [
              Text(
                "Welcome back !",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: 24),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  filled: true,
                  prefixIcon: Icon(Icons.email_outlined),
                  labelText: "Email",
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? "Please enter your email"
                    : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                    filled: true,
                    prefixIcon: Icon(Icons.lock_outline),
                    labelText: "Password",
                    suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        icon: _obscurePassword
                            ? Icon(Icons.visibility)
                            : Icon(Icons.visibility_off))),
                validator: (value) => (value == null || value.isEmpty)
                    ? "Please enter your password"
                    : null,
              ),
              SizedBox(height: 24),
              FilledButton(
                onPressed: () => {
                  if (_loginFormKey.currentState!.validate())
                    context.read<AuthProvider>().login()
                },
                child: Text("Login"),
              )
            ],
          ),
        ));
  }
}
