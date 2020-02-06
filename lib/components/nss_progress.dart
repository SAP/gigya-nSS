import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gigya_native_screensets_engine/components/nss_platform.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/theme/nss_decoration_mixins.dart';

class NssProgressWidget extends NssStatelessPlatformWidget with NssWidgetDecorationMixin {
  final NssWidgetData data;

  NssProgressWidget({this.data});

  @override
  Widget buildCupertinoWidget(BuildContext context) {
    // TODO: implement buildCupertinoWidget
    return buildMaterialWidget(context);
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    // TODO: Decoration needs to be set from the data style object.
    return Material(
      child: CircularProgressIndicator(),
    );
  }
}

class NssScreenProgressWidget extends StatefulWidget {
  final NssWidgetData data;

  const NssScreenProgressWidget({Key key, this.data}) : super(key: key);

  @override
  _NssScreenProgressWidgetState createState() => _NssScreenProgressWidgetState();
}

class _NssScreenProgressWidgetState extends NssStatefulPlatformWidgetState<NssScreenProgressWidget>
    with NssWidgetDecorationMixin {
  @override
  Widget buildCupertinoWidget(BuildContext context) {
    // TODO: implement buildCupertinoWidget
    return buildMaterialWidget(context);
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        //TODO: Temporary color for background opacity. Should receive it from data style object.
        color: Colors.grey.withOpacity(0.6),
      ),
      child: Center(
        child: NssProgressWidget(data: widget.data),
      ),
    );
  }
}
