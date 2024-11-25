import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toki_app/errors/auth_error.dart';
import 'package:toki_app/main.dart';
import 'package:toki_app/providers/auth_provider.dart';
import 'package:toki_app/screens/register_screen.dart';
import 'package:toki_app/widgets/divider_with_text.dart';
import 'package:toki_app/widgets/email_input.dart';
import 'package:toki_app/widgets/google_login_button.dart';
import 'package:toki_app/widgets/password_input.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LoginHeader(),
              SizedBox(height: 48),
              LoginForm(),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Welcome back !',
      style: Theme.of(context).textTheme.displaySmall,
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          children: [
            EmailInput(emailController: _emailController),
            SizedBox(height: 16),
            PasswordInput(
                passwordController: _passwordController,
                obscurePassword: _obscurePassword,
                onVisibilityToggle: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                }),
            SizedBox(height: 24),
            Row(children: [
              Expanded(
                child: LoginButton(
                  formKey: _formKey,
                  emailController: _emailController,
                  passwordController: _passwordController,
                ),
              ),
            ]),
            SizedBox(height: 24),
            DividerWithText('Or sign in with'),
            SizedBox(height: 24),
            Row(children: [
              Expanded(
                child: GoogleLoginButton('Sign in with google'),
              ),
            ]),
            SizedBox(height: 24),
            SignUpRedirect()
          ],
        ));
  }
}

class LoginButton extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const LoginButton({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () async {
        if (formKey.currentState!.validate()) {
          final email = emailController.text.trim();
          final password = passwordController.text.trim();

          final authProvider = context.read<AuthProvider>();

          try {
            await authProvider.login(email, password);
          } on InvalidCredentials catch (e) {
            showGlobalSnackBar(e.toString());
          }
        }
      },
      child: Text('Sign in'),
    );
  }
}

class SignUpRedirect extends StatelessWidget {
  const SignUpRedirect({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}
