import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gigya_native_screensets_engine/models/screen.dart';
import 'package:gigya_native_screensets_engine/utils/localization.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';
import 'package:gigya_native_screensets_engine/widgets/material/errors.dart';
import 'package:gigya_native_screensets_engine/providers/binding_provider.dart';
import 'package:gigya_native_screensets_engine/providers/screen_provider.dart';
import 'package:gigya_native_screensets_engine/widgets/screen.dart';
import 'package:gigya_native_screensets_engine/style/styling_mixins.dart';
import 'package:provider/provider.dart';

class MaterialScreenWidget extends StatefulWidget {
  final ScreenViewModel viewModel;
  final BindingModel bindingModel;
  final Screen screen;
  final Widget content;

  /// Routing data is the dyanmic data that is injected or changed in realtime when you edit
  /// your screen form.
  final Map<String, dynamic> routingData;

  const MaterialScreenWidget({
    Key key,
    this.viewModel,
    this.bindingModel,
    this.screen,
    this.content,
    this.routingData,
  }) : super(key: key);

  @override
  _MaterialScreenWidgetState createState() => _MaterialScreenWidgetState(viewModel, bindingModel);
}

class _MaterialScreenWidgetState extends ScreenWidgetState<MaterialScreenWidget>
    with StyleMixin, LocalizationMixin {
  _MaterialScreenWidgetState(ScreenViewModel viewModel, BindingModel bindings)
      : super(viewModel, bindings);

  @override
  void initState() {
    // Update dynamic view model screen id because view model is instantiated view IOC.
    viewModel.id = widget.screen.id;
    super.initState();

    // Screen Event triggered "routeFrom"
    didRouteFrom();

    // Initialize screen build logic.
    _attachScreenAction();
    _registerNavigationStream();

    // Screen Event triggered "screenDidLoad".
    WidgetsBinding.instance.addPostFrameCallback((_) => screenDidLoad(widget.screen.id));
  }

  @override
  Widget buildScaffold() {
    var background = getStyle(Styles.background, styles: widget.screen.style);
    var appBackground = getStyle(Styles.background,
        styles: widget.screen.appBar.style, themeProperty: 'primaryColor');

    return Scaffold(
      extendBodyBehindAppBar: appBackground == Colors.transparent,
      appBar: widget.screen.appBar == null
          ? null
          : AppBar(
              elevation: getStyle(Styles.elevation, styles: widget.screen.appBar.style),
              backgroundColor: appBackground,
              title: Text(
                localizedStringFor(widget.screen.appBar.textKey) ?? '',
                style: TextStyle(
                  color: getStyle(Styles.fontColor,
                      styles: widget.screen.appBar.style, themeProperty: 'secondaryColor'),
                  fontWeight: getStyle(Styles.fontWeight, styles: widget.screen.appBar.style),
                ),
              ),
              leading: Platform.isIOS
                  ? Container(
                      child: IconButton(
                        icon: Icon(
                          Icons.close,
                          color: getStyle(Styles.fontColor,
                              styles: widget.screen.appBar.style, themeProperty: 'secondaryColor'),
                        ),
                        onPressed: () => Navigator.pushNamed(context, '_canceled'),
                      ),
                    )
                  : null,
            ),
      body: Container(
        decoration: BoxDecoration(
            color: background is Color ? background : null,
            image: background is NetworkImage
                ? DecorationImage(
                    fit: BoxFit.cover,
                    image: background,
                  )
                : null),
        child: SafeArea(
          child: Stack(
            children: <Widget>[
              SingleChildScrollView(
                child: Form(
                  key: widget.viewModel.formKey,
                  child: Container(width: MediaQuery.of(context).size.width, child: widget.content),
                ),
              ),
              Consumer<ScreenViewModel>(
                builder: (context, vm, child) {
                  if (vm.isProgress()) {
                    return MaterialScreenProgressWidget();
                  } else {
                    return Container();
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  /// Register view model instance to a navigation steam controller.
  /// Only the current context contains the main Navigator instance. Therefore we must communicate back to the
  /// screen widget in order to perform navigation actions.
  _registerNavigationStream() {
    viewModel.navigationStream.stream.listen((route) async {
      if (ModalRoute.of(context).settings.name.split('/').last ==
          route.toString().split('/').last) {
        return;
      }

      // Trigger "routeTo" event to determine routing override.
      String routingOverride = await willRouteTo(route);

      // Merge bindings & routing data to avoid data loss between screens.
      widget.routingData.addAll(bindings.savedBindingData);

      // Route.
      Navigator.pushReplacementNamed(
        context,
        routingOverride.isNotEmpty ? routingOverride : route,
        arguments: {'pid': viewModel.id, 'routingData': widget.routingData},
      );
    });
  }

  /// Attach the relevant screen action.
  /// This will result in the instantiation of the native controller action model which will handle all
  /// the native SDK logic.
  _attachScreenAction() async {
    var dataMap = await viewModel.attachScreenAction(widget.screen.action);
    // Merge routing data into injected screen data and update bindings.
    dataMap.addAll(widget.routingData);
    bindings.updateWith(dataMap);
  }

  void didRouteFrom() async {
    Map<String, dynamic> eventData = await routeFrom(viewModel.pid, widget.routingData);
    if (eventData != null) {
      setState(() {
        // Overrite current routing data if exists.
        widget.routingData.addAll(eventData['data']);
        // Merge routing data into available binding data.
        bindings.updateWith(widget.routingData);

        debugPrint('didRouteFrom: data = ${widget.routingData.toString()}');
      });
    }
  }

  Future<String> willRouteTo(nid) async {
    Map<String, dynamic> eventData = await routeTo(nid, bindings.savedBindingData);
    if (eventData != null) {
      setState(() {
        // Overrite current routing data if exists.
        widget.routingData.addAll(eventData['data']);
        // Merge routing data into available binding data.
        bindings.updateWith(widget.routingData);

        // Fetch sid override if exists.
        String sid = eventData['sid'] ?? '';

        debugPrint('willRouteTo: sid = $sid, data = ${widget.routingData.toString()}');
        // Update routing override
        return sid;
      });
    }
    return '';
  }
}

/// Custom screen progress widget.
/// Will be displayed on top of the screen stack when the screen state is in progress.
class MaterialScreenProgressWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.4),
      ),
      child: Center(
        //TODO: Allow theming of the progress indicator.
        child: CircularProgressIndicator(),
      ),
    );
  }
}
