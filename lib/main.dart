import 'package:flutter/material.dart';
import 'package:gigya_native_screensets_engine/bloc/initialization.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<InitializationBloc>(
          create: (_) => InitializationBloc(),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        //TODO Initialization widget should actually wrap the main App widget.
        home: TestEngineInitializationWidget(),
      ),
    );
  }
}

/// Testing initialization logic. This widget is redundant.
/// Main Initialization will commence in the [EngineInitializationWidget].
class TestEngineInitializationWidget extends StatefulWidget {
  @override
  _TestEngineInitializationWidgetState createState() => _TestEngineInitializationWidgetState();
}

class _TestEngineInitializationWidgetState extends State<TestEngineInitializationWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: FutureBuilder(
          future: Provider.of<InitializationBloc>(context).initEngine(),
          builder: (buildContext, snapshot) {
            if (snapshot.hasData) {
              debugPrint('Initialization response: ${snapshot.data.toString()}');
              return Center(
                child: Text(
                  snapshot.data['responseId'],
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
