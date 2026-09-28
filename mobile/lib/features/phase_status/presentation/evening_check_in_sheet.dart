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
import '../../context_notebook/context_notebook_entry_point.dart';
import '../../journal/journal_entry_point.dart';
import '../data/local_notification_scheduler.dart';
import '../data/phase_content_repository.dart';
import '../domain/evening_check_in_scheduler.dart';
import '../domain/phase_content.dart';
import 'widgets/checkin_capture_block.dart';

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

/// The notebook side of saving. Separate from [EveningJournalRoute] because the
/// two halves must be able to fail independently (BR-10).
typedef EveningCaptureWrite = Future<void> Function({
  required NotebookKind kind,
  required String value,
  required String originCheckInRef,
  String? cardId,
  String? cardTitle,
});

/// Where the typed line stood when the save button finished with it.
enum _CaptureOutcome {
  /// Nothing to write: no copy shipped, or the field was empty or blank (AC-2).
  nothingAsked,

  /// One notebook entry now exists for this check-in.
  written,

  /// Typed, but no group chosen. Deliberately not written and deliberately not
  /// guessed (AC-16, BR-4).
  kindMissing,

  /// The notebook write itself failed. The sentence and photos are unaffected.
  failed;

  /// Whether the block has nothing left to ask the user, which is what decides
  /// if the screen may close (KD-1).
  bool get settled =>
      this == _CaptureOutcome.nothingAsked || this == _CaptureOutcome.written;
}

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
    this.journalAvailable = true,
    this.capture,
    this.recordCapture,
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

  /// AC-18 build capability flag, not a test seam ([openJournal] is the test
  /// seam): production is always `true` today because [openJournalComposer] is
  /// an unconditional top-level function with no absent state to detect.
  final bool journalAvailable;

  /// Resolved REQ-017 copy. `null` means the build shipped no wording for the
  /// optional notebook ask, so the whole block is absent — the content decides
  /// this, never [recordCapture], which is only a test seam (STORY-012 §7).
  final CheckinCaptureCopySet? capture;

  final EveningCaptureWrite? recordCapture;

  static Future<void> show(
    BuildContext context, {
    String? title,
    required String body,
    required String cardId,
    String? cardTitle,
    EveningPhotoPicker? pickPhotos,
    EveningJournalRoute? openJournal,
    bool journalAvailable = true,
    CheckinCaptureCopySet? capture,
    EveningCaptureWrite? recordCapture,
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
          journalAvailable: journalAvailable,
          capture: capture,
          recordCapture: recordCapture,
        ),
      ),
    );
  }

  @override
  State<EveningCheckInSheet> createState() => _EveningCheckInSheetState();
}

class _EveningCheckInSheetState extends State<EveningCheckInSheet> {
  final TextEditingController _line = TextEditingController();

  /// Always starts empty and is never seeded from [_line] or anywhere else
  /// (AC-6, BR-3).
  final TextEditingController _captureLine = TextEditingController();

  List<String> _photos = const <String>[];
  bool _busy = false;
  NotebookKind? _captureKind;
  bool _captureKindMissing = false;
  bool _captureFailed = false;

  /// The journal is handed the sentence and photos once per screen. The screen
  /// now stays open in two states (AC-16, AC-12), so without this a second tap
  /// on save would compose a second entry out of the same evening.
  bool _journalHandedOff = false;

  @override
  void initState() {
    super.initState();
    _captureLine.addListener(_onCaptureLineChanged);
  }

  @override
  void dispose() {
    _line.dispose();
    _captureLine.removeListener(_onCaptureLineChanged);
    _captureLine.dispose();
    super.dispose();
  }

  /// Clearing the line clears what the block was asking about, so the screen
  /// goes back to the untouched case with no message left over (UX Phần A.4).
  void _onCaptureLineChanged() {
    if (_captureLine.text.trim().isNotEmpty) {
      return;
    }
    if (!_captureKindMissing && !_captureFailed) {
      return;
    }
    setState(() {
      _captureKindMissing = false;
      _captureFailed = false;
    });
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
                      if (widget.journalAvailable) ...<Widget>[
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
                      if (widget.capture != null)
                        CheckinCaptureBlock(
                          key: eveningCheckInCaptureKey,
                          copy: widget.capture!,
                          controller: _captureLine,
                          selectedKind: _captureKind,
                          enabled: !_busy,
                          kindMissing: _captureKindMissing,
                          saveFailed: _captureFailed,
                          onKindSelected: _selectCaptureKind,
                          onRetry: _retryCapture,
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

  /// The notebook write runs first and its result never reaches the journal call
  /// below, which is what keeps one half from taking the other down (BR-10,
  /// KD-1). Only the pop is conditional: the screen has to stay for a missing
  /// group or a failed write, because both are answered in place.
  Future<void> _save() async {
    final EveningJournalRoute route = widget.openJournal ?? _openJournal;
    final String trimmed = _line.text.trim();
    final NavigatorState navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _captureKindMissing = false;
      _captureFailed = false;
    });

    final _CaptureOutcome outcome = await _writeCapture();
    if (!mounted) {
      return;
    }
    setState(() {
      _captureKindMissing = outcome == _CaptureOutcome.kindMissing;
      _captureFailed = outcome == _CaptureOutcome.failed;
    });

    if (!_journalHandedOff) {
      _journalHandedOff = true;
      await route(
        context,
        line: trimmed.isEmpty ? null : trimmed,
        photoPaths: _photos,
        originRef: eveningCheckInOriginRef(widget.cardId),
      );
    }
    if (!mounted) {
      return;
    }
    setState(() => _busy = false);
    if (outcome.settled) {
      navigator.pop();
    }
  }

  /// Picking a group answers the message the save button left behind, so the
  /// line is written right then — a second tap on save is not required
  /// (UX Phần A.4).
  Future<void> _selectCaptureKind(NotebookKind kind) async {
    final bool answersOpenQuestion = _captureKindMissing;
    setState(() {
      _captureKind = kind;
      _captureKindMissing = false;
    });
    if (answersOpenQuestion) {
      await _resolveCaptureInPlace();
    }
  }

  Future<void> _retryCapture() => _resolveCaptureInPlace();

  /// Re-runs the notebook half alone. The photos and sentence are already with
  /// the journal and are not touched again; the same check-in reference keeps a
  /// retry from adding a second entry (AC-12, AC-8).
  Future<void> _resolveCaptureInPlace() async {
    final NavigatorState navigator = Navigator.of(context);
    setState(() => _busy = true);
    final _CaptureOutcome outcome = await _writeCapture();
    if (!mounted) {
      return;
    }
    setState(() {
      _busy = false;
      _captureKindMissing = outcome == _CaptureOutcome.kindMissing;
      _captureFailed = outcome == _CaptureOutcome.failed;
    });
    if (outcome.settled && _journalHandedOff) {
      navigator.pop();
    }
  }

  Future<_CaptureOutcome> _writeCapture() async {
    if (widget.capture == null) {
      return _CaptureOutcome.nothingAsked;
    }
    final String value = _captureLine.text.trim();
    if (value.isEmpty) {
      return _CaptureOutcome.nothingAsked;
    }
    final NotebookKind? kind = _captureKind;
    if (kind == null) {
      return _CaptureOutcome.kindMissing;
    }
    final EveningCaptureWrite write = widget.recordCapture ?? _recordCapture;
    try {
      await write(
        kind: kind,
        value: value,
        originCheckInRef: eveningCheckInOriginRef(widget.cardId),
        cardId: widget.cardId,
        cardTitle: widget.cardTitle,
      );
    } catch (_) {
      return _CaptureOutcome.failed;
    }
    return _CaptureOutcome.written;
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
  // A build whose copy package cannot be read simply has no optional notebook
  // ask on this screen; the photo and sentence steps are unaffected.
  CheckinCaptureCopySet? capture;
  try {
    capture = await loadCheckInCaptureCopy();
  } catch (_) {
    capture = null;
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
    capture: capture,
  );
}

/// Production wiring of the notebook half. The check-in screen hands down the
/// line, the group, and the card values it already holds; resolving the entry
/// and snapshotting the title stay behind the notebook's own write door (BR-6).
Future<void> _recordCapture({
  required NotebookKind kind,
  required String value,
  required String originCheckInRef,
  String? cardId,
  String? cardTitle,
}) {
  return recordCheckInCapture(
    kind: kind,
    value: value,
    originCheckInRef: originCheckInRef,
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
