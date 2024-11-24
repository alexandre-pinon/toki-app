import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toki_app/errors/auth_error.dart';
import 'package:toki_app/main.dart';
import 'package:toki_app/providers/auth_provider.dart';
import 'package:toki_app/screens/register_screen.dart';

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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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
                'Welcome back !',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              SizedBox(height: 48),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  filled: true,
                  prefixIcon: Icon(Icons.email_outlined),
                  labelText: 'Email',
                ),
                controller: _emailController,
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Please enter your email'
                    : null,
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
                controller: _passwordController,
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Please enter your password'
                    : null,
              ),
              SizedBox(height: 24),
              Row(children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final email = _emailController.text.trim();
                        final password = _passwordController.text.trim();

                        try {
                          final authProvider = context.read<AuthProvider>();
                          await authProvider.login(email, password);
                        } on InvalidCredentials catch (e) {
                          showGlobalSnackBar(e.toString());
                        }
                      }
                    },
                    child: Text('Sign in'),
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
                      'Or sign in with',
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
                      label: Text('Sign in with Google'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterScreen(),
                        ),
                      );
                    },
                    child: Text('Sign up'),
                  ),
                ],
              )
            ],
          ),
        ));
  }
}
