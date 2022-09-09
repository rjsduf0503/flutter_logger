import 'package:flutter/material.dart';

class DetailButton extends StatelessWidget {
  const DetailButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.blue[400], borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 2, 4, 2),
        child: Row(
          children: const [
            Text('Detail ', style: TextStyle(color: Colors.white)),
            Icon(Icons.search, size: 16, color: Colors.white),
          ],
        ),
      ),
    );
  }
}