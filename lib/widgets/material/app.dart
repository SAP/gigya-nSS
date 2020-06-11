import 'package:flutter/material.dart';
import 'package:gigya_native_screensets_engine/models/markup.dart';
import 'package:gigya_native_screensets_engine/widgets/router.dart';

class MaterialAppWidget extends StatelessWidget {
  final Markup markup;
  final MaterialRouter router;

  const MaterialAppWidget({Key key, this.markup, this.router}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      color: Colors.white, //TODO: Theme not implemented for v0.1.
      initialRoute: markup.routing.initial,
      onGenerateRoute: router.generateRoute,
    );
  }
}
