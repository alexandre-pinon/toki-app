import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toki_app/errors/auth_error.dart';
import 'package:toki_app/main.dart';
import 'package:toki_app/providers/auth_provider.dart';
import 'package:toki_app/widgets/divider_with_text.dart';
import 'package:toki_app/widgets/email_input.dart';
import 'package:toki_app/widgets/full_name_input.dart';
import 'package:toki_app/widgets/google_login_button.dart';
import 'package:toki_app/widgets/password_input.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RegisterHeader(),
              SizedBox(height: 48),
              RegisterForm(),
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterHeader extends StatelessWidget {
  const RegisterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Create your account',
      style: Theme.of(context).textTheme.displaySmall,
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
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          children: [
            FullNameInput(fullNameController: _fullNameController),
            SizedBox(height: 16),
            EmailInput(emailController: _emailController),
            SizedBox(height: 16),
            PasswordInput(
              passwordController: _passwordController,
              obscurePassword: _obscurePassword,
              onVisibilityToggle: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            SizedBox(height: 24),
            Row(children: [
              Expanded(
                child: RegisterButton(
                  formKey: _formKey,
                  fullNameController: _fullNameController,
                  emailController: _emailController,
                  passwordController: _passwordController,
                ),
              ),
            ]),
            SizedBox(height: 24),
            DividerWithText('Or sign up with'),
            SizedBox(height: 24),
            Row(children: [
              Expanded(
                child: GoogleLoginButton('Sign up with google'),
              ),
            ]),
            SizedBox(height: 24),
            SignInRedirect()
          ],
        ));
  }
}

class RegisterButton extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const RegisterButton({
    super.key,
    required this.formKey,
    required this.fullNameController,
    required this.emailController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () async {
        if (formKey.currentState!.validate()) {
          final fullName = fullNameController.text.trim();
          final email = emailController.text.trim();
          final password = passwordController.text.trim();

          final navigator = Navigator.of(context);
          final authProvider = context.read<AuthProvider>();

          try {
            await authProvider.register(fullName, email, password);
            navigator.pop();
          } on EmailAlreadyExist catch (e) {
            showGlobalSnackBar(e.toString());
          }
        }
      },
      child: Text('Sign up'),
    );
  }
}

class SignInRedirect extends StatelessWidget {
  const SignInRedirect({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}
