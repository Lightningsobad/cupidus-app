import 'dart:io';

import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/features/context_notebook/domain/checkin_capture_content.dart';
import 'package:cupid_mobile/features/context_notebook/domain/checkin_origin_resolver.dart';
import 'package:cupid_mobile/features/context_notebook/domain/context_notebook_models.dart';
import 'package:flutter_test/flutter_test.dart';

/// The shipped package, read off disk: the two origin lines are content, so a
/// test that hard-coded them would pass while the user saw something else
/// (AC-14).
final CheckinCaptureCopySet _copy = CheckinCaptureCopySet(
  ContentPackage.parse<CheckinCaptureCopy>(
    File(checkinCaptureAssetKey).readAsStringSync(),
    expectedSchemaId: checkinCaptureSchemaId,
    itemParser: checkinCaptureCopyFromJson,
    source: checkinCaptureAssetKey,
  ),
);

final String _withCardTemplate = _copy.text(notebookOriginWithCardId);
final String _fallback = _copy.text(notebookOriginFallbackId);

NotebookEntry _entry({
  required String id,
  String? originCheckInRef,
  String? originCardId,
  String? originCardTitle,
}) {
  final DateTime at = DateTime.utc(2026, 9, 27);
  return NotebookEntry(
    id: id,
    ownerKey: 'user-1',
    kind: NotebookKind.interest,
    value: 'giá trị $id',
    source: originCheckInRef == null
        ? ContextEntrySource.manual
        : ContextEntrySource.askOnTheSpot,
    originCheckInRef: originCheckInRef,
    originCardId: originCardId,
    originCardTitle: originCardTitle,
    createdAt: at,
    updatedAt: at,
  );
}

void main() {
  group('nhãn xuất xứ theo lô (AC-4, AC-9, BR-6, BR-11)', () {
    test('thẻ còn dò được thì nhãn mang ảnh chụp tên thẻ', () async {
      final CheckinOriginResolver resolver = CheckinOriginResolver(
        copy: _copy,
        probe: (Set<String> ids) async => ids,
      );

      final Map<String, String> labels = await resolver.labelsFor(
        <NotebookEntry>[
          _entry(
            id: 'e1',
            originCheckInRef: 'checkin-1',
            originCardId: 'card-1',
            originCardTitle: 'Đi cà phê tối',
          ),
        ],
      );

      expect(
        labels['e1'],
        _withCardTemplate.replaceAll(
          '{$checkinCaptureCardParam}',
          'Đi cà phê tối',
        ),
      );
      expect(labels['e1'], contains('Đi cà phê tối'));
    });

    test('ảnh chụp tên thẻ null thì suy biến, dù thẻ còn đó', () async {
      final CheckinOriginResolver resolver = CheckinOriginResolver(
        copy: _copy,
        probe: (Set<String> ids) async => ids,
      );

      final Map<String, String> labels = await resolver.labelsFor(
        <NotebookEntry>[
          _entry(
            id: 'e1',
            originCheckInRef: 'checkin-1',
            originCardId: 'card-1',
          ),
        ],
      );

      expect(labels['e1'], _fallback);
    });

    test('thẻ không còn dò được thì suy biến dù còn ảnh chụp tên', () async {
      final CheckinOriginResolver resolver = CheckinOriginResolver(
        copy: _copy,
        probe: (Set<String> ids) async => const <String>{},
      );

      final Map<String, String> labels = await resolver.labelsFor(
        <NotebookEntry>[
          _entry(
            id: 'e1',
            originCheckInRef: 'checkin-1',
            originCardId: 'card-1',
            originCardTitle: 'Đi cà phê tối',
          ),
        ],
      );

      expect(labels['e1'], _fallback);
      expect(labels['e1'], isNot(contains('Đi cà phê tối')));
    });

    test('phép dò ném lỗi thì suy biến, không bao giờ ném lên UI', () async {
      final CheckinOriginResolver resolver = CheckinOriginResolver(
        copy: _copy,
        probe: (Set<String> ids) async => throw StateError('card store down'),
      );

      final Map<String, String> labels = await resolver.labelsFor(
        <NotebookEntry>[
          _entry(
            id: 'e1',
            originCheckInRef: 'checkin-1',
            originCardId: 'card-1',
            originCardTitle: 'Đi cà phê tối',
          ),
        ],
      );

      expect(labels['e1'], _fallback);
    });

    test('mục tự thêm không có nhãn nào (BR-11)', () async {
      final CheckinOriginResolver resolver = CheckinOriginResolver(
        copy: _copy,
        probe: (Set<String> ids) async => ids,
      );

      final Map<String, String> labels = await resolver.labelsFor(
        <NotebookEntry>[_entry(id: 'manual-1')],
      );

      expect(labels, isEmpty);
    });

    test('phép dò chạy đúng một lượt với tập id phân biệt', () async {
      int calls = 0;
      final List<Set<String>> seen = <Set<String>>[];
      final CheckinOriginResolver resolver = CheckinOriginResolver(
        copy: _copy,
        probe: (Set<String> ids) async {
          calls += 1;
          seen.add(ids);
          return ids;
        },
      );

      await resolver.labelsFor(<NotebookEntry>[
        _entry(
          id: 'e1',
          originCheckInRef: 'checkin-1',
          originCardId: 'card-1',
          originCardTitle: 'Buổi hẹn A',
        ),
        _entry(
          id: 'e2',
          originCheckInRef: 'checkin-2',
          originCardId: 'card-1',
          originCardTitle: 'Buổi hẹn A',
        ),
        _entry(
          id: 'e3',
          originCheckInRef: 'checkin-3',
          originCardId: 'card-2',
          originCardTitle: 'Buổi hẹn B',
        ),
        _entry(id: 'manual-1'),
      ]);

      expect(calls, 1);
      expect(seen.single, <String>{'card-1', 'card-2'});
    });

    test('không mục nào từ check-in thì không dò lần nào', () async {
      int calls = 0;
      final CheckinOriginResolver resolver = CheckinOriginResolver(
        copy: _copy,
        probe: (Set<String> ids) async {
          calls += 1;
          return ids;
        },
      );

      final Map<String, String> labels = await resolver.labelsFor(
        <NotebookEntry>[_entry(id: 'manual-1'), _entry(id: 'manual-2')],
      );

      expect(calls, 0);
      expect(labels, isEmpty);
    });

    test('mục từ check-in không có id thẻ vẫn ra nhãn suy biến', () async {
      final CheckinOriginResolver resolver = CheckinOriginResolver(
        copy: _copy,
        probe: (Set<String> ids) async => ids,
      );

      final Map<String, String> labels = await resolver.labelsFor(
        <NotebookEntry>[_entry(id: 'e1', originCheckInRef: 'checkin-1')],
      );

      expect(labels['e1'], _fallback);
    });
  });

  group('nhãn xuất xứ không rò sang widget/thông báo (AC-13, BR-7)', () {
    // The two STORY-012 surfaces that render outside the app. Their own tests
    // live in that story's scope, so the assertion this story owes is made
    // here, against their source.
    const List<String> surfaceFiles = <String>[
      'lib/features/phase_status/data/home_widget_bridge.dart',
      'lib/features/phase_status/data/local_notification_scheduler.dart',
    ];

    test('neither surface can reach an entry value or an origin column', () {
      final Map<String, List<String>> offenders = <String, List<String>>{};
      for (final String path in surfaceFiles) {
        final File file = File(path);
        expect(
          file.existsSync(),
          isTrue,
          reason: '$path moved; this guard would silently scan nothing',
        );
        final String source = file.readAsStringSync();
        final List<String> hits = <String>[
          for (final String token in <String>[
            'NotebookEntry',
            'ContextNotebookReader',
            'context_notebook',
            'originCheckInRef',
            'originCardId',
            'originCardTitle',
            'originLabel',
            'CheckinOriginResolver',
            notebookOriginWithCardId,
            notebookOriginFallbackId,
          ])
            if (source.contains(token)) token,
        ];
        if (hits.isNotEmpty) {
          offenders[path] = hits;
        }
      }

      expect(
        offenders,
        isEmpty,
        reason: 'the widget and the notification carry phase state only; an '
            'entry value or its origin there would leak the notebook outside '
            'the app: $offenders',
      );
    });

    test('the origin wording ships nowhere outside this feature', () {
      final Map<String, List<String>> offenders = <String, List<String>>{};
      for (final FileSystemEntity entity
          in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) {
          continue;
        }
        if (entity.path.startsWith('lib/features/context_notebook/')) {
          continue;
        }
        final String source = entity.readAsStringSync();
        final List<String> hits = <String>[
          for (final String token in <String>[
            notebookOriginWithCardId,
            notebookOriginFallbackId,
          ])
            if (source.contains(token)) token,
        ];
        if (hits.isNotEmpty) {
          offenders[entity.path] = hits;
        }
      }

      expect(
        offenders,
        isEmpty,
        reason: 'the origin label is resolved in one place only (KD-2): '
            '$offenders',
      );
    });
  });
}
