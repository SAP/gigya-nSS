import 'package:gigya_native_screensets_engine/nss_ignition.dart';
import 'package:test/test.dart';

void main() {
  group('IgnitionWorker unit tests', () {
    var worker = IgnitionWorker();

    test('IgnitionWorker with using mock from assets file', () async {
      registry.isMock = true;

      var spark = await worker.spark();

      expect(spark.platformAware, false);
      expect(spark.markup.screens['register'].id, 'register');
    });

    test('IgnitionWorker with mocking method channel response', () async {
      registry.isMock = false;

      registry.channels.mainChannel.setMockMethodCallHandler((call) {
        print(call.method);
        return Future<Map<dynamic, dynamic>>.value({
          'platformAware': true,
          'markup': {
            'initialRoute': 'login',
            'screens': {
              'login': {
                'id': 'login',
                'appbar': {'textKey': 'login'}
              }
            }
          }
        });
      });

      var spark = await worker.spark();
      expect(spark.platformAware, true);
      expect(spark.markup.initialRoute, 'login');
      expect(spark.markup.screens['login'].id, 'login');
    });
  });
}
