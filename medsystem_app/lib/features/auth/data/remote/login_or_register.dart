import 'package:flutter/material.dart';
import 'package:medsystem_app/features/auth/presentation/pages/login_page.dart';
import 'package:medsystem_app/features/auth/presentation/pages/register_page.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  //initially, show login
  bool showLoginPage = true;

  //method to toggle between login and register
  void toggle() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return const LoginPage();
    } else {
      return const RegisterPage();
    }
  }
}
