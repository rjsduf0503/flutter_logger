import 'package:dio/dio.dart';
import 'enums.dart';
import 'http_request_model.dart';

class RenderedClientLogEventModel {
  final int id;
  final HttpRequestModel request;
  final Response? response;
  final String? errorType;

  RenderedClientLogEventModel(this.id, this.request, this.response,
      {this.errorType});
}

class RenderedAppLogEventModel {
  final int id;
  final Level level;
  final String lowerCaseText;

  RenderedAppLogEventModel(this.id, this.level, this.lowerCaseText);
}
