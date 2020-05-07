import 'package:flutter/material.dart';
import 'package:gigya_native_screensets_engine/models/option.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/providers/binding_provider.dart';
import 'package:gigya_native_screensets_engine/style/decoration_mixins.dart';
import 'package:provider/provider.dart';

class CheckboxWidget extends StatefulWidget {
  final NssWidgetData data;

  const CheckboxWidget({Key key, this.data}) : super(key: key);

  @override
  _CheckboxWidgetState createState() => _CheckboxWidgetState();
}

/// General checkbox widget state.
class _CheckboxWidgetState extends State<CheckboxWidget> with WidgetDecorationMixin, BindingMixin {
  bool _currentValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: defaultPadding(),
      child: Consumer<BindingModel>(
        builder: (context, bindings, child) {
          _currentValue = getBool(widget.data, bindings);
          return CheckboxListTile(
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(widget.data.textKey),
            value: _currentValue,
            onChanged: (bool val) {
              setState(() {
                bindings.save(widget.data.bind, val);
              });
            },
          );
        },
      ),
    );
  }
}

class RadioGroupWidget extends StatefulWidget {
  final NssWidgetData data;

  const RadioGroupWidget({Key key, this.data}) : super(key: key);

  @override
  _RadioGroupWidgetState createState() => _RadioGroupWidgetState();
}

/// General radio group widget state.
class _RadioGroupWidgetState extends State<RadioGroupWidget> with WidgetDecorationMixin, BindingMixin {
  String _groupValue;
  String _defaultValue;

  @override
  Widget build(BuildContext context) {
    return expandIfNeeded(widget.data.expand, Padding(
      padding: defaultPadding(),
      child: Consumer<BindingModel>(
        builder: (context, bindings, child) {
          _groupValue = getText(widget.data, bindings);
          if (_groupValue.isEmpty) {
            widget.data.options.forEach((option) {
              if (option.defaultValue != null && option.defaultValue) {
                _groupValue = option.value;
              }
            });
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.data.options.length,
            itemBuilder: (BuildContext lvbContext, int index) {
              NssOption option = widget.data.options[index];
              return RadioListTile(
                controlAffinity: ListTileControlAffinity.leading,
                value: option.value,
                title: Text(option.textKey),
                groupValue: _groupValue,
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
    ));
  }
}

class DropDownButtonWidget extends StatefulWidget {
  final NssWidgetData data;

  const DropDownButtonWidget({Key key, this.data}) : super(key: key);

  @override
  _DropDownButtonWidgetState createState() => _DropDownButtonWidgetState();
}

/// General dropdown button widget state.
class _DropDownButtonWidgetState extends State<DropDownButtonWidget> with WidgetDecorationMixin, BindingMixin {
  String _dropdownValue;
  List<String> _dropdownItems = [];

  int indexFromDisplayValue(String value) {
    int index = 0;
    for (var i = 0; i < _dropdownItems.length; i++) {
      if (_dropdownItems[i] == value) {
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

  @override
  Widget build(BuildContext context) {
    return expandIfNeeded(widget.data.expand, Padding(
      padding: defaultPadding(),
      child: Consumer<BindingModel>(builder: (context, bindings, child) {
        _dropdownItems.clear();
        var bindValue = getText(widget.data, bindings);
        widget.data.options.forEach((option) {
          _dropdownItems.add(option.textKey);
          if (bindValue.isEmpty && option.defaultValue != null && option.defaultValue) {
            bindValue = option.value;
          }
        });
        _dropdownValue = _dropdownItems[indexFromValue(bindValue)];
        return DropdownButton<String>(
          isExpanded: true,
          value: _dropdownValue,
          icon: Icon(
            Icons.arrow_drop_down,
            color: Theme.of(context).accentColor,
          ),
          iconSize: 24,
          elevation: 4,
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
          items: _dropdownItems.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        );
      }),
    ));
  }
}