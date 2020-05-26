import 'package:gigya_native_screensets_engine/utils/linkify.dart';
import 'package:test/test.dart';

void main() {
  group('Linkify: ', () {

    test(
      'no matches',
          () async {
        String str = 'there is a ghost in the machine';
        Linkify linkify = Linkify();
        final bool isLinkified = linkify.containsLinks(str);
        expect(isLinkified, false);
        expect(linkify.matches.length, 0);
      },
    );

    test(
      'matches single',
      () async {
        String str = 'this is a cool text then suddenly... '
            '[there\'s a link](https://myBrand.com/terms.html)...'
            ' this bla bla';
        Linkify linkify = Linkify();
        final bool isLinkified = linkify.containsLinks(str);
        expect(isLinkified, true);
        expect(linkify.matches.length, 1);
        expect(linkify.matches.elementAt(0).group(1), 'there\'s a link');
        expect(linkify.matches.elementAt(0).group(2), 'https://myBrand.com/terms.html');
        expect(linkify.wrappers[0], 'this is a cool text then suddenly... ');
        expect(linkify.wrappers[1], '... this bla bla');
      },
    );

    test(
      'matches multiple',
      () async {
        String str = 'And [there](https://www.google.co.il/maps) we stood and'
            ' [searched](http://www.google.com) for the meaning of life';
        Linkify linkify = Linkify();
        final bool isLinkified = linkify.containsLinks(str);
        expect(isLinkified, true);
        expect(linkify.matches.length, 2);
        expect(linkify.matches.elementAt(0).group(1), 'there');
        expect(linkify.matches.elementAt(0).group(2), 'https://www.google.co.il/maps');
        expect(linkify.matches.elementAt(1).group(1), 'searched');
        expect(linkify.matches.elementAt(1).group(2), 'http://www.google.com');
        expect(linkify.wrappers[0],'And ');
        expect(linkify.wrappers[1],' we stood and ');
        expect(linkify.wrappers[2],' for the meaning of life');
      },
    );
  });
}
