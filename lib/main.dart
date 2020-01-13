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
          home: EngineInitializationWidget()),
    );
  }
}

class EngineInitializationWidget extends StatefulWidget {
  @override
  _EngineInitializationWidgetState createState() =>
      _EngineInitializationWidgetState();
}

class _EngineInitializationWidgetState
    extends State<EngineInitializationWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: FutureBuilder(
              future: Provider.of<InitializationBloc>(context).initEngine(),
              builder: (buildContext, snapshot) {
                if (snapshot.hasData) {
                  return Text(snapshot.data);
                } else {
                  return SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                      backgroundColor: Theme.of(context).primaryColor,
                      strokeWidth: 4,
                    ),
                  );
                }
              }),
        ),
      ),
    );
  }
}
