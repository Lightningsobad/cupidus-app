import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/emojis/presentation/widgets/emoji_drawer.dart';

void main() {
  testWidgets('EmojiDrawer renders pack tabs and triggers onEmojiSelected on item tap', (
    WidgetTester tester,
  ) async {
    String? selectedEmoji;
    String? selectedPack;

    await tester.pumpWidget(
      MaterialApp(
        theme: buildCupidTheme(
          platform: CupidPlatform.material,
          brightness: Brightness.dark,
        ),
        home: Scaffold(
          body: EmojiDrawer(
            onEmojiSelected: (code, packId) {
              selectedEmoji = code;
              selectedPack = packId;
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify pack tabs and stickers are rendered
    expect(find.byType(EmojiStickerGraphic), findsWidgets);

    // Tap first emoji item
    final firstEmoji = find.byType(EmojiStickerGraphic).first;
    await tester.tap(firstEmoji);
    await tester.pumpAndSettle();

    expect(selectedEmoji, isNotNull);
    expect(selectedPack, 'mochi-cat');
  });
}
