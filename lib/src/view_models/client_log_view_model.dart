import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../global_functions.dart';
import '../models/checked_log_entry_model.dart';
import '../models/http_model.dart';
import '../models/http_request_model.dart';
import '../models/rendered_event_model.dart';

ListQueue<HttpModel> _outputEventBuffer = ListQueue();
bool _initialized = false;
int _bufferSize = 100;
var _currentId = 0;

class ClientLogViewModel with ChangeNotifier {
  static final ClientLogViewModel _clientLogConsoleViewModel =
      ClientLogViewModel._internal();
  factory ClientLogViewModel() => _clientLogConsoleViewModel;

  ClientLogViewModel._internal()
      : assert(_initialized, "Please call ClientLogViewModel.init() first.");

  static void init({int bufferSize = 100}) {
    if (_initialized) return;

    _bufferSize = bufferSize;
    _initialized = true;

    ClientLogEvent.addOutputListener((event) {
      if (_outputEventBuffer.length == bufferSize) {
        _outputEventBuffer.removeFirst();
      }
      _outputEventBuffer.add(event);
    });
  }

  late OutputCallback _callback;

  final ListQueue<RenderedClientLogEventModel> _renderedBuffer = ListQueue();
  List filteredBuffer = [];
  List refreshedBuffer = [];

  var filterController = TextEditingController();
  bool allChecked = false;

  String copyText = '';
  List<CheckedLogEntryModel> checked = [];

  void initState() {
    // Add events to buffer
    _callback = (event) {
      if (_renderedBuffer.length == _bufferSize) {
        _renderedBuffer.removeFirst();
      }
      _renderedBuffer.add(_renderEvent(event));
      refreshFilter();
    };

    // Add event listener
    ClientLogEvent.addOutputListener(_callback);

    checked = List<CheckedLogEntryModel>.generate(
        _renderedBuffer.length, (index) => CheckedLogEntryModel());
    allChecked = false;

    var temp = 0;
    for (var item in _renderedBuffer) {
      checked[temp++].logEntry = item;
    }
  }

  void didChangeDependencies() {
    _renderedBuffer.clear();

    for (var event in _outputEventBuffer) {
      _renderedBuffer.add(_renderEvent(event));
    }

    checked = List<CheckedLogEntryModel>.generate(
        _renderedBuffer.length, (index) => CheckedLogEntryModel());
    allChecked = false;

    var temp = 0;
    for (var item in _renderedBuffer) {
      checked[temp++].logEntry = item;
    }

    copyText = '';
    filterController.text = '';
    allChecked = false;

    refreshFilter();
  }

  // Remove event listener
  @override
  void dispose() {
    ClientLogEvent.removeOutputListener(_callback);
    super.dispose();
  }

  // Handle event
  RenderedClientLogEventModel _renderEvent(HttpModel value) {
    return RenderedClientLogEventModel(
      _currentId++,
      value.request,
      value.response,
      errorType: value.errorType,
    );
  }

  // Get buffer by filtering
  List getFilteredBuffer(List list) {
    return list.where((it) {
      if (filterController.text.isNotEmpty) {
        var filterText = filterController.text.toLowerCase();
        return it.logEntry.request.url.contains(filterText);
      } else {
        return true;
      }
    }).toList();
  }

  void refreshFilter() {
    filteredBuffer = getFilteredBuffer(checked);
    refreshedBuffer = filteredBuffer;
    notifyListeners();
  }

  // Handle buffer by filter controlling
  void filterControl() {
    refreshFilter();
    allChecked = true;
    copyText = '';
    if (refreshedBuffer.isEmpty) {
      allChecked = false;
    } else {
      for (var element in refreshedBuffer) {
        if (element.checked) {
          var stringHttp = stringfyHttp(element.logEntry);
          copyText +=
              refreshedBuffer.last == element ? stringHttp : '$stringHttp\n\n';
        } else {
          allChecked = false;
        }
      }
    }
    notifyListeners();
  }

  // Temporary refresh buffer
  void refreshBuffer() {
    refreshedBuffer = [];
    copyText = '';
    _renderedBuffer.clear();
    checked = [];
    allChecked = false;
    notifyListeners();
  }

  // Handle single checkbox button click
  void handleCheckboxClick(int index, bool value) {
    refreshedBuffer[index].checked = value;
    allChecked = true;
    copyText = '';

    for (var element in refreshedBuffer) {
      if (element.checked) {
        var stringHttp = stringfyHttp(element.logEntry);
        copyText +=
            refreshedBuffer.last == element ? stringHttp : '$stringHttp\n\n';
      } else {
        allChecked = false;
      }
    }

    notifyListeners();
  }

  // Handle entire checkbox button click
  void handleAllCheckboxClick() {
    for (var item in refreshedBuffer) {
      item.checked = !allChecked;
    }

    allChecked = !allChecked;

    copyText = '';
    if (allChecked) {
      for (var element in refreshedBuffer) {
        if (element.checked) {
          var stringHttp = stringfyHttp(element.logEntry);
          copyText +=
              refreshedBuffer.last == element ? stringHttp : '$stringHttp\n\n';
        }
      }
    }

    notifyListeners();
  }
}

typedef OutputCallback = void Function(HttpModel value);

class ClientLogEvent {
  static final Set<OutputCallback> _outputCallbacks = {};

  static void addOutputListener(OutputCallback callback) {
    _outputCallbacks.add(callback);
  }

  static void removeOutputListener(OutputCallback callback) {
    _outputCallbacks.remove(callback);
  }

  static Set<OutputCallback> get getOutputCallbacks => _outputCallbacks;
}

// Custom dio [Interceptor]
// Showing [response], [request], [error] message by using [debugPrint]
class ClientLogInterceptor extends Interceptor {
  late DateTime requestTime;
  late RequestOptions reqOptions;
  var debugPrint = (String? message,
          {int? wrapWidth, String? currentState, dynamic time}) =>
      debugPrintSynchronouslyWithText(
        message!,
        wrapWidth: wrapWidth,
        currentState: currentState,
        time: time,
      );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    requestTime = DateTime.now().toLocal();
    reqOptions = options;
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    var status = response.statusMessage;
    debugPrint('     ===== Dio $status [Start] =====',
        currentState: status, time: requestTime);
    debugPrint('     method => ${reqOptions.method}',
        currentState: status, time: requestTime);
    debugPrint('     uri => ${reqOptions.uri}',
        currentState: status, time: requestTime);
    debugPrint('     requestHeader => ${reqOptions.headers}',
        currentState: status, time: requestTime);
    debugPrint('     requestBody => ${reqOptions.data}',
        currentState: status, time: requestTime);

    DateTime responseTime = DateTime.now().toLocal();
    debugPrint('     responseStatus => ${response.statusCode.toString()}',
        currentState: status, time: responseTime);
    debugPrint(
        '     responseCorrelationId => a7aa5198-8bb3-40f3-aa30-0c0889a02222',
        currentState: status,
        time: responseTime);
    debugPrint('     responseBody => ${response.data}',
        currentState: status, time: responseTime);
    debugPrint('     ===== Dio $status [End] =====',
        currentState: status, time: responseTime);
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    var status = err.type.name;
    debugPrint('     ===== Dio $status [Start] =====',
        currentState: status, time: requestTime);
    debugPrint('     method => ${reqOptions.method}',
        currentState: status, time: requestTime);
    debugPrint('     uri => ${reqOptions.uri}',
        currentState: status, time: requestTime);
    debugPrint('     requestHeader => ${reqOptions.headers}',
        currentState: status, time: requestTime);
    debugPrint('     requestBody => ${reqOptions.data}',
        currentState: status, time: requestTime);
    debugPrint('     ===== Dio $status [End] =====',
        currentState: status, time: requestTime);
    return super.onError(err, handler);
  }
}

BaseOptions baseOptions = BaseOptions(
  connectTimeout: 10000,
  receiveTimeout: 10000,
  followRedirects: false,
  validateStatus: (status) {
    return status! < 600;
  },
);

// Handle client log
class ClientLogger {
  void get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    int? timeout,
  }) {
    doDio('GET', url,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
        timeout: timeout);
  }

  void post(
    String url, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    doDio('POST', url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress);
  }

  void put(
    String url, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    doDio(
      'PUT',
      url,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  void delete(
    String url, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    doDio(
      'DELETE',
      url,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  void patch(
    String url, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    doDio(
      'PATCH',
      url,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  void doDio(
    String type,
    String url, {
    Map<String, dynamic>? queryParameters,
    data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    int? timeout,
  }) async {
    BaseOptions dioOptions = timeout == null
        ? baseOptions.copyWith(
            queryParameters: queryParameters,
            method: type,
          )
        : baseOptions.copyWith(
            queryParameters: queryParameters,
            method: type,
            connectTimeout: timeout,
            receiveTimeout: timeout,
          );
    // Adding [intercepter] to our [Dio] model
    final dio = Dio(dioOptions)
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
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      DateTime responseTime = DateTime.now().toLocal();
      response.headers['date']?[0] = responseTime.toString();

      var httpModel = HttpModel(request, response);
      Set<OutputCallback> outputCallbacks = ClientLogEvent.getOutputCallbacks;

      // For showing in app
      for (var callback in outputCallbacks) {
        callback(httpModel);
      }
    }
    // Dio Error handling
    on DioError catch (error) {
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
}
