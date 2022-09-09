// ignore_for_file: deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'components/flutter_logger_overlay.dart';
import 'models/enums.dart';
import 'models/environments_model.dart';
import 'view_models/app_log_view_model.dart';
import 'view_models/client_log_view_model.dart';
import 'view_models/log_view_model.dart';

AppLogger appLogger = AppLogger();
ClientLogger clientLogger = ClientLogger();

class FlutterLogger extends StatefulWidget {
  const FlutterLogger({Key? key}) : super(key: key);

  @override
  FlutterLoggerState createState() => FlutterLoggerState();
}

class FlutterLoggerState extends State<FlutterLogger> {
  // Initialize overlay
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterLoggerOverlay.setOverlay = context;
      FlutterLoggerOverlay.insertOverlay();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //Initialize view models
    AppLogViewModel.init();
    ClientLogViewModel.init();
    LogViewModel.init();

    // For error handling
    // You can change case by exception runtimeType by editting this function
    FlutterError.onError = (FlutterErrorDetails details) {
      final dynamic exception = details.exception;

      // todo: AssertionError vs _AssertionError
      if (exception.runtimeType.toString() == '_AssertionError') {
        appLogger.d(exception);
        return;
      }
      switch (exception.runtimeType) {
        case IntegerDivisionByZeroException:
        case RangeError:
        case ArgumentError:
        case NullThrownError:
        case OutOfMemoryError:
        case StackOverflowError:
        case StateError:
          appLogger.e(exception);
          break;
        case NoSuchMethodError:
        case FallThroughError:
        case CyclicInitializationError:
        case ConcurrentModificationError:
        case FormatException:
        case TypeError:
        case UnimplementedError:
        case UnsupportedError:
          appLogger.w(exception);
          break;
        case FlutterError:
          appLogger.i(exception);
          break;
        case AssertionError:
        case Error:
        case Exception:
          appLogger.d(exception);
          break;
        default:
          appLogger.v(exception);
          break;
      }
    };

    // Check development environments
    if (kDebugMode) {
      EnvironmentsModel.setEnvironment(Environment.debug);
    } else if (kProfileMode) {
      EnvironmentsModel.setEnvironment(Environment.profile);
    } else if (kReleaseMode) {
      EnvironmentsModel.setEnvironment(Environment.release);
    }

    return const SizedBox.shrink();
  }
}
