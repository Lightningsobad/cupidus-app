import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/content/content_package.dart';
import '../../../activity_cards/domain/activity_card.dart';
import '../../../context_notebook/context_notebook_entry_point.dart';
import '../../domain/date_script_content.dart';
import '../../domain/date_script_renderer.dart';
import '../../domain/date_script_selector.dart';

/// Everything screen (9) draws.
///
/// All three paragraphs are rendered at once and carried together, which is
/// what makes switching parts a pure state change: the pack is not re-read, the
/// selector is not re-run, and the reader cannot land on a different script by
/// tapping "Trong" (AC-7).
class DateScriptState {
  const DateScriptState({
    required this.loading,
    required this.part,
    required this.paragraphs,
  });

  static const DateScriptState initial = DateScriptState(
    loading: true,
    part: DateScriptPart.before,
    paragraphs: <DateScriptPart, String>{},
  );

  final bool loading;
  final DateScriptPart part;
  final Map<DateScriptPart, String> paragraphs;

  /// The paragraph for the part being read. Empty is unreachable for a pack
  /// that passed the ship gate, because every part ships at least one
  /// unconditional sentence (AC-23/AC-34).
  String get paragraph => paragraphs[part] ?? '';

  DateScriptState withPart(DateScriptPart next) =>
      DateScriptState(loading: loading, part: next, paragraphs: paragraphs);
}

/// Screen (9)'s state holder: read the pack once, pick one script for this
/// card, and fill it from the card plus what the user wrote down.
///
/// Memory only. No database, no `SharedPreferences`, no script history — which
/// part was last read and which script this card got both die with the screen,
/// on purpose (AC-22, `architecture/contract-summary.md` §5).
class DateScriptCubit extends Cubit<DateScriptState> {
  DateScriptCubit({
    required ActivityCard card,
    ContentPackageLoader loader = const ContentPackageLoader(),
    ContextNotebookReader? notebook,
  }) : _card = card,
       _loader = loader,
       _notebook = notebook,
       super(DateScriptState.initial);

  final ActivityCard _card;
  final ContentPackageLoader _loader;
  final ContextNotebookReader? _notebook;

  ContentPackage<DateScriptPreset>? _pack;
  DateScriptPreset? _preset;

  Future<void> load() async {
    final ContentPackage<DateScriptPreset> pack =
        _pack ??= await _loader.load<DateScriptPreset>(
          dateScriptAssetKey,
          expectedSchemaId: dateScriptSchemaId,
          itemParser: dateScriptPresetFromJson,
        );
    final DateScriptPreset preset = _preset ??= selectPreset(pack, _card);
    final List<NotebookEntry> notebook = await (_notebook ??
            contextNotebookReader())
        .entries();
    if (isClosed) {
      return;
    }

    emit(
      DateScriptState(
        loading: false,
        part: state.part,
        paragraphs: renderScript(preset, bindVariables(_card, notebook)),
      ),
    );
  }

  /// Re-reads the notebook after the inline ask card records an answer, then
  /// re-renders in place. The cached pack and the cached preset are reused, so
  /// answering a question makes the same script less generic instead of handing
  /// the reader a different one (AC-24).
  Future<void> reload() => load();

  /// Pure state change: no load, no selector call, no re-render (AC-7).
  void showPart(DateScriptPart part) {
    if (part == state.part || isClosed) {
      return;
    }
    emit(state.withPart(part));
  }
}
