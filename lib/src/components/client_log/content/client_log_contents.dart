import 'package:flutter/material.dart';
import 'client_log_content.dart';

class ClientLogContents extends StatelessWidget {
  final dynamic provider;
  const ClientLogContents({Key? key, required this.provider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var buffer = provider.refreshedBuffer;
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return ClientLogContent(
              provider: provider,
              index: index,
              logEntry: buffer[index].logEntry);
        },
        itemCount: buffer.length,
      ),
    );
  }
}
