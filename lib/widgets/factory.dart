import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/config.dart';
import 'package:gigya_native_screensets_engine/ioc/injector.dart';
import 'package:gigya_native_screensets_engine/models/screen.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/providers/binding_provider.dart';
import 'package:gigya_native_screensets_engine/providers/runtime_provider.dart';
import 'package:gigya_native_screensets_engine/providers/screen_provider.dart';
import 'package:gigya_native_screensets_engine/style/decoration_mixins.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';
import 'package:gigya_native_screensets_engine/widgets/material/app.dart';
import 'package:gigya_native_screensets_engine/widgets/material/buttons.dart';
import 'package:gigya_native_screensets_engine/widgets/material/checkbox.dart';
import 'package:gigya_native_screensets_engine/widgets/material/container.dart';
import 'package:gigya_native_screensets_engine/widgets/material/date_picker/date_picker.dart';
import 'package:gigya_native_screensets_engine/widgets/material/dropdown.dart';
import 'package:gigya_native_screensets_engine/widgets/material/image.dart';
import 'package:gigya_native_screensets_engine/widgets/material/inputs.dart';
import 'package:gigya_native_screensets_engine/widgets/material/labels.dart';
import 'package:gigya_native_screensets_engine/widgets/material/phone.dart';
import 'package:gigya_native_screensets_engine/widgets/material/profile_photo.dart';
import 'package:gigya_native_screensets_engine/widgets/material/radio.dart';
import 'package:gigya_native_screensets_engine/widgets/material/screen.dart';
import 'package:gigya_native_screensets_engine/widgets/material/social.dart';
import 'package:gigya_native_screensets_engine/widgets/router.dart';

/// Available widget types supported by the Nss engine.
enum NssWidgetType {
  app,
  screen,
  container,
  label,
  textInput,
  emailInput,
  passwordInput,
  phoneInput,
  submit,
  checkbox,
  radio,
  dropdown,
  socialLoginButton,
  socialLoginGrid,
  image,
  profilePhoto,
  datePicker,
  button
}

extension NssWidgetTypeExt on NssWidgetType {
  String get name => describeEnum(this);
}

/// Directional layout alignment widget for "stack" markup property.
enum NssStack { vertical, horizontal }

/// Multi widget container alignment options for "alignment" markup property.
enum NssAlignment { start, end, center, equal_spacing, spread }

abstract class WidgetFactory with DecorationMixin{
  Widget? buildApp();

  Widget? buildScreen(Screen screen, Map<String, dynamic> routingData);

  Widget buildComponent(NssWidgetType? type, NssWidgetData data);

  NssAlignment? screenAlignment;

  Widget buildContainer(List<Widget> children, NssWidgetData data) {
    if (data.stack == null) {
      engineLogger!.e('Invalid null value for container stack property');
      return Container();
    }

    switch (data.stack) {
      case NssStack.vertical:
        return ContainerWidget(
          data: data,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: getCrossAxisAlignment(data.alignment ?? screenAlignment),
            children: children,
          ),
        );
      case NssStack.horizontal:
        return ContainerWidget(
          data: data,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: getMainAxisAlignment(data.alignment ?? screenAlignment),
            crossAxisAlignment: CrossAxisAlignment.center,
            children: children,
          ),
        );
      default:
        return ContainerWidget(
          data: data,
          child: Column(children: children),
        );
    }
  }

  List<Widget> buildWidgets(List<NssWidgetData>? widgetsToBuild) {
    if (widgetsToBuild == null || widgetsToBuild.isEmpty) {
      return [];
    }

    List<Widget> widgets = [];
    widgetsToBuild.forEach((widget) {
      if (widget.type == NssWidgetType.container) {
        widget.isNestedContainer = true;
        // View group required.
        widgets.add(
          buildContainer(buildWidgets(widget.children), widget),
        );
      } else {
        widgets.add(
          buildComponent(widget.type, widget),
        );
      }
    });
    return widgets;
  }
}

class MaterialWidgetFactory extends WidgetFactory {
  @override
  Widget buildApp() {
    return MaterialAppWidget(
      markup: NssIoc().use(NssConfig).markup,
      router: NssIoc().use(MaterialRouter),
    );
  }

  @override
  Widget buildScreen(Screen screen, Map<String, dynamic>? arguments) {

    // Save main screen alignment in instance.
    screenAlignment = screen.alignment;

    ScreenViewModel? viewModel = NssIoc().use(ScreenViewModel);
    viewModel?.screenAlignment = screenAlignment;

    BindingModel? binding = NssIoc().use(BindingModel);

    RuntimeStateEvaluator? expressionProvider = NssIoc().use(RuntimeStateEvaluator);

    // Make sure screen routing data is being passed on with every screen transition.
    Map<String, dynamic> routingData = {};
    if (arguments is Map<String, dynamic>) {
      if (arguments.containsKey('routingData')) {
        routingData.addAll(arguments['routingData']);
      }
      if (arguments.containsKey('expressions')) {
        viewModel!.expressions = arguments['expressions'];
      }
      if (arguments.containsKey('initialData')) {
        binding!.updateWith(arguments['initialData']);
      }
    }

    return MaterialScreenWidget(
      viewModel: viewModel,
      bindingModel: binding,
      routingData: routingData,
      expressionProvider: expressionProvider,
      screen: screen,
      content: buildContainer(
        buildWidgets(screen.children),
        NssWidgetData(
            style: screen.style ?? {},
            stack: screen.stack,
            alignment: screen.alignment ?? NssAlignment.center),
      ),
    );
  }

  @override
  Widget buildComponent(NssWidgetType? type, NssWidgetData data) {
    switch (type) {
      case NssWidgetType.label:
        return LabelWidget(key: UniqueKey(), data: data);
      case NssWidgetType.textInput:
      case NssWidgetType.emailInput:
      case NssWidgetType.passwordInput:
        return TextInputWidget(key: UniqueKey(), data: data);
      case NssWidgetType.submit:
        return SubmitWidget(key: UniqueKey(), data: data);
      case NssWidgetType.button:
        return ButtonWidget(key: UniqueKey(), data: data);
      case NssWidgetType.checkbox:
        return CheckboxWidget(key: UniqueKey(), data: data);
      case NssWidgetType.radio:
        return RadioGroupWidget(key: UniqueKey(), data: data);
      case NssWidgetType.dropdown:
        return DropDownButtonWidget(key: UniqueKey(), data: data);
      case NssWidgetType.socialLoginButton:
        return SocialButtonWidget(key: UniqueKey(), data: data);
      case NssWidgetType.socialLoginGrid:
        return SocialLoginGrid(key: UniqueKey(), data: data);
      case NssWidgetType.image:
        return ImageWidget(key: UniqueKey(), data: data);
      case NssWidgetType.profilePhoto:
        return ProfilePhotoWidget(key: UniqueKey(), data: data);
      case NssWidgetType.container:
        return buildContainer(buildWidgets(data.children), data);
      case NssWidgetType.phoneInput:
        return PhoneInputWidget(key: UniqueKey(), data: data);
      case NssWidgetType.datePicker:
        return DatePickerWidget(
            key: UniqueKey(), data: data, inputType: data.initialDisplay);
      default:
        return Container();
    }
  }
}

//TODO Not planned for v0.1.
class CupertinoWidgetFactory extends WidgetFactory {
  @override
  Widget? buildApp() {
    // TODO: implement buildApp
    return null;
  }

  @override
  Widget? buildScreen(Screen screen, Map<String, dynamic> routingData) {
    // TODO: implement buildScreen
    return null;
  }

  @override
  Widget buildComponent(NssWidgetType? type, NssWidgetData data) {
    switch (type) {
      case NssWidgetType.label:
        // TODO: Handle this case.
        break;
      case NssWidgetType.textInput:
        // TODO: Handle this case.
        break;
      case NssWidgetType.emailInput:
        // TODO: Handle this case.
        break;
      case NssWidgetType.passwordInput:
        // TODO: Handle this case.
        break;
      case NssWidgetType.submit:
        // TODO: Handle this case.
        break;
      case NssWidgetType.checkbox:
        // TODO: Handle this case.
        break;
      case NssWidgetType.radio:
        // TODO: Handle this case.
        break;
      case NssWidgetType.dropdown:
        // TODO: Handle this case.
        break;
      default:
        return Container();
    }
    return Container();
  }
}
