import 'package:flutter/material.dart';
import '../log_filter.dart';

class ClientLogFilter extends StatelessWidget {
  final bool dark;
  final dynamic provider;
  const ClientLogFilter({
    Key? key,
    required this.provider,
    required this.dark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LogFilter(
      dark: dark,
      provider: provider,
      logType: 'client log',
    );
  }
}
