import 'package:flutter/material.dart';
import 'package:lomi/screens/home/home.dart';
import 'package:lomi/screens/sign_in/sign_in_view.dart';
import 'package:provider/provider.dart';

import 'sign_in_controller.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final signInController = Provider.of<SignInController>(context);
    return signInController.userName == null
        ? const SignInView()
        : const Home();
  }
}
