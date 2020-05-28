import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gigya_native_screensets_engine/models/screen.dart';
import 'package:gigya_native_screensets_engine/widgets/factory.dart';
import 'package:gigya_native_screensets_engine/widgets/router.dart';
import 'package:gigya_native_screensets_engine/models/appbar.dart' as nssAppbar;
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'nss_test_extensions.dart';

void main() {
  group('Router unit: ', () {
    // Mocking party.
    var config = MockConfig();
    var channels = MockChannels();
    mockLogging(config, channels);

    var factory = MockMaterialWidgetFactory();

    var markup = MockMarkup();
    var routing = MockRouting();
    when(markup.routing).thenReturn(routing);
    when(routing.defaultRouting).thenReturn({});

    var screen = MockScreen();
    var channel = MockMethodChannel();

    // Test instance.
    var router = MaterialRouter(config, channels, factory);

    var nextRoute;

    test('getNextRoute: 1 level null input', () async {
      nextRoute = router.getNextRoute(null);
      expect(null, nextRoute);
    });

    test('getNextRoute: 1 level success', () async {
      nextRoute = router.getNextRoute('login');
      expect('login', nextRoute);
    });

    test('getNextRoute: 1 level failure', () async {
      nextRoute = router.getNextRoute('login/');
      expect(null, nextRoute);
    });

    test('getNextRoute: 2 level success', () async {
      when(config.markup).thenReturn(markup);
      when(markup.screens).thenReturn({'login': screen});
      when(screen.routes).thenReturn({'onSuccess': '_dismiss'});
      nextRoute = router.getNextRoute('login/onSuccess');
      expect('_dismiss', nextRoute);
    });

    test('getNextRoute: 2 level failure (empty default routing)', () async {
      when(config.markup).thenReturn(markup);
      when(markup.screens).thenReturn({'login': screen});
      when(routing.defaultRouting).thenReturn({});
      when(screen.routes).thenReturn({'onSuccess': '_dismiss'});
      nextRoute = router.getNextRoute('login/onSuccess');
      expect('_dismiss', nextRoute);
    });

    test('getNextRoute: 2 level success (backup default routing)', () async {
      when(config.markup).thenReturn(markup);
      when(markup.screens).thenReturn({'login': screen});
      when(routing.defaultRouting).thenReturn({'fail': '_dismiss'});
      when(screen.routes).thenReturn(null);
      nextRoute = router.getNextRoute('login/fail');
      expect('_dismiss', nextRoute);
    });

    test('getNextRoute: 2 level success (backup default routing)', () async {
      when(config.markup).thenReturn(markup);
      when(markup.screens).thenReturn({'login': screen});
      when(routing.defaultRouting).thenReturn({'fail': '_dismiss'});
      when(screen.routes).thenReturn({'onSuccess': '_dismiss'});
      nextRoute = router.getNextRoute('login/fail');
      expect('_dismiss', nextRoute);
    });

    test('generateRoute: nextRoute = null', () async {
      var settings = RouteSettings(
        arguments: null,
        name: null,
      );
      MaterialPageRoute route = router.generateRoute(settings);
      expect(route is MaterialPageRoute, true);
      expect(route.settings.name, null);
    });

    test('generateRoute: nextRoute = _dismiss, isMock = false', () async {
      var settings = RouteSettings(
        arguments: null,
        name: '_dismiss',
      );
      when(config.isMock).thenReturn(false);
      when(channels.screenChannel).thenReturn(channel);
      MaterialPageRoute route = router.generateRoute(settings);
      expect(route.settings.name, '_dismiss');
    });

    test('generateRoute: nextRoute = _dismiss, isMock = true', () async {
      var settings = RouteSettings(
        arguments: null,
        name: '_dismiss',
      );
      when(config.isMock).thenReturn(true);
      MaterialPageRoute route = router.generateRoute(settings);
      expect(route.settings.name, '_dismiss');
    });

    test('generateRoute: nextRoute = _dismiss, isMock = false', () async {
      var settings = RouteSettings(
        arguments: null,
        name: '_dismiss',
      );
      when(config.isMock).thenReturn(false);
      when(channels.screenChannel).thenReturn(channel);
      when(channel.invokeMethod('_dismiss')).thenThrow(MissingPluginException);
      expect(() => router.generateRoute(settings), throwsA(MissingPluginException));
    });

    test('nextScreen: ', () async {
      // Creating fake Screen instance.
      var fakeScreen = Screen(null, 'flow', NssStack.vertical, [], appBar: nssAppbar.AppBar(''), routes: {});
      when(config.markup).thenReturn(markup);
      when(markup.screens).thenReturn({'login': fakeScreen});
      var nextRoute = 'login';
      var sc = router.nextScreen(nextRoute);
      expect(sc.id, 'login');
    });
  });
}
