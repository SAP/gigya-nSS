import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gigya_native_screensets_engine/components/nss_platform.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/nss_configuration.dart';
import 'package:gigya_native_screensets_engine/theme/nss_decoration_mixins.dart';

class NssProgressWidget extends NssPlatformWidget with NssWidgetDecorationMixin {
  final NssConfig config;
  final NssWidgetData data;

  NssProgressWidget({
    @required this.config,
    this.data,
  }) : super(isPlatformAware: config.isPlatformAware);

  @override
  Widget buildCupertinoWidget(BuildContext context) {
    // TODO: implement buildCupertinoWidget
    return buildMaterialWidget(context);
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    // TODO: Decoration needs to be set from the data style object.
    return Material(
      color: Colors.transparent,
      child: CircularProgressIndicator(),
    );
  }
}

class NssScreenProgressWidget extends StatefulWidget {
  final NssConfig config;
  final NssWidgetData data;

  const NssScreenProgressWidget({
    Key key,
    @required this.config,
    this.data,
  }) : super(key: key);

  @override
  _NssScreenProgressWidgetState createState() => _NssScreenProgressWidgetState(
        config: config,
      );
}

class _NssScreenProgressWidgetState extends NssPlatformState<NssScreenProgressWidget> with NssWidgetDecorationMixin {
  final NssConfig config;

  _NssScreenProgressWidgetState({
    @required this.config,
  }) : super(isPlatformAware: config.isPlatformAware);

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
        color: Colors.grey.withOpacity(0.4),
      ),
      child: Center(
        child: NssProgressWidget(config: config, data: widget.data),
      ),
    );
  }
}
