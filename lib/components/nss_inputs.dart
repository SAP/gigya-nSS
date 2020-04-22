import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/components/nss_platform.dart';
import 'package:gigya_native_screensets_engine/models/option.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/nss_configuration.dart';
import 'package:gigya_native_screensets_engine/nss_factory.dart';
import 'package:gigya_native_screensets_engine/providers/nss_binding_bloc.dart';
import 'package:gigya_native_screensets_engine/theme/nss_decoration_mixins.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';
import 'package:gigya_native_screensets_engine/utils/validation.dart';
import 'package:provider/provider.dart';

/// General text input widget.
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

/// General text input widget state.
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

/// General checkbox widget.
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

/// General checkbox widget state.
class _NssCheckboxWidgetState extends NssPlatformState<NssCheckboxWidget> with NssWidgetDecorationMixin, BindingMixin {
  _NssCheckboxWidgetState({
    @required this.isPlatformAware,
  }) : super(isPlatformAware: isPlatformAware);

  final bool isPlatformAware;

  bool currentValue;

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
            currentValue = getBool(widget.data, bindings);
            return CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(widget.data.textKey),
              value: currentValue,
              onChanged: (bool val) {
                setState(() {
                  bindings.save(widget.data.bind, val);
                });
              },
            );
          },
        ),
      ),
    );
  }
}

/// General radio group widget.
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

/// General radio group widget state.
class _NssRadioWidgetState extends NssPlatformState<NssRadioWidget> with NssWidgetDecorationMixin, BindingMixin {
  _NssRadioWidgetState({
    @required this.isPlatformAware,
  }) : super(isPlatformAware: isPlatformAware);

  final bool isPlatformAware;

  String groupValue;
  String defaultValue;

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
            groupValue = getText(widget.data, bindings);
            if (groupValue.isEmpty) {
              widget.data.options.forEach((option) {
                if (option.defaultValue != null && option.defaultValue) {
                  groupValue = option.value;
                }
              });
            }
            return ListView.builder(
              shrinkWrap: true,
              itemCount: widget.data.options.length,
              itemBuilder: (BuildContext lvbContext, int index) {
                NssOption option = widget.data.options[index];
                return RadioListTile(
                  controlAffinity: ListTileControlAffinity.leading,
                  value: option.value,
                  title: Text(option.textKey),
                  groupValue: groupValue,
                  onChanged: (String value) {
                    setState(() {
                      bindings.save(widget.data.bind, value);
                    });
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// General dropdown button widget.
class NssDropDownButtonWidget extends StatefulWidget {
  final NssConfig config;
  final NssWidgetData data;

  const NssDropDownButtonWidget({
    Key key,
    @required this.config,
    @required this.data,
  }) : super(key: key);

  @override
  _NssDropDownButtonWidgetState createState() => _NssDropDownButtonWidgetState(
        isPlatformAware: config.isPlatformAware,
      );
}

/// General dropdown button widget state.
class _NssDropDownButtonWidgetState extends NssPlatformState<NssDropDownButtonWidget>
    with NssWidgetDecorationMixin, BindingMixin {
  _NssDropDownButtonWidgetState({
    @required this.isPlatformAware,
  }) : super(isPlatformAware: isPlatformAware);

  final bool isPlatformAware;

  String dropdownValue;
  String defaultValue;
  List<String> dropdownItems = [];

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
          dropdownItems.clear();
          var bindValue = getText(widget.data, bindings);
          widget.data.options.forEach((option) {
            dropdownItems.add(option.textKey);
            if (bindValue.isEmpty && option.defaultValue != null && option.defaultValue) {
              bindValue = option.value;
            }
          });
          dropdownValue = dropdownItems[indexFromValue(bindValue)];
          return DropdownButton<String>(
            value: dropdownValue,
            icon: Icon(Icons.arrow_drop_down),
            iconSize: 24,
            elevation: 16,
            underline: Container(
              height: 2,
              color: Theme.of(context).accentColor,
            ),
            onChanged: (String newValue) {
              setState(() {
                var index = indexFromDisplayValue(newValue);
                bindings.save(widget.data.bind, widget.data.options[index].value);
              });
            },
            items: dropdownItems.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          );
        }),
      ),
    );
  }

  int indexFromDisplayValue(String value) {
    int index = 0;
    for (var i = 0; i < dropdownItems.length; i++) {
      if (dropdownItems[i] == value) {
        return i;
      }
    }
    return index;
  }

  int indexFromValue(String value) {
    int index = 0;
    for (var i = 0; i < widget.data.options.length; i++) {
      if (widget.data.options[i].value == value) {
        return i;
      }
    }
    return index;
  }
}
