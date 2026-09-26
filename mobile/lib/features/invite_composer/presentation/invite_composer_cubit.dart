import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/content/content_package.dart';
import '../../activity_cards/domain/activity_card.dart';
import '../../activity_cards/domain/activity_card_repository.dart';
import '../domain/invite_payload.dart';
import '../domain/invite_payload_repository.dart';
import '../domain/invite_preset.dart';
import '../domain/invite_renderer.dart';
import '../domain/mad_libs.dart';
import '../domain/preset_catalogue.dart';

/// Hands one finished invite string to the OS.
///
/// Returns nothing on purpose. The Share Sheet's own result type is not part of
/// this signature and must not be reintroduced by a caller: once the OS takes
/// the text, this app learns nothing further about it (R-1b/AC-16/AC-19).
typedef ShareInviteText = Future<void> Function(String text);

enum InviteComposerStatus {
  loading,

  /// A usable pack is loaded and [InviteComposerState.preset] is non-null.
  ready,

  /// The pack could not be loaded or contains no preset. The sheet must not
  /// open in this state (`ux/uiux-spec.md` §1 — never an empty composer).
  unavailable,
}

/// Why a share tap did not finish. Never surfaced as a count or a history, only
/// as the current attempt's inline message.
enum InviteComposerFailure { saveFailed }

class InviteComposerState {
  const InviteComposerState({
    this.status = InviteComposerStatus.loading,
    this.presets = const <InvitePreset>[],
    this.packVersion = '',
    this.values,
    this.frameIndex = 0,
    this.editedTexts = const <String, String>{},
    this.exporting = false,
    this.exported = false,
    this.failure,
  });

  final InviteComposerStatus status;

  /// The pack's presets in pack order. Its length is data, never a constant:
  /// nothing in this feature may hard-code how many frames exist (R-15b).
  final List<InvitePreset> presets;
  final String packVersion;
  final MadLibsValues? values;

  /// Always already normalised into range by [InviteComposerCubit.selectFrame],
  /// so the UI never has to bound-check it.
  final int frameIndex;

  /// Manual overrides keyed by preset id (AC-7). Keyed rather than single so
  /// switching frames and coming back does not destroy typed text, while a
  /// frame the user never edited still shows the freshly rendered draft.
  final Map<String, String> editedTexts;

  /// A share is in flight. Guards AC-17's "exactly once" against a double tap.
  final bool exporting;

  /// At least one export finished. Drives nothing countable — the sheet uses it
  /// only to close itself.
  final bool exported;
  final InviteComposerFailure? failure;

  InvitePreset? get preset =>
      presets.isEmpty ? null : presets[frameIndex % presets.length];

  /// The rendered draft for the selected frame, ignoring any manual edit.
  String get renderedText {
    final InvitePreset? current = preset;
    final MadLibsValues? currentValues = values;
    if (current == null || currentValues == null) {
      return '';
    }
    return renderInvite(current, currentValues);
  }

  /// What the preview shows and what a share exports: the manual override when
  /// the user typed one, otherwise the rendered draft.
  String get text {
    final InvitePreset? current = preset;
    if (current == null) {
      return '';
    }
    return editedTexts[current.id] ?? renderedText;
  }

  String? get userEditedText {
    final InvitePreset? current = preset;
    return current == null ? null : editedTexts[current.id];
  }

  InviteComposerState copyWith({
    InviteComposerStatus? status,
    List<InvitePreset>? presets,
    String? packVersion,
    MadLibsValues? values,
    int? frameIndex,
    Map<String, String>? editedTexts,
    bool? exporting,
    bool? exported,
    InviteComposerFailure? failure,
    bool clearFailure = false,
  }) =>
      InviteComposerState(
        status: status ?? this.status,
        presets: presets ?? this.presets,
        packVersion: packVersion ?? this.packVersion,
        values: values ?? this.values,
        frameIndex: frameIndex ?? this.frameIndex,
        editedTexts: editedTexts ?? this.editedTexts,
        exporting: exporting ?? this.exporting,
        exported: exported ?? this.exported,
        failure: clearFailure ? null : (failure ?? this.failure),
      );
}

/// State for one invite composition (`ux/uiux-spec.md` §2).
///
/// [categoryId] is a hidden parameter supplied by the caller (§6): there is no
/// category picker anywhere in this feature, and this Cubit exposes no way to
/// change it after construction.
class InviteComposerCubit extends Cubit<InviteComposerState> {
  InviteComposerCubit({
    required ActivityCard card,
    required String categoryId,
    required PresetCatalogue catalogue,
    required InvitePayloadRepository payloads,
    required ActivityCardRepository cards,
    required ShareInviteText share,
  })  : _card = card,
        _invited = card.invited,
        _categoryId = categoryId,
        _catalogue = catalogue,
        _payloads = payloads,
        _cards = cards,
        _share = share,
        super(const InviteComposerState());

  final ActivityCard _card;

  /// Local mirror of the card's `invited` column, so a second share in the same
  /// sheet session does not rewrite a flag that is already true (AC-17: the
  /// column is set on first export, and this feature never toggles it back —
  /// STORY-001's detail-screen toggle stays the only other writer).
  bool _invited;
  final String _categoryId;
  final PresetCatalogue _catalogue;
  final InvitePayloadRepository _payloads;
  final ActivityCardRepository _cards;
  final ShareInviteText _share;

  Future<void> load() async {
    try {
      final ContentPackage<InvitePreset> package =
          await _catalogue.load(_categoryId);
      if (isClosed) {
        return;
      }
      if (package.items.isEmpty) {
        emit(state.copyWith(status: InviteComposerStatus.unavailable));
        return;
      }
      emit(
        state.copyWith(
          status: InviteComposerStatus.ready,
          presets: package.items,
          packVersion: package.version,
          values: MadLibsValues.fromCard(_card),
          frameIndex: 0,
        ),
      );
    } catch (_) {
      if (isClosed) {
        return;
      }
      emit(state.copyWith(status: InviteComposerStatus.unavailable));
    }
  }

  /// Selects a frame and re-renders the preview immediately — there is no
  /// separate "apply" step (AC-5, `ux/uiux-spec.md` §2.2).
  ///
  /// [index] wraps modulo the pack length, so walking past either end lands on
  /// another frame instead of an "hết khung" message or a dead end
  /// (AC-26/AC-27/R-15b). Negative indices wrap the same way.
  void selectFrame(int index) {
    final int length = state.presets.length;
    if (length == 0) {
      return;
    }
    final int normalised = index % length;
    emit(
      state.copyWith(
        frameIndex: normalised < 0 ? normalised + length : normalised,
        clearFailure: true,
      ),
    );
  }

  /// Records an inline edit of the preview for the selected frame (AC-7).
  ///
  /// Typing the rendered draft back verbatim clears the override, so an
  /// untouched frame keeps re-rendering from the pack rather than freezing a
  /// stale copy of it.
  void editText(String text) {
    final InvitePreset? preset = state.preset;
    if (preset == null) {
      return;
    }
    final Map<String, String> next = Map<String, String>.of(state.editedTexts);
    if (text == state.renderedText) {
      next.remove(preset.id);
    } else {
      next[preset.id] = text;
    }
    emit(state.copyWith(editedTexts: next, clearFailure: true));
  }

  /// Writes the payload, marks the card invited, then hands the text to the OS.
  ///
  /// Order matters and is not an optimisation: the payload is durable before
  /// the Share Sheet opens (AC-17), because the app is never told whether the
  /// user completed or cancelled the share and so has no later moment at which
  /// it could correctly write. A failed write therefore aborts the share
  /// instead of exporting something that was never recorded.
  Future<void> share() async {
    final InvitePreset? preset = state.preset;
    if (preset == null || state.exporting) {
      return;
    }
    final String text = state.text;
    if (text.trim().isEmpty) {
      return;
    }
    emit(state.copyWith(exporting: true, clearFailure: true));
    try {
      await _payloads.savePayload(
        cardId: _card.id,
        categoryId: _categoryId,
        presetId: preset.id,
        packVersion: state.packVersion,
        filledValues: filledValuesFrom(
          state.values ?? MadLibsValues.fromCard(_card),
        ),
        userEditedText: state.userEditedText,
      );
      if (!_invited) {
        await _cards.updateCardDetails(_card.id, _invitedEdit(_card));
        _invited = true;
      }
    } catch (_) {
      if (isClosed) {
        return;
      }
      emit(
        state.copyWith(
          exporting: false,
          failure: InviteComposerFailure.saveFailed,
        ),
      );
      return;
    }
    await _share(text);
    if (isClosed) {
      return;
    }
    emit(state.copyWith(exporting: false, exported: true));
  }
}

/// [ActivityCardEdit.from] with `invited` flipped on.
///
/// Spelled out field by field because [ActivityCardEdit] has no `copyWith` and
/// its writes are full-snapshot: a field omitted here would be written as
/// `null`, silently clearing a column the user filled in elsewhere.
ActivityCardEdit _invitedEdit(ActivityCard card) => ActivityCardEdit(
      title: card.title,
      activityType: card.activityType,
      scheduledOn: card.scheduledOn,
      priceVnd: card.priceVnd,
      distanceKm: card.distanceKm,
      needsBooking: card.needsBooking,
      indoorOutdoor: card.indoorOutdoor,
      note: card.note,
      sourceLink: card.sourceLink,
      durationMinutes: card.durationMinutes,
      timeOfDaySlot: card.timeOfDaySlot,
      noteKeywords: card.noteKeywords,
      linkSourceLabel: card.linkSourceLabel,
      linkSavedAt: card.linkSavedAt,
      location: card.location,
      invited: true,
      replyState: card.replyState,
    );
