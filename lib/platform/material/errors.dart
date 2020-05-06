import 'package:flutter/material.dart';
import 'package:gigya_native_screensets_engine/providers/screen_provider.dart';
import 'package:provider/provider.dart';

class MaterialScreenRenderErrorWidget extends StatelessWidget {
  final String errorMessage;

  const MaterialScreenRenderErrorWidget({Key key, this.errorMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.red[400],
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
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
                  errorMessage,
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

class MaterialComponentRenderErrorWidget extends StatelessWidget {
  final String errorMessage;

  const MaterialComponentRenderErrorWidget({Key key, this.errorMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.red[400],
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            errorMessage,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.0,
            ),
          ),
        ),
      ),
    );
  }
}

class MaterialScreenInfoErrorWidget extends StatelessWidget {

  @visibleForTesting
  ScreenViewModel getProvider(context) {
    return Provider.of<ScreenViewModel>(context, listen: false);
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

