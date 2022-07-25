import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ResponseCard extends StatelessWidget {
  final dynamic response;
  const ResponseCard({Key? key, required this.response}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12.0),
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'RESPONSE',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            _buildCardContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildCardContent() {
    var stringResponseTime = response.headers['date']?.first;
    DateTime responseTime = DateTime.parse(stringResponseTime);
    var hms = DateFormat.Hms().format(responseTime);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('[Response Time]  =>  $hms'),
        Text('[Status Code]  =>  ${response.statusCode}'),
        Text('[Status Message]  =>  ${response.statusMessage}'),
        Text('[Response Header]  =>  ${{response.headers}}'),
        response.requestOptions.responseType == ResponseType.json
            ? Text('[Response Body]  =>  ${response.data}')
            : Text(
                '[Response Type]  =>  ${response.requestOptions.responseType}'),
        Text('[Extras]  =>  ${response.extra}'),
      ],
    );
  }
}
