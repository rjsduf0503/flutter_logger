import 'package:flutter/material.dart';
import '../elevated_color_button.dart';
import '../log_bar.dart';

class LogFilter extends StatelessWidget {
  final bool dark;
  final dynamic provider;
  const LogFilter({Key? key, required this.provider, required this.dark})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // dark = WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
    Color textColor = dark ? Colors.grey.shade100 : Colors.black87;
    Color buttonColor = dark ? Colors.white12 : Colors.grey.shade200;
    return LogBar(
      dark: dark,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.max,
        children: [
          ElevatedColorButton(
            text: 'ALL',
            buttonColor: buttonColor,
            textColor: textColor,
            boxShadow: false,
            pressEvent: () {
              provider.filterController.text = '';
              provider.filterControl();
            },
          ),
          ElevatedColorButton(
            text: 'App Log',
            buttonColor: buttonColor,
            textColor: textColor,
            boxShadow: false,
            pressEvent: () {
              provider.filterController.text = 'RenderedAppLogEventModel';
              provider.filterControl();
            },
          ),
          ElevatedColorButton(
            text: 'Client Log',
            buttonColor: buttonColor,
            textColor: textColor,
            boxShadow: false,
            pressEvent: () {
              provider.filterController.text = 'RenderedClientLogEventModel';
              provider.filterControl();
            },
          ),
        ],
      ),
    );
  }
}
