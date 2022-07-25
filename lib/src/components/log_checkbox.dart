import 'package:flutter/material.dart';

class LogCheckbox extends StatelessWidget {
  final dynamic provider;
  final int index;
  final List<double> position;
  final Color color;

  const LogCheckbox(
      {Key? key,
      required this.provider,
      required this.index,
      required this.position,
      required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position[0],
      top: position[1],
      child: Transform.scale(
        scale: 1.2,
        child: Checkbox(
            activeColor: color,
            side: MaterialStateBorderSide.resolveWith(
              (states) => BorderSide(width: 2, color: color),
            ),
            splashRadius: 18,
            value: provider.refreshedBuffer[index].checked,
            onChanged: (value) {
              provider.handleCheckboxClick(index, value);
            }),
      ),
    );
  }
}
