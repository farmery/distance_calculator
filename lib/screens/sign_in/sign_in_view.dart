import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'sign_in_controller.dart';

class SignInView extends StatefulWidget {
  const SignInView({Key? key}) : super(key: key);

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  late GlobalKey<FormState> key;

  @override
  void initState() {
    super.initState();
    key = GlobalKey<FormState>();
  }

  @override
  Widget build(BuildContext context) {
    final loginController = Provider.of<SignInController>(context);
    String userName = '';
    String password = '';
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          currentFocus.focusedChild!.unfocus();
        }
      },
      child: SafeArea(
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: key,
              child: Column(children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                TextFormField(
                  keyboardType: TextInputType.name,
                  onChanged: (val) {
                    setState(() => userName = val);
                  },
                  validator: (val) {
                    if (val!.length < 2) {
                      return 'Please Enter a Valid Username';
                    }
                  },
                  decoration: const InputDecoration(hintText: 'Username'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  onChanged: (val) {
                    setState(() => password = val);
                  },
                  validator: (val) {
                    if (val!.length < 7) {
                      return 'Please Enter a Strong password';
                    }
                  },
                  decoration: const InputDecoration(hintText: 'Password'),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    color: Theme.of(context).colorScheme.secondary,
                    child: const Text('Sign in'),
                    onPressed: () {
                      if (key.currentState!.validate()) {
                        loginController.loginUser(userName, password);
                      }
                    },
                  ),
                )
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
