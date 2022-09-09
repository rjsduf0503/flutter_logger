import 'package:flutter/material.dart';
import '../components/app_log/app_log_contents.dart';
import '../components/app_log/app_log_filter.dart';
import '../components/custom_material_app.dart';
import '../components/log_header.dart';
import '../view_models/app_log_view_model.dart';
import 'package:provider/provider.dart';

class AppLogScreen extends StatefulWidget {
  const AppLogScreen({Key? key}) : super(key: key);

  @override
  AppLogScreenState createState() => AppLogScreenState();
}

class AppLogScreenState extends State<AppLogScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    AppLogViewModel().initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    AppLogViewModel().didChangeDependencies();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    bool dark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Consumer<AppLogViewModel>(
      builder: (context, provider, child) {
        return CustomMaterialApp(
          dark: dark,
          child: Column(
            children: <Widget>[
              LogHeader(
                parentContext: context,
                dark: dark,
                consoleType: 'App Log',
                provider: provider,
              ),
              Expanded(
                child: AppLogContents(dark: dark, provider: provider),
              ),
              AppLogFilter(dark: dark, provider: provider),
            ],
          ),
        );
      },
    );
  }
}
