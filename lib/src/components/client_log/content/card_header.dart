import 'package:flutter/material.dart';
import 'response_type.dart';
import '../../../global_functions.dart';

class CardHeader extends StatelessWidget {
  final String requestTime;
  final dynamic responseType;
  final String requestMethod;
  final dynamic timeDifference;
  const CardHeader(
      {Key? key,
      required this.requestTime,
      required this.responseType,
      required this.requestMethod,
      required this.timeDifference})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String stringTimeDifference = getTimeDifference(timeDifference).toString();
    return Expanded(
      child: Row(
        children: [
          Text(requestTime),
          const SizedBox(width: 5),
          ResponseType(responseType: responseType),
          const SizedBox(width: 5),
          Text(requestMethod),
          const SizedBox(width: 5),
          Text(stringTimeDifference),
        ],
      ),
    );
  }
}
