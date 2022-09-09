import 'enums.dart';

class LogEventModel {
  final Level level;
  final dynamic message;
  final dynamic error;
  final StackTrace? stackTrace;

  LogEventModel(this.level, this.message, this.error, this.stackTrace);
}
