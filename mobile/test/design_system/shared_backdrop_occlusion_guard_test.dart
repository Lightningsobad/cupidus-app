import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Protects the single composition-root `--sky` wash: `CupidAppBackground` is
/// mounted exactly once, via `MaterialApp.builder` at `lib/app/cupid_app.dart`
/// line 59, above the `Navigator`, so it sits behind every route by
/// construction. `cupid_theme.dart:45` keeps `scaffoldBackgroundColor`
/// `Colors.transparent` so it shows through.
///
/// Why a guard exists at all: REQ-002 STORY-046 had to remove six separate
/// screens that each re-introduced an opaque root fill and silently occluded
/// that shared wash on their own route. Nothing in the codebase prevented a
/// seventh. The per-screen probe test next to this file pins only those six
/// screens; a screen written tomorrow is covered by nothing.
///
/// What it detects: every `Scaffold(`-bearing file under `lib/` is walked, and
/// for each `Scaffold(` call only its **root-level** (depth-1) arguments are
/// inspected — an opaque `backgroundColor:`, or a `body:` whose outermost
/// widget is a `DecoratedBox`/`ColoredBox`/`Container` carrying an un-faded
/// `color:`/`decoration:`/`gradient:`. Nested component colours (avatar fills,
/// chip fills, sheet surfaces) are deliberately invisible to it, and so are
/// alpha-modulated decorative glows, which composite over the wash instead of
/// replacing it (see [_alphaModulated]).
///
/// Known limit: a source scan cannot judge a computed colour, a conditional
/// branch, a partially-faded fill, or a full-bleed container buried deeper in a
/// screen's tree. That gap is covered at runtime by
/// `shared_backdrop_occlusion_test.dart`, which probes real rendered pixels for
/// a representative sample of composition patterns
/// (`architecture/solution.md` AD-4/AD-5).
const Map<String, String> _allowlist = <String, String>{
  'lib/features/auth/presentation/screens/splash_screen.dart':
      'Design-source-backed: `Cupid Screens.dc.html:1418` gives the splash '
          'block its own full-bleed linear-gradient over the root frame, so the '
          'design overrides `--sky` here on purpose. Ratified by OQ-1.',
  'lib/features/gallery/presentation/screens/gallery_viewer_screen.dart':
      'Product judgment, media legibility: the purple/magenta wash behind '
          'letterboxed photos degrades viewing and shifts perceived photo '
          'colour, so the hardcoded `dark()` fill keeps the letterbox neutral '
          'in both themes. Ratified by OQ-1.',
  'lib/features/auth/presentation/screens/welcome_screen.dart':
      'Design-source-backed: `Cupid Screens.dc.html:69` (the `isWelcome` '
          'block) specifies `linear-gradient(165deg,#7B2FBE 0%,#FF4B8C 58%,'
          '#FF3366 100%)` over the root frame, transcribed value-for-value as '
          '`colors.gradientBrandBackdrop` at `:147`. Ratified by OQ-3.',
};

/// The developer preview harness is not an app route, so it is outside AC2
/// (`architecture/solution.md` §3.3).
bool _isPreviewHarness(String path) =>
    path.startsWith('lib/preview/') || path == 'lib/main_preview.dart';

/// Root-level `body:` widgets that paint a full-bleed layer when they carry one
/// of [_paintingArguments].
const Set<String> _layerWidgets = <String>{
  'DecoratedBox',
  'ColoredBox',
  'Container',
};

const Set<String> _paintingArguments = <String>{
  'color',
  'decoration',
  'gradient',
};

/// Markers that a paint expression modulates alpha somewhere. A root layer that
/// fades its own colours is a screen-local decorative accent — the shared wash
/// still composites through it — rather than a base fill that replaces it
/// (`ux/uiux-spec.md` §4, §5 risk area 3). `vow_screen.dart` is the worked
/// example: its root `DecoratedBox` is a `.5 -> 0` alpha radial glow, and the
/// AC7 runtime probe in `shared_backdrop_occlusion_test.dart` proves the wash
/// reads through it.
///
/// A fill that fades only *some* of its stops would read as translucent here
/// and still occlude in practice. That is this guard's documented blind spot
/// (`architecture/solution.md` AD-4), and it is why the AD-5 runtime probes
/// exist alongside it.
final RegExp _alphaModulated = RegExp(
  r'withValues\s*\(\s*alpha\s*:|withOpacity\s*\(|withAlpha\s*\(|transparent',
);

/// A `Scaffold.backgroundColor` value that does not occlude the shared wash.
const Set<String> _transparentValues = <String>{'Colors.transparent', 'null'};

class _NamedArgument {
  const _NamedArgument({
    required this.name,
    required this.value,
    required this.valueStart,
    required this.line,
  });

  final String name;

  /// The value expression with comments stripped and whitespace collapsed.
  final String value;

  /// Offset of the value expression in the original source, so a nested widget
  /// call can be re-scanned in place and keep real line numbers.
  final int valueStart;

  final int line;
}

bool _isIdentifierStart(String c) =>
    (c.codeUnitAt(0) >= 0x41 && c.codeUnitAt(0) <= 0x5A) ||
    (c.codeUnitAt(0) >= 0x61 && c.codeUnitAt(0) <= 0x7A) ||
    c == '_' ||
    c == r'$';

bool _isIdentifierChar(String c) =>
    _isIdentifierStart(c) || (c.codeUnitAt(0) >= 0x30 && c.codeUnitAt(0) <= 0x39);

/// End offset of the comment starting at [i], or -1 when [i] is not a comment.
/// Block comments nest in Dart, so the depth is tracked rather than stopping at
/// the first `*/`.
int _commentEnd(String s, int i) {
  if (!s.startsWith('//', i) && !s.startsWith('/*', i)) {
    return -1;
  }
  if (s.startsWith('//', i)) {
    final int newline = s.indexOf('\n', i);
    return newline == -1 ? s.length : newline;
  }
  int depth = 0;
  int j = i;
  while (j < s.length) {
    if (s.startsWith('/*', j)) {
      depth++;
      j += 2;
    } else if (s.startsWith('*/', j)) {
      depth--;
      j += 2;
      if (depth == 0) {
        return j;
      }
    } else {
      j++;
    }
  }
  return s.length;
}

/// End offset of the string literal starting at [i], or -1 when [i] is not one.
/// Handles the raw prefix, triple quotes, escapes, and `${...}` interpolation
/// (whose braces would otherwise corrupt the caller's depth tracking).
int _stringEnd(String s, int i) {
  int cursor = i;
  bool raw = false;
  if (s[cursor] == 'r' &&
      cursor + 1 < s.length &&
      (s[cursor + 1] == "'" || s[cursor + 1] == '"')) {
    raw = true;
    cursor++;
  }
  if (cursor >= s.length) {
    return -1;
  }
  final String quote = s[cursor];
  if (quote != "'" && quote != '"') {
    return -1;
  }
  String delimiter = quote;
  if (cursor + 2 < s.length &&
      s[cursor + 1] == quote &&
      s[cursor + 2] == quote) {
    delimiter = quote * 3;
  }
  cursor += delimiter.length;

  while (cursor < s.length) {
    if (!raw && s[cursor] == r'\') {
      cursor += 2;
      continue;
    }
    if (!raw && s.startsWith(r'${', cursor)) {
      cursor += 2;
      int braces = 1;
      while (cursor < s.length && braces > 0) {
        final int nested = _stringEnd(s, cursor);
        if (nested > cursor) {
          cursor = nested;
          continue;
        }
        if (s[cursor] == '{') {
          braces++;
        } else if (s[cursor] == '}') {
          braces--;
        }
        cursor++;
      }
      continue;
    }
    if (s.startsWith(delimiter, cursor)) {
      return cursor + delimiter.length;
    }
    cursor++;
  }
  return s.length;
}

int _lineAt(String s, int offset) {
  int line = 1;
  for (int i = 0; i < offset; i++) {
    if (s[i] == '\n') {
      line++;
    }
  }
  return line;
}

int _skipTrivia(String s, int i) {
  int cursor = i;
  while (cursor < s.length) {
    if (s[cursor].trim().isEmpty) {
      cursor++;
      continue;
    }
    final int comment = _commentEnd(s, cursor);
    if (comment > cursor) {
      cursor = comment;
      continue;
    }
    break;
  }
  return cursor;
}

/// Reads the value expression starting at [start] up to the enclosing call's
/// depth-0 `,` or `)`. Returns the comment-stripped text and the terminator
/// offset.
(String, int) _readValue(String s, int start) {
  final StringBuffer buffer = StringBuffer();
  int depth = 0;
  int cursor = start;
  while (cursor < s.length) {
    final int comment = _commentEnd(s, cursor);
    if (comment > cursor) {
      cursor = comment;
      continue;
    }
    final int string = _stringEnd(s, cursor);
    if (string > cursor) {
      buffer.write(s.substring(cursor, string));
      cursor = string;
      continue;
    }
    final String c = s[cursor];
    if (depth == 0 && (c == ',' || c == ')')) {
      break;
    }
    if (c == '(' || c == '[' || c == '{') {
      depth++;
    } else if (c == ')' || c == ']' || c == '}') {
      depth--;
    }
    buffer.write(c);
    cursor++;
  }
  return (buffer.toString().replaceAll(RegExp(r'\s+'), ' ').trim(), cursor);
}

/// Named arguments at depth 1 of the call whose `(` sits at [openParen].
/// Anything deeper is another widget's business and is never inspected — that
/// exclusion is what keeps this guard off legitimate component fills
/// (`architecture/solution.md` §3.3).
List<_NamedArgument> _depthOneArguments(String s, int openParen) {
  final List<_NamedArgument> arguments = <_NamedArgument>[];
  int depth = 0;
  int cursor = openParen + 1;
  bool atArgumentBoundary = true;

  while (cursor < s.length) {
    final int comment = _commentEnd(s, cursor);
    if (comment > cursor) {
      cursor = comment;
      continue;
    }
    final int string = _stringEnd(s, cursor);
    if (string > cursor) {
      cursor = string;
      atArgumentBoundary = false;
      continue;
    }

    final String c = s[cursor];
    if (c.trim().isEmpty) {
      cursor++;
      continue;
    }
    if (depth == 0 && c == ')') {
      break;
    }
    if (c == '(' || c == '[' || c == '{') {
      depth++;
      cursor++;
      atArgumentBoundary = false;
      continue;
    }
    if (c == ')' || c == ']' || c == '}') {
      depth--;
      cursor++;
      atArgumentBoundary = false;
      continue;
    }
    if (depth == 0 && c == ',') {
      cursor++;
      atArgumentBoundary = true;
      continue;
    }

    if (depth == 0 && atArgumentBoundary && _isIdentifierStart(c)) {
      int end = cursor;
      while (end < s.length && _isIdentifierChar(s[end])) {
        end++;
      }
      final int afterName = _skipTrivia(s, end);
      final bool isNamedArgument =
          afterName < s.length &&
          s[afterName] == ':' &&
          (afterName + 1 >= s.length || s[afterName + 1] != ':');
      if (isNamedArgument) {
        final int valueStart = _skipTrivia(s, afterName + 1);
        final (String value, int terminator) = _readValue(s, valueStart);
        arguments.add(
          _NamedArgument(
            name: s.substring(cursor, end),
            value: value,
            valueStart: valueStart,
            line: _lineAt(s, cursor),
          ),
        );
        cursor = terminator;
        atArgumentBoundary = false;
        continue;
      }
      cursor = end;
      atArgumentBoundary = false;
      continue;
    }

    atArgumentBoundary = false;
    cursor++;
  }
  return arguments;
}

/// Resolves the widget constructor call an argument value opens with, skipping
/// an optional `const`. Returns null when the value is not a plain widget call.
(String, int)? _widgetCallAt(String s, int start) {
  int cursor = _skipTrivia(s, start);
  if (cursor >= s.length || !_isIdentifierStart(s[cursor])) {
    return null;
  }
  int end = cursor;
  while (end < s.length && _isIdentifierChar(s[end])) {
    end++;
  }
  String name = s.substring(cursor, end);
  if (name == 'const' || name == 'new') {
    cursor = _skipTrivia(s, end);
    if (cursor >= s.length || !_isIdentifierStart(s[cursor])) {
      return null;
    }
    end = cursor;
    while (end < s.length && _isIdentifierChar(s[end])) {
      end++;
    }
    name = s.substring(cursor, end);
  }
  final int afterName = _skipTrivia(s, end);
  if (afterName >= s.length || s[afterName] != '(') {
    return null;
  }
  return (name, afterName);
}

/// Offsets of every `Scaffold(` constructor call in [s], excluding matches
/// inside comments/strings and identifiers that merely end in `Scaffold`
/// (`PreviewScaffold(`).
List<int> _scaffoldCalls(String s) {
  final List<int> calls = <int>[];
  int cursor = 0;
  while (cursor < s.length) {
    final int comment = _commentEnd(s, cursor);
    if (comment > cursor) {
      cursor = comment;
      continue;
    }
    final int string = _stringEnd(s, cursor);
    if (string > cursor) {
      cursor = string;
      continue;
    }
    if (s.startsWith('Scaffold(', cursor) &&
        (cursor == 0 || !_isIdentifierChar(s[cursor - 1])) &&
        (cursor < 1 || s[cursor - 1] != '.')) {
      calls.add(cursor + 'Scaffold'.length);
    }
    cursor++;
  }
  return calls;
}

List<String> _violationsIn(String path, String source) {
  final List<String> violations = <String>[];
  for (final int openParen in _scaffoldCalls(source)) {
    for (final _NamedArgument argument in _depthOneArguments(
      source,
      openParen,
    )) {
      if (argument.name == 'backgroundColor' &&
          !_transparentValues.contains(argument.value)) {
        violations.add(
          '$path:${argument.line}: Scaffold(backgroundColor: '
          '${argument.value}) paints an opaque root fill over the shared '
          '--sky wash',
        );
        continue;
      }
      if (argument.name != 'body') {
        continue;
      }
      final (String, int)? call = _widgetCallAt(source, argument.valueStart);
      if (call == null || !_layerWidgets.contains(call.$1)) {
        continue;
      }
      final bool paintsOpaquely = _depthOneArguments(source, call.$2).any(
        (_NamedArgument nested) =>
            _paintingArguments.contains(nested.name) &&
            !_alphaModulated.hasMatch(nested.value),
      );
      if (paintsOpaquely) {
        violations.add(
          '$path:${argument.line}: Scaffold(body: ${call.$1}(...)) is a '
          'full-bleed opaque root layer over the shared --sky wash',
        );
      }
    }
  }
  return violations;
}

List<File> _scaffoldBearingFiles() {
  final Directory lib = Directory('lib');
  expect(
    lib.existsSync(),
    isTrue,
    reason:
        'the guard resolves `lib/` relative to the `mobile/` package root, '
        'which is `flutter test`\'s working directory',
  );
  return <File>[
    for (final FileSystemEntity entity in lib.listSync(recursive: true))
      if (entity is File &&
          entity.path.endsWith('.dart') &&
          !_isPreviewHarness(entity.path) &&
          entity.readAsStringSync().contains('Scaffold('))
        entity,
  ];
}

void main() {
  test(
    'AC2: no screen paints an opaque root fill over the shared --sky wash '
    'outside the ratified allowlist',
    () {
      final List<File> inventory = _scaffoldBearingFiles();
      // A broken path would otherwise let an empty sweep pass as clean.
      expect(
        inventory,
        isNotEmpty,
        reason: 'no Scaffold-bearing file was found under lib/',
      );

      final List<String> violations = <String>[];
      for (final File file in inventory) {
        if (_allowlist.containsKey(file.path)) {
          continue;
        }
        violations.addAll(_violationsIn(file.path, file.readAsStringSync()));
      }

      expect(
        violations,
        isEmpty,
        reason:
            'The --sky wash is mounted once at cupid_app.dart:59 and shows '
            'through because every Scaffold stays transparent. A screen that '
            'paints its own opaque root layer hides it on that route only, '
            'silently — the REQ-002 STORY-046 defect. Remove the fill, or, if '
            'the design source genuinely overrides --sky on this screen, '
            'escalate it as a new allowlist entry (a reviewable design '
            'decision, never a mechanical unblock — architecture/solution.md '
            'AD-3):\n${violations.join('\n')}',
      );
    },
  );

  test(
    'AC3: every allowlist entry still exists and still occludes, so no '
    'exemption rots into permanent dead weight',
    () {
      final List<String> stale = <String>[];
      _allowlist.forEach((String path, String rationale) {
        final File file = File(path);
        if (!file.existsSync()) {
          stale.add('$path: allowlisted but no longer on disk');
          return;
        }
        expect(rationale, isNotEmpty, reason: path);
        if (_violationsIn(path, file.readAsStringSync()).isEmpty) {
          stale.add(
            '$path: allowlisted but no longer paints an opaque root fill, so '
            'the exemption grants nothing',
          );
        }
      });

      expect(
        stale,
        isEmpty,
        reason:
            'Drop the entry from _allowlist — an exemption that no longer '
            'exempts anything only widens the guard\'s blind spot:\n'
            '${stale.join('\n')}',
      );
    },
  );
}
