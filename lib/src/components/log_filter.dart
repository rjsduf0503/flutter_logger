import 'package:flutter/material.dart';
import 'log_bar.dart';

class LogFilter extends StatelessWidget {
  final dynamic provider;
  final Widget padding;
  final Widget levelFiltering;
  final String logType;
  final bool dark;

  const LogFilter({
    Key? key,
    required this.provider,
    this.padding = const SizedBox.shrink(),
    this.levelFiltering = const SizedBox.shrink(),
    required this.logType,
    required this.dark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LogBar(
      dark: dark,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            child: TextField(
              style: const TextStyle(fontSize: 20),
              controller: provider.filterController,
              onChanged: (s) => provider.filterControl(),
              decoration: InputDecoration(
                labelText: logType == 'app log'
                    ? 'Filter $logType output'
                    : 'Filter $logType uri',
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          padding,
          levelFiltering,
        ],
      ),
    );
  }
}
