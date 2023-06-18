import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/config.dart';
import 'package:gigya_native_screensets_engine/ioc/injector.dart';
import 'package:gigya_native_screensets_engine/models/markup.dart';
import 'package:gigya_native_screensets_engine/models/screen.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/utils/debug.dart';
import 'package:gigya_native_screensets_engine/utils/linkify.dart';
import 'package:gigya_native_screensets_engine/utils/localization.dart';
import 'package:gigya_native_screensets_engine/widgets/events.dart';
import 'package:gigya_native_screensets_engine/widgets/factory.dart';
import 'package:gigya_native_screensets_engine/widgets/components/social.dart';
import 'package:gigya_native_screensets_engine/widgets/router.dart';
import 'package:gigya_native_screensets_engine/services/api_service.dart';
import 'package:gigya_native_screensets_engine/services/screen_service.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';

enum NssScreenState { idle, progress, error }

enum ScreenAction { submit, api, socialLogin }

enum NssShowOnlyFields { none, empty }

extension ScreenActionExt on ScreenAction {
  String get name => describeEnum(this);
}

/// The view model class acts as the coordinator to the currently displayed screen.
/// It will handle the current screen visual state and its adjacent form and is responsible for service/repository
/// action triggering.
class ScreenViewModel
    with ChangeNotifier, DebugUtils, LocalizationMixin, EngineEvents {
  final ApiService? apiService;
  final ScreenService? screenService;

  final bool? _isMock = NssIoc().use(NssConfig).isMock;

  Map<String, String?> screenShowIfMapping = {};

  Map<dynamic, dynamic>? expressions = {};

  ScreenViewModel(this.apiService, this.screenService);

  /// Previous screen unique identifier.
  String pid = '';

  /// Screen unique identifier.
  String? id;

  /// Create new globalKey which is important to trigger all form specific actions.
  /// Only one form can exist in one screen.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Stream controller responsible for triggering navigation events.
  /// The [NssScreenWidget] holds the correct [BuildContext] which can access the [Navigator]. Therefore it will
  /// be the only one listening to this stream.
  final StreamController<NavigationEvent> navigationStream =
      StreamController<NavigationEvent>();

  @override
  void dispose() {
    // Close screen event stream to avoid leaks.
    navigationStream.close();
    super.dispose();
  }

  /// Attach screen action.
  /// Method will use the [ScreenService] to send the correct action to the native to initialize the correct
  /// native logic object.
  Future<Map<String, dynamic>> attachScreenAction(String? action,
      String? screenId, Map<String, String?> expressions) async {
    if (isMock!) {
      return {};
    }
    try {
      var map =
          await screenService!.initiateAction(action, screenId, expressions);
      engineLogger!.d('Screen $screenId flow initialized with data map');
      return map;
    } on MissingPluginException {
      engineLogger!.e('Missing channel connection: check mock state?');
      return {};
    }
  }

  /// Runtime evaluation request of specific expression & relevant data.
  Future<void> evaluateExpressionByDemand(
      NssWidgetData? widgetData, Map<String, dynamic> data) async {
    if (_isMock!) {
      return;
    }

    engineLogger!.d('[evaluateExpressionByDemand]: ${screenShowIfMapping}');

    String? expression = screenShowIfMapping[widgetData!.showIf!];

    // evaluate expression with adjacent data.
    String evaluated =
        await screenService!.evaluateExpression(expression, data);

    if (expressions != null) {
      // Merge expression result with current expression map.
      expressions![widgetData.showIf] = evaluated;
    }
  }

  NssAlignment? screenAlignment;

  /// Current screen [NssScreenState] state.
  /// Available states: idle, progress, error.
  NssScreenState _state = NssScreenState.idle;

  String? _errorText;

  String? get error => _errorText;

  isIdle() => _state == NssScreenState.idle;

  isProgress() => _state == NssScreenState.progress;

  isError() => _state == NssScreenState.error;

  /// Screen idle state.
  void setIdle() {
    engineLogger!.d('Screen with id: $id setIdle');
    _state = NssScreenState.idle;
    _errorText = null;
    notifyListeners();
  }

  /// Screen in progress state. Will show common progress indicator ontop a semi transparent background.
  void setProgress() {
    engineLogger!.d('Screen with id: $id setProgress');
    _state = NssScreenState.progress;
    _errorText = null;
    notifyListeners();
  }

  /// Screen in error mode. Will display a specific error under submission button.
  /// Other error display options will be added.
  void setError(String? error) {
    engineLogger!.d('Screen with id: $id setError with $error');
    _state = NssScreenState.error;

    // Check if error string exists in localization keys. If so use it.
    _errorText = localizedStringFor(error);
    notifyListeners();
  }

  /// Request form submission. Form will try to validate first. If validation succeeds than the submission action
  /// will be sent to the native container.
  void submitScreenForm(Map<String, dynamic> submission) async {
    var validated = formKey.currentState!.validate();
    if (validated) {
      engineLogger!.d('Form validations success - submission requested.');
      engineLogger!
          .d('submitScreenForm - submission: ${submission.toString()}');

      // Request form save state. This will update the binding map with the required data for submission.
      formKey.currentState!.save();

      // Handle engine submit event.
      Map<String, dynamic> eventData = await beforeSubmit(id, submission);
      if (eventData.isNotEmpty) {
        engineLogger!.d(
            'submitScreenForm - eventData (not empty): ${eventData.toString()}');

        if (eventData.containsKey('error')) {
          String error = eventData['error'];

          if (error.isEmpty) {
            engineLogger!.d(
                'Provided empty error message from event submission override');
          }
          setError(error);
          return;
        }

        // Overwrite submission data if exists.
        Map<String, dynamic> submissionData =
            eventData['data'].cast<String, dynamic>();
        engineLogger!.d(
            'submitScreenForm - overwrite submission data from event (not empty): ${submissionData.toString()}');
        if (submissionData.isNotEmpty) submission = submissionData;
      }

      // Send API only if validated.
      sendApi(ScreenAction.submit.name, submission);
    }
  }

  /// Force form validation request.
  void requestScreenFormValidation() {
    formKey.currentState!.validate();
  }

  /// Trigger native social login flow with selected [provider].
  void socialLogin(NssSocialProvider? provider) {
    if (isMock!) {
      debugPrint('Requested social login with ${provider.name}');
      return;
    }
    sendApi(ScreenAction.socialLogin.name, {'provider': provider.name});
  }

  /// Label widget initiated link action.
  /// Validate option available are URL/route.
  void linkifyTap(String link) async {
    engineLogger!.d('link tap: $link');

    // Linkify browser link.
    if (Linkify.isValidUrl(link)) {
      if (isMock!) return;
      engineLogger!.d('URL link validated : $link');
      screenService!.linkToBrowser(link);
      return;
    }

    // Linkify internal route.
    if (RouteEvaluator.validatedRoute(link)) {
      engineLogger!.d('Route link validated : $link');

      // Initiate next action.
      final Map<String, dynamic> actionData =
          await initiateNextLinkAction(link);
      // Get routing data.
      Map<String, dynamic>? screenData = {};
      Map<String, dynamic>? expressionData = {};
      if (actionData.isNotEmpty) {
        screenData = actionData['data'].cast<String, dynamic>();
        expressionData = actionData['expressions'].cast<String, dynamic>();
      }

      navigationStream.sink
          .add(NavigationEvent('$link', screenData, expressionData));
      return;
    }
  }

  /// Send requested API request given a String [method] and base [parameters] map.
  /// [parameter] map is not signed.
  void sendApi(String method, Map<String, dynamic> parameters) {
    if (isMock!) return;
    setProgress();

    engineLogger!.d(
        'sendApi (api channel) - method: $method, params: ${parameters.toString()}');

    apiService!.send(method, parameters).then(
      (result) async {
        engineLogger!.d('Api request success: ${result.data.toString()}');

        // Initiate next action.
        final Map<String, dynamic> actionData =
            await initiateNextAction('onSuccess');
        // Get routing data.
        Map<String, dynamic>? screenData = {};
        Map<String, dynamic>? expressionData = {};
        if (actionData.isNotEmpty) {
          screenData = actionData['data'].cast<String, dynamic>();
          expressionData = actionData['expressions'].cast<String, dynamic>();
        }

        if (result.data?['data']?.cast<String, dynamic>() != null) {
          screenData?.addAll(result.data?['data']?.cast<String, dynamic>());
        }
        if (result.data?['expressions']?.cast<String, dynamic>() != null) {
          expressionData
              ?.addAll(result.data?['expressions']?.cast<String, dynamic>());
        }

        setIdle();

        engineLogger!.d('screenData : $screenData');
        // Trigger navigation.
        var event =
            NavigationEvent('$id/onSuccess', screenData, expressionData);
        if (actionData['screenShowIfMapping'] != null) {
          event.screenShowIfMapping =
              actionData['screenShowIfMapping'].cast<String, dynamic>();
        }

        navigationStream.sink.add(event);
      },
    ).catchError(
      (error) async {
        engineLogger!.d('error : $error');

        final RoutingAllowed route = RouteEvaluator.allowedBy(error.errorCode);
        if (route != RoutingAllowed.none) {
          final routeNamed = describeEnum(route);

          // Initiate next action.
          final Map<String, dynamic> actionData =
              await initiateNextAction(routeNamed);
          // Get routing data.
          Map<String, dynamic>? screenData = {};
          Map<String, dynamic>? expressionData = {};
          if (actionData.isNotEmpty) {
            if (actionData['data'] != null) {
              screenData = actionData['data'].cast<String, dynamic>();
            }
            if (actionData['expressions'] != null) {
              expressionData =
                  actionData['expressions'].cast<String, dynamic>();
            }
          }

          setIdle();

          navigationStream.sink.add(
              NavigationEvent('$id/$routeNamed', screenData, expressionData));
        } else {
          // Error will be displayed when there is no available routing option.
          setError(error.errorMessage);
        }

        // Log the error.
        engineLogger!.d('Api request error: ${error.errorMessage}');
      },
    );
  }

  void navigateTo() async {
    // Initiate next action.
    final Map<String, dynamic> actionData =
        await initiateNextAction('onSuccess');
    // Get routing data.
    Map<String, dynamic>? screenData = {};
    Map<String, dynamic>? expressionData = {};
    if (actionData.isNotEmpty) {
      screenData = actionData['data'].cast<String, dynamic>();
      expressionData = actionData['expressions'].cast<String, dynamic>();
    }

    var event = NavigationEvent('$id/onSuccess', screenData, expressionData);
    event.screenShowIfMapping =
        actionData['screenShowIfMapping'].cast<String, dynamic>();

    // Trigger navigation.
    navigationStream.sink.add(event);
  }

  Future<Map<String, dynamic>> anonSendApi(
      String method, Map<String, dynamic> parameters) async {
    // if (isMock!) return {};
    setProgress();

    return await apiService!.send(method, parameters).then(
      (result) async {
        engineLogger!.d('Api request success: ${result.data.toString()}');

        // Initiate next action.
        // Get routing data.

        setIdle();

        engineLogger!.d('response data: $result.data');
        return result.data ?? {} as Map<String, dynamic>;
      },
    ).catchError((error) async {
      setIdle();
      throw error;
    });
  }

  Future<Map<String, dynamic>> initiateNextLinkAction(String link) async {
    final Markup markup = NssIoc().use(NssConfig).markup;
    final String? linkAction =
        markup.screens![link] != null ? markup.screens![link]!.action : null;
    if (linkAction == null || linkAction.isEmpty) {
      return {};
    }

    engineLogger!.d(
        'initiateNextAction: for next screen id = $link and action = $linkAction');

    // Action initialization data fetch.
    var dataMap = await attachScreenAction(
      linkAction,
      link,
      {}, // No expressions when linking.
    );
    return dataMap;
  }

  /// Initiate the next screen's native action.
  /// This will allow action initialization data to be retrieved prior to navigation and will
  /// remove data population jitter.
  Future<Map<String, dynamic>> initiateNextAction(String nextRoute) async {
    final Markup markup = NssIoc().use(NssConfig).markup;

    final String? nextScreenId = markup.screens![id!]!.routes![nextRoute];

    // Check for available route.
    if (nextScreenId == null || nextScreenId.isEmpty) {
      return {};
    }

    // Check if the next route is a screen definition (can be _dismiss).
    if (markup.screens![nextScreenId] == null) {
      return {};
    }

    final String? nextScreenAction = markup.screens![nextScreenId]!.action;
    if (nextScreenAction == null || nextScreenAction.isEmpty) {
      return {};
    }

    // Map next screen expressions.
    final Screen nextScreen = markup.screens![nextScreenId]!;
    var nextScreenExpressions = mapScreenExpressions(nextScreen);

    engineLogger!.d(
        'initiateNextAction: for next screen id = $nextScreenId and action = $nextScreenAction');

    // Action initialization data fetch.
    var dataMap = await attachScreenAction(
      nextScreenAction,
      nextScreenId,
      nextScreenExpressions,
    );
    dataMap['screenShowIfMapping'] = nextScreenExpressions;
    return dataMap;
  }

  /// Map all screen expressions before sending it when attaching the next screen.
  Map<String, String?> mapScreenExpressions(Screen screen) {
    Map<String, String?> expressionMap = {};
    screen.children!.asMap().forEach((index, widget) {
      // Adding showIf expression.
      if (widget.showIf != null) {
        // Check if `showOnlyFields` is `true` then override the expression to showing by empty.
        if (screen.showOnlyFields == NssShowOnlyFields.empty &&
            widget.bind != null) {
          widget.showIf = "${widget.showIf} && ${widget.bind} == null";
        }
        // Add expression with hierarchy index as unique key.
        expressionMap[index.toString()] = widget.showIf;

        // Overwrite markup expression field with index.
        widget.showIf = index.toString();
      } else {
        // Note: only when `showIf` if empty.
        // Check if `showOnlyFields` is `true` then add expression to showing by empty.
        if (screen.showOnlyFields == NssShowOnlyFields.empty &&
            widget.bind != null) {
          expressionMap[index.toString()] = "${widget.bind} == null";
          widget.showIf = index.toString();
        }
      }
    });

    // Keeping track of showIf mapping.
    screenShowIfMapping.addAll(expressionMap);

    engineLogger!.d("showifMapping: ${screenShowIfMapping}");

    return expressionMap;
  }
}

class NavigationEvent {
  final String route;
  final Map<String, dynamic>? routingData;
  final Map<String, dynamic>? expressions;
  Map<String, dynamic>? screenShowIfMapping;

  NavigationEvent(this.route, this.routingData, this.expressions);
}
