import 'package:flutter/material.dart';
import 'card_header.dart';
import 'detail_button.dart';
import '../../log_checkbox.dart';
import '../../../routes/routing.dart';
import 'package:intl/intl.dart';

class ClientLogContent extends StatelessWidget {
  final dynamic logEntry;
  final dynamic provider;
  final int index;
  const ClientLogContent(
      {Key? key,
      required this.logEntry,
      required this.provider,
      required this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    dynamic stringResponseTime = logEntry.response?.headers?['date']?.first;
    dynamic responseTime =
        stringResponseTime != null ? DateTime.parse(stringResponseTime) : null;
    String requestTime = DateFormat.Hms().format(logEntry.request.requestTime);
    dynamic responseType = logEntry.response != null
        ? logEntry.response.statusCode
        : logEntry.errorType;
    dynamic requestMethod = logEntry.request.method;
    dynamic timeDifference = responseTime != null
        ? responseTime.difference(logEntry.request.requestTime)
        : '';
    return Card(
      margin: const EdgeInsets.all(12.0),
      elevation: 4.0,
      child: Stack(
        children: [
          LogCheckbox(
            provider: provider,
            index: index,
            position: const [6, 18],
            color: Colors.blue.shade500,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(58, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CardHeader(
                      requestTime: requestTime,
                      responseType: responseType,
                      requestMethod: requestMethod,
                      timeDifference: timeDifference,
                    ),
                    GestureDetector(
                        onTap: () {
                          handleRouting(context, 'Client Log Detail',
                              logEntry: logEntry);
                        },
                        child: const DetailButton()),
                  ],
                ),
                const SizedBox(height: 12.0),
                Text(logEntry.request.url),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
