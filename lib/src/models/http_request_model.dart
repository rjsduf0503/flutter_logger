class HttpRequestModel {
  final dynamic requestTime;
  final String method;
  final String url;
  final Map<String, dynamic>? queryParameters;
  final Map<String, dynamic>? header;
  final dynamic body;

  HttpRequestModel(this.requestTime, this.method, this.url, this.queryParameters,
      this.header, this.body);
}
