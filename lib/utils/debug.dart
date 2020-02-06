import 'package:flutter/material.dart';

class NssDebugDecorWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          decoration: new BoxDecoration(
            color: Color(0x66c1c1c1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              'Uses mock',
              style: TextStyle(
                decoration: TextDecoration.none,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xff3f6f79),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
