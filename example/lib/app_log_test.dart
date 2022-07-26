import 'package:flutter/material.dart';
import 'package:flutter_logger/flutter_logger.dart';

import 'main.dart';

class AppLogTest extends StatelessWidget {
  const AppLogTest({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      child: GridView.count(
        childAspectRatio: 3,
        shrinkWrap: true,
        primary: false,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        crossAxisCount: 2,
        children: [
          BuildCustomButton(
            text: 'App Error Test',
            pressEvent: () {
              appLogger.e('error test');
              appLogger.v('verbose test');
              appLogger.d('debug test');
              appLogger.i('info test');
              appLogger.w('warning test');
            },
          ),
          BuildCustomButton(
            text: 'Overflow Error Test',
            pressEvent: () {
              overflowError(context);
            },
          ),
          BuildCustomButton(
            text: 'IntegerDivisionByZeroException Error Test',
            pressEvent: () {
              divideError();
            },
          ),
          BuildCustomButton(
            text: 'Range Error Test',
            pressEvent: () {
              rangeError();
            },
          ),
          BuildCustomButton(
            text: 'Type Error Test',
            pressEvent: () {
              typeError();
            },
          ),
          BuildCustomButton(
            text: 'Assert Error Test',
            pressEvent: () {
              assertError();
            },
          ),
        ],
      ),
    );
  }
}

divideError() {
  try {
    return throw 1 ~/ 0;
  } catch (error) {
    FlutterError.reportError(FlutterErrorDetails(
      exception: error,
    ));
  }
}

rangeError() {
  List<int> fixedList = List<int>.filled(5, 0);
  try {
    return throw fixedList[6];
  } on RangeError catch (error) {
    FlutterError.reportError(FlutterErrorDetails(
      exception: error,
    ));
  }
}

// for not debug mode
typeError() {
  try {
    throw NoSuchMethodError.withInvocation;
  } catch (error) {
    FlutterError.reportError(FlutterErrorDetails(
      exception: error,
    ));
  }
}

assertError() {
  int number = 200;
  try {
    assert(number < 100);
  } catch (error) {
    FlutterError.reportError(FlutterErrorDetails(
      exception: error,
    ));
  }
}

void overflowError(context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Padding(
          padding: const EdgeInsets.only(bottom: 30.0),
          child: Row(
            children: const [
              Text(
                '-------------- Overflow Error Test --------------',
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text("Close"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}
