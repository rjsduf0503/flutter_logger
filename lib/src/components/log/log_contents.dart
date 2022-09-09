import 'package:flutter/material.dart';
import '../client_log/content/client_log_content.dart';
import '../log_checkbox.dart';
import '../../global_functions.dart';
import '../../models/rendered_event_model.dart';

class LogContents extends StatelessWidget {
  final bool dark;
  final dynamic provider;

  const LogContents({
    Key? key,
    this.provider,
    required this.dark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var buffer = provider.refreshedBuffer;
    return Container(
      decoration: BoxDecoration(
        color: dark ? const Color.fromARGB(255, 22, 22, 22) : Colors.grey[150],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemBuilder: (context, index) {
          var logEntry = buffer[index].logEntry;
          if (logEntry.runtimeType == RenderedAppLogEventModel) {
            Color? color = getLevelColorsInApp(logEntry.level, dark);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: color!,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Center(
                              child: Text(
                                logEntry.level
                                    .toString()
                                    .split('.')
                                    .last
                                    .toUpperCase(),
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              const SizedBox(height: 10),
                              Text(
                                logEntry.lowerCaseText,
                                style: TextStyle(
                                  color: color,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      LogCheckbox(
                        provider: provider,
                        index: index,
                        position: const [-5, -10],
                        color: color,
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return ClientLogContent(
                provider: provider, index: index, logEntry: logEntry);
          }
        },
        itemCount: buffer.length,
      ),
    );
  }
}
