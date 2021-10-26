import 'package:flutter/cupertino.dart';

class HomeViewmodel extends ChangeNotifier {
  String addressQuery = '';

  setAddressQuery(val) {
    addressQuery = val;
    notifyListeners();
  }
}
