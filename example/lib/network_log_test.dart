import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_logger/flutter_logger.dart';

import 'main.dart';

class NetworkLogTest extends StatelessWidget {
  const NetworkLogTest({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
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
              text: 'Get Success',
              pressEvent: () {
                clientLogger.get('https://reqres.in/api/users/2');
              },
              buttonColor: Colors.green,
            ),
            BuildCustomButton(
              text: 'Get Failed',
              pressEvent: () {
                clientLogger.get('https://reqres.in/apiusers/23');
              },
            ),
            BuildCustomButton(
              text: 'Post Success',
              pressEvent: () {
                clientLogger.post(
                  'https://reqres.in/api/users',
                  data: {"name": "morpheus", "job": "leader"},
                );
              },
              buttonColor: Colors.green,
            ),
            BuildCustomButton(
              text: 'Post Failed',
              pressEvent: () {
                clientLogger.post(
                  'https://reqres.in/apiregister',
                  data: {"email": "sydney@fife"},
                );
              },
            ),
            BuildCustomButton(
              text: 'Put Success',
              pressEvent: () {
                clientLogger.put(
                  'https://reqres.in/api/users/2',
                  data: {"name": "morpheus", "job": "zion resident"},
                );
              },
              buttonColor: Colors.green,
            ),
            BuildCustomButton(
              text: 'Put Failed',
              pressEvent: () {
                clientLogger.put(
                  'https://reqres.in/apiusers/2',
                  data: {"name": "morpheus", "job": "zion resident"},
                );
              },
            ),
            BuildCustomButton(
              text: 'Patch Success',
              pressEvent: () {
                clientLogger.patch(
                  'https://reqres.in/api/users/2',
                  data: {"name": "morpheus", "job": "zion resident"},
                );
              },
              buttonColor: Colors.green,
            ),
            BuildCustomButton(
              text: 'Patch Failed',
              pressEvent: () {
                clientLogger.patch(
                  'https://reqres.in/apiusers/2',
                  data: {"name": "morpheus", "job": "zion resident"},
                );
              },
            ),
            BuildCustomButton(
              text: 'Delete Success',
              pressEvent: () {
                clientLogger.delete('https://reqres.in/api/users/2');
              },
              buttonColor: Colors.green,
            ),
            BuildCustomButton(
              text: 'Delete Failed',
              pressEvent: () {
                clientLogger.delete('https://reqres.in/apiusers/2');
              },
            ),
            BuildCustomButton(
              text: 'Time out',
              pressEvent: () {
                clientLogger.get('https://reqres.in/api/users/2', timeout: 1);
              },
            ),
          ],
        ),
      ),
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
