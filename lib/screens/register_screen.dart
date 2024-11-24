import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toki_app/providers/auth_provider.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [RegisterForm()],
        ),
      ),
    );
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Text(
                'Create your account',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              SizedBox(height: 48),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  filled: true,
                  prefixIcon: Icon(Icons.account_circle),
                  labelText: 'Full name',
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Please enter your full name'
                    : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  filled: true,
                  prefixIcon: Icon(Icons.email_outlined),
                  labelText: 'Email',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }

                  final emailRegex =
                      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Enter a valid email address';
                  }

                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                      filled: true,
                      prefixIcon: Icon(Icons.lock_outline),
                      labelText: 'Password',
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: _obscurePassword
                              ? Icon(Icons.visibility)
                              : Icon(Icons.visibility_off))),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }

                    final passwordRegex = RegExp(
                        r'^(?=.*[0-9])(?=.*[!@#$%^&*])(?=.*[A-Za-z])[A-Za-z\d!@#$%^&*]{8,}$');
                    if (!passwordRegex.hasMatch(value)) {
                      return 'Password must be at least 8 characters, include a number, and a special character';
                    }

                    return null;
                  }),
              SizedBox(height: 24),
              Row(children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () {},
                    child: Text('Sign up'),
                  ),
                ),
              ]),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Or sign up with',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      icon: Image.asset(
                        'assets/google_logo.png',
                        height: 24,
                        width: 24,
                      ),
                      label: Text('Sign up with Google'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account?'),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Sign in'),
                  ),
                ],
              )
            ],
          ),
        ));
  }
}
