import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/components/nss_platform.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/nss_configuration.dart';
import 'package:gigya_native_screensets_engine/nss_factory.dart';
import 'package:gigya_native_screensets_engine/providers/nss_binding_bloc.dart';
import 'package:gigya_native_screensets_engine/theme/nss_decoration_mixins.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';
import 'package:gigya_native_screensets_engine/utils/validation.dart';
import 'package:provider/provider.dart';

class NssTextInputWidget extends StatefulWidget {
  final NssConfig config;
  final NssWidgetData data;

  const NssTextInputWidget({
    Key key,
    @required this.config,
    @required this.data,
  }) : super(key: key);

  @override
  _NssTextInputWidgetState createState() => _NssTextInputWidgetState(
        isPlatformAware: config.isPlatformAware,
      );
}

class _NssTextInputWidgetState extends NssPlatformState<NssTextInputWidget>
    with NssWidgetDecorationMixin, BindingMixin {
  _NssTextInputWidgetState({
    @required this.isPlatformAware,
  }) : super(isPlatformAware: isPlatformAware);

  final bool isPlatformAware;
  final TextEditingController _textEditingController = TextEditingController();

  GlobalKey wKey;

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget buildCupertinoWidget(BuildContext context) {
    // TODO: implement buildCupertinoWidget
    return buildMaterialWidget(context);
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    return expandIfNeeded(
      widget.data.expand,
      Padding(
        padding: defaultPadding(),
        child: Consumer<BindingModel>(
          builder: (context, bindings, child) {
            final placeHolder = getText(widget.data, bindings);

            _textEditingController.text = placeHolder;

            return TextFormField(
              obscureText: widget.data.type == NssWidgetType.password,
              controller: _textEditingController,
              decoration: InputDecoration(hintText: widget.data.textKey),
              validator: (input) {
                //TODO: Take in mind that we will need to think how we will be injecting custom field validations here as well.
                return _validateField(input.trim());
              },
              onSaved: (value) {
                if (value.trim().isEmpty && placeHolder.isEmpty) {
                  return;
                }

                bindings.save(widget.data.bind, value.trim());
              },
            );
          },
        ),
      ),
    );
  }

  /// Validate input according to instance type.
  String _validateField(input) {
    var validated = NssValidations.validate(input, forType: widget.data.type.name);

    switch (validated) {
      case NssInputValidation.failed:
        //TODO: Validation errors should be injected via the localization map.
        return 'Validation faild for type: ${widget.data.type.name}';
      case NssInputValidation.na:
        //TODO: Not available validator error should be injected via the localization map.
        nssLogger.d('Validator not specified for input widget type');
        break;
      case NssInputValidation.passed:
        break;
    }
    return null;
  }
}

class NssCheckboxWidget extends StatefulWidget {
  final NssConfig config;
  final NssWidgetData data;

  const NssCheckboxWidget({
    Key key,
    @required this.config,
    @required this.data,
  }) : super(key: key);

  @override
  _NssCheckboxWidgetState createState() => _NssCheckboxWidgetState(
        isPlatformAware: config.isPlatformAware,
      );
}

class _NssCheckboxWidgetState extends NssPlatformState<NssCheckboxWidget> with NssWidgetDecorationMixin, BindingMixin {
  _NssCheckboxWidgetState({
    @required this.isPlatformAware,
  }) : super(isPlatformAware: isPlatformAware);

  final bool isPlatformAware;

  bool currentValue = false;

  @override
  Widget buildCupertinoWidget(BuildContext context) {
    // TODO: implement buildCupertinoWidget
    return null;
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    return expandIfNeeded(
      widget.data.expand,
      Padding(
        padding: defaultPadding(),
        child: Consumer<BindingModel>(builder: (context, bindings, child) {
          return InkWell(
            onTap: () {
              if (mounted) {
                setState(() {
                  currentValue = !currentValue;
                });
              }
            },
            child: Container(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Checkbox(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    value: currentValue,
                    onChanged: (val) {
                      setState(
                        () {
                          if (mounted) {
                            currentValue = val;
                          }
                        },
                      );
                    },
                  ),
                  Text(widget.data.textKey),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class NssRadioWidget extends StatefulWidget {
  final NssConfig config;
  final NssWidgetData data;

  const NssRadioWidget({
    Key key,
    @required this.config,
    @required this.data,
  }) : super(key: key);

  @override
  _NssRadioWidgetState createState() => _NssRadioWidgetState(
        isPlatformAware: config.isPlatformAware,
      );
}

class _NssRadioWidgetState extends NssPlatformState<NssRadioWidget> with NssWidgetDecorationMixin, BindingMixin {
  _NssRadioWidgetState({
    @required this.isPlatformAware,
  }) : super(isPlatformAware: isPlatformAware);

  final bool isPlatformAware;

  String groupValue = '';

  @override
  Widget buildCupertinoWidget(BuildContext context) {
    // TODO: implement buildCupertinoWidget
    return null;
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    return expandIfNeeded(
      widget.data.expand,
      Padding(
        padding: defaultPadding(),
        child: Consumer<BindingModel>(
          builder: (context, bindings, child) {
            return ListView.builder(
              itemCount: 2,
              itemBuilder: (BuildContext lvbContext, int index) {
                return ListTile(
                  title: Text(widget.data.textKey),
                  leading: Radio(
                    value: 'sdss',
                    groupValue: groupValue,
                    onChanged: (String value) {
                      setState(() {
                        groupValue = value;
                      });
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
