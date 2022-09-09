import 'package:flutter/material.dart';
import '../components/custom_material_app.dart';
import '../components/log/log_contents.dart';
import '../components/log/log_filter.dart';
import '../components/log_header.dart';
import '../view_models/log_view_model.dart';
import 'package:provider/provider.dart';

class LogScreen extends StatefulWidget {
  const LogScreen({Key? key}) : super(key: key);

  @override
  LogScreenState createState() => LogScreenState();
}

class LogScreenState extends State<LogScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    LogViewModel().initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    LogViewModel().didChangeDependencies();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    bool dark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Consumer<LogViewModel>(
      builder: (context, provider, child) {
        return CustomMaterialApp(
          dark: dark,
          child: Column(
            children: <Widget>[
              LogHeader(
                parentContext: context,
                dark: dark,
                consoleType: 'Log',
                provider: provider,
              ),
              Expanded(
                child: LogContents(dark: dark, provider: provider),
              ),
              LogFilter(dark: dark, provider: provider),
            ],
          ),
        );
      },
    );
  }
}
