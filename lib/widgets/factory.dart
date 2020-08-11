import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/config.dart';
import 'package:gigya_native_screensets_engine/injector.dart';
import 'package:gigya_native_screensets_engine/models/screen.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/providers/binding_provider.dart';
import 'package:gigya_native_screensets_engine/providers/screen_provider.dart';
import 'package:gigya_native_screensets_engine/widgets/material/app.dart';
import 'package:gigya_native_screensets_engine/widgets/material/buttons.dart';
import 'package:gigya_native_screensets_engine/widgets/material/checkbox.dart';
import 'package:gigya_native_screensets_engine/widgets/material/container.dart';
import 'package:gigya_native_screensets_engine/widgets/material/dropdown.dart';
import 'package:gigya_native_screensets_engine/widgets/material/image.dart';
import 'package:gigya_native_screensets_engine/widgets/material/inputs.dart';
import 'package:gigya_native_screensets_engine/widgets/material/labels.dart';
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
  submit,
  checkbox,
  radio,
  dropdown,
  socialLoginButton,
  socialLoginGrid,
  image,
}

extension NssWidgetTypeExt on NssWidgetType {
  String get name => describeEnum(this);
}

/// Directional layout alignment widget for "stack" markup property.
enum NssStack { vertical, horizontal }

/// Multi widget container alignment options for "alignment" markup property.
enum NssAlignment { start, end, center, equal_spacing, spread }

abstract class WidgetFactory {
  Widget buildApp();

  Widget buildScreen(Screen screen);

  Widget buildComponent(NssWidgetType type, NssWidgetData data);

  Widget buildContainer(List<Widget> childrenWidgets, NssStack stack,
      {NssAlignment alignment, Map<String, dynamic> style, bool isScreen = false}) {
    if (stack == null) {
      //TODO: Markup error.
      return Container();
    }

    switch (stack) {
      case NssStack.vertical:
        return ContainerWidget(
          isScreen: isScreen,
          style: style,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: getMainAxisAlignment(alignment),
            children: childrenWidgets,
          ),
        );
      case NssStack.horizontal:
        return ContainerWidget(
          isScreen: isScreen,
          style: style,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: getMainAxisAlignment(alignment),
            children: childrenWidgets,
          ),
        );
      default:
        return ContainerWidget(
          isScreen: isScreen,
          style: style,
          child: Column(children: childrenWidgets),
        );
    }
  }

  List<Widget> buildWidgets(List<NssWidgetData> widgetsToBuild) {
    if (widgetsToBuild == null || widgetsToBuild.isEmpty) {
      return [];
    }
    List<Widget> widgets = [];
    widgetsToBuild.forEach((widget) {
      if (widget.type == NssWidgetType.container) {
        // View group required.
        widgets.add(
          buildContainer(
            buildWidgets(widget.children),
            widget.stack,
            alignment: widget.alignment,
            style: widget.style,
          ),
        );
      } else {
        widgets.add(
          buildComponent(widget.type, widget),
        );
      }
    });
    return widgets;
  }

  /// [Flex] Widgets such as [Column] and [Row] require alignment property in order
  /// to better understand where their child widgets are will layout.
  MainAxisAlignment getMainAxisAlignment(NssAlignment alignment) {
    if (alignment == null) return MainAxisAlignment.start;
    switch (alignment) {
      case NssAlignment.start:
        return MainAxisAlignment.start;
      case NssAlignment.end:
        return MainAxisAlignment.end;
      case NssAlignment.center:
        return MainAxisAlignment.center;
      case NssAlignment.equal_spacing:
        return MainAxisAlignment.spaceEvenly;
      case NssAlignment.spread:
        return MainAxisAlignment.spaceBetween;
      default:
        return MainAxisAlignment.start;
    }
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
  Widget buildScreen(Screen screen) {
    return MaterialScreenWidget(
      viewModel: NssIoc().use(ScreenViewModel),
      bindingModel: NssIoc().use(BindingModel),
      screen: screen,
      content:
          buildContainer(buildWidgets(screen.children), screen.stack, style: screen.style, isScreen: true),
    );
  }

  @override
  Widget buildComponent(NssWidgetType type, NssWidgetData data) {
    switch (type) {
      case NssWidgetType.label:
        return LabelWidget(key: UniqueKey(), data: data);
      case NssWidgetType.textInput:
      case NssWidgetType.emailInput:
      case NssWidgetType.passwordInput:
        return TextInputWidget(key: UniqueKey(), data: data);
      case NssWidgetType.submit:
        return SubmitWidget(key: UniqueKey(), data: data);
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
      default:
        return Container();
    }
  }
}

//TODO Not planned for v0.1.
class CupertinoWidgetFactory extends WidgetFactory {
  @override
  Widget buildApp() {
    // TODO: implement buildApp
    return null;
  }

  @override
  Widget buildScreen(Screen screen) {
    // TODO: implement buildScreen
    return null;
  }

  @override
  Widget buildComponent(NssWidgetType type, NssWidgetData data) {
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
