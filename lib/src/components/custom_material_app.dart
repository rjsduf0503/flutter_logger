import 'package:flutter/material.dart';

class CustomMaterialApp extends StatelessWidget {
  final bool dark;
  final Widget child;
  final Widget? fab;

  const CustomMaterialApp({
    Key? key,
    required this.child,
    this.fab,
    required this.dark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          brightness: Brightness.light,
          secondary: Colors.black,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          brightness: Brightness.dark,
          secondary: Colors.white,
        ),
      ),
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          color: dark
              ? const Color.fromARGB(255, 47, 47, 47)
              : const Color.fromARGB(0, 255, 255, 255),
          child: SafeArea(
            child: child,
          ),
        ),
        floatingActionButton: fab,
      ),
    );
  }
}
