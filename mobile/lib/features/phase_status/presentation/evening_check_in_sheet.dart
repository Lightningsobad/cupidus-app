import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/di/service_locator.dart';
import '../../activity_cards/domain/activity_card_repository.dart';
import '../../../design_system/theme/cupid_theme_context.dart';
import '../../../design_system/tokens/cupid_color_tokens.dart';
import '../../../design_system/tokens/cupid_platform_tokens.dart';
import '../../../design_system/tokens/cupid_spacing.dart';
import '../../../design_system/tokens/cupid_typography_tokens.dart';
import '../../../l10n/generated/app_l10n.dart';
import '../../journal/journal_entry_point.dart';
import '../data/local_notification_scheduler.dart';
import '../data/phase_content_repository.dart';
import '../domain/evening_check_in_scheduler.dart';
import '../domain/phase_content.dart';

/// The design shows the places a photo can go before one is picked, so the
/// sheet states its whole ask up front instead of hiding it behind a word.
const int _photoSlotCount = 3;

const Key eveningCheckInSheetKey = Key('evening_check_in_sheet');
const Key eveningCheckInAttachKey = Key('evening_check_in_attach');
const Key eveningCheckInFieldKey = Key('evening_check_in_field');
const Key eveningCheckInSaveKey = Key('evening_check_in_save');
const Key eveningCheckInLaterKey = Key('evening_check_in_later');
const Key eveningCheckInContextKey = Key('evening_check_in_context');
const Key eveningCheckInCardTitleKey = Key('evening_check_in_card_title');
const Key eveningCheckInReassuranceKey = Key('evening_check_in_reassurance');

/// Opaque provenance tag stored with the journal entry. The journal never
/// parses or renders it.
String eveningCheckInOriginRef(String cardId) =>
    'req016.evening_check_in.$cardId';

typedef EveningPhotoPicker = Future<List<String>> Function();

typedef EveningJournalRoute = Future<void> Function(
  BuildContext context, {
  required String? line,
  required List<String> photoPaths,
  required String originRef,
});

/// Where the 23h nudge lands (`ux/uiux-spec.md` §4).
///
/// Two steps and nothing else: attach a photo, and write one sentence. Neither
/// is required and neither locks the other, so a surface closed untouched is a
/// finished interaction, not an abandoned one — there is no score, no rating,
/// no question about the other person, and nothing anywhere afterwards that
/// says a thing is still owed (AC-16, AC-17, AC-19, BR-14).
///
/// D-6: this is a full screen, not the low bottom sheet `ux/uiux-spec.md` §78
/// still calls a "sheet nhỏ". AC-16/AC-18 are satisfied by either shape — both
/// steps stay optional and the sentence field is never locked — so the design
/// canvas (`23h-vua-ve-j8`) decides, per the REQ-016 design-anchor precedent.
/// The class name is kept: it is the name the notification route, the tests
/// and the AC text all already use.
///
/// It writes nothing itself. Saving hands the sentence and the photos to
/// [openJournalComposer], the journal's one-way entry point, which is the only
/// composer in the app.
class EveningCheckInSheet extends StatefulWidget {
  const EveningCheckInSheet({
    super.key,
    required this.title,
    required this.body,
    required this.cardId,
    this.cardTitle,
    this.pickPhotos,
    this.openJournal,
  });

  /// Title and body of the `evening_check_in` item of `nudges.v1.json`, so the
  /// sheet repeats the question the notification asked instead of inventing a
  /// second wording of it.
  final String? title;
  final String body;

  final String cardId;

  /// The title of the card this evening was about (D-8), so the screen says
  /// which evening it is asking about instead of leaving the user to guess.
  /// User data, not copy — `null` when the card can no longer be read, and the
  /// context block then simply carries no name.
  final String? cardTitle;

  final EveningPhotoPicker? pickPhotos;
  final EveningJournalRoute? openJournal;

  static Future<void> show(
    BuildContext context, {
    String? title,
    required String body,
    required String cardId,
    String? cardTitle,
    EveningPhotoPicker? pickPhotos,
    EveningJournalRoute? openJournal,
  }) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (BuildContext _) => EveningCheckInSheet(
          title: title,
          body: body,
          cardId: cardId,
          cardTitle: cardTitle,
          pickPhotos: pickPhotos,
          openJournal: openJournal,
        ),
      ),
    );
  }

  @override
  State<EveningCheckInSheet> createState() => _EveningCheckInSheetState();
}

class _EveningCheckInSheetState extends State<EveningCheckInSheet> {
  final TextEditingController _line = TextEditingController();
  List<String> _photos = const <String>[];
  bool _busy = false;

  @override
  void dispose() {
    _line.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;

    return Scaffold(
      backgroundColor: colors.colorBackground,
      body: SafeArea(
        child: Padding(
          key: eveningCheckInSheetKey,
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(CupidSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (widget.title != null) ...<Widget>[
                        Text(
                          widget.title!,
                          style: type.display.copyWith(
                            fontSize: 28,
                            color: colors.colorText,
                          ),
                        ),
                        const SizedBox(height: CupidSpacing.sm),
                      ],
                      Text(
                        widget.body,
                        style: type.body.copyWith(color: colors.colorTextMuted),
                      ),
                      const SizedBox(height: CupidSpacing.lg),
                      _Block(
                        key: eveningCheckInContextKey,
                        children: <Widget>[
                          Text(
                            l10n.evening_check_in_context_label,
                            style: type.caption.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: colors.colorTextMuted,
                            ),
                          ),
                          if (widget.cardTitle != null) ...<Widget>[
                            const SizedBox(height: CupidSpacing.xs),
                            Text(
                              widget.cardTitle!,
                              key: eveningCheckInCardTitleKey,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: type.cardTitle.copyWith(
                                fontSize: 19,
                                color: colors.colorText,
                              ),
                            ),
                          ],
                          const SizedBox(height: CupidSpacing.md),
                          Row(
                            children: <Widget>[
                              for (int slot = 0;
                                  slot < _photoSlotCount;
                                  slot++) ...<Widget>[
                                if (slot > 0)
                                  const SizedBox(width: CupidSpacing.sm),
                                Expanded(
                                  child: _PhotoSlot(
                                    key: slot == 0
                                        ? eveningCheckInAttachKey
                                        : Key('evening_check_in_slot_$slot'),
                                    path: slot < _photos.length
                                        ? _photos[slot]
                                        : null,
                                    onTap: _busy ? null : _attach,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: CupidSpacing.sm),
                          Text(
                            _photos.isEmpty
                                ? l10n.evening_check_in_attach
                                : l10n.evening_check_in_photos_attached(
                                    _photos.length,
                                  ),
                            style: type.body.copyWith(
                              color: colors.colorAccentPink,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: CupidSpacing.md),
                      _Block(
                        children: <Widget>[
                          Text(
                            l10n.evening_check_in_line_label,
                            style: type.body.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colors.colorText,
                            ),
                          ),
                          const SizedBox(height: CupidSpacing.sm),
                          TextField(
                            key: eveningCheckInFieldKey,
                            controller: _line,
                            enabled: !_busy,
                            minLines: 3,
                            maxLines: 5,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            style: type.body.copyWith(color: colors.colorText),
                            decoration: InputDecoration(
                              hintText: l10n.evening_check_in_line_hint,
                              hintStyle: type.body.copyWith(
                                color: colors.colorTextMuted,
                              ),
                              filled: true,
                              fillColor: colors.colorSurface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  platform.radiusSmall,
                                ),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: CupidSpacing.sm),
                          Row(
                            children: <Widget>[
                              _Chip(label: l10n.evening_check_in_journal_chip),
                              const SizedBox(width: CupidSpacing.sm),
                              _Chip(label: l10n.evening_check_in_private_chip),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  CupidSpacing.md,
                  0,
                  CupidSpacing.md,
                  CupidSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: colors.gradientHot,
                        borderRadius: BorderRadius.circular(
                          platform.radiusButton,
                        ),
                      ),
                      child: SizedBox(
                        height: platform.tapTarget,
                        child: FilledButton(
                          key: eveningCheckInSaveKey,
                          onPressed: _busy ? null : _save,
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            disabledBackgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: colors.colorOnAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                platform.radiusButton,
                              ),
                            ),
                          ),
                          child: Text(
                            l10n.evening_check_in_save,
                            style: type.body.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // AC-17: leaving is a finished ending, so it stays one tap
                    // away from where the user already is. The design canvas
                    // has no dismiss control of its own; on a full screen the
                    // system back gesture is not enough on its own.
                    TextButton(
                      key: eveningCheckInLaterKey,
                      onPressed: _busy ? null : () => Navigator.of(context).pop(),
                      child: Text(
                        l10n.evening_check_in_later,
                        style: type.body.copyWith(color: colors.colorTextMuted),
                      ),
                    ),
                    Text(
                      l10n.evening_check_in_reassurance,
                      key: eveningCheckInReassuranceKey,
                      textAlign: TextAlign.center,
                      style: type.caption.copyWith(
                        color: colors.colorTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _attach() async {
    final EveningPhotoPicker picker = widget.pickPhotos ?? _pickPhotos;
    setState(() => _busy = true);
    final List<String> picked = await picker();
    if (!mounted) {
      return;
    }
    setState(() {
      _photos = picked;
      _busy = false;
    });
  }

  Future<void> _save() async {
    final EveningJournalRoute route = widget.openJournal ?? _openJournal;
    final String trimmed = _line.text.trim();
    final NavigatorState navigator = Navigator.of(context);
    setState(() => _busy = true);
    await route(
      context,
      line: trimmed.isEmpty ? null : trimmed,
      photoPaths: _photos,
      originRef: eveningCheckInOriginRef(widget.cardId),
    );
    if (!mounted) {
      return;
    }
    navigator.pop();
  }
}

/// One of the two rounded surfaces the full screen is built from: the context
/// block that names the evening, and the block that holds the sentence field.
class _Block extends StatelessWidget {
  const _Block({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;

    return Container(
      padding: const EdgeInsets.all(CupidSpacing.md),
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platform.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

/// A statement about where a saved sentence goes and who can read it, not a
/// control: there is no other destination to switch to and no sharing path in
/// stage 1, so neither of these is tappable.
class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.colorSurfaceAlt,
        borderRadius: BorderRadius.circular(platform.radiusSmall),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: CupidSpacing.sm,
          vertical: CupidSpacing.xs,
        ),
        child: Text(
          label,
          style: type.caption.copyWith(color: colors.colorTextMuted),
        ),
      ),
    );
  }
}

/// One place a photo can sit. Empty it is an outlined square; filled it shows
/// the picked image, and falls back to a glyph when the path no longer reads,
/// so a deleted file cannot throw inside the sheet.
class _PhotoSlot extends StatelessWidget {
  const _PhotoSlot({super.key, required this.path, required this.onTap});

  final String? path;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final String? path = this.path;

    return AspectRatio(
      aspectRatio: 1,
      child: Material(
        color: colors.colorSurfaceAlt,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(platform.radiusSmall),
          side: BorderSide(color: colors.colorLine),
        ),
        child: InkWell(
          onTap: onTap,
          child: path == null
              ? Center(
                  child: Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 24,
                    color: colors.colorTextMuted,
                  ),
                )
              : Image.file(
                  File(path),
                  fit: BoxFit.cover,
                  errorBuilder: (
                    BuildContext context,
                    Object error,
                    StackTrace? stackTrace,
                  ) =>
                      Center(
                    child: Icon(
                      Icons.image_outlined,
                      size: 24,
                      color: colors.colorAccentPink,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

/// Production wiring, and the only place the reminder and its destination are
/// tied together: the notification carries the card id, the tap hands it back,
/// and this sheet is what opens.
///
/// `null` when the app shell has not registered a navigator key. There is then
/// nowhere for a tapped notification to land, so nothing is queued either —
/// a reminder with no destination is exactly what AC-16 forbids.
EveningCheckInScheduler? buildEveningCheckInScheduler({
  PhaseContentRepository? content,
  ActivityCardRepository? cards,
}) {
  if (!getIt.isRegistered<GlobalKey<NavigatorState>>()) {
    return null;
  }
  final GlobalKey<NavigatorState> navigatorKey =
      getIt<GlobalKey<NavigatorState>>();
  final PhaseContentRepository repository =
      content ?? PhaseContentRepository();

  return EveningCheckInScheduler(
    notifications: PluginLocalNotificationScheduler(
      onSelected: (String? payload) =>
          _openFromPayload(navigatorKey, repository, cards, payload),
    ),
    content: repository,
  );
}

Future<void> _openFromPayload(
  GlobalKey<NavigatorState> navigatorKey,
  PhaseContentRepository content,
  ActivityCardRepository? cards,
  String? cardId,
) async {
  if (cardId == null || cardId.isEmpty) {
    return;
  }
  final NudgeItem? nudge;
  try {
    nudge = eveningCheckInNudge(await content.catalogue());
  } catch (_) {
    return;
  }
  if (nudge == null) {
    return;
  }
  // D-8: the screen names the evening it is asking about. A card that no
  // longer reads leaves the name out rather than blocking the screen — the
  // question itself is still answerable without it.
  String? cardTitle;
  try {
    cardTitle = (await (cards ?? getIt<ActivityCardRepository>())
            .cardById(cardId))
        ?.title;
  } catch (_) {
    cardTitle = null;
  }
  final NavigatorState? navigator = navigatorKey.currentState;
  if (navigator == null || !navigator.mounted) {
    return;
  }
  await EveningCheckInSheet.show(
    navigator.context,
    title: nudge.title,
    body: nudge.body,
    cardId: cardId,
    cardTitle: cardTitle,
  );
}

Future<List<String>> _pickPhotos() async {
  final List<XFile> picked = await ImagePicker().pickMultiImage();
  return picked.map((XFile file) => file.path).toList(growable: false);
}

Future<void> _openJournal(
  BuildContext context, {
  required String? line,
  required List<String> photoPaths,
  required String originRef,
}) async {
  await openJournalComposer(
    context,
    seed: JournalComposerSeed(
      seedText: line,
      seedPhotoPaths: photoPaths,
      originRef: originRef,
    ),
  );
}
