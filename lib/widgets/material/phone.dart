import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gigya_native_screensets_engine/config.dart';
import 'package:gigya_native_screensets_engine/ioc/injector.dart';
import 'package:gigya_native_screensets_engine/models/markup.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/providers/binding_provider.dart';
import 'package:gigya_native_screensets_engine/providers/runtime_provider.dart';
import 'package:gigya_native_screensets_engine/providers/screen_provider.dart';
import 'package:gigya_native_screensets_engine/style/decoration_mixins.dart';
import 'package:gigya_native_screensets_engine/style/styling_mixins.dart';
import 'package:gigya_native_screensets_engine/utils/accessibility.dart';
import 'package:gigya_native_screensets_engine/utils/localization.dart';
import 'package:gigya_native_screensets_engine/utils/validation.dart';
import 'package:provider/provider.dart';

/// Phone input component.
/// Designed for inputting phone number only with adjacent country code selection.
class PhoneInputWidget extends StatefulWidget {
  final NssWidgetData data;

  const PhoneInputWidget({Key key, this.data}) : super(key: key);

  @override
  _PhoneInputWidgetState createState() => _PhoneInputWidgetState();
}

class _PhoneInputWidgetState extends State<PhoneInputWidget>
    with LocalizationMixin, StyleMixin, DecorationMixin, ValidationMixin, VisibilityStateMixin {
  /// Memory allocation of available country codes objects.
  List<CountryCodePick> _countryCodeList = [];

  /// Current pick object.
  CountryCodePick _countryCodePick = CountryCodePick.fallback();

  /// Phone input text controller.
  final TextEditingController _textEditingController =
      TextEditingController(text: '');

  /// Widget specific data that is parsed out of the generic [NssWidgetData] injection.
  Countries _countriesData;

  @override
  void initState() {
    super.initState();

    // Parsing widget specific data. Can be null if the client does not provide one.
    _countriesData = widget.data.countries;

    registerVisibilityNotifier(context, widget.data, () {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ScreenViewModel, BindingModel>(
      builder: (context, viewModel, bindings, child) {
        return Visibility(
          visible: isVisible(viewModel, widget.data),
          child: FutureBuilder<List<CountryCodePick>>(
            future: _countryCodeList.isEmpty ? loadCC() : cachedCC(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                _countryCodeList = snapshot.data;
                // Need to set the default pick.
                return _ccPhoneView(bindings);
              }
              return _ccPlaceHolderView();
            },
          ),
        );
      },
    );
  }

  /// Widget will be displayed while loading the country code list and initializing the data.
  Widget _ccPlaceHolderView() {
    return Padding(
      padding: stylePadding(widget.data),
      child: NssCustomSizeWidget(
        data: widget.data,
        child: Container(
          color: styleBackground(widget.data),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  constraints: BoxConstraints(minWidth: 60),
                ),
              ),
              Expanded(
                child: TextField(
                  enabled: false,
                  textAlign: styleTextAlign(widget.data),
                  style: TextStyle(
                    // Style font color.
                    color: styleFontColor(widget.data, widget.data.disabled),
                    // Style font size.
                    fontSize: styleFontSize(widget.data),
                    // Style font weight.
                    fontWeight: styleFontWeight(widget.data),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// Main widget view.
  /// 1. Displays the default (selected/device) country (flag if shown) and dialCode in a selection view.
  /// 2. Phone number input.
  ///
  /// Pressing on the cc view will open the selection and provide scroll selection & search options.
  Widget _ccPhoneView(bindings) {
    final borderSize = styleBorderSize(widget.data);
    final borderRadius = styleBorderRadius(widget.data);

    return Padding(
      // Style padding.
      padding: stylePadding(widget.data),
      // Style sizing.
      child: NssCustomSizeWidget(
        data: widget.data,
        // Style opacity.
        child: Opacity(
          opacity: styleOpacity(widget.data),
          child: Container(
            // Style background.
            child: Row(
              children: [
                Flexible(
                  child: SemanticsWrapperWidget(
                    accessibility: widget.data.accessibility,
                    child: TextFormField(
                      controller: _textEditingController,
                      // Style enabled/disabled.
                      enabled: !widget.data.disabled,
                      // Style textAlign.
                      textAlign: styleTextAlign(widget.data),
                      style: TextStyle(
                        // Style font color.
                        color:
                            styleFontColor(widget.data, widget.data.disabled),
                        // Style font size.
                        fontSize: styleFontSize(widget.data),
                        // Style font weight.
                        fontWeight: styleFontWeight(widget.data),
                      ),
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: styleBackground(widget.data),
                          prefixIcon: InkWell(
                            // Verify click.
                            onTap: widget.data.disabled
                                ? null
                                : allowCCTap()
                                    ? () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return _ccSelectionDialog();
                                            });
                                      }
                                    : null,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 12, right: 8, top: 8, bottom: 8),
                              child: Container(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _showCountryIcons()
                                        ? Text(_countryCodePick.flag)
                                        : Container(),
                                    SizedBox(width: 8),
                                    Text(
                                      _countryCodePick.dialCode,
                                      style: TextStyle(
                                          // Style font color
                                          color: styleFontColor(widget.data,
                                              widget.data.disabled),
                                          // Style font size.
                                          fontSize: getStyle(Styles.fontSize,
                                              data: widget.data),
                                          // Style font weight.
                                          fontWeight: getStyle(
                                              Styles.fontWeight,
                                              data: widget.data)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          hintText: localizedStringFor(widget.data.textKey),
                          // Style placeholder/hint.
                          hintStyle: TextStyle(
                            color: stylePlaceholder(
                                widget.data, widget.data.disabled),
                          ),
                          disabledBorder: borderRadius == 0
                              ? UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: getThemeColor('disabledColor')
                                        .withOpacity(0.3),
                                    width: borderSize + 2,
                                  ),
                                )
                              : OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(borderRadius)),
                                  borderSide: BorderSide(
                                    color: getThemeColor('disabledColor')
                                        .withOpacity(0.3),
                                    width: borderSize,
                                  ),
                                ),
                          errorBorder: borderRadius == 0
                              ? UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: getThemeColor('errorColor'),
                                    width: borderSize + 2,
                                  ),
                                )
                              : OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(borderRadius)),
                                  borderSide: BorderSide(
                                    color: getThemeColor('errorColor'),
                                    width: borderSize,
                                  ),
                                ),
                          focusedErrorBorder: borderRadius == 0
                              ? UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: getThemeColor('errorColor'),
                                    width: borderSize + 2,
                                  ),
                                )
                              : OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(borderRadius)),
                                  borderSide: BorderSide(
                                    color: getThemeColor('errorColor'),
                                    width: borderSize,
                                  ),
                                ),
                          focusedBorder: borderRadius == 0
                              ? UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: getThemeColor('enabledColor'),
                                    width: borderSize + 2,
                                  ),
                                )
                              : OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(borderRadius)),
                                  borderSide: BorderSide(
                                    color: getThemeColor('enabledColor'),
                                    width: borderSize,
                                  ),
                                ),
                          enabledBorder: borderRadius == 0
                              ? UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: styleBorderColor(widget.data),
                                    width: borderSize,
                                  ),
                                )
                              : OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(borderRadius)),
                                  borderSide: BorderSide(
                                    color: styleBorderColor(widget.data),
                                    width: borderSize,
                                  ),
                                )),
                      onChanged: (input) {
                        onValueSave(input, bindings);

                        // Track runtime data change.
                        Provider.of<RuntimeStateEvaluator>(context,
                            listen: false)
                            .notifyChanged(widget.data.bind, input);
                      },
                      onSaved: (input) {
                          onValueSave(input, bindings);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onValueSave(input, bindings) {
    // Combine text from code selection & phone number.
    final String phone =
        _countryCodePick.dialCode + input.trim();

    // Field can only be bound using the bind tag.
    bindings.save<String>(widget.data.bind, phone);
  }

  /// Check if click on country code picker area is allowed.
  bool allowCCTap() {
    // Widget is set to disabled.
    if (widget.data.disabled) return false;
    // Lock the click if no countries are available or set to a single include.
    if (_countryCodeList.isEmpty || _countryCodeList.length == 1) return false;
    return true;
  }

  /// Determine if the widget will display country code icons in the phone widget only!!
  bool _showCountryIcons() {
    if (_countriesData == null) return true;
    return _countriesData.showIcons;
  }

  /// Country code selection dialog/floating screen.
  Widget _ccSelectionDialog() {
    return Material(
      color: Colors.transparent,
      child: Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 30.0),
        child: CountryPickerDialogWidget(
          mainList: _countryCodeList,
          showIcons: _showCountryIcons(),
          onPick: (picked) {
            // Update picked selection.
            setState(() {
              _countryCodePick = picked;
            });
          },
        ),
      ),
    );
  }

  /// Return the cached country code list to prevent the future to load the initial state again.
  Future<List<CountryCodePick>> cachedCC() async {
    return _countryCodeList;
  }

  /// Load static country code JSON from assets.
  /// Loading needs to take place prior to widget build.
  Future<List<CountryCodePick>> loadCC() async {
    Map tempCCMap = {};
    String data = await DefaultAssetBundle.of(context)
        .loadString("assets/static/countries.json");
    tempCCMap = Map.fromIterable(json.decode(data),
        key: (e) => e['code'], value: (e) => e);
    includeEntries(tempCCMap);
    excludeEntries(tempCCMap);
    replaceWithLocalizedEntries(tempCCMap);
    getDefaultCCPick(tempCCMap);
    // To list with sorting.
    return CountryCodePick.listFrom(tempCCMap);
  }

  /// Include various entries (manually).
  /// This will override the asset loading.
  void includeEntries(Map ccMap) {
    if (_countriesData == null) return;
    if (_countriesData.include.isEmpty) return;
    _countriesData.include =
        _countriesData.include.map((element) => element.toUpperCase()).toList();
    ccMap.removeWhere((key, value) => !_countriesData.include.contains(key));
  }

  /// Exclude various entries (manually).
  /// This will not override any pre-loaded assets.
  void excludeEntries(Map ccMap) {
    if (_countriesData == null) return;
    if (_countriesData.exclude.isEmpty) return;
    _countriesData.exclude =
        _countriesData.exclude.map((element) => element.toUpperCase()).toList();
    ccMap.removeWhere((key, value) => _countriesData.exclude.contains(key));
  }

  /// Replace country code entries with manually localized entries.
  /// Entries need to be in a specific pattern.
  ///
  /// For example: COUNTRY_IL or COUNTRY_il.
  void replaceWithLocalizedEntries(Map ccMap) {
    var localizedEntries = entriesInMapThat('COUNTRY', '_');
    if (localizedEntries.isNotEmpty) {
      // Replace country code display map name with manually localized Strings.
      localizedEntries.forEach(
        (key, value) {
          if (ccMap.containsKey(key)) {
            ccMap[key]['name'] = value;
          }
        },
      );
    }
  }

  /// Determine the default country code displayed when the widget is initialized.
  void getDefaultCCPick(Map ccMap) {
    // This means that the client have included only one option in the include list which
    // we will treat as a single selection.
    if (ccMap.length == 1) {
      _countryCodePick =
          CountryCodePick.fromJson(ccMap.entries.first.value.toUpperCase());
      return;
    }

    // Fetch the platform injected iso3116-2 country code if available.
    final Platform platform = NssIoc().use(NssConfig).markup.platform;
    if (platform != null) {
      final String iso3116 = platform.iso3166 ?? "US";
      _countryCodePick = CountryCodePick.fromJson(ccMap[iso3116.toUpperCase()]);
    }

    // Manually set the default selected country code.
    if (_countriesData != null && _countriesData.defaultSelected != 'auto') {
      _countryCodePick = CountryCodePick.fromJson(
          ccMap[_countriesData.defaultSelected.toUpperCase()]);
    }
  }
}

/// Country code dialog selection widget.
//TODO: Widget is not styled.
class CountryPickerDialogWidget extends StatefulWidget {
  final List<CountryCodePick> mainList;
  final OnCountryCodePick onPick;
  final bool showIcons;

  const CountryPickerDialogWidget(
      {Key key, this.mainList, this.onPick, this.showIcons})
      : super(key: key);

  @override
  _CountryPickerDialogWidgetState createState() =>
      _CountryPickerDialogWidgetState();
}

/// Definition for country code picker child widget callback.
typedef OnCountryCodePick(CountryCodePick pick);

class _CountryPickerDialogWidgetState extends State<CountryPickerDialogWidget> {
  /// List of country code objects used for search purposes.
  List<CountryCodePick> _countryCodeSearchList = [];

  @override
  void initState() {
    super.initState();
    // Reset search list.
    _countryCodeSearchList = List.of(widget.mainList);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 20, top: 10, right: 20, bottom: 10),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: widget.showIcons ? Icon(Icons.search) : null,
              ),
              onChanged: (input) {
                if (input.isEmpty) {
                  // Reset search list.
                  setState(() {
                    _countryCodeSearchList.clear();
                    _countryCodeSearchList.addAll(List.of(widget.mainList));
                  });
                  return;
                }
                // Filter list by search input.
                setState(() {
                  _countryCodeSearchList.clear();
                  _countryCodeSearchList.addAll(widget.mainList
                      .where((CountryCodePick element) => element.name
                          .toLowerCase()
                          .startsWith(input.toLowerCase()))
                      .toList());
                });
              },
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _countryCodeSearchList.length,
              itemBuilder: (BuildContext context, int index) {
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      // Confirm selection.
                      widget.onPick(_countryCodeSearchList[index]);
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 4),
                      child: _ccPickerTile(
                          _countryCodeSearchList[index], widget.showIcons),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Picker selection tile.
  /// Constructed of flag image and country name.
  ///
  //TODO: Picker style is not styled.
  Widget _ccPickerTile(CountryCodePick pick, bool showIcons) {
    return Container(
      constraints: BoxConstraints(minHeight: 44),
      child: Row(
        children: [
          Visibility(
            visible: showIcons,
            child: Center(
              child: Text(pick.flag),
            ),
          ),
          SizedBox(width: 20),
          Text(
            pick.dialCode,
            style: TextStyle(
              fontSize: 15,
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Text(
              pick.name,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Country code entry helper class.
class CountryCodePick {
  String name;
  String code;
  String dialCode;
  String flag;

  CountryCodePick.fromJson(Map json)
      : name = json['name'],
        code = json['code'],
        flag = json['flag'],
        dialCode = json['dial_code'];

  /// Fallback country code object is set to US.
  static fallback() => CountryCodePick.fromJson({
        "name": "United States",
        "flag": "🇺🇸",
        "code": "US",
        "dial_code": "+1"
      });

  static List<CountryCodePick> listFrom(Map map) {
    List<CountryCodePick> list = [];
    map.entries.forEach((e) => list.add(CountryCodePick.fromJson(e.value)));
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }
}
