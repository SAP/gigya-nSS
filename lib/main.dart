import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: InfraTestWidget());
  }
}

class InfraTestWidget extends StatefulWidget {

  @override
  _InfraTestWidgetState createState() => _InfraTestWidgetState();
}

class _InfraTestWidgetState extends State<InfraTestWidget> {

  static const platform = const MethodChannel('gigya_nss_engine/method/platform');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: FutureBuilder(
              future: infraInit(),
              builder: (buildContext, snapshot) {
                if (snapshot.hasData) {
                  return Text(snapshot.data);
                } else {
                  return SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                  );
                }
              }),
        ),
      ),
    );
  }

  Future<String> infraInit() async {
    // Using main communication method channel to request initialization data.
    return await platform.invokeMethod<String>("infraInit");
  }
}
