import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gigya_native_screensets_engine/models/screen.dart';
import 'package:gigya_native_screensets_engine/nss_factory.dart';
import 'package:gigya_native_screensets_engine/nss_router.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'nss_test_extensions.dart';

void main() {
  group('Router unit: ', () {
    // Mocking party.
    var config = MockConfig();
    var channels = MockNssChannels();
    var factory = MockWidgetFactory();
    var main = MockMain();
    var screen = MockScreen();
    var channel = MockMethodChannel();

    // Test instance.
    var router = Router(
      config: config,
      channels: channels,
      widgetFactory: factory,
    );

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
      when(config.main).thenReturn(main);
      when(main.screens).thenReturn({'login': screen});
      when(screen.routing).thenReturn({'success': 'dismiss'});
      nextRoute = router.getNextRoute('login/success');
      expect('dismiss', nextRoute);
    });

    test('getNextRoute: 2 level failure (empty default routing)', () async {
      when(config.main).thenReturn(main);
      when(main.screens).thenReturn({'login': screen});
      when(main.defaultRouting).thenReturn({});
      when(screen.routing).thenReturn({'success': 'dismiss'});
      nextRoute = router.getNextRoute('login/successs');
      expect(null, nextRoute);
    });

    test('getNextRoute: 2 level success (backup default routing)', () async {
      when(config.main).thenReturn(main);
      when(main.screens).thenReturn({'login': screen});
      when(main.defaultRouting).thenReturn({'fail': 'dismiss'});
      when(screen.routing).thenReturn(null);
      nextRoute = router.getNextRoute('login/fail');
      expect('dismiss', nextRoute);
    });

    test('getNextRoute: 2 level success (backup default routing)', () async {
      when(config.main).thenReturn(main);
      when(main.screens).thenReturn({'login': screen});
      when(main.defaultRouting).thenReturn({'fail': 'dismiss'});
      when(screen.routing).thenReturn({'success': 'dismiss'});
      nextRoute = router.getNextRoute('login/fail');
      expect('dismiss', nextRoute);
    });

    test('generateRoute: nextRoute = null', () async {
      var settings = RouteSettings(
        arguments: null,
        isInitialRoute: false,
        name: null,
      );
      MaterialPageRoute route = router.generateRoute(settings);
      expect(route is MaterialPageRoute, true);
      expect(route.settings.name, null);
    });

    test('generateRoute: nextRoute = dismiss, isMock = false', () async {
      var settings = RouteSettings(
        arguments: null,
        isInitialRoute: false,
        name: 'dismiss',
      );
      when(config.isMock).thenReturn(false);
      when(channels.screenChannel).thenReturn(channel);
      MaterialPageRoute route = router.generateRoute(settings);
      expect(route.settings.name, 'dismiss');
    });

    test('generateRoute: nextRoute = dismiss, isMock = true', () async {
      var settings = RouteSettings(
        arguments: null,
        isInitialRoute: false,
        name: 'dismiss',
      );
      when(config.isMock).thenReturn(true);
      MaterialPageRoute route = router.generateRoute(settings);
      expect(route.settings.name, 'dismiss');
    });

    test('generateRoute: nextRoute = dismiss, isMock = false', () async {
      var settings = RouteSettings(
        arguments: null,
        isInitialRoute: false,
        name: 'dismiss',
      );
      when(config.isMock).thenReturn(false);
      when(channels.screenChannel).thenReturn(channel);
      when(channel.invokeMethod('dismiss')).thenThrow(MissingPluginException);
      expect(() => router.generateRoute(settings), throwsA(MissingPluginException));
    });

    test('nextScreen: ', () async {
      // Creating fake Screen instance.
      var fakeScreen = Screen(null, 'flow', NssStack.vertical, [], appBar: {}, routing: {});
      when(config.main).thenReturn(main);
      when(main.screens).thenReturn({'login': fakeScreen});
      var nextRoute = 'login';
      var sc = router.nextScreen(nextRoute);
      expect(sc.id, 'login');
    });
  });
}
