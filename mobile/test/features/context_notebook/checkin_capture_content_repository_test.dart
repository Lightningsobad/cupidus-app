import 'dart:convert';
import 'dart:io';

import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/features/context_notebook/data/checkin_capture_content_repository.dart';
import 'package:cupid_mobile/features/context_notebook/domain/checkin_capture_content.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeBundle extends CachingAssetBundle {
  _FakeBundle(this._sources);

  final Map<String, String> _sources;

  @override
  Future<ByteData> load(String key) async {
    final String? source = _sources[key];
    if (source == null) {
      throw StateError('asset "$key" is not in this bundle');
    }
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(source)));
  }
}

CheckinCaptureContentRepository _repositoryOver(String source) =>
    CheckinCaptureContentRepository(
      loader: ContentPackageLoader(
        bundle: _FakeBundle(<String, String>{checkinCaptureAssetKey: source}),
      ),
    );

void main() {
  late String shippedSource;

  setUpAll(() {
    shippedSource = File(checkinCaptureAssetKey).readAsStringSync();
  });

  test('the repository loads the shipped pack from the asset bundle', () async {
    final CheckinCaptureCopySet copy =
        await _repositoryOver(shippedSource).load();

    for (final String id in requiredCheckinCaptureCopyIds) {
      expect(copy.text(id), isNotEmpty, reason: id);
    }
  });

  test('a second load returns the cached set, not a second parse', () async {
    final CheckinCaptureContentRepository repository =
        _repositoryOver(shippedSource);

    expect(await repository.load(), same(await repository.load()));
  });

  test('the resolved origin label comes from the pack, not the caller',
      () async {
    final CheckinCaptureCopySet copy =
        await _repositoryOver(shippedSource).load();

    expect(copy.originLabel(cardTitle: 'Tối thứ Bảy'), contains('Tối thứ Bảy'));
    expect(copy.originLabel(cardTitle: 'Tối thứ Bảy'), isNot(contains('{')));
    expect(copy.originLabel(), copy.text(notebookOriginFallbackId));
  });

  test('a malformed asset fails loudly instead of degrading (R-15a)', () async {
    await expectLater(
      _repositoryOver('{"id":"x"}').load(),
      throwsA(isA<ContentPackageFormatException>()),
    );
  });

  test('a missing asset is not swallowed into an empty pack', () async {
    final CheckinCaptureContentRepository repository =
        CheckinCaptureContentRepository(
      loader: ContentPackageLoader(bundle: _FakeBundle(const <String, String>{})),
    );

    await expectLater(repository.load(), throwsA(isA<StateError>()));
  });
}
