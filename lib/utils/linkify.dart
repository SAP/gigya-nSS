import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/style/styling_mixins.dart';

typedef OnLinkTap(String link);

class Linkify with StyleMixin {
  RegExp _regExp = RegExp(r'\[([^\]]*)\]\(([^)]*)\)');
  Iterable<RegExpMatch> matches;
  String _original;
  List<String> wrappers;

  dispose() {
    _regExp = null;
    _original = null;
    matches = null;
    wrappers = null;
  }

  bool containsLinks(string) {
    // If true will already prepare the data to linkify it.
    _original = string;
    matches = _regExp.allMatches(_original);
    wrappers = _original.split(_regExp);
    return matches.length > 0;
  }

  linkify(
    Map<String, dynamic> styles,
    OnLinkTap tap,
  ) {
    List<TextSpan> span = List<TextSpan>();
    for (var i = 0; i < wrappers.length; i++) {
      if (i == wrappers.length - 1) {
        // Add only the last element.
        span.add(TextSpan(text: wrappers[i], style: TextStyle()));
        break;
      }
      RegExpMatch match = matches.elementAt(i);
      _linkSingle(wrappers[i], match.group(1), match.group(2), tap, styles, span);
    }
    return RichText(
      text: TextSpan(children: span),
    );
  }

  _linkSingle(
    String leading,
    String actual,
    String link,
    OnLinkTap tap,
    Map<String, dynamic> styles,
    List<TextSpan> list,
  ) {
    // Check validation of provided link.
    bool isValidUrl = Uri.parse(link).isAbsolute;
    list
      ..add(
        TextSpan(
          text: leading,
          style: TextStyle(
            fontSize: getStyle(Styles.fontSize, styles),
            color: getStyle(Styles.fontColor, styles),
            fontWeight: getStyle(Styles.fontWeight, styles),
          ),
        ),
      )
      ..add(
        TextSpan(
          text: isValidUrl ? actual : 'http link invalid',
          style: TextStyle(
            fontSize: getStyle(Styles.fontSize, styles),
            color: isValidUrl ? getColor('blue') : getColor('red'), // TODO: need to take color from theme.
            fontWeight: getStyle(Styles.fontWeight, styles),
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = (() {
              tap(link);
            }),
        ),
      );
  }
}
