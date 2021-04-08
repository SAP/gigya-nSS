import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gigya_native_screensets_engine/config.dart';
import 'package:gigya_native_screensets_engine/ioc/injector.dart';
import 'package:gigya_native_screensets_engine/models/screen.dart';
import 'package:gigya_native_screensets_engine/providers/binding_provider.dart';
import 'package:gigya_native_screensets_engine/providers/screen_provider.dart';
import 'package:gigya_native_screensets_engine/style/styling_mixins.dart';
import 'package:gigya_native_screensets_engine/utils/localization.dart';
import 'package:gigya_native_screensets_engine/widgets/screen.dart';
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

class _MaterialScreenWidgetState extends ScreenWidgetState<MaterialScreenWidget> with StyleMixin, LocalizationMixin {
  _MaterialScreenWidgetState(ScreenViewModel viewModel, BindingModel bindings) : super(viewModel, bindings);

  @override
  void initState() {
    // Update dynamic view model screen id because view model is instantiated view IOC.
    viewModel.id = widget.screen.id;

    super.initState();

    didRouteFrom();

    _registerNavigationStream();

    // On first render issue "screenDidLoad" event.
    // If this is the first screen being rendered, a "ready_for_display" event will be triggered to allow
    // smooth transition when the engine loads.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Issuing ready for display native trigger only when the initial screen has been rendered.
      // This will occur only once per load.
      if (viewModel.pid == '' && viewModel.id == NssIoc().use(NssConfig).markup.routing.initial) {
        if (!NssIoc().use(NssConfig).isMock) {
          NssIoc().use(NssChannels).ignitionChannel.invokeMethod<void>('ready_for_display');

          // Attach the initial screen action only.
          // Follwing actions will be initiated as a part of the navigation flow moving forward.
          _attachInitialScreenAction();
        }
      }

      screenDidLoad(widget.screen.id);
    });
  }

  @override
  Widget buildScaffold() {
    var appBarBackground = getStyle(Styles.background,
        styles: widget.screen.appBar == null ? null : widget.screen.appBar.style, themeProperty: 'primaryColor');
    var scaffoldBackground = getStyle(Styles.background, styles: widget.screen.style) ?? Colors.white;

    return Scaffold(
      backgroundColor: scaffoldBackground,
      extendBodyBehindAppBar: true,
      appBar: widget.screen.appBar == null
          ? null
          : AppBar(
              elevation: getStyle(Styles.elevation, styles: widget.screen.appBar.style),
              backgroundColor: appBarBackground,
              title: Text(
                localizedStringFor(widget.screen.appBar.textKey) ?? '',
                style: TextStyle(
                  color: getStyle(Styles.fontColor, styles: widget.screen.appBar.style, themeProperty: 'secondaryColor'),
                  fontWeight: getStyle(Styles.fontWeight, styles: widget.screen.appBar.style),
                ),
              ),
              leading: kIsWeb
                  ? null
                  : Platform.isIOS
                      ? Container(
                          child: IconButton(
                            icon: Icon(
                              Icons.close,
                              color:
                                  getStyle(Styles.fontColor, styles: widget.screen.appBar.style, themeProperty: 'secondaryColor'),
                            ),
                            onPressed: () => Navigator.pushNamed(context, '_canceled'),
                          ),
                        )
                      : null,
            ),
      body: Container(
        child: SafeArea(
          child: Stack(
            children: <Widget>[
              SingleChildScrollView(
                child: Form(
                  key: widget.viewModel.formKey,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: widget.content,
                  ),
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
    viewModel.navigationStream.stream.listen((NavigationEvent event) async {
      if (ModalRoute.of(context).settings.name == event.route.toString()) {
        return;
      }

      // If route data is available, make sure it is added to the routing/binding data.
      if (event.routingData != null && event.routingData.isNotEmpty) {
//        widget.routingData.addAll(event.routingData);
      }

      // Trigger "routeTo" event to determine routing override.
      String routingOverride = await willRouteTo(event.route);

      // Merge bindings & routing data to avoid data loss between screens.
      widget.routingData.addAll(bindings.savedBindingData);

      // Route.
      Navigator.pushReplacementNamed(
        context,
        routingOverride.isNotEmpty ? routingOverride : event.route,
        arguments: {
          'pid': viewModel.id,
          'routingData': widget.routingData,
          'initialData': event.routingData,
          'expressions': event.expressions
        },
      );
    });
  }

  /// Attach the relevant screen action.
  /// This will result in the instantiation of the native controller action model which will handle all
  /// the native SDK logic.
  _attachInitialScreenAction() async {
    var dataMap = await viewModel.attachScreenAction(
      widget.screen.action,
      widget.screen.id,
      viewModel.mapScreenExpressions(widget.screen),
    );
    // Merge routing data into injected screen data and update bindings.
    viewModel.expressions = dataMap['expressions'];
    dataMap.addAll(widget.routingData);
    bindings.updateWith(dataMap);
  }

  void didRouteFrom() async {
    Map<String, dynamic> eventData = await routeFrom(viewModel.id, viewModel.pid, widget.routingData);
    if (eventData != null) {
      // Overrite current routing data if exists.
      if (eventData['data'] != null) {
        widget.routingData.addAll(eventData['data'].cast<String, dynamic>());
      }
      // Merge routing data into available binding data.
      bindings.updateRoutingWith(widget.routingData);

      debugPrint('didRouteFrom: data = ${widget.routingData.toString()}');

      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<String> willRouteTo(nid) async {
    Map<String, dynamic> eventData = await routeTo(viewModel.id, nid, bindings.savedBindingData);
    if (eventData != null && eventData.isNotEmpty) {
      // Overrite current routing data if exists.
      widget.routingData.addAll(eventData['data'].cast<String, dynamic>());
      // Merge routing data into available binding data.
      bindings.updateRoutingWith(widget.routingData);

      // Fetch sid override if exists.
      String sid = eventData['sid'] ?? '';

      debugPrint('willRouteTo: sid = $sid, data = ${widget.routingData.toString()}');
      // Update routing override

      if (mounted) {
        setState(() {});
      }

      return sid;
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
