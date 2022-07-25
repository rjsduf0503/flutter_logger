import 'package:flutter/material.dart';
import '../components/flutter_logger_overlay.dart';
import '../pages/app_log_screen.dart';
import '../pages/client_log/client_log_detail_screen.dart';
import '../pages/client_log/client_log_screen.dart';
import '../pages/log_screen.dart';
import '../view_models/app_log_view_model.dart';
import '../view_models/client_log_view_model.dart';
import '../view_models/log_view_model.dart';
import 'package:provider/provider.dart';

void handleRouting(context, item, {logEntry}) {
  Navigator.of(context).push(PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        Routing(item, logEntry),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = const Offset(1.0, 0.0);
      var end = Offset.zero;
      var curve = Curves.ease;
      var curveTween = CurveTween(curve: curve);

      var tween = Tween(begin: begin, end: end).chain(curveTween);

      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  ));
}

final AppLogViewModel appLogViewModel = AppLogViewModel();
final ClientLogViewModel clientLogViewModel = ClientLogViewModel();
final LogViewModel logViewModel = LogViewModel();

// If assertion error occurs, you can delay milliseconds more than 250ms
Future<void> futureRemoveOverlay() async {
  await Future.delayed(const Duration(milliseconds: 250))
      .then((_) => FlutterLoggerOverlay.removeOverlay());
}

class Routing extends StatelessWidget {
  final String item;
  final dynamic logEntry;

  const Routing(this.item, this.logEntry, {Key? key}) : super(key: key);

  Widget getStackBody(context) {
    switch (item) {
      case "App Log":
        futureRemoveOverlay();
        return ChangeNotifierProvider.value(
          value: appLogViewModel,
          child: const AppLogScreen(),
        );
      case "Client Log":
        futureRemoveOverlay();
        return ChangeNotifierProvider.value(
          value: clientLogViewModel,
          child: const ClientLogScreen(),
        );
      case "Client Log Detail":
        return ClientLogDetailScreen(logEntry: logEntry);
      case 'Log':
        futureRemoveOverlay();
        return ChangeNotifierProvider.value(
          value: logViewModel,
          child: const LogScreen(),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getStackBody(context),
    );
  }
}
