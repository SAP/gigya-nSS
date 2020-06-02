import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gigya_native_screensets_engine/models/screen.dart';
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

  const MaterialScreenWidget(
      {Key key, this.viewModel, this.bindingModel, this.screen, this.content})
      : super(key: key);

  @override
  _MaterialScreenWidgetState createState() => _MaterialScreenWidgetState(viewModel, bindingModel);
}

class _MaterialScreenWidgetState extends ScreenWidgetState<MaterialScreenWidget> with StyleMixin {
  _MaterialScreenWidgetState(ScreenViewModel viewModel, BindingModel bindings)
      : super(viewModel, bindings);

  @override
  void initState() {
    // Update dynamic view model screen id because view model is instantiated view IOC.
    viewModel.id = widget.screen.id;

    super.initState();

    // Initialize screen build logic.
    _attachScreenAction();
    _registerNavigationSteam();
  }

  @override
  Widget buildScaffold() {
    var background = getStyle(Styles.background, widget.screen.style);
    var appBackground = getStyle(Styles.background, widget.screen.appBar.style, theme: 'primaryColor');

    return Scaffold(
      extendBodyBehindAppBar: appBackground == Colors.transparent,
      appBar: widget.screen.appBar == null
          ? null
          : AppBar(
              elevation: getStyle(Styles.elevation, widget.screen.appBar.style),
              backgroundColor: appBackground,
              title: Text(
                widget.screen.appBar.textKey ?? '',
                style: TextStyle(
                  color: getStyle(Styles.fontColor, widget.screen.appBar.style, theme: 'secondaryColor'),
                  fontWeight: getStyle(Styles.fontWeight, widget.screen.appBar.style),
                ),
              ),
              leading: Platform.isIOS
                  ? Container(
                      child: IconButton(
                        icon: Icon(
                          Icons.close,
                          color: getStyle(Styles.fontColor, widget.screen.appBar.style, theme: 'secondaryColor'),
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
                  child: widget.content,
                ),
              ),
              Consumer<ScreenViewModel>(
                builder: (context, vm, child) {
                  if (vm.isProgress()) {
                    return MaterialScreenProgressWidget();
                  } else if (vm.isError()) {
                    return MaterialScreenInfoErrorWidget();
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
  _registerNavigationSteam() {
    viewModel.navigationStream.stream.listen((route) {
      if (ModalRoute.of(context).settings.name.split('/').last ==
          route.toString().split('/').last) {
        return;
      }
      Navigator.pushReplacementNamed(context, route);
    });
  }

  /// Attach the relevant screen action.
  /// This will result in the instantiation of the native controller action model which will handle all
  /// the native SDK logic.
  _attachScreenAction() async {
    var screenDataMap = await viewModel.attachScreenAction(widget.screen.action);
    bindings.updateWith(screenDataMap);
  }
}

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
        child: CircularProgressIndicator(),
      ),
    );
  }
}
