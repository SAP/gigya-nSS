import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/style/styling_mixins.dart';

typedef OnLinkTap(String link);

class Linkify with StyleMixin {
  final String original;
  final RegExp _regExp = RegExp(r'\[([^\]]*)\]\(([^)]*)\)');
  Iterable<RegExpMatch> matches;

  List<String> wrappers;

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
      final RegExpMatch match = matches.elementAt(i);
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
          text: actual,
          style: TextStyle(
            fontSize: getStyle(Styles.fontSize, styles),
            color: getColor('blue'), // TODO: need to take color from theme.
            fontWeight: getStyle(Styles.fontWeight, styles),
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
    var protocols = ['http', 'https', 'ftp'];
    if (split.length == 1) {
      return false;
    }
    if (!protocols.contains(split[0])) {
      return false;
    }
    return Uri.parse(validate).isAbsolute;
  }
}
