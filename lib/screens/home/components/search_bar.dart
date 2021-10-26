import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lomi/screens/home/home_viewmodel.dart';
import 'package:provider/provider.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({
    Key? key,
  }) : super(key: key);

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          height: 50,
          width: MediaQuery.of(context).size.width - 48,
          child: TextField(
            enabled: false,
            decoration: InputDecoration(
              floatingLabelBehavior: FloatingLabelBehavior.never,
              prefixIcon: const Icon(Icons.my_location),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(width: 2, color: Colors.grey[400]!),
              ),
              fillColor: Colors.black.withOpacity(0.1),
              filled: true,
              labelText: 'Where do you want to go?',
              labelStyle: TextStyle(color: Colors.black.withOpacity(0.55)),
            ),
          ),
        ),
      );
  
  }
}
