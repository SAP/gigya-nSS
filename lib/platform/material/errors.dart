import 'package:flutter/material.dart';

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
