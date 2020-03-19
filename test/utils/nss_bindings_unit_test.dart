import 'package:gigya_native_screensets_engine/blocs/nss_binding_bloc.dart';
import 'package:test/test.dart';

void main() {
  BindingModel bindUtils = BindingModel();
  bindUtils.bindingData = {
    'UID': '123',
    'profile': {
      'firstName': 'sagi',
      'lastName': 'shmuel',
      'details': {'address': 'test'},
      'array': [
        '1stItem',
        '2ndItem',
        '3rdItem',
        {
          'props': 'fuck',
          'array': [
            'test',
            {
              'props': {
                'more': ['test', 'fuckagain']
              }
            }
          ]
        }
      ]
    }
  };

  group('parse value from key', () {
    test('get 1st value', () {
      String value = bindUtils.getValue('UID');

      expect(value, '123');
    });

    test('get 2nd value', () {
      String value = bindUtils.getValue('profile.firstName');

      expect(value, 'sagi');
    });

    test('get 3rd value', () {
      String value = bindUtils.getValue('profile.details.address');

      expect(value, 'test');
    });

    test('get array 1st value', () {
      String value = bindUtils.getValue('profile.array[0]');

      expect(value, '1stItem');
    });

    test('get array 2nd value', () {
      String value = bindUtils.getValue('profile.array[1]');

      expect(value, '2ndItem');
    });

    test('get array 3rd value', () {
      String value = bindUtils.getValue('profile.array[2]');

      expect(value, '3rdItem');
    });

    test('get array with object value', () {
      String value = bindUtils.getValue('profile.array[3].array[1].props.more[1]');

      expect(value, 'fuckagain');
    });

    test('long get array with object value', () {
      String value = bindUtils.getValue('profile.array[3].props');

      expect(value, 'fuck');
    });

    test('item not found in array', () {
      String value = bindUtils.getValue('profile.array[15]');

      expect(value, 'key not found');
    });

    test('test limits', () {
      String value = bindUtils.getValue('profile.details.address.a.b.d.c.e.f.g.j');

      expect(value, 'key not found');
    });

    test('test item not found', () {
      String value = bindUtils.getValue('xxx.xxx.dsds.fs');

      expect(value, 'key not found');
    });

    test('test change 1st value', () {
      bindUtils.save('UID', 'changeUidTest');

      String value = bindUtils.getValue('UID');

      expect(value, 'changeUidTest');
    });

    test('test change 2nd value', () {
      bindUtils.save('profile.firstName', 'changeNameTest');

      String value = bindUtils.getValue('profile.firstName');

      expect(value, 'changeNameTest');
    });

    test('test change 3rd value', () {
      bindUtils.save('profile.details.address', 'tel aviv');

      String value = bindUtils.getValue('profile.details.address');

      expect(value, 'tel aviv');
    });

    test('test add new value', () {
      bindUtils.bindingData = {};

      bindUtils.save('profile.firstName', 'sagi');

      String value = bindUtils.getValue('profile.firstName');

      expect(value, 'sagi');
    });
  });
}
