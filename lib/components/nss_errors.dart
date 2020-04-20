import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/providers/nss_screen_bloc.dart';
import 'package:provider/provider.dart';

class NssRenderingErrorWidget extends StatelessWidget {
  final String message;

  const NssRenderingErrorWidget({Key key, @required this.message}) : super(key: key);

  factory NssRenderingErrorWidget.routeMissMatch() {
    return NssRenderingErrorWidget(
      message: 'Initial route missmatch.'
          '\nMarkup does not contain requested route.',
    );
  }

  factory NssRenderingErrorWidget.screenWithNotChildren() {
    return NssRenderingErrorWidget(
      message: 'Screen must contain children.'
          '\nMarkup tag \"screen\" must contain children.',
    );
  }

  factory NssRenderingErrorWidget.missingFlow() {
    return NssRenderingErrorWidget(
      message: 'Screen must contain a flow.',
    );
  }

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
                  'Nss Render error:',
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
}

/// Error widget for Form. (Bottom of the screen)
class NssFormErrorWidget extends StatelessWidget {
  @visibleForTesting
  NssScreenViewModel getProvider(context) {
    return Provider.of<NssScreenViewModel>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      alignment: getProvider(context).isError() ? Alignment(0.0, 1.0) : Alignment(0.0, 4.0),
      duration: Duration(milliseconds: 450),
      curve: Curves.easeInOut,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.red,
              border: Border.all(color: Colors.red[900], width: 3.0),
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          width: double.infinity,
          height: 38.0,
          child: Stack(
            children: <Widget>[
              Align(
                  alignment: Alignment.center,
                  child: Text(
                    getProvider(context).error ?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  )),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    child: Icon(Icons.close, color: Colors.white),
                    onTap: () {
                      getProvider(context).setIdle();
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
