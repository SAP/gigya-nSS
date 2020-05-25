import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

typedef OnLinkTap(String link);

class Linkify {
  static const String linkifyPattern = r'\[([^\]]*)\]\(([^)]*)\)';

  final RegExp _regExp = RegExp(linkifyPattern);
  Iterable<RegExpMatch> matches;
  String original;

  bool containsLinks(string) {
    // If true will already prepare the data to linkify it.
    original = string;
    matches = _regExp.allMatches(original);
    return matches.length > 0;
  }

  linkify(Map<String, dynamic> styles, OnLinkTap tap) {
    List<TextSpan> span = List<TextSpan>();
    List<String> wrappers = original.split(_regExp);
    for (var i = 0; i < wrappers.length; i++) {
      if (i == wrappers.length - 1) {
        // Add only the last element.
        span.add(TextSpan(text: wrappers[i], style: TextStyle()));
      }
      RegExpMatch match = matches.elementAt(i);
      _linkSingle(wrappers[i], match.group(1), match.group(2), tap, span);
    }
    return RichText(
      text: TextSpan(children: span),
    );
  }

  _linkSingle(String leading, String actual, String link, OnLinkTap tap, List<TextSpan> list) {
    list
      ..add(
        TextSpan(
          text: leading,
          style: TextStyle(),
        ),
      )
      ..add(
        TextSpan(
          text: actual,
          style: TextStyle(),
          recognizer: TapGestureRecognizer()..onTap = (tap(link)),
        ),
      );
  }
}
