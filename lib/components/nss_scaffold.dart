import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/blocs/nss_screen_state_bloc.dart';
import 'package:gigya_native_screensets_engine/components/nss_platform.dart';
import 'package:gigya_native_screensets_engine/models/screen.dart';
import 'package:provider/provider.dart';

class NssScaffoldWidget extends NssStatelessPlatformWidget {
  final String appBarTitle;
  final Widget child;

  NssScaffoldWidget({ this.appBarTitle, this.child});

  @override
  Widget buildCupertinoWidget(BuildContext context) {
    // TODO: implement buildCupertinoWidget
    return Container();
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    // TODO: implement buildMaterialWidget
    return Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle),
        ),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            child,
            // TODO: This Buttons is only for testing, Need to remove it.
            RaisedButton(
              child: Text('Test api'),
              onPressed: () {
                Provider.of<NssScreenStateBloc>(context, listen: false).sendApi("test", {'dsad': 'dsad'});
              },
            ),
            AnimatedOpacity(
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
            )
          ],
        ),
      ),
    );
  }
}


