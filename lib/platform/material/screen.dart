import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gigya_native_screensets_engine/models/screen.dart';
import 'package:gigya_native_screensets_engine/providers/binding_provider.dart';
import 'package:gigya_native_screensets_engine/providers/screen_provider.dart';
import 'package:gigya_native_screensets_engine/platform/screen.dart';
import 'package:provider/provider.dart';

class MaterialScreenWidget extends StatefulWidget {
  final ScreenViewModel viewModel;
  final BindingModel bindingModel;
  final Screen screen;
  final Widget content;

  const MaterialScreenWidget({Key key, this.viewModel, this.bindingModel, this.screen, this.content}) : super(key: key);

  @override
  _MaterialScreenWidgetState createState() => _MaterialScreenWidgetState(viewModel, bindingModel);
}

class _MaterialScreenWidgetState extends ScreenWidgetState<MaterialScreenWidget> {
  _MaterialScreenWidgetState(ScreenViewModel viewModel, BindingModel bindings) : super(viewModel, bindings);

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
    return Scaffold(
      appBar: widget.screen.appBar == null
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              title: Text(
                widget.screen.appBar['textKey'] ?? '',
                style: TextStyle(color: Colors.black),
              ),
              leading: Platform.isIOS
                  ? Container(
                    child: IconButton(
                        icon: Icon(Icons.close, color: Colors.black),
                        onPressed: () => Navigator.pushNamed(context, '_canceled'),
                      ),
                  )
                  : null,
            ),
      body: SafeArea(
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
                return vm.isProgress() ? MaterialScreenProgressWidget() : Container();
              },
            )
          ],
        ),
      ),
    );
  }

  /// Register view model instance to a navigation steam controller.
  /// Only the current context contains the main Navigator instance. Therefore we must communicate back to the
  /// screen widget in order to perform navigation actions.
  _registerNavigationSteam() {
    viewModel.navigationStream.stream.listen((route) {
      if (ModalRoute.of(context).settings.name.split('/').last == route.toString().split('/').last) {
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
