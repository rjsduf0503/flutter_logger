import 'package:flutter/material.dart';
import '../routes/routing.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class Fab extends StatelessWidget {
  const Fab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size.width * 0.15;

    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      buttonSize: Size(size, size),
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      overlayColor: Colors.grey,
      overlayOpacity: 0.5,
      spacing: 15,
      spaceBetweenChildren: 10,
      children: [
        SpeedDialChild(
            child: const Icon(Icons.wysiwyg),
            label: 'Log',
            onTap: () {
              handleRouting(context, 'Log');
            }),
        SpeedDialChild(
            child: const Icon(Icons.last_page_outlined),
            label: 'App Log',
            onTap: () {
              handleRouting(context, 'App Log');
            }),
        SpeedDialChild(
            child: const Icon(Icons.public),
            label: 'Client Log',
            onTap: () {
              handleRouting(context, 'Client Log');
            }),
      ],
    );
  }
}
