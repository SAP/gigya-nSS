import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/style/styling_mixins.dart';

typedef OnLinkTap(String? link);

/// Adding a "linkification" action.
/// According to specifc regular expression format a spannable text widget will be
/// created which will add touch click triggering for external & internal links.
class Linkify with StyleMixin {
  final String original;
  final RegExp _regExp = RegExp(r'\[([^\]]*)\]\(([^)]*)\)');
  Iterable<RegExpMatch>? matches;

  List<String>? wrappers;

  Linkify(this.original) {
    // If true will already prepare the data to linkify it.
    matches = _regExp.allMatches(original);
    wrappers = original.split(_regExp);
  }

  dispose() {
    matches = null;
    wrappers = null;
  }

  bool containLinks(string) {
    return matches!.length > 0;
  }

  linkify(
    NssWidgetData? data,
    OnLinkTap tap,
    Color linkColor,
  ) {
    List<TextSpan> span = [];
    for (var i = 0; i < wrappers!.length; i++) {
      if (i == wrappers!.length - 1) {
        // Add only the last element.
        span.add(TextSpan(text: wrappers![i], style: TextStyle()));
        break;
      }
      final RegExpMatch match = matches!.elementAt(i);
      _linkSingle(wrappers![i], match.group(1), match.group(2), tap, data!,
          span, linkColor);
    }
    return Text.rich(
      TextSpan(children: span),
      overflow: TextOverflow.visible,
      textAlign: getStyle(Styles.textAlign, data: data) ?? TextAlign.start,
    );
  }

  _linkSingle(
    String leading,
    String? actual,
    String? link,
    OnLinkTap tap,
    NssWidgetData data,
    List<TextSpan> list,
    Color linkColor,
  ) {
    list
      ..add(
        TextSpan(
          text: leading,
          style: TextStyle(
            fontSize: getStyle(Styles.fontSize, data: data),
            color: data.disabled!
                ? getThemeColor('disabledColor').withOpacity(0.3)
                : getStyle(Styles.fontColor,
                    data: data, themeProperty: 'textColor'),
            fontWeight: getStyle(Styles.fontWeight, data: data),
          ),
        ),
      )
      ..add(
        TextSpan(
          text: actual,
          style: TextStyle(
            fontSize: getStyle(Styles.fontSize, data: data),
            color: data.disabled!
                ? getThemeColor('disabledColor').withOpacity(0.3)
                : linkColor,
            fontWeight: getStyle(Styles.fontWeight, data: data),
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = (() {
              tap(link);
            }),
        ),
      );
  }

  static bool isValidUrl(String validate) {
    var split = validate.split('://');
    var protocols = ['http', 'https'];
    if (split.length == 1) {
      return false;
    }
    if (!protocols.contains(split[0])) {
      return false;
    }
    return Uri.parse(validate).isAbsolute;
  }
}
