import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class NssErrorWidget extends StatelessWidget {
  final String message;

  const NssErrorWidget({Key key, @required this.message}) : super(key: key);

  factory NssErrorWidget.missingRoute() {
    return NssErrorWidget(
      message: 'Initial route missmatch.'
          '\nMarkup does not contain requested route.',
    );
  }

  factory NssErrorWidget.screenWithNotChildren() {
    return NssErrorWidget(
      message: 'Screen must contain children.'
          '\nMarkup tag \"screen\" must contain children.',
    );
  }

  //region Build

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.red[400],
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Render error:',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //endregion
}
