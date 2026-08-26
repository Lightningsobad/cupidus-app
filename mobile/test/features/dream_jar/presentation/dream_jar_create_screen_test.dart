import 'dart:async';

import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/dream_jar/data/dream_jar.dart';
import 'package:cupid_mobile/features/dream_jar/data/dream_jar_repository.dart';
import 'package:cupid_mobile/features/dream_jar/presentation/screens/dream_jar_create_screen.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeDreamJarRepository extends DreamJarRepository {
  _FakeDreamJarRepository(this._createJar) : super(CupidApiClient.create());

  final Future<DreamJar> Function({
    required String name,
    required num targetAmount,
    DateTime? deadline,
  })
  _createJar;

  int createJarCallCount = 0;

  @override
  Future<DreamJar> createJar({
    required String name,
    required num targetAmount,
    DateTime? deadline,
  }) {
    createJarCallCount++;
    return _createJar(
      name: name,
      targetAmount: targetAmount,
      deadline: deadline,
    );
  }
}

Widget _harness(DreamJarRepository repository, {String? partnerDisplayName}) {
  return MaterialApp(
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    locale: const Locale('vi'),
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    home: DreamJarCreateScreen(
      repository: repository,
      partnerDisplayName: partnerDisplayName,
    ),
  );
}

void main() {
  testWidgets('renders all cards according to design canvas', (tester) async {
    final repository = _FakeDreamJarRepository(
      ({required name, required targetAmount, deadline}) =>
          Completer<DreamJar>().future,
    );

    await tester.pumpWidget(
      _harness(repository, partnerDisplayName: 'Linh'),
    );
    await tester.pump();

    // 1. Headline
    expect(find.text('Hai đứa để dành cho gì?'), findsOneWidget);
    expect(
      find.text('Cả hai phải cùng đồng ý trước khi hũ được mở'),
      findsOneWidget,
    );

    // 2. Card 1: Name the dream
    expect(find.text('ĐẶT TÊN CHO ƯỚC MƠ'), findsOneWidget);

    // 3. Card 2: Pick an icon
    expect(find.text('CHỌN BIỂU TƯỢNG'), findsOneWidget);

    // 4. Card 3: Target
    expect(find.text('MỤC TIÊU'), findsOneWidget);
    expect(find.text('−1tr'), findsOneWidget);
    expect(find.text('+1tr'), findsOneWidget);
    expect(find.text('+5tr'), findsOneWidget);

    // 5. Card 4: Deadline & Reminder
    expect(find.text('Hạn chót'), findsOneWidget);
    expect(find.text('Nhắc góp hằng tuần'), findsOneWidget);

    // 6. Card 5 & Button
    expect(find.text('Gửi cho Linh duyệt'), findsOneWidget);
  });

  testWidgets('shows validation error when submitting blank name', (
    tester,
  ) async {
    final repository = _FakeDreamJarRepository(
      ({required name, required targetAmount, deadline}) =>
          Completer<DreamJar>().future,
    );

    await tester.pumpWidget(
      _harness(repository, partnerDisplayName: 'Linh'),
    );
    await tester.pump();

    final Finder submitBtn = find.text('Gửi cho Linh duyệt');
    await tester.ensureVisible(submitBtn);
    await tester.tap(submitBtn);
    await tester.pump();

    expect(find.text('Vui lòng nhập tên'), findsOneWidget);
    expect(repository.createJarCallCount, 0);
  });

  testWidgets('bumps target amount when tapping bump buttons', (tester) async {
    final repository = _FakeDreamJarRepository(
      ({required name, required targetAmount, deadline}) =>
          Completer<DreamJar>().future,
    );

    await tester.pumpWidget(
      _harness(repository, partnerDisplayName: 'Linh'),
    );
    await tester.pump();

    expect(find.text('15.000.000₫'), findsOneWidget);

    await tester.tap(find.text('+5tr'));
    await tester.pump();

    expect(find.text('20.000.000₫'), findsOneWidget);

    await tester.tap(find.text('−1tr'));
    await tester.pump();

    expect(find.text('19.000.000₫'), findsOneWidget);
  });
}
