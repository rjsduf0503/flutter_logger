import 'package:flutter/material.dart';
import '../../global_functions.dart';

class AppLogExtendButton extends StatelessWidget {
  final dynamic provider;
  final bool dark;
  final int index;

  const AppLogExtendButton(
      {Key? key,
      required this.provider,
      required this.dark,
      required this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var temp = provider.refreshedBuffer[index];
    Color? color = getLevelColorsInApp(temp.logEntry.level, dark);
    return Positioned(
      right: 2,
      top: -1,
      child: InkWell(
        onTap: (() {
          provider.handleExtendLogIconClick(index);
        }),
        child: temp.extended
            ? Icon(Icons.remove, color: color, size: 32)
            : Icon(Icons.add, color: color, size: 32),
      ),
    );
  }
}
