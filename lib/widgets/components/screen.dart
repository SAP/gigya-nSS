import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:gigya_native_screensets_engine/comm/channels.dart';
import 'package:gigya_native_screensets_engine/config.dart';
import 'package:gigya_native_screensets_engine/ioc/injector.dart';
import 'package:gigya_native_screensets_engine/models/screen.dart';
import 'package:gigya_native_screensets_engine/providers/binding_provider.dart';
import 'package:gigya_native_screensets_engine/providers/runtime_provider.dart';
import 'package:gigya_native_screensets_engine/providers/screen_provider.dart';
import 'package:gigya_native_screensets_engine/style/styling_mixins.dart';
import 'package:gigya_native_screensets_engine/utils/localization.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';
import 'package:gigya_native_screensets_engine/widgets/components/progress_indicator.dart';
import 'package:gigya_native_screensets_engine/widgets/events.dart';
import 'package:gigya_native_screensets_engine/widgets/router.dart';
import 'package:provider/provider.dart';

enum ScreenChannelAction { flow, submit }

extension ScreenChannelActionExt on ScreenChannelAction {
  String get action {
    return describeEnum(this);
  }
}

class ScreenWidget extends StatefulWidget {
  final ScreenViewModel? viewModel;
  final BindingModel? bindingModel;
  final RuntimeStateEvaluator? expressionProvider;
  final Screen? screen;
  final Widget? content;

  /// Routing data is the dynamic data that is injected or changed in realtime when you edit
  /// your screen form.
  final Map<String, dynamic>? routingData;

  const ScreenWidget({
    Key? key,
    this.viewModel,
    this.bindingModel,
    this.expressionProvider,
    this.screen,
    this.content,
    this.routingData,
  }) : super(key: key);

  @override
  _ScreenWidgetState createState() =>
      _ScreenWidgetState(viewModel, bindingModel, expressionProvider);
}

class _ScreenWidgetState extends State<ScreenWidget>
    with StyleMixin, LocalizationMixin, EngineEvents, Logging {
  final ScreenViewModel? viewModel;
  final BindingModel? bindings;
  final RuntimeStateEvaluator? expressionProvider;

  _ScreenWidgetState(this.viewModel, this.bindings, this.expressionProvider);

  @override
  void initState() {
    // Update dynamic view model screen id because view model is instantiated view IOC.
    viewModel!.id = widget.screen!.id;

    super.initState();

    didRouteFrom();

    _registerNavigationStream();
    _registerNativeBackHandlerStream();

    // On first render issue "screenDidLoad" event.
    // If this is the first screen being rendered, a "ready_for_display" event will be triggered to allow
    // smooth transition when the engine loads.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Issuing ready for display native trigger only when the initial screen has been rendered.
      // This will occur only once per load.
      if (viewModel!.pid == '' &&
          viewModel!.id == NssIoc().use(NssConfig).markup.routing.initial) {
        if (!NssIoc().use(NssConfig).isMock) {
          NssIoc()
              .use(NssChannels)
              .ignitionChannel
              .invokeMethod<void>('ready_for_display');

          // Attach the initial screen action only.
          // Following actions will be initiated as a part of the navigation flow moving forward.
          _attachInitialScreenAction();
        }
      }

      // DEBUG LOG.
      log('ScreenDidLoad for ${widget.screen!.id}');

      screenDidLoad(widget.screen!.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ScreenViewModel?>(
          create: (_) => viewModel,
        ),
        ChangeNotifierProvider<BindingModel?>(
          create: (_) => bindings,
        ),
        ChangeNotifierProvider<RuntimeStateEvaluator?>(
          create: (_) => expressionProvider,
        )
      ],
      child: buildScaffold(),
    );
  }

  /// Main UI content build tree.
  Widget buildScaffold() {
    // DEBUG LOG.
    log('Build scaffold called for screen');

    var appBarBackground = getStyle(Styles.background,
        styles:
            widget.screen!.appBar == null ? null : widget.screen!.appBar!.style,
        themeProperty: 'primaryColor');
    var scaffoldBackground =
        getStyle(Styles.background, styles: widget.screen!.style) ??
            Colors.white;

    return Directionality(
      textDirection: isRTL(),
      child: PlatformScaffold(
        backgroundColor: scaffoldBackground,
        //extendBodyBehindAppBar: true,
        appBar: _createAppBar(appBarBackground),
        body: Container(
          child: SafeArea(
            child: Stack(
              children: <Widget>[
                SingleChildScrollView(
                  child: Form(
                    key: widget.viewModel!.formKey,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: widget.content,
                    ),
                  ),
                ),
                Consumer<ScreenViewModel>(
                  builder: (context, vm, child) {
                    if (vm.isProgress()) {
                      return ScreenProgressWidget();
                    } else {
                      return Container();
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Create AppBar widget for given platform. If required.
  PlatformAppBar? _createAppBar(appBarBackground) {
    if (widget.screen!.appBar == null) return null;
    return PlatformAppBar(
      material: (_, __) => MaterialAppBarData(
        elevation:
            getStyle(Styles.elevation, styles: widget.screen!.appBar!.style),
      ),
      cupertino: (_, __) => CupertinoNavigationBarData(),
      backgroundColor: appBarBackground,
      title: Text(
        localizedStringFor(widget.screen!.appBar!.textKey) ?? '',
        style: TextStyle(
          color: getStyle(Styles.fontColor,
              styles: widget.screen!.appBar!.style,
              themeProperty: 'secondaryColor'),
          fontWeight:
              getStyle(Styles.fontWeight, styles: widget.screen!.appBar!.style),
        ),
      ),
      leading: _createAppBarLeadingIcon(),
    );
  }

  /// Create AppBar icon & state for the relevant platform.
  PlatformIconButton _createAppBarLeadingIcon() {
    bool? firstRouteInStack = ModalRoute.of(context)?.isFirst;
    if (firstRouteInStack == null) {
      firstRouteInStack = false;
    }

    return PlatformIconButton(
      padding: EdgeInsets.zero,
      icon: Icon(
        Platform.isIOS || kIsWeb
            ? firstRouteInStack
                ? Icons.close
                : Icons.chevron_left
            : Icons.arrow_back,
        color: getStyle(Styles.fontColor,
            styles: widget.screen!.appBar!.style,
            themeProperty: 'secondaryColor'),
      ),
      onPressed: () {
        _handleBackOrDismiss(firstRouteInStack);
      },
    );
  }

  _handleBackOrDismiss(firstRouteInStack) {
    if (firstRouteInStack!) {
      log('Last screen in stack. _cancel route initiated');
      Navigator.pushNamed(context, '_cancel');
    } else {
      // Handle custom back route if available.
      String? backRoute = widget.screen!.routes?['onBack'];
      if (backRoute != null) {
        viewModel?.linkifyLinkOrRoute(backRoute);
      } else {
        Navigator.pop(context);
      }
    }
  }

  /// Register view model instance to a navigation steam controller.
  /// Only the current context contains the main Navigator instance. Therefore we must communicate back to the
  /// screen widget in order to perform navigation actions.
  _registerNavigationStream() {
    viewModel!.navigationStream.stream.listen((NavigationEvent event) async {
      if (ModalRoute.of(context)!.settings.name == event.route.toString()) {
        return;
      }

      String route = await _evaluateRoute(event);
      _navigateToScreen(route, event);
    });
  }

  _registerNativeBackHandlerStream() {
    viewModel?.nativeBackEventChannel.receiveBroadcastStream().listen((event) {
      log("Native back event fired");
      bool? firstRouteInStack = ModalRoute.of(context)?.isFirst;
      if (firstRouteInStack == null) {
        firstRouteInStack = false;
      }
      _handleBackOrDismiss(firstRouteInStack);
    });
  }

  /// Evaluate route prior to navigation.
  Future<String> _evaluateRoute(NavigationEvent event) async {
    // Trigger "routeTo" event to determine routing override.
    String routingOverride = await willRouteTo(event.route);

    // Merge bindings & routing data to avoid data loss between screens.
    widget.routingData!.addAll(bindings!.savedBindingData);

    // Apply navigation.
    final String route =
        routingOverride.isNotEmpty ? routingOverride : event.route;
    return route;
  }

  /// Remove all sensitive data from the widget routing data before screen transitions.
  _removeUnsecureRoutingData() {
    // Remove password field from widget routing.
    widget.routingData!.remove('password');
    widget.routingData!.remove('newPassword');
  }

  /// Route to next screen.
  _navigateToScreen(route, event) {
    _removeUnsecureRoutingData();

    // DEBUG LOG.
    log('Navigate to screen: $route');

    Navigator.pushNamed(
      context,
      route,
      arguments: {
        'pid': viewModel!.id,
        'routingData': widget.routingData,
        'initialData': event.routingData,
        'expressions': event.expressions,
        'screenShowIfMapping': event.screenShowIfMapping
      },
    ).then((value) {
      // Recall to attach the correct screen action.
      _attachInitialScreenAction();
      _registerNativeBackHandlerStream();
      setState(() {});
    });
  }

  /// Attach the relevant screen action.
  /// This will result in the instantiation of the native controller action model which will handle all
  /// the native SDK logic.
  _attachInitialScreenAction() async {
    var dataMap = await viewModel!.attachScreenAction(
      widget.screen!.action,
      widget.screen!.id,
      viewModel!.mapScreenExpressions(widget.screen!),
    );
    // Merge routing data into injected screen data and update bindings.
    viewModel!.expressions = dataMap['expressions'];

    if (dataMap['expressions'] != null) {
      dataMap.addAll(widget.routingData!);
      bindings!.updateWith(dataMap['data'].cast<String, dynamic>());
    }
  }

  /// Handle "didRouteFrom" native event injection.
  void didRouteFrom() async {
    Map<String, dynamic> eventData =
        await routeFrom(viewModel!.id, viewModel!.pid, widget.routingData);
    if (eventData['data'] != null) {
      widget.routingData!.addAll(eventData['data'].cast<String, dynamic>());
    }
    // Merge routing data into available binding data.
    bindings!.updateRoutingWith(widget.routingData!);

    debugPrint('didRouteFrom: data = ${widget.routingData.toString()}');

    if (mounted) {
      setState(() {});
    }
  }

  /// Handle "willRouteTo" native event injection.
  Future<String> willRouteTo(nid) async {
    Map<String, dynamic> eventData =
        await routeTo(viewModel!.id, nid, bindings!.savedBindingData);
    if (eventData.isNotEmpty) {
      // Override current routing data if exists.
      widget.routingData!.addAll(eventData['data'].cast<String, dynamic>());
      // Merge routing data into available binding data.
      bindings!.updateRoutingWith(widget.routingData!);

      // Fetch sid override if exists.
      String sid = eventData['sid'] ?? '';

      debugPrint(
          'willRouteTo: sid = $sid, data = ${widget.routingData.toString()}');
      // Update routing override

      if (mounted) {
        setState(() {});
      }

      return sid;
    }

    return '';
  }
}
