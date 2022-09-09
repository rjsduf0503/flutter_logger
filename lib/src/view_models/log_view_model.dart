import 'dart:collection';

import 'package:flutter/material.dart';
import '../global_functions.dart';
import '../models/checked_log_entry_model.dart';
import '../models/output_event_model.dart';
import '../models/rendered_event_model.dart';
import 'app_log_view_model.dart' as applog;
import 'client_log_view_model.dart' as clientlog;

ListQueue _outputEventBuffer = ListQueue();
int _bufferSize = 200;
bool _initialized = false;
var _currentId = 0;

class LogViewModel with ChangeNotifier {
  static final LogViewModel _logConsoleViewModel = LogViewModel._internal();
  factory LogViewModel() => _logConsoleViewModel;

  LogViewModel._internal()
      : assert(_initialized, "Please call LogViewModel.init() first.");

  static void init({int bufferSize = 200}) {
    if (_initialized) return;

    _bufferSize = bufferSize;
    _initialized = true;

    applog.AppLogEvent.addOutputListenerWithoutPrefix((event) {
      if (_outputEventBuffer.length == bufferSize) {
        _outputEventBuffer.removeFirst();
      }
      _outputEventBuffer.add(event);
    });

    clientlog.ClientLogEvent.addOutputListener((event) {
      if (_outputEventBuffer.length == bufferSize) {
        _outputEventBuffer.removeFirst();
      }
      _outputEventBuffer.add(event);
    });
  }

  late applog.OutputCallbackWithoutPrefix _appLogCallback;
  late clientlog.OutputCallback _clientLogCallback;

  final ListQueue _renderedBuffer = ListQueue();
  List filteredBuffer = [];
  List refreshedBuffer = [];

  final filterController = TextEditingController();
  bool allChecked = false;

  String copyText = '';
  List<CheckedLogEntryModel> checked = [];

  void initState() {
    // Add events to buffers
    _appLogCallback = (event) {
      if (_renderedBuffer.length == _bufferSize) {
        _renderedBuffer.removeFirst();
      }
      _renderedBuffer.add(_renderEvent(event));

      refreshFilter();
    };
    _clientLogCallback = (event) {
      if (_renderedBuffer.length == _bufferSize) {
        _renderedBuffer.removeFirst();
      }
      _renderedBuffer.add(_renderEvent(event));

      refreshFilter();
    };

    // Add event listeners
    clientlog.ClientLogEvent.addOutputListener(_clientLogCallback);
    applog.AppLogEvent.addOutputListener(_appLogCallback);

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
    var temp = 0;
    for (var item in _renderedBuffer) {
      checked[temp++].logEntry = item;
    }

    copyText = '';
    filterController.text = '';
    allChecked = false;

    refreshFilter();
  }

  // Remove event listeners
  @override
  void dispose() {
    applog.AppLogEvent.removeOutputListener(_appLogCallback);
    clientlog.ClientLogEvent.removeOutputListener(_clientLogCallback);
    super.dispose();
  }

  // Handle event
  dynamic _renderEvent(event) {
    if (event.runtimeType == OutputEventModel) {
      var text = event.lines.join('\n');
      return RenderedAppLogEventModel(
        _currentId++,
        event.level,
        text.toLowerCase(),
      );
    } else {
      return RenderedClientLogEventModel(
        _currentId++,
        event.request,
        event.response,
        errorType: event.errorType,
      );
    }
  }

  // Get buffer by filtering
  List getFilteredBuffer(List list) {
    return list.where((it) {
      if (filterController.text.isNotEmpty) {
        var filterText = filterController.text;
        return it.logEntry.runtimeType.toString() == filterText;
      } else {
        return true;
      }
    }).toList();
  }

  void refreshFilter() {
    filteredBuffer = getFilteredBuffer(checked);
    refreshedBuffer = filteredBuffer;
  }

  // Handle buffer by filter controlling
  void filterControl() {
    refreshFilter();
    allChecked = true;
    copyText = '';
    for (var item in refreshedBuffer) {
      if (!item.checked) {
        allChecked = false;
        break;
      }
    }
    for (var element in refreshedBuffer) {
      if (element.checked) {
        if (element.logEntry.runtimeType == RenderedClientLogEventModel) {
          var stringHttp = stringfyHttp(element.logEntry);
          copyText +=
              refreshedBuffer.last == element ? stringHttp : '$stringHttp\n\n';
        } else {
          var text = element.logEntry.lowerCaseText;
          copyText += refreshedBuffer.last == element ? text : '$text\n\n';
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
    for (var item in refreshedBuffer) {
      if (item.checked == false) {
        allChecked = false;
        break;
      }
    }

    copyText = '';
    for (var element in refreshedBuffer) {
      if (element.checked) {
        if (element.logEntry.runtimeType == RenderedClientLogEventModel) {
          var stringHttp = stringfyHttp(element.logEntry);
          copyText +=
              refreshedBuffer.last == element ? stringHttp : '$stringHttp\n\n';
        } else {
          var text = element.logEntry.lowerCaseText;
          copyText += refreshedBuffer.last == element ? text : '$text\n\n';
        }
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
          if (element.logEntry.runtimeType == RenderedClientLogEventModel) {
            var stringHttp = stringfyHttp(element.logEntry);
            copyText += refreshedBuffer.last == element
                ? stringHttp
                : '$stringHttp\n\n';
          } else {
            var text = element.logEntry.lowerCaseText;
            copyText += refreshedBuffer.last == element ? text : '$text\n\n';
          }
        }
      }
    }
    notifyListeners();
  }
}
