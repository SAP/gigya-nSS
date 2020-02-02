import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/blocs/nss_screen_state_bloc.dart';
import 'package:gigya_native_screensets_engine/theme/nss_decoration_mixins.dart';
import 'package:provider/provider.dart';

typedef Widget LayoutNssScreen();

class NssScreenWidget extends StatefulWidget {
  final LayoutNssScreen layoutScreen;

  const NssScreenWidget({Key key, @required this.layoutScreen}) : super(key: key);

  @override
  _NssScreenWidgetState createState() => _NssScreenWidgetState();
}

class _NssScreenWidgetState extends State<NssScreenWidget> with NssWidgetDecorationMixin {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<NssScreenStateBloc>(
      create: (_) => NssScreenStateBloc(),
      child: Container(
        child: widget.layoutScreen(),
      ),
    );
  }
}
