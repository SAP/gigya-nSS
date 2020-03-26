import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/blocs/nss_form_bloc.dart';
import 'package:gigya_native_screensets_engine/blocs/nss_screen_bloc.dart';
import 'package:gigya_native_screensets_engine/components/nss_actions.dart';
import 'package:gigya_native_screensets_engine/components/nss_form.dart';
import 'package:gigya_native_screensets_engine/components/nss_inputs.dart';
import 'package:gigya_native_screensets_engine/components/nss_labels.dart';
import 'package:gigya_native_screensets_engine/components/nss_scaffold.dart';
import 'package:gigya_native_screensets_engine/components/nss_screen.dart';
import 'package:gigya_native_screensets_engine/models/screen.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/nss_configuration.dart';
import 'package:gigya_native_screensets_engine/nss_injector.dart';
import 'package:provider/provider.dart';

enum NssWidgetType { screen, label, input, email, password, submit }

extension NssWidgetTypeExt on NssWidgetType {
  String get name => describeEnum(this);
}

enum NssAlignment { vertical, horizontal }

class NssWidgetFactory {
  final NssConfig config;
  final NssChannels channels;

  NssWidgetFactory({
    @required this.config,
    @required this.channels,
  });

  Widget createScreen(Screen screen) {
    return ChangeNotifierProvider<NssScreenViewModel>(
      create: (_) {
        final NssScreenViewModel viewModel = NssInjector().use(NssScreenViewModel);
        viewModel.id = screen.id;
        return viewModel;
      },
      child: NssScreenWidget(
        screen: screen,
        config: config,
        channels: channels,
        widgetFactory: this,
      ),
    );
  }

  Widget _buildScreenRootWidget(Screen screen) {
    return _groupBy(screen.align, _buildWidgets(screen.children, screen.align));
  }

  Widget createScaffold(Screen screen) {
    return NssScaffoldWidget(
      config: config,
      appBarTitle: screen.appBar != null ? screen.appBar['textKey'] ?? '' : '',
      body: createForm(screen),
    );
  }

  Widget createForm(Screen screen) {
    final NssFormBloc formBloc = NssInjector().use(NssFormBloc);
    return NssFormWidget(
      screenId: screen.id,
      child: _buildScreenRootWidget(screen),
      bloc: formBloc,
    );
  }

  Widget create(NssWidgetType type, NssWidgetData data, NssAlignment align) {
    switch (type) {
      case NssWidgetType.screen:
      case NssWidgetType.label:
        return NssLabelWidget(config: config, data: data);
      case NssWidgetType.input:
      case NssWidgetType.email:
      case NssWidgetType.password:
        var input = NssTextInputWidget(config: config, data: data);
        return align == NssAlignment.horizontal ? Expanded(child: input) : input;
      case NssWidgetType.submit:
        return NssSubmitWidget(config: config, data: data);
        break;
    }
    return Container();
  }

  /// Dynamically create component widget or components view group according to children parameter
  /// of the [NssWidgetData] provided.
  List<Widget> _buildWidgets(List<NssWidgetData> children, NssAlignment align) {
    if (children.isEmpty) {
      return [];
    }

    List<Widget> widgets = [];
    children.forEach((widget) {
      if (widget.hasChildren()) {
        // View group required.
        widgets.add(
          _groupBy(widget.stack, _buildWidgets(widget.children, widget.stack)),
        );
      } else {
        widgets.add(
          create(widget.type, widget, align),
        );
      }
    });
    return widgets;
  }

  Widget _groupBy(NssAlignment alignment, List<Widget> list) {
    switch (alignment) {
      case NssAlignment.vertical:
        return Column(children: list);
      case NssAlignment.horizontal:
        return Row(children: list);
      default:
        return Column(children: list);
    }
  }
}
