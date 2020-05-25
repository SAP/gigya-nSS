import 'package:flutter/cupertino.dart';
import 'package:test/test.dart';
import 'package:gigya_native_screensets_engine/utils/extensions.dart';

void main() {
  group('Linkify: ', () {
    test(
      'matches 1',
      () async {
//        String str = 'this is a cool text then suddenly... '
//            '[there\'s a link](https://myBrand.com/terms.html)...'
//            ' this bla bla';
//        Iterable<RegExpMatch> matches = str.linkMatches();
//        expect(matches.length, 1);
//        for (final m in matches) {
//          debugPrint('text: ');
//          debugPrint(m.group(1));
//          expect('there\'s a link', m.group(1));
//          debugPrint('url:');
//          debugPrint(m.group(2));
//          expect('https://myBrand.com/terms.html', m.group(2));
//        }
//        debugPrint(str.split(RegExp(r'\[([^\]]*)\]\(([^)]*)\)')).toString());
      },
    );

    test(
      'matches multiple',
      () async {
//        String str = 'And [there](https://www.google.co.il/maps) we stood and'
//            ' [searched](http://www.google.com) for the meaning of life';
//        Iterable<RegExpMatch> matches = str.linkMatches();
//        expect(matches.length, 2);
//        for (final m in matches) {
//          debugPrint('text: ');
//          debugPrint(m.group(1));
//          debugPrint('url:');
//          debugPrint(m.group(2));
//        }
//        debugPrint(str.split(RegExp(r'\[([^\]]*)\]\(([^)]*)\)')).toString());
      },
    );
  });
}
