import 'dart:collection';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import '../models/checked_log_entry_model.dart';
import '../models/enums.dart';
import '../models/environments_model.dart';
import '../models/log_event_model.dart';
import '../models/log_printer_model.dart';
import '../models/output_event_model.dart';
import '../models/rendered_event_model.dart';

ListQueue<OutputEventModel> _outputEventBufferWithoutPrefix = ListQueue();
int _bufferSize = 100;
bool _initialized = false;
var _currentId = 0;

class AppLogViewModel with ChangeNotifier, WidgetsBindingObserver {
  static final AppLogViewModel _appLogConsoleViewModel =
      AppLogViewModel._internal();
  factory AppLogViewModel() => _appLogConsoleViewModel;

  AppLogViewModel._internal()
      : assert(_initialized, "Please call AppLogViewModel.init() first.");

  static void init({int bufferSize = 100}) {
    if (_initialized) return;

    _bufferSize = bufferSize;
    _initialized = true;

    AppLogEvent.addOutputListenerWithoutPrefix((event) {
      if (_outputEventBufferWithoutPrefix.length == bufferSize) {
        _outputEventBufferWithoutPrefix.removeFirst();
      }
      _outputEventBufferWithoutPrefix.add(event);
    });
  }

  late OutputCallbackWithoutPrefix _callbackWithoutPrefix;

  final ListQueue<RenderedAppLogEventModel> _renderedBufferWithoutPrefix =
      ListQueue();
  List filteredBufferWithoutPrefix = [];
  List refreshedBuffer = [];

  TextEditingController filterController = TextEditingController();
  bool allChecked = false;

  String copyText = '';
  List<CheckedAndExtendedLogEntryModel> checked = [];

  Level filterLevel = Level.nothing;
  late List<Level> currentLevels = [];

  void initState() {
    // Add events to buffer
    _callbackWithoutPrefix = (event) {
      if (_renderedBufferWithoutPrefix.length == _bufferSize) {
        _renderedBufferWithoutPrefix.removeFirst();
      }

      _renderedBufferWithoutPrefix.add(_renderEvent(event));
      refreshFilter();
    };

    // Add event listener
    AppLogEvent.addOutputListener(_callbackWithoutPrefix);

    currentLevels = [];
    checked = List<CheckedAndExtendedLogEntryModel>.generate(
        _renderedBufferWithoutPrefix.length,
        (index) => CheckedAndExtendedLogEntryModel());
    allChecked = false;

    var temp = 0;
    for (var item in _renderedBufferWithoutPrefix) {
      checked[temp++].logEntry = item;
    }
  }

  void didChangeDependencies() {
    _renderedBufferWithoutPrefix.clear();

    for (var event in _outputEventBufferWithoutPrefix) {
      _renderedBufferWithoutPrefix.add(_renderEvent(event));
    }

    checked = List<CheckedAndExtendedLogEntryModel>.generate(
        _renderedBufferWithoutPrefix.length,
        (index) => CheckedAndExtendedLogEntryModel());
    var temp = 0;
    for (var item in _renderedBufferWithoutPrefix) {
      checked[temp++].logEntry = item;
    }

    currentLevels = [];
    for (var item in _renderedBufferWithoutPrefix) {
      if (!currentLevels.contains(item.level)) currentLevels.add(item.level);
    }

    copyText = '';
    filterLevel = Level.nothing;
    filterController.text = '';
    allChecked = false;

    refreshFilter();
  }

  // Remove event listener
  @override
  void dispose() {
    AppLogEvent.removeOutputListener(_callbackWithoutPrefix);
    super.dispose();
  }

  // Get buffer by filtering
  List getFilteredBuffer(List list) {
    return list.where((it) {
      var logLevelMatches = filterLevel.name == 'nothing'
          ? it.logEntry.level.index <= filterLevel.index
          : it.logEntry.level.index == filterLevel.index;
      if (!logLevelMatches) {
        return false;
      } else if (filterController.text.isNotEmpty) {
        var filterText = filterController.text.toLowerCase();
        return it.logEntry.lowerCaseText.contains(filterText);
      } else {
        return true;
      }
    }).toList();
  }

  void refreshFilter() {
    filteredBufferWithoutPrefix = getFilteredBuffer(checked);
    refreshedBuffer = filteredBufferWithoutPrefix;
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
          var text = element.logEntry.lowerCaseText;
          copyText += refreshedBuffer.last == element ? text : '$text\n\n';
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
    _renderedBufferWithoutPrefix.clear();
    checked = [];
    allChecked = false;
    notifyListeners();
  }

  // Handle single extend button click
  void handleExtendLogIconClick(int index) {
    refreshedBuffer[index].extended = !refreshedBuffer[index].extended;
    notifyListeners();
  }

  // Handle single checkbox button click
  void handleCheckboxClick(int index, bool value) {
    refreshedBuffer[index].checked = value;
    allChecked = true;
    copyText = '';

    for (var element in refreshedBuffer) {
      if (element.checked) {
        var text = element.logEntry.lowerCaseText;
        copyText += refreshedBuffer.last == element ? text : '$text\n\n';
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
          var text = element.logEntry.lowerCaseText;
          copyText += refreshedBuffer.last == element ? text : '$text\n\n';
        }
      }
    }

    notifyListeners();
  }

  // Handle event
  RenderedAppLogEventModel _renderEvent(OutputEventModel event) {
    var text = event.lines.join('\n');
    return RenderedAppLogEventModel(
      _currentId++,
      event.level,
      text.toLowerCase(),
    );
  }
}

// Handle app log
class AppLogger {
  static Level level = Level.nothing;
  final LogPrinterModel _printer;
  bool _active = true;

  AppLogger({
    LogPrinterModel? printer,
    Level? level,
  }) : _printer = printer ?? LogPrinter();

  /// Log a message at level [Level.verbose].
  void v(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    log(Level.verbose, message, error, stackTrace);
  }

  /// Log a message at level [Level.debug].
  void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    log(Level.debug, message, error, stackTrace);
  }

  /// Log a message at level [Level.info].
  void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    log(Level.info, message, error, stackTrace);
  }

  /// Log a message at level [Level.warning].
  void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    log(Level.warning, message, error, stackTrace);
  }

  /// Log a message at level [Level.error].
  void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    log(Level.error, message, error, stackTrace);
  }

  /// Log a message with [level].
  void log(Level level, dynamic message,
      [dynamic error, StackTrace? stackTrace]) {
    if (!_active) {
      throw ArgumentError('Logger has already been closed.');
    } else if (error != null && error is StackTrace) {
      throw ArgumentError('Error parameter cannot take a StackTrace!');
    } else if (level == Level.nothing) {
      throw ArgumentError('Log events cannot have Level.nothing');
    }
    // Log-level handling by development environments
    if (level.index > EnvironmentsModel.getMaxDisplayLevel.index) return;
    var logEvent = LogEventModel(level, message, error, stackTrace);

    // For debug console log
    List<String> output = _printer.log(logEvent, false);

    List<String> outputWithoutPrefix = _printer.log(logEvent, true);
    Set<OutputCallbackWithoutPrefix> outputCallbackWithoutPrefix =
        AppLogEvent.getOutputCallbacksWithoutPrefix;

    if (outputWithoutPrefix.isNotEmpty) {
      var outputEventWithoutPrefix =
          OutputEventModel(level, outputWithoutPrefix);

      // For showing in app
      for (var callback in outputCallbackWithoutPrefix) {
        callback(outputEventWithoutPrefix);
      }

      // For debug console log
      if (output.isNotEmpty) {
        try {
          for (var item in output) {
            developer.log(item);
          }
        } catch (e, s) {
          debugPrint(e as String);
          debugPrint(s as String);
        }
      }
    }
  }

  void close() {
    _active = false;
  }
}

typedef OutputCallback = void Function(OutputEventModel event);
typedef OutputCallbackWithoutPrefix = void Function(OutputEventModel event);

class AppLogEvent {
  static final Set<OutputCallback> _outputCallbacks = {};
  static final Set<OutputCallbackWithoutPrefix> _outputCallbacksWithoutPrefix =
      {};

  static void addOutputListener(OutputCallback callback) {
    _outputCallbacks.add(callback);
  }

  static void removeOutputListener(OutputCallback callback) {
    _outputCallbacks.remove(callback);
  }

  static void addOutputListenerWithoutPrefix(
      OutputCallbackWithoutPrefix callback) {
    _outputCallbacksWithoutPrefix.add(callback);
  }

  static void removeOutputListenerWithoutPrefix(
      OutputCallbackWithoutPrefix callback) {
    _outputCallbacksWithoutPrefix.remove(callback);
  }

  static Set<OutputCallback> get getOutputCallbacks => _outputCallbacks;
  static Set<OutputCallbackWithoutPrefix> get getOutputCallbacksWithoutPrefix =>
      _outputCallbacksWithoutPrefix;
}

class LogPrinter extends LogPrinterModel {
  static const topLeftCorner = '┌';
  static const topRightCorner = '┐';
  static const bottomLeftCorner = '└';
  static const bottomRightCorner = '┘';
  static const middleCorner = '├';
  static const verticalLine = '│';
  static const doubleDivider = '─';
  static const singleDivider = '┄';

  static final levelColors = {
    Level.verbose: Colorizing.fg(Colorizing.grey(0.5)),
    Level.debug: Colorizing.fg(190),
    Level.info: Colorizing.fg(12),
    Level.warning: Colorizing.fg(208),
    Level.error: Colorizing.fg(196),
  };

  static final levelEmojis = {
    Level.verbose: '',
    Level.debug: '🐛 ',
    Level.info: '❗️ ',
    Level.warning: '🚨 ',
    Level.error: '⛔ ',
  };

  static final _deviceStackTraceRegex =
      RegExp(r'#[0-9]+[\s]+(.+) \(([^\s]+)\)');

  static final _webStackTraceRegex =
      RegExp(r'^((packages|dart-sdk)\/[^\s]+\/)');

  static final _browserStackTraceRegex =
      RegExp(r'^(?:package:)?(dart:[^\s]+|[^\s]+)');

  static DateTime? _startTime;

  final int stackTraceBeginIndex;
  final int methodCount;
  final int errorMethodCount;
  final int lineLength;
  final bool colors;
  final bool printEmojis;
  final bool printTime;

  final Map<Level, bool> excludeBox;

  final bool noBoxingByDefault;

  late final Map<Level, bool> includeBox;

  String _topBorder = '';
  String _middleBorder = '';
  String _bottomBorder = '';

  LogPrinter({
    this.stackTraceBeginIndex = 0,
    this.methodCount = 2,
    this.errorMethodCount = 8,
    this.lineLength = 110,
    this.colors = true,
    this.printEmojis = true,
    this.printTime = false,
    this.excludeBox = const {},
    this.noBoxingByDefault = false,
  }) {
    _startTime ??= DateTime.now();

    var doubleDividerLine = StringBuffer();
    var singleDividerLine = StringBuffer();
    for (var i = 0; i < lineLength - 1; i++) {
      doubleDividerLine.write(doubleDivider);
      singleDividerLine.write(singleDivider);
    }

    _topBorder = '$topLeftCorner$doubleDividerLine$topRightCorner';
    _middleBorder = '$middleCorner$singleDividerLine';
    _bottomBorder = '$bottomLeftCorner$doubleDividerLine$bottomRightCorner';

    includeBox = {};
    for (var l in Level.values) {
      includeBox[l] = !noBoxingByDefault;
    }
    excludeBox.forEach((k, v) => includeBox[k] = !v);
  }

  @override
  List<String> log(LogEventModel event, bool isWithoutPrefix) {
    var messageStr = stringifyMessage(event.message);

    String? stackTraceStr;
    if (event.stackTrace == null) {
      if (methodCount > 0) {
        stackTraceStr = formatStackTrace(StackTrace.current, methodCount);
      }
    } else if (errorMethodCount > 0) {
      stackTraceStr = formatStackTrace(event.stackTrace, errorMethodCount);
    }

    var errorStr = event.error?.toString();

    String? timeStr;
    if (printTime) {
      timeStr = getTime();
    }

    List<String> logForDebugConsole = _formatAndPrint(
      event.level,
      messageStr,
      isWithoutPrefix,
      timeStr,
      errorStr,
      stackTraceStr,
    );

    return logForDebugConsole;
  }

  String? formatStackTrace(StackTrace? stackTrace, int methodCount) {
    var lines = stackTrace.toString().split('\n');
    if (stackTraceBeginIndex > 0 && stackTraceBeginIndex < lines.length - 1) {
      lines = lines.sublist(stackTraceBeginIndex);
    }
    var formatted = <String>[];
    var count = 0;
    for (var line in lines) {
      if (_discardDeviceStacktraceLine(line) ||
          _discardWebStacktraceLine(line) ||
          _discardBrowserStacktraceLine(line) ||
          line.isEmpty) {
        continue;
      }
      formatted.add('#$count   ${line.replaceFirst(RegExp(r'#\d+\s+'), '')}');
      if (++count == methodCount) {
        break;
      }
    }

    if (formatted.isEmpty) {
      return null;
    } else {
      return formatted.join('\n');
    }
  }

  bool _discardDeviceStacktraceLine(String line) {
    var match = _deviceStackTraceRegex.matchAsPrefix(line);
    if (match == null) {
      return false;
    }
    return match.group(2)!.startsWith('package:logger');
  }

  bool _discardWebStacktraceLine(String line) {
    var match = _webStackTraceRegex.matchAsPrefix(line);
    if (match == null) {
      return false;
    }
    return match.group(1)!.startsWith('packages/logger') ||
        match.group(1)!.startsWith('dart-sdk/lib');
  }

  bool _discardBrowserStacktraceLine(String line) {
    var match = _browserStackTraceRegex.matchAsPrefix(line);
    if (match == null) {
      return false;
    }
    return match.group(1)!.startsWith('package:logger') ||
        match.group(1)!.startsWith('dart:');
  }

  String getTime() {
    String _threeDigits(int n) {
      if (n >= 100) return '$n';
      if (n >= 10) return '0$n';
      return '00$n';
    }

    String _twoDigits(int n) {
      if (n >= 10) return '$n';
      return '0$n';
    }

    var now = DateTime.now();
    var h = _twoDigits(now.hour);
    var min = _twoDigits(now.minute);
    var sec = _twoDigits(now.second);
    var ms = _threeDigits(now.millisecond);
    var timeSinceStart = now.difference(_startTime!).toString();
    return '$h:$min:$sec.$ms (+$timeSinceStart)';
  }

  Object toEncodableFallback(dynamic object) {
    return object.toString();
  }

  String stringifyMessage(dynamic message) {
    final finalMessage = message is Function ? message() : message;
    if (finalMessage is Map || finalMessage is Iterable) {
      var encoder = JsonEncoder.withIndent('  ', toEncodableFallback);
      return encoder.convert(finalMessage);
    } else {
      return finalMessage.toString();
    }
  }

  Colorizing _getLevelColor(Level level, bool isWithoutPrefix) {
    if (isWithoutPrefix) return Colorizing.none();
    if (colors) {
      return levelColors[level]!;
    } else {
      return Colorizing.none();
    }
  }

  Colorizing _getErrorColor(Level level) {
    if (colors) {
      return levelColors[Level.error]!.toBg();
    } else {
      return Colorizing.none();
    }
  }

  String _getEmoji(Level level) {
    if (printEmojis) {
      return levelEmojis[level]!;
    } else {
      return '';
    }
  }

  // Coloring print message by log level
  List<String> _formatAndPrint(
    Level level,
    String message,
    bool isWithoutPrefix,
    String? time,
    String? error,
    String? stacktrace,
  ) {
    List<String> buffer = [];
    var color = _getLevelColor(level, isWithoutPrefix);
    bool withoutPrefix = (includeBox[level]!) && isWithoutPrefix;
    var verticalLineAtLevel = !withoutPrefix ? ('$verticalLine ') : '';

    if (!withoutPrefix) buffer.add(color(_topBorder));

    if (error != null) {
      var errorColor = _getErrorColor(level);
      for (var line in error.split('\n')) {
        buffer.add(
          verticalLineAtLevel +
              errorColor.resetForeground +
              errorColor(line) +
              errorColor.resetBackground,
        );
      }
      if (!withoutPrefix) buffer.add(color(_middleBorder));
    }

    if (stacktrace != null) {
      for (var line in stacktrace.split('\n')) {
        buffer.add(color('$verticalLineAtLevel$line'));
      }
      if (!withoutPrefix) buffer.add(color(_middleBorder));
    }

    if (time != null) {
      buffer.add(color('$verticalLineAtLevel$time'));
      if (!withoutPrefix) buffer.add(color(_middleBorder));
    }

    var emoji = _getEmoji(level);
    for (var line in message.split('\n')) {
      buffer.add(color('$verticalLineAtLevel$emoji$line'));
    }
    if (!withoutPrefix) buffer.add(color(_bottomBorder));

    return buffer;
  }
}

// For Debug Console
class Colorizing {
  static const ansiEsc = '\x1B[';

  static const ansiDefault = '${ansiEsc}0m';

  final int? fg;
  final int? bg;
  final bool color;

  Colorizing.none()
      : fg = null,
        bg = null,
        color = false;

  Colorizing.fg(this.fg)
      : bg = null,
        color = true;

  Colorizing.bg(this.bg)
      : fg = null,
        color = true;

  @override
  String toString() {
    if (fg != null) {
      return '${ansiEsc}38;5;${fg}m';
    } else if (bg != null) {
      return '${ansiEsc}48;5;${bg}m';
    } else {
      return '';
    }
  }

  String call(String msg) {
    if (color) {
      return '${this}$msg$ansiDefault';
    } else {
      return msg;
    }
  }

  Colorizing toFg() => Colorizing.fg(bg);

  Colorizing toBg() => Colorizing.bg(fg);

  String get resetForeground => color ? '${ansiEsc}39m' : '';

  String get resetBackground => color ? '${ansiEsc}49m' : '';

  static int grey(double level) => 232 + (level.clamp(0.0, 1.0) * 23).round();
}
