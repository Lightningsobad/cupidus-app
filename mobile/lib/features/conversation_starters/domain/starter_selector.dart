import '../../../core/content/content_package.dart';
import '../../context_notebook/domain/context_notebook_models.dart';
import 'starter_content.dart';

/// One starter line as the reader will see it, with every token already
/// substituted. [text] is sendable as written (AC-1, BR-11).
class RenderedStarter {
  const RenderedStarter({
    required this.id,
    required this.text,
    required this.kind,
  });

  /// The package item's stable id (R-15a), never a list index.
  final String id;
  final String text;
  final StarterKind kind;
}

/// Deterministic ordering and paging over a starter package (AC-17, AC-27,
/// AC-28).
///
/// Pure over (package, notebook, today, page, perPage): it holds no cursor, no
/// "seen" set, and no exhaustion flag, so there is nothing here that could
/// surface a progress indicator or a dead end (AC-27).
class StarterSelector {
  const StarterSelector._();

  /// Returns at most [perPage] rendered lines, wrapping around the eligible
  /// pool forever.
  ///
  /// [today] is a civil `YYYY-MM-DD` date and is always injected: this file
  /// must not read a clock, or the same inputs would stop producing the same
  /// output across a midnight boundary (AC-17).
  static List<RenderedStarter> select({
    required ContentPackage<StarterItem> package,
    required List<NotebookEntry> notebook,
    required String today,
    required int page,
    required int perPage,
  }) {
    if (perPage <= 0) {
      return const <RenderedStarter>[];
    }

    final List<_Candidate> eligible = _eligible(
      package: package,
      notebook: notebook,
      today: today,
    );
    if (eligible.isEmpty) {
      return const <RenderedStarter>[];
    }

    // A pool smaller than the layout's slot count yields exactly the pool, not
    // a repeat and not a placeholder (AC-28).
    final int length = eligible.length;
    final int count = perPage < length ? perPage : length;
    final int start = (page * perPage) % length;

    return List<RenderedStarter>.unmodifiable(
      List<RenderedStarter>.generate(
        count,
        (int offset) => eligible[(start + offset) % length].rendered,
      ),
    );
  }

  /// Contextual items that found a notebook value first, then generic ones
  /// (AC-5); inside each group, the deterministic key decides.
  static List<_Candidate> _eligible({
    required ContentPackage<StarterItem> package,
    required List<NotebookEntry> notebook,
    required String today,
  }) {
    final List<_Candidate> contextual = <_Candidate>[];
    final List<_Candidate> generic = <_Candidate>[];

    for (final StarterItem item in package.items) {
      final int key = stableContentKey('$today|${item.id}');
      switch (item.kind) {
        case StarterKind.generic:
          generic.add(
            _Candidate(
              key: key,
              rendered: RenderedStarter(
                id: item.id,
                text: item.text,
                kind: item.kind,
              ),
            ),
          );
        case StarterKind.contextual:
          final String? value = _contextValue(
            item: item,
            notebook: notebook,
            key: key,
          );
          // No recorded value means the line would still carry its token, so
          // the item is not eligible at all rather than rendered half-filled.
          if (value == null) {
            continue;
          }
          contextual.add(
            _Candidate(
              key: key,
              rendered: RenderedStarter(
                id: item.id,
                text: item.text.replaceAll(starterValueToken, value),
                kind: item.kind,
              ),
            ),
          );
      }
    }

    contextual.sort(_byKeyThenId);
    generic.sort(_byKeyThenId);
    return <_Candidate>[...contextual, ...generic];
  }

  static String? _contextValue({
    required StarterItem item,
    required List<NotebookEntry> notebook,
    required int key,
  }) {
    final StarterContextSlot? slot = item.contextSlot;
    if (slot == null) {
      return null;
    }
    final List<NotebookEntry> matches = notebook
        .where(
          (NotebookEntry entry) =>
              entry.kind.wireValue == slot.wireValue && entry.value.isNotEmpty,
        )
        .toList(growable: false)
      ..sort((NotebookEntry a, NotebookEntry b) => a.id.compareTo(b.id));
    if (matches.isEmpty) {
      return null;
    }
    return matches[key % matches.length].value;
  }

  static int _byKeyThenId(_Candidate a, _Candidate b) {
    final int byKey = a.key.compareTo(b.key);
    return byKey != 0 ? byKey : a.rendered.id.compareTo(b.rendered.id);
  }
}

class _Candidate {
  const _Candidate({required this.key, required this.rendered});

  final int key;
  final RenderedStarter rendered;
}

/// FNV-1a over UTF-16 code units.
///
/// Deliberately not `String.hashCode`: that value is only promised to be
/// stable inside one process, and AC-17 asks for the same order across two
/// separate runs.
int stableContentKey(String value) {
  int hash = 0x811c9dc5;
  for (final int unit in value.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  return hash;
}
