import 'log_event_model.dart';

abstract class LogPrinterModel {
  void init() {}

  List<String> log(LogEventModel event, bool isWithoutPrefix);

  void destroy() {}
}
