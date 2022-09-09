import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RequestCard extends StatelessWidget {
  final dynamic request;
  const RequestCard({Key? key, this.request}) : super(key: key);

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
                'REQUEST',
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
    var requestTime = DateFormat.Hms().format(request.requestTime);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Request Time: $requestTime'),
        Text('Request Method: ${request.method}'),
        Text('Request URI: ${request.url}'),
        Text('Query Parameters: ${request.queryParameters}'),
        Text('Request Header: ${request.header}'),
        Text('Request Body: ${request.body}'),
      ],
    );
  }
}
