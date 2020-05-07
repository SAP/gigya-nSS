import 'package:gigya_native_screensets_engine/providers/binding_provider.dart';
import 'package:test/test.dart';

void main() {
  BindingModel bindUtils = BindingModel();

  group('BindingModel: empty ', () {
    bindUtils.updateWith({});

    test('save new value', () {});
  });

  group('BindingModel: with preset ', () {
    bindUtils.updateWith({
      'UID': '123',
      'Xbool': true,
      'profile': {
        'testBool': false,
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
    });


    test('get bool value', () {
      bool value = bindUtils.getValue('Xbool');

      expect(value, true);
    });

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

      expect(value, '');
    });

    test('test limits', () {
      String value = bindUtils.getValue('profile.details.address.a.b.d.c.e.f.g.j');

      expect(value, '');
    });

    test('test item not found', () {
      String value = bindUtils.getValue('profile.xxx');

      expect(value, '');
    });

    test('test item not found 2', () {
      String value = bindUtils.getValue('sx.xxx');

      expect(value, '');
    });

    test('test item not found 3', () {
      String value = bindUtils.getValue('profile.details.csd');

      expect(value, '');
    });

    test('test change 1st value', () {
      bindUtils.save('UID', 'changeUidTest');

      String value = bindUtils.getSavedValue('UID');

      expect(value, 'changeUidTest');
    });

    test('test change 2nd value', () {
      bindUtils.save('profile.firstName', 'changeNameTest');

      String value = bindUtils.getSavedValue('profile.firstName');

      expect(value, 'changeNameTest');
    });

    test('test change 3rd value', () {
      bindUtils.save('profile.details.address', 'tel aviv');

      String value = bindUtils.getSavedValue('profile.details.address');

      expect(value, 'tel aviv');
    });

    test('test update (bool)', () {

      bindUtils.save('profile.testBool', true);

      bool value = bindUtils.getSavedValue<bool>('profile.testBool');

      expect(value, true);
    });

    test('test value no found (Bool)', () {
      bindUtils.updateWith({});

      bool value = bindUtils.getValue<bool>('checkBool');

      expect(value, false);
    });


    test('test add new value (Bool)', () {
      bindUtils.updateWith({});

      bindUtils.save('checkBool', true);

      bool value = bindUtils.getSavedValue('checkBool');

      expect(value, true);
    });

    test('test value no found (Bool)', () {
      bindUtils.updateWith({});

      bool value = bindUtils.getValue<bool>('checkBool');

      expect(value, false);
    });

    test('types supported', () {

      String value = bindUtils.typeSupported[String];

      expect(value, '');
    });


  });
}