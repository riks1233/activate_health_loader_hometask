import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:activate_health_loader_hometask/app_provider.dart';
import 'package:activate_health_loader_hometask/colors.dart';
import 'package:activate_health_loader_hometask/loader.dart';


void main() => runApp(const App());

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const MaterialApp(
        home: AppBody(),
      ),
    );
  }
}

class AppBody extends StatelessWidget {
  const AppBody({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    AppProvider appProvider = context.read<AppProvider>();
    double loadedValue = context.watch<AppProvider>().loadedValue;
    return Scaffold(
      body: Container(
        color: AppColors.background,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: ActivateHealthProgressIndicator(value: loadedValue),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(onPressed: () => appProvider.loadedValue += 10.0, child: Text('Add 10% loaded')),
                  TextButton(onPressed: () => appProvider.loadedValue = 0.0, child: Text('Reset loaded')),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

