import 'package:flutter/cupertino.dart';

class SignInController extends ChangeNotifier {
  String? userName;
  String? password;

  void loginUser(String userName, String password) {
    this.userName = userName;
    this.password = password;
    notifyListeners();
  }
}
