import 'package:flutter/material.dart';
import 'package:gigya_native_screensets_engine/nss_ignition.dart';
import 'package:gigya_native_screensets_engine/models/main.dart';
import 'package:gigya_native_screensets_engine/blocs/nss_registry_bloc.dart';
import 'package:gigya_native_screensets_engine/nss_runner.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<NssRegistryBloc>(
          create: (_) => NssRegistryBloc(),
        ),
      ],
      child: NssIgnitionWidget(
        layoutScreenSet: (Main main, String initialRoute) {
          return NssLayoutBuilder(initialRoute).render(main.screens);
        },
        //TODO: Set this value as false when building frameworks!!
        useMockData: true,
      ),
//      child: TestWidget(),
    );
  }
}

class TestWidget extends StatefulWidget {
  @override
  _TestWidgetState createState() => _TestWidgetState();
}

class _TestWidgetState extends State<TestWidget> {
  GlobalKey gKey = GlobalKey(debugLabel: 'sss');
  var controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          child: Column(
            children: <Widget>[
              TextField(
                controller: controller,
                key: gKey,
              ),
              RaisedButton(
                onPressed: () {
                  debugPrint((gKey.currentWidget as TextField).controller.text);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
