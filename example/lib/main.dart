import 'package:flutter/material.dart';
import 'package:flutter_logger/flutter_logger.dart';

import 'app_log_test.dart';
import 'network_log_test.dart';

void main() {
  runApp(
    const MaterialApp(
      title: 'Flutter Logger',
      home: TestApp(),
    ),
  );
}

class TestApp extends StatefulWidget {
  const TestApp({Key? key}) : super(key: key);
  @override
  TestAppState createState() => TestAppState();
}

class TestAppState extends State<TestApp> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      doDioCommunication('exampleURL2', data: "data");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Test Screen 1"),
        backgroundColor: Colors.grey.shade900,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TestApp2(),
                ),
              );
            },
            icon: const Icon(Icons.chevron_right, size: 40),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: const [
            FlutterLogger(),
            SizedBox(height: 20),
            CenterBoldText(text: 'App Log Test'),
            AppLogTest(),
            CenterBoldText(text: 'Client Log Test'),
            NetworkLogTest(),
          ],
        ),
      ),
    );
  }
}

class TestApp2 extends StatelessWidget {
  const TestApp2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Test Screen 2"),
        backgroundColor: Colors.grey.shade800,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TestApp3(),
                ),
              );
            },
            icon: const Icon(Icons.chevron_right, size: 40),
          ),
        ],
      ),
    );
  }
}

class TestApp3 extends StatelessWidget {
  const TestApp3({
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Test Screen 3"),
        backgroundColor: Colors.grey.shade700,
      ),
    );
  }
}

class BuildCustomButton extends StatelessWidget {
  final String text;
  final Function pressEvent;
  final bool boxShadow;
  final Color buttonColor;
  final Color textColor;
  const BuildCustomButton(
      {Key? key,
      required this.text,
      required this.pressEvent,
      this.boxShadow = true,
      this.buttonColor = Colors.red,
      this.textColor = Colors.white})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          boxShadow
              ? const BoxShadow(
                  color: Colors.black,
                  blurRadius: 2.0,
                  offset: Offset(2.0, 2.0),
                )
              : const BoxShadow(color: Colors.transparent),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: buttonColor,
          onPrimary: textColor,
        ),
        onPressed: () {
          pressEvent();
        },
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class CenterBoldText extends StatelessWidget {
  final String text;
  const CenterBoldText({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            blurRadius: 2.0,
            offset: Offset(1.0, 1.0),
          )
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
