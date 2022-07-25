import 'package:flutter/material.dart';
import '../../components/client_log/detail/request_card.dart';
import '../../components/client_log/detail/response_card.dart';
import '../../components/custom_material_app.dart';
import '../../components/log_header.dart';
import '../../global_functions.dart';

class ClientLogDetailScreen extends StatelessWidget {
  final dynamic logEntry;

  const ClientLogDetailScreen({Key? key, required this.logEntry})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String stringHttp = stringfyHttp(logEntry, errorType: logEntry.errorType);
    bool dark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return CustomMaterialApp(
      dark: dark,
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          LogHeader(
            parentContext: context,
            dark: dark,
            consoleType: 'Client Log Detail',
            stringHttp: stringHttp,
          ),
          RequestCard(request: logEntry.request),
          logEntry.response != null
              ? ResponseCard(response: logEntry.response)
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
