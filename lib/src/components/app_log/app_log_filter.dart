import 'package:flutter/material.dart';
import '../log_filter.dart';
import '../../models/enums.dart';
import '../../models/environments_model.dart';

class AppLogFilter extends StatelessWidget {
  final bool dark;
  final dynamic provider;
  const AppLogFilter({
    Key? key,
    required this.provider,
    required this.dark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Level maxLevel = EnvironmentsModel.getMaxDisplayLevel;
    return LogFilter(
      dark: dark,
      provider: provider,
      padding: const SizedBox(width: 20),
      levelFiltering: DropdownButton(
        value: provider.filterLevel,
        items: [
          const DropdownMenuItem(
            value: Level.nothing,
            child: Text("ALL"),
          ),
          for (var item in provider.currentLevels)
            if (item != Level.nothing)
              DropdownMenuItem(
                value: item,
                enabled: item.index <= maxLevel.index,
                child: Text((item as Level).name.toUpperCase()),
              )
        ],
        onChanged: (value) {
          provider.filterLevel = value as Level;
          provider.filterControl();
        },
      ),
      logType: 'app log',
    );
  }
}
