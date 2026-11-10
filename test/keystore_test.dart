import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Check keystore SHA1', () async {
    final result = await Process.run('keytool', [
      '-list',
      '-v',
      '-keystore',
      'android/app/islami-release.keystore',
      '-storepass',
      '6B49AA433C072BD7CBB44E94D90435B9'
    ]);
    print('EXIT CODE: ${result.exitCode}');
    print('STDOUT:\n${result.stdout}');
    print('STDERR:\n${result.stderr}');
  });
}
