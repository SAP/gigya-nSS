import 'package:gigya_native_screensets_engine/config.dart';
import 'package:gigya_native_screensets_engine/injector.dart';
import 'package:gigya_native_screensets_engine/utils/localization.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'nss_test_extensions.dart';

class MockLocalized with LocalizationMixin {}

void main() {
  group('Localization: Simple tests', () {
    var config = MockConfig();
    var markup = MockMarkup();
    when(config.markup).thenReturn(markup);

    Map<String, dynamic> localizationMap = {
      '_default': {'hello': 'Hello'},
      'es': {'hello': 'Hola'}
    };

    when(markup.localiation).thenReturn(localizationMap);

    // Mock IOC.
    NssIoc().register(NssConfig, (ioc) => config);

    test(
      'localizedStringFor: default lang',
      () async {
        var lcl = MockLocalized();

        expect(lcl.localizedStringFor('hello'), 'Hello');
      },
    );

    test(
      'localizedStringFor: lang: es',
      () async {
        when(markup.lang).thenReturn('es');
        var lcl = MockLocalized();

        expect(lcl.localizedStringFor('hello'), 'Hola');
      },
    );

    test(
      'localizedStringFor: lang: en (not available)',
      () async {
        when(markup.lang).thenReturn('en');
        var lcl = MockLocalized();

        expect(lcl.localizedStringFor('hello'), 'Hello');
      },
    );
  });
}
