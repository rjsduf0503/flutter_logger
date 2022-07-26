# Flutter Logger

You can see app, network logs to help your debugging 🐞

[![GitHub stars](https://img.shields.io/github/stars/rjsduf0503/flutter_logger.svg?style=social)](https://github.com/rjsduf0503/flutter_logger)

## Development Stack
<p align="center">
  <img src="https://img.shields.io/badge/Flutter->=1.17.0-blue" />
  <img src="https://img.shields.io/badge/provider-v6.0.3-blue" />
  <img src="https://img.shields.io/badge/VSCode-blue" />
</p>
<p align="center" text-align="center" width="100%">
  <img src="https://img.shields.io/github/contributors/rjsduf0503/flutter_logger?color=brightgreen" />
  <img src="https://img.shields.io/github/last-commit/rjsduf0503/flutter_logger?color=red" />
  <img src="https://img.shields.io/github/commit-activity/w/rjsduf0503/flutter_logger?color=red" />
</p>

## Demo
<table style="margin:auto;">
    <tr>
        <th>Test Screen</th>
        <th>App Log Screen</th>
    </tr>
    <tr>
        <td style="text-align:center;"><image src="https://user-images.githubusercontent.com/34560965/180914427-1c7e36d7-b328-45c3-8edc-cc2fe4ce0c3b.gif" width=240px/></td>
        <td style="text-align:center;"><image src="https://user-images.githubusercontent.com/34560965/180914425-1f43885a-f838-42bd-b509-a814bb1df4ff.gif" width=240px/></td>
    </tr>
    <tr>
        <th>Client Log Screen</th>
        <th>Intergrated Log Screen</th>
    </tr>
    <tr>
        <td style="text-align:center;"><image src="https://user-images.githubusercontent.com/34560965/180914421-542f8a2b-5682-4824-9c70-9a34d681a6c4.gif" width=240px/></td>
        <td style="text-align:center;"><image src="https://user-images.githubusercontent.com/34560965/180914403-d3342cfe-d49e-4785-942f-b09877bee3ac.gif" width=240px/></td>
    </tr>
</table>

## Installation

Add dependency to `pubspec.yaml`

```yaml
dependencies:
  ...
  flutter_logger: ^1.0.0
```

Run in your terminal

```sh
flutter pub get
```

## Example

```dart
import 'package:flutter_logger/flutter_logger.dart';
    // ...
    // add FlutterLogger() to your top of you app in any child
    chidren: [
        // ...
        FlutterLogger(),
        // ...
    ]


  // for app logs
  // when error occurs in your application, you can see app logs


  // for client logs
void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
        // then call clientLogger.${method}('url', {data, ...})
        clientLogger.get('exampleURL');

        // ...

        // or make your own dio communication method just by insert ClientLogIntercepter()
        doDioCommunication('exampleURL2', data: "data");
    });
}

// ...
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
```

More see at 
  > [Example code](./example/lib/main.dart) <br/>


## License

> MIT License </br>
> Copyright (c) 2022 Geonyeol Ryu