import 'package:gigya_native_screensets_engine/providers/binding_provider.dart';
import 'package:gigya_native_screensets_engine/widgets/material/social.dart';
import 'package:test/test.dart';

void main() {
  group('Social: ', () {
    test(
      'Determine providers - default',
      () async {

        var defaultProviders = [NssSocialProvider.facebook, NssSocialProvider.google];
        BindingModel bindings = BindingModel();

        var providers = SocialEvaluator().determineProviders(defaultProviders, bindings);

        expect(providers.length, 2);
      },
    );

    test(
      'Determine providers - from binding',
          () async {

        var defaultProviders = [NssSocialProvider.facebook, NssSocialProvider.google];
        BindingModel bindings = BindingModel();

        var conflictingAccount = {
          'loginProviders': [
            'facebook', 'line'
          ]
        };

        bindings.savedBindingData['conflictingAccount'] = conflictingAccount;

        var providers = SocialEvaluator().determineProviders(defaultProviders, bindings);

        expect(providers.length, 2);
        expect(providers[1], NssSocialProvider.line);
      },
    );
  });
}
