import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_logger/flutter_logger.dart';

void main() {
  runApp(const MaterialApp(title: 'Flutter Logger', home: TestApp()));
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
      clientLogger.get('exampleURL');
      doDioCommunication('exampleURL2', data: "data");
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Container(
          width: screenWidth,
          height: screenHeight,
          decoration: BoxDecoration(color: Colors.purple.shade100),
          child: Column(
            children: [
              const Text("Test Screen 1"),
              TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TestApp2(
                              screenWidth: screenWidth,
                              screenHeight: screenHeight)),
                    );
                  },
                  child: const Text("Next Page")),
              const FlutterLogger(),
              TextButton(
                  child: const Text("Overflow Test"),
                  onPressed: () {
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
                        });
                  }),
            ],
          )),
    );
  }
}

class TestApp2 extends StatelessWidget {
  const TestApp2({
    Key? key,
    required this.screenWidth,
    required this.screenHeight,
  }) : super(key: key);
  final double screenWidth;
  final double screenHeight;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
          width: screenWidth,
          height: screenHeight,
          decoration: const BoxDecoration(color: Colors.yellow),
          child: Column(
            children: [
              const Text("Test Screen 2"),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Prev Page")),
              TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TestApp3(
                              screenWidth: screenWidth,
                              screenHeight: screenHeight)),
                    );
                  },
                  child: const Text("Next Page"))
            ],
          )),
    );
  }
}

class TestApp3 extends StatelessWidget {
  const TestApp3({
    Key? key,
    required this.screenWidth,
    required this.screenHeight,
  }) : super(key: key);
  final double screenWidth;
  final double screenHeight;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
          width: screenWidth,
          height: screenHeight,
          decoration: const BoxDecoration(color: Colors.orange),
          child: Column(
            children: [
              const Text("Test Screen 3"),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Prev Screen"))
            ],
          )),
    );
  }
}

void doDioCommunication(String url, {data}) async {
  final dio = Dio()
    ..interceptors.add(
      ClientLogInterceptor(),
    );
  DateTime requestTime = DateTime.now().toLocal();
  var request = HttpRequestModel(
    requestTime,
    dio.options.method,
    dio.options.baseUrl + url,
    dio.options.queryParameters,
    dio.options.headers,
    data,
  );

  try {
    Response response = await dio.request(
      url,
      data: data,
      queryParameters: dio.options.queryParameters,
      options: Options(method: 'POST'),
    );
    DateTime responseTime = DateTime.now().toLocal();
    response.headers['date']?[0] = responseTime.toString();

    var httpModel = HttpModel(request, response);
    Set<OutputCallback> outputCallbacks = ClientLogEvent.getOutputCallbacks;

    // For showing in app
    for (var callback in outputCallbacks) {
      callback(httpModel);
    }
  } on DioError catch (error) {
    var httpModel =
        HttpModel(request, error.response, errorType: error.type.name);
    Set<OutputCallback> outputCallbacks = ClientLogEvent.getOutputCallbacks;

    // For showing in app
    for (var callback in outputCallbacks) {
      callback(httpModel);
    }
  }
  // Other Error handling
  on Error catch (error) {
    debugPrint(error as String);
  }
}
