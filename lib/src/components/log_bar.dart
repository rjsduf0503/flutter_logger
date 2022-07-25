import 'package:flutter/material.dart';

class LogBar extends StatelessWidget {
  final Widget child;
  final bool dark;

  const LogBar({Key? key, required this.child, required this.dark})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom:
                BorderSide(color: Color.fromARGB(255, 76, 76, 76), width: 1),
            top: BorderSide(color: Color.fromARGB(255, 76, 76, 76), width: 1),
          ),
        ),
        child: Material(
          color: dark ? const Color.fromARGB(255, 29, 29, 29) : Colors.white,
          elevation: 3.0,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
            child: child,
          ),
        ),
      ),
    );
  }
}
