import 'package:flutter/material.dart';

class ElevatedColorButton extends StatelessWidget {
  final String text;
  final Function pressEvent;
  final bool boxShadow;
  final Color buttonColor;
  final Color textColor;
  const ElevatedColorButton(
      {Key? key,
      required this.text,
      required this.pressEvent,
      this.boxShadow = true,
      this.buttonColor = Colors.red,
      this.textColor = Colors.white})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          boxShadow
              ? const BoxShadow(
                  color: Colors.black,
                  blurRadius: 2.0,
                  offset: Offset(2.0, 2.0),
                )
              : const BoxShadow(color: Colors.transparent),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: buttonColor,
          onPrimary: textColor,
        ),
        onPressed: () {
          pressEvent();
        },
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
