import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards BUG-20260907-002: the iOS Xcode project must expose one scheme and a
/// Debug/Release/Profile build configuration triple per Android product
/// flavor, otherwise `flutter build ios` cannot resolve a scheme at all.
void main() {
  const String pbxprojPath = 'ios/Runner.xcodeproj/project.pbxproj';
  const String gradlePath = 'android/app/build.gradle.kts';
  const String schemeDir = 'ios/Runner.xcodeproj/xcshareddata/xcschemes';

  late Set<String> androidFlavors;
  late String pbxproj;

  setUpAll(() {
    final String gradle = File(gradlePath).readAsStringSync();
    final int start = gradle.indexOf('productFlavors');
    expect(start, isNot(-1), reason: '$gradlePath defines no productFlavors');
    final String block = gradle.substring(start);
    androidFlavors = RegExp(r'create\("([^"]+)"\)')
        .allMatches(block)
        .map((RegExpMatch m) => m.group(1)!)
        .toSet();
    pbxproj = File(pbxprojPath).readAsStringSync();
  });

  test('android declares at least one product flavor', () {
    expect(androidFlavors, isNotEmpty);
  });

  test('every android flavor has matching iOS build configurations', () {
    for (final String flavor in androidFlavors) {
      for (final String mode in <String>['Debug', 'Release', 'Profile']) {
        expect(
          pbxproj.contains('name = "$mode-$flavor";'),
          isTrue,
          reason: '$pbxprojPath is missing build configuration $mode-$flavor',
        );
      }
    }
  });

  test('every android flavor has a shared iOS scheme', () {
    for (final String flavor in androidFlavors) {
      expect(
        File('$schemeDir/$flavor.xcscheme').existsSync(),
        isTrue,
        reason: '$schemeDir/$flavor.xcscheme is missing',
      );
    }
  });
}
