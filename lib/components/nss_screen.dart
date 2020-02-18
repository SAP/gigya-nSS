import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/blocs/nss_screen_bloc.dart';
import 'package:gigya_native_screensets_engine/components/nss_form.dart';
import 'package:gigya_native_screensets_engine/components/nss_scaffold.dart';
import 'package:gigya_native_screensets_engine/models/screen.dart';
import 'package:gigya_native_screensets_engine/theme/nss_decoration_mixins.dart';
import 'package:provider/provider.dart';

typedef Widget LayoutNssScreen();

class NssScreenWidget extends StatefulWidget {
  final LayoutNssScreen layoutScreen;
  final Screen screen;

  const NssScreenWidget({Key key, @required this.screen, @required this.layoutScreen}) : super(key: key);

  @override
  _NssScreenWidgetState createState() => _NssScreenWidgetState();
}

class _NssScreenWidgetState extends State<NssScreenWidget> with NssWidgetDecorationMixin {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<NssScreenViewModel>(
      create: (_) => NssScreenViewModel(widget.screen.id),
      child: NssScaffoldWidget(
        appBarTitle: widget.screen.appBar != null ? widget.screen.appBar['textKey'] ?? '' : '',
        body: NssFormWidget(
          screenId: widget.screen.id,
          layoutForm: widget.layoutScreen,
        ),
      ),
    );
  }
}
