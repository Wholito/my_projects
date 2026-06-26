import 'package:flutter/material.dart';

class AuthForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePasswordVisibility;
  final bool showLabels;

  const AuthForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePasswordVisibility,
    this.showLabels = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: showLabels ? 'Email' : null,
            hintText: 'Email',
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Введите email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Некорректный email';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: passwordController,
          decoration: InputDecoration(
            labelText: showLabels ? 'Пароль' : null,
            hintText: 'Пароль',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: onTogglePasswordVisibility,
            ),
          ),
          obscureText: obscurePassword,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Введите пароль';
            }
            if (value.length < 6) {
              return 'Пароль должен быть минимум 6 символов';
            }
            return null;
          },
        ),
      ],
    );
  }
}