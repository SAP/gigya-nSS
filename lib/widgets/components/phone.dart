import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
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
  final NssWidgetData? data;

  const PhoneInputWidget({Key? key, this.data}) : super(key: key);

  @override
  _PhoneInputWidgetState createState() => _PhoneInputWidgetState();
}

class _PhoneInputWidgetState extends State<PhoneInputWidget> with LocalizationMixin, StyleMixin, DecorationMixin, ValidationMixin, VisibilityStateMixin, BindingMixin {
  /// Memory allocation of available country codes objects.
  List<CountryCodePick>? _countryCodeList = [];

  /// Current pick object.
  CountryCodePick _countryCodePick = CountryCodePick.fallback();

  /// Phone input text controller.
  final TextEditingController _phoneNumberController = TextEditingController(text: '');
  String? eventInjectedError;

  /// Widget specific data that is parsed out of the generic [NssWidgetData] injection.
  Countries? _countriesData;

  @override
  void initState() {
    super.initState();

    initValidators(widget.data!);
    // Parsing widget specific data. Can be null if the client does not provide one.
    _countriesData = widget.data!.countries;

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
          child: FutureBuilder<List<CountryCodePick>?>(
            future: _countryCodeList!.isEmpty ? loadCC() : cachedCC(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                _countryCodeList = snapshot.data;
                setBindingValue(bindings);

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

  setBindingValue(BindingModel bindings){
    BindingValue bindingValue = getBindingText(widget.data!, bindings,asArray: widget.data!.storeAsArray);

    if(bindingValue.value != null) {
      CountryCodePick? country = getPhonesCountryCode(bindingValue.value);

      if (country != null) {
        _countryCodePick = country;
        String bindingPhone = bindingValue.value.replaceFirst(country.dialCode, '').trim();
        _phoneNumberController.text = bindingPhone;
      }
    }
  }

  CountryCodePick? getPhonesCountryCode(String phoneNumber) {
    return _countryCodeList?.firstWhere((country)=> phoneNumber.startsWith(country.dialCode as String));
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
                child: PlatformTextField(
                  enabled: false,
                  textAlign: styleTextAlign(widget.data),
                  style: TextStyle(
                    // Style font color.
                    color: styleFontColor(widget.data, widget.data!.disabled),
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

    return Container(
      // Style opacity.
      child: SemanticsWrapperWidget(
        accessibility: widget.data!.accessibility,
        child: Padding(
          padding: getStyle(Styles.margin, data: widget.data),
          child: Opacity(
            opacity: getStyle(Styles.opacity, data: widget.data),
            child: PlatformTextFormField(
              material: (_, __) => MaterialTextFormFieldData(
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                  isDense: true,
                  filled: true,
                  fillColor: styleBackground(widget.data),
                  prefixIconConstraints: BoxConstraints(maxHeight: 26),
                  prefixIcon: InkWell(
                    // Verify click.
                    onTap: widget.data!.disabled!
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
                      padding: const EdgeInsets.only(left: 12.0, right: 8, top: 0, bottom: 0),
                      child: Container(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _showCountryIcons()! ? Text(_countryCodePick.flag!) : Container(),
                            SizedBox(width: 8),
                            Text(
                              _countryCodePick.dialCode!,
                              style: TextStyle(
                                  // Style font color
                                  color: styleFontColor(widget.data, widget.data!.disabled),
                                  // Style font size.
                                  fontSize: getStyle(Styles.fontSize, data: widget.data),
                                  // Style font weight.
                                  fontWeight: getStyle(Styles.fontWeight, data: widget.data)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  hintText: localizedStringFor(widget.data!.textKey),
                  // Style placeholder/hint.
                  hintStyle: TextStyle(
                    color: stylePlaceholder(widget.data, widget.data!.disabled!),
                  ),
                  disabledBorder: borderRadius == 0
                      ? UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: getThemeColor('disabledColor').withOpacity(0.3),
                            width: borderSize + 2,
                          ),
                        )
                      : OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                          borderSide: BorderSide(
                            color: getThemeColor('disabledColor').withOpacity(0.3),
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
                          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
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
                          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                          borderSide: BorderSide(
                            color: getThemeColor('errorColor'),
                            width: borderSize,
                          ),
                        ),
                ),
              ),
              cupertino: (_, __) => CupertinoTextFormFieldData(
                padding: EdgeInsets.all(4),
                controller: _phoneNumberController,
                decoration: BoxDecoration(color: styleBackground(widget.data), backgroundBlendMode: BlendMode.color),
                prefix: buildPrefix(),
                placeholder:localizedStringFor(widget.data!.textKey),
                placeholderStyle: styleText(widget.data),
              ),
              controller: _phoneNumberController,
              // Style enabled/disabled.
              enabled: !widget.data!.disabled!,
              // Style textAlign.
              textAlign: styleTextAlign(widget.data),
              style: TextStyle(
                // Style font color.
                color: styleFontColor(widget.data, widget.data!.disabled),
                // Style font size.
                fontSize: styleFontSize(widget.data),
                // Style font weight.
                fontWeight: styleFontWeight(widget.data),
              ),
              keyboardType: TextInputType.phone,
              onChanged: (input) {
                onValueSave(input, bindings);

                // Track runtime data change.
                Provider.of<RuntimeStateEvaluator>(context, listen: false).notifyChanged(widget.data!.bind, input);
              },
              validator: (input) {
                if(widget.data!.disabled! == true)
                  return null;
                // Event injected error has priority in field validation.
                if (eventInjectedError != null) {
                  if (eventInjectedError!.isEmpty) {
                    eventInjectedError = null;
                    return null;
                  }
                }
                // Field validation triggered.
                return validateField(input, widget.data!.bind);
              },
              onSaved: (input) {
                onValueSave(input, bindings);
              },
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector buildPrefix() {
    return GestureDetector(
                        // Verify click.
                        onTap: widget.data!.disabled!
                            ? null
                            : allowCCTap()
                                ? () {
                                    _showCupertinoDialog(context);
                                  }
                                : null,
                        child: Container(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(width: 8),
                              //Text(_countryCodePick.flag!),
                              _showCountryIcons()! ? Text(_countryCodePick.flag!) : Container(),
                              SizedBox(width: 8),
                              Text(
                                _countryCodePick.dialCode!,
                                style: TextStyle(
                                    // Style font color
                                    color: styleFontColor(widget.data, widget.data!.disabled),
                                    // Style font size.
                                    fontSize: getStyle(Styles.fontSize, data: widget.data),
                                    // Style font weight.
                                    fontWeight: getStyle(Styles.fontWeight, data: widget.data)),
                              ),
                            ],
                          ),
                        ),
                      );
  }

  void onValueSave(input, bindings) {
    // Combine text from code selection & phone number.
    final String phone = _countryCodePick.dialCode! + input.trim();

    // Field can only be bound using the bind tag.
    bindings.save<String>(widget.data!.bind, phone);
  }

  /// Check if click on country code picker area is allowed.
  bool allowCCTap() {
    // Widget is set to disabled.
    if (widget.data!.disabled!) return false;
    // Lock the click if no countries are available or set to a single include.
    if (_countryCodeList!.isEmpty || _countryCodeList!.length == 1) return false;
    return true;
  }

  /// Determine if the widget will display country code icons in the phone widget only!!
  bool? _showCountryIcons() {
    if (_countriesData == null) return true;
    return _countriesData!.showIcons;
  }

  void _showCupertinoDialog(BuildContext context) {
    showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) => Container(
          height: 216,
          padding: const EdgeInsets.only(top: 6.0),
          // The Bottom margin is provided to align the popup above the system navigation bar.
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          // Provide a background color for the popup.
          color: CupertinoColors.systemBackground.resolveFrom(context),
          // Use a SafeArea widget to avoid system overlaps.
            child: SafeArea(
              top: false,
                child: _ccCupertinoSelection()
            ),
        ));
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
          countryCodePick: _countryCodePick,
        ),
      ),
    );
  }

  Widget _ccCupertinoSelection() {
    return Material(
      color: Colors.transparent,
      child: CountryPickerDialogWidget(
        mainList: _countryCodeList,
        showIcons: _showCountryIcons(),
        onPick: (picked) {
          // Update picked selection.
          setState(() {
            _countryCodePick = picked;
          });
        },
        countryCodePick: _countryCodePick,
      ),
    );
  }

  /// Return the cached country code list to prevent the future to load the initial state again.
  Future<List<CountryCodePick>?> cachedCC() async {
    return _countryCodeList;
  }

  /// Load static country code JSON from assets.
  /// Loading needs to take place prior to widget build.
  Future<List<CountryCodePick>> loadCC() async {
    Map tempCCMap = {};
    String data = await DefaultAssetBundle.of(context).loadString("assets/static/countries.json");
    tempCCMap = Map.fromIterable(json.decode(data), key: (e) => e['code'], value: (e) => e);
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
    if (_countriesData!.include!.isEmpty) return;
    _countriesData!.include = _countriesData!.include!.map((element) => element.toUpperCase()).toList();
    ccMap.removeWhere((key, value) => !_countriesData!.include!.contains(key));
  }

  /// Exclude various entries (manually).
  /// This will not override any pre-loaded assets.
  void excludeEntries(Map ccMap) {
    if (_countriesData == null) return;
    if (_countriesData!.exclude!.isEmpty) return;
    _countriesData!.exclude = _countriesData!.exclude!.map((element) => element.toUpperCase()).toList();
    ccMap.removeWhere((key, value) => _countriesData!.exclude!.contains(key));
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
      _countryCodePick = CountryCodePick.fromJson(ccMap.entries.first.value.toUpperCase());
      return;
    }

    // Fetch the platform injected iso3116-2 country code if available.
    final Platform? platform = NssIoc().use(NssConfig).markup.platform;
    if (platform != null) {
      final String iso3116 = platform.iso3166 ?? "US";
      _countryCodePick = CountryCodePick.fromJson(ccMap[iso3116.toUpperCase()]);
    }

    // Manually set the default selected country code.
    if (_countriesData != null && _countriesData!.defaultSelected != 'auto') {
      _countryCodePick = CountryCodePick.fromJson(ccMap[_countriesData!.defaultSelected!.toUpperCase()]);
    }
  }
}

/// Country code dialog selection widget.
//TODO: Widget is not styled.
class CountryPickerDialogWidget extends StatefulWidget {
  final List<CountryCodePick>? mainList;
  final OnCountryCodePick? onPick;
  final bool? showIcons;
  final CountryCodePick countryCodePick;

  const CountryPickerDialogWidget({Key? key, this.mainList, this.onPick, this.showIcons, required this.countryCodePick}) : super(key: key);

  @override
  _CountryPickerDialogWidgetState createState() => _CountryPickerDialogWidgetState();
}

/// Definition for country code picker child widget callback.
typedef OnCountryCodePick(CountryCodePick pick);

class _CountryPickerDialogWidgetState extends State<CountryPickerDialogWidget> with DecorationMixin {


  /// List of country code objects used for search purposes.
  List<CountryCodePick> _countryCodeSearchList = [];
  static const double _kItemExtent = 32.0;
  late TextEditingController cupertinoPickerController;
  late FixedExtentScrollController cupertinoScrollController;

  @override
  void initState() {
    _countryCodeSearchList = List.of(widget.mainList!);
    cupertinoPickerController = TextEditingController(text: widget.countryCodePick.name);
    cupertinoScrollController = FixedExtentScrollController(initialItem: _countryCodeSearchList.indexOf(widget.countryCodePick));

    super.initState();
    // Reset search list.
 
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if(isMaterial(context))
            ...buildMaterialSearchBoxPicker(context)
          else
            ...buildCupertinoSearchBoxPicker(context)
        ],
      ),
    );
  }

  List<Widget> buildMaterialSearchBoxPicker(BuildContext context) {
    return [
      Padding(
          padding: const EdgeInsets.only(left: 20, top: 10, right: 20, bottom: 10),
          child: TextFormField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (input) {
              if (input.isEmpty) {
                // Reset search list.
                setState(() {
                  _countryCodeSearchList.clear();
                  _countryCodeSearchList.addAll(List.of(widget.mainList!));
                });
                return;
              }
              // Filter list by search input.
              setState(() {
                _countryCodeSearchList.clear();
                _countryCodeSearchList.addAll(widget.mainList!.where((CountryCodePick element) => element.name!.toLowerCase().startsWith(input.toLowerCase())).toList());
              });
            },
          )

        ),
    Flexible(
    child: ListView.builder(
      shrinkWrap: true,
      itemCount: _countryCodeSearchList.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          onTap: () {
            // Confirm selection.
            widget.onPick!(_countryCodeSearchList[index]);
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: _ccPickerTile(_countryCodeSearchList[index], widget.showIcons!),
          ),
        );
      },
    ),
    )];
  }

  List<Widget> buildCupertinoSearchBoxPicker(BuildContext context) {
    return [
      Padding(
        padding: const EdgeInsets.only(left: 20, top: 10, right: 20, bottom: 10),
        child: CupertinoSearchTextField(
          decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey,
                  width: 1.0,
                ),
              ),
              color: Colors.white, backgroundBlendMode: BlendMode.color
          ),
          padding: const EdgeInsets.all(16.0),
          placeholder: '',
          onChanged: (input) {
            if (input.isEmpty) {
              // Reset search list.
              setState(() {
                _countryCodeSearchList.clear();
                _countryCodeSearchList.addAll(List.of(widget.mainList!));
              });
              return;
            }
            // Filter list by search input.
            setState(() {
              _countryCodeSearchList.clear();
              _countryCodeSearchList.addAll(widget.mainList!.where((CountryCodePick element) => element.name!.toLowerCase().startsWith(input.toLowerCase())).toList());
            });
          },
        ),

      ),
      Flexible(
        child:CupertinoPicker(
          scrollController: cupertinoScrollController,
          magnification: 1.22,
          squeeze: 1.2,
          useMagnifier: true,
          itemExtent: _kItemExtent,
          // This is called when selected item is changed.
          onSelectedItemChanged: (int index) {
            setState(() {
              cupertinoPickerController.text = _countryCodeSearchList[index].name!;
              //cupertinoScrollController.dispose();
              cupertinoScrollController = FixedExtentScrollController(initialItem: index);
              widget.onPick!(_countryCodeSearchList[index]);
            });

          },
          children:
          List<Widget>.generate(_countryCodeSearchList.length, (int index) {
            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                widget.onPick!(_countryCodeSearchList[index]);
                Navigator.of(context).pop(_countryCodeSearchList[index]);
                },
              child: Center(
                child: Text(
                  _countryCodeSearchList[index].name! + ' ' + _countryCodeSearchList[index].dialCode!,
                ),
              ),
            );
          }),
        )
      )];
  }
  /// Picker selection tile.
  /// Constructed of flag image and country name.
  ///
  //TODO: Picker style is not styled.
  Widget _ccPickerTile(CountryCodePick pick, bool showIcons) {
    return Container(
      constraints: BoxConstraints(minHeight: 44),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Visibility(
            visible: showIcons,
            child: Row(
              children: [
                Center(
                  child: Text(pick.flag!),
                ),
                SizedBox(width: 16)
              ],
            ),
          ),
          Container(
            constraints: BoxConstraints(minWidth: 60),
            child: Text(
              pick.dialCode!,
              style: TextStyle(
                fontSize: 15,
              ),
            ),
          ),
          Expanded(
            child: Text(
              pick.name!,
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

  // @override
  // void dispose(){
  //   cupertinoScrollController.dispose();
  //   cupertinoPickerController.dispose();
  //   super.dispose();
  //
  // }


}

/// Country code entry helper class.
class CountryCodePick {
  String? name;
  String? code;
  String? dialCode;
  String? flag;

  CountryCodePick.fromJson(Map json)
      : name = json['name'],
        code = json['code'],
        flag = json['flag'],
        dialCode = json['dial_code'];

  /// Fallback country code object is set to US.
  static fallback() => CountryCodePick.fromJson({"name": "United States", "flag": "🇺🇸", "code": "US", "dial_code": "+1"});

  static List<CountryCodePick> listFrom(Map map) {
    List<CountryCodePick> list = [];
    map.entries.forEach((e) => list.add(CountryCodePick.fromJson(e.value)));
    list.sort((a, b) => a.name!.compareTo(b.name!));
    return list;
  }
}
