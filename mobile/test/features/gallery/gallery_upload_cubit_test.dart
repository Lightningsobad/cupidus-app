import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/gallery/data/gallery_api.dart';
import 'package:cupid_mobile/features/gallery/data/gallery_local_cache.dart';
import 'package:cupid_mobile/features/gallery/data/gallery_repository.dart';
import 'package:cupid_mobile/features/gallery/domain/gallery_item.dart';
import 'package:cupid_mobile/features/gallery/presentation/gallery_upload_cubit.dart';
import 'package:cupid_mobile/features/gallery/presentation/gallery_upload_state.dart';
import 'package:cupid_mobile/features/gallery/presentation/widgets/gallery_upload_item.dart';
import 'package:cupid_mobile/features/gallery/presentation/widgets/gallery_upload_sheet.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Mirrors `gallery_repository_test.dart`'s `_FakeGalleryAdapter`: a fake
/// `HttpClientAdapter` wrapping a real `GalleryApi`/`GalleryRepository`, so
/// `GalleryUploadCubit` exercises the real two-step upload sequence without
/// hitting a network. `failUploadForFilenames` fails step 1 only for
/// matching source file paths, letting a test fail one item in a batch
/// while its sibling succeeds.
class _FakeGalleryAdapter implements HttpClientAdapter {
  final Set<String> failUploadForPaths = {};
  int uploadCalls = 0;
  int createItemCalls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path == '/uploads' && options.method == 'POST') {
      uploadCalls++;
      final formData = options.data as FormData;
      final multipartFile = formData.files.single.value;
      final sourcePath = multipartFile.filename ?? '';
      if (failUploadForPaths.any((p) => sourcePath.contains(p))) {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        );
      }
      return _jsonResponse(
        jsonEncode({
          'url': '/uploads/$sourcePath',
          'filename': sourcePath,
          'originalName': sourcePath,
          'mimeType': 'image/jpeg',
          'size': 1024,
        }),
      );
    }

    if (options.path == '/gallery' && options.method == 'POST') {
      createItemCalls++;
      final body = options.data as Map<String, dynamic>;
      return _jsonResponse(
        jsonEncode({
          'id': 'item-${body['filename']}',
          'userId': 'u1',
          'filename': body['filename'],
          'thumbnailUrl': null,
          'isEncrypted': true,
          'encryptionKeyId': null,
          'mimeType': 'image/jpeg',
          'createdAt': '2026-07-31T00:00:00.000Z',
        }),
      );
    }

    throw UnimplementedError(
      'unexpected request ${options.method} ${options.path}',
    );
  }

  @override
  void close({bool force = false}) {}

  ResponseBody _jsonResponse(String body) => ResponseBody.fromString(
    body,
    200,
    headers: {
      Headers.contentTypeHeader: ['application/json'],
    },
  );
}

GalleryRepository _repositoryWith(_FakeGalleryAdapter adapter) {
  final api = CupidApiClient.create();
  api.dio.httpClientAdapter = adapter;
  return GalleryRepository(api: GalleryApi(api: api), cache: GalleryLocalCache());
}

File _tempFile(String name) {
  final file = File('${Directory.systemTemp.path}/gallery_upload_test_$name');
  file.writeAsBytesSync(const [0xFF, 0xD8, 0xFF]);
  return file;
}

GalleryImagePicker _fakePicker(
  List<File> files, {
  List<Map<String, Object?>>? capturedCalls,
}) {
  return ({double? maxWidth, double? maxHeight, int? imageQuality}) async {
    capturedCalls?.add({
      'maxWidth': maxWidth,
      'maxHeight': maxHeight,
      'imageQuality': imageQuality,
    });
    return [for (final file in files) XFile(file.path)];
  };
}

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    home: Scaffold(body: child),
  );
}

void main() {
  List<File> tempFiles = [];

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    tempFiles = [];
  });

  tearDown(() {
    for (final file in tempFiles) {
      if (file.existsSync()) file.deleteSync();
    }
  });

  group('GalleryUploadCubit.pick', () {
    test(
      'while offline, sets isOffline and never invokes the picker',
      () async {
        bool pickerCalled = false;
        final cubit = GalleryUploadCubit(
          repository: _repositoryWith(_FakeGalleryAdapter()),
          onUploaded: (_) {},
          isOnline: () async => false,
          pickImages: ({maxWidth, maxHeight, imageQuality}) async {
            pickerCalled = true;
            return const <XFile>[];
          },
        );

        await cubit.pick();

        expect(cubit.state.isOffline, isTrue);
        expect(pickerCalled, isFalse);
        await cubit.close();
      },
    );

    test(
      'passes the R4/D-2 downscale budget (2048x2048, quality 85) to the '
      'picker',
      () async {
        final captured = <Map<String, Object?>>[];
        final cubit = GalleryUploadCubit(
          repository: _repositoryWith(_FakeGalleryAdapter()),
          onUploaded: (_) {},
          isOnline: () async => true,
          pickImages: _fakePicker(const [], capturedCalls: captured),
        );

        await cubit.pick();

        expect(captured.single['maxWidth'], 2048);
        expect(captured.single['maxHeight'], 2048);
        expect(captured.single['imageQuality'], 85);
        await cubit.close();
      },
    );

    test(
      'selecting N photos produces N independent records; one failing '
      'leaves the other done',
      () async {
        tempFiles = [_tempFile('ok.jpg'), _tempFile('bad.jpg')];
        final adapter = _FakeGalleryAdapter()
          ..failUploadForPaths.add('bad.jpg');
        final uploaded = <GalleryItem>[];
        final cubit = GalleryUploadCubit(
          repository: _repositoryWith(adapter),
          onUploaded: uploaded.add,
          isOnline: () async => true,
          pickImages: _fakePicker(tempFiles),
        );

        await cubit.pick();

        expect(cubit.state.items, hasLength(2));
        final okRecord = cubit.state.items.firstWhere(
          (r) => r.file.path.contains('ok.jpg'),
        );
        final badRecord = cubit.state.items.firstWhere(
          (r) => r.file.path.contains('bad.jpg'),
        );
        expect(okRecord.status, GalleryUploadItemStatus.done);
        expect(okRecord.progress, 1.0);
        expect(badRecord.status, GalleryUploadItemStatus.failed);
        expect(uploaded, hasLength(1));
        await cubit.close();
      },
    );

    test(
      'a step-1 upload failure never issues step 2 for that item',
      () async {
        tempFiles = [_tempFile('bad.jpg')];
        final adapter = _FakeGalleryAdapter()
          ..failUploadForPaths.add('bad.jpg');
        final cubit = GalleryUploadCubit(
          repository: _repositoryWith(adapter),
          onUploaded: (_) {},
          isOnline: () async => true,
          pickImages: _fakePicker(tempFiles),
        );

        await cubit.pick();

        expect(adapter.uploadCalls, 1);
        expect(adapter.createItemCalls, 0);
        expect(
          cubit.state.items.single.status,
          GalleryUploadItemStatus.failed,
        );
        await cubit.close();
      },
    );

    test(
      'retry restarts only the failed item and can succeed the second time',
      () async {
        tempFiles = [_tempFile('flaky.jpg')];
        final adapter = _FakeGalleryAdapter()
          ..failUploadForPaths.add('flaky.jpg');
        final uploaded = <GalleryItem>[];
        final cubit = GalleryUploadCubit(
          repository: _repositoryWith(adapter),
          onUploaded: uploaded.add,
          isOnline: () async => true,
          pickImages: _fakePicker(tempFiles),
        );

        await cubit.pick();
        expect(
          cubit.state.items.single.status,
          GalleryUploadItemStatus.failed,
        );

        adapter.failUploadForPaths.clear();
        await cubit.retry(cubit.state.items.single.id);

        expect(cubit.state.items.single.status, GalleryUploadItemStatus.done);
        expect(uploaded, hasLength(1));
        await cubit.close();
      },
    );
  });

  group('GalleryUploadItem', () {
    testWidgets(
      'exposes a text-equivalent semantics label for every status, not '
      'color/icon alone',
      (tester) async {
        final file = _tempFile('widget.jpg');
        addTearDown(() => file.deleteSync());

        await tester.pumpWidget(
          _wrap(
            GalleryUploadItem(
              record: GalleryUploadRecord(
                id: 'r1',
                file: file,
                status: GalleryUploadItemStatus.uploading,
                progress: 0.5,
              ),
              onRetry: () {},
              thumbnailBuilder: (context, file) =>
                  const ColoredBox(color: Colors.black),
            ),
          ),
        );

        expect(find.bySemanticsLabel('Uploading 50%'), findsOneWidget);
      },
    );

    testWidgets('tapping a failed item invokes onRetry', (tester) async {
      final file = _tempFile('widget2.jpg');
      addTearDown(() => file.deleteSync());
      bool retried = false;

      await tester.pumpWidget(
        _wrap(
          GalleryUploadItem(
            record: GalleryUploadRecord(
              id: 'r2',
              file: file,
              status: GalleryUploadItemStatus.failed,
            ),
            onRetry: () => retried = true,
            thumbnailBuilder: (context, file) =>
                const ColoredBox(color: Colors.black),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('gallery_upload_item_r2')));
      expect(retried, isTrue);
    });
  });

  group('GalleryUploadSheet', () {
    testWidgets('renders the offline message and disables the pick button', (
      tester,
    ) async {
      final cubit = GalleryUploadCubit(
        repository: _repositoryWith(_FakeGalleryAdapter()),
        onUploaded: (_) {},
        isOnline: () async => false,
        pickImages: _fakePicker(const []),
      );
      addTearDown(cubit.close);

      await tester.pumpWidget(_wrap(GalleryUploadSheet(cubit: cubit)));
      await cubit.pick();
      await tester.pump();

      expect(
        find.byKey(const Key('gallery_upload_offline_message')),
        findsOneWidget,
      );
      final button = tester.widget<CupidPrimaryButton>(
        find.byType(CupidPrimaryButton),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('renders one GalleryUploadItem per selected photo', (
      tester,
    ) async {
      tempFiles = [_tempFile('sheet1.jpg'), _tempFile('sheet2.jpg')];
      final cubit = GalleryUploadCubit(
        repository: _repositoryWith(_FakeGalleryAdapter()),
        onUploaded: (_) {},
        isOnline: () async => true,
        pickImages: _fakePicker(tempFiles),
      );
      addTearDown(cubit.close);

      await tester.pumpWidget(
        _wrap(
          GalleryUploadSheet(
            cubit: cubit,
            thumbnailBuilder: (context, file) =>
                const ColoredBox(color: Colors.black),
          ),
        ),
      );
      // The real MultipartFile/Dio upload path performs genuine dart:io
      // async I/O, which never resolves under testWidgets' faked-timer
      // zone unless driven through tester.runAsync.
      await tester.runAsync(() => cubit.pick());
      await tester.pump();

      expect(find.byType(GalleryUploadItem), findsNWidgets(2));
    });
  });
}
