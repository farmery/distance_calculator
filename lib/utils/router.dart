import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lomi/screens/home/home.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (_) => const Home());
    default:
      return MaterialPageRoute(builder: (_) => const Home());
  }
}
