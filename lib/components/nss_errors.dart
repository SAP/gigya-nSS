import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/blocs/nss_screen_state_bloc.dart';
import 'package:provider/provider.dart';

class NssErrorWidget extends StatelessWidget {
  final String message;

  const NssErrorWidget({Key key, @required this.message}) : super(key: key);

  factory NssErrorWidget.routeMissMatch() {
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
                  'Native ScreenSets Render error:',
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

/// Error widget for Form. (Bottom of the screen)
class NssFormErrorWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: Provider.of<NssScreenStateBloc>(context).isError() ? 0.7 : 0.0,
      duration: Duration(milliseconds: 200),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          color: Colors.red,
          width: double.infinity,
          height: 44.0,
          child: Stack(
            children: <Widget>[
              Align(
                  alignment: Alignment.center,
                  child: Text(Provider.of<NssScreenStateBloc>(context).error ?? '')
              ),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Provider.of<NssScreenStateBloc>(context, listen: false).setIdle();
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

}