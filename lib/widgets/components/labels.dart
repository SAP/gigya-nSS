import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/providers/binding_provider.dart';
import 'package:gigya_native_screensets_engine/providers/runtime_provider.dart';
import 'package:gigya_native_screensets_engine/providers/screen_provider.dart';
import 'package:gigya_native_screensets_engine/style/decoration_mixins.dart';
import 'package:gigya_native_screensets_engine/style/styling_mixins.dart';
import 'package:gigya_native_screensets_engine/utils/accessibility.dart';
import 'package:gigya_native_screensets_engine/utils/error.dart';
import 'package:gigya_native_screensets_engine/utils/linkify.dart';
import 'package:gigya_native_screensets_engine/utils/localization.dart';
import 'package:provider/provider.dart';

class LabelWidget extends StatefulWidget {
  final NssWidgetData? data;

  LabelWidget({Key? key, this.data}) : super(key: key);

  @override
  _LabelWidgetState createState() => _LabelWidgetState();
}

class _LabelWidgetState extends State<LabelWidget>
    with
        DecorationMixin,
        StyleMixin,
        LocalizationMixin,
        BindingMixin,
        VisibilityStateMixin,
        ErrorMixin {
  @override
  void initState() {
    super.initState();

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
        BindingValue bindingValue = getBindingText(widget.data!, bindings);

        // Check for binding error. Display on screen.
        if (bindingValueError(bindingValue)) {
          return bindingValueErrorDisplay(widget.data!.bind,
              errorText: bindingValue.errorText);
        }

        // Check for binding error. Display on screen.
        if (bindingValueError(bindingValue)) {
          return bindingValueErrorDisplay(widget.data!.bind,
              errorText: bindingValue.errorText);
        }

        // Binding validated.
        String? text = bindingValue.value;
        if (text == null) {
          // Get localized label text.
          text = localizedStringFor(widget.data!.textKey);
        }

        // Apply link action if needed.
        final Linkify linkify = Linkify(text ?? '');
        final bool linkified = linkify.containLinks(text);
        if (!linkified) linkify.dispose();

        return SemanticsWrapperWidget(
          accessibility: widget.data!.accessibility,
          child: Visibility(
            visible: isVisible(viewModel, widget.data),
            child: Padding(
              padding: getStyle(Styles.margin, data: widget.data),
              child: NssCustomSizeWidget(
                data: widget.data,
                child: Opacity(
                  opacity: getStyle(Styles.opacity, data: widget.data),
                  child: Container(
                    color: getStyle(Styles.background, data: widget.data),
                    child: linkified
                        ? linkify.linkify(widget.data, (link) {
                            viewModel.linkifyLinkOrRoute(link!);
                          },
                            // link color
                            getStyle(Styles.linkColor,
                                    data: widget.data,
                                    themeProperty: 'linkColor') ??
                                getColor('blue'))
                        : Text(
                            text!,
                            textAlign:
                                getStyle(Styles.textAlign, data: widget.data) ??
                                    TextAlign.start,
                            style: TextStyle(
                              fontSize:
                                  getStyle(Styles.fontSize, data: widget.data),
                              color: getStyle(Styles.fontColor,
                                  data: widget.data,
                                  themeProperty: 'textColor'),
                              fontWeight: getStyle(Styles.fontWeight,
                                  data: widget.data),
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
