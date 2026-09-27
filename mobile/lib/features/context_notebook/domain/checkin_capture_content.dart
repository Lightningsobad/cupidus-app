import '../../../core/content/content_package.dart';

/// The REQ-017 check-in capture package family. Its own schema id because the
/// item shape (plain parameterised copy) has nothing in common with an ask
/// question or a skill seed.
const String checkinCaptureSchemaId = 'req017.checkin_capture.v1';

const String checkinCaptureAssetKey =
    'assets/data/req017/checkin_capture.v1.json';

/// The only content parameter this family supports. The UI resolves it through
/// [CheckinCaptureCopySet.originLabel]; it never concatenates a card name onto
/// authored copy itself (AC-14, UX Part D).
const String checkinCaptureCardParam = 'card';

const String checkinCaptureQuestionId = 'checkin.capture.question.v1';
const String checkinCaptureOptionalLabelId =
    'checkin.capture.optional_label.v1';
const String checkinCaptureInterestKindId = 'checkin.capture.kind.interest.v1';
const String checkinCaptureEventKindId = 'checkin.capture.kind.event.v1';
const String checkinCaptureKindRequiredHintId =
    'checkin.capture.kind_required_hint.v1';
const String checkinCaptureSaveErrorId = 'checkin.capture.save_error.v1';
const String checkinCaptureRetryId = 'checkin.capture.retry.v1';
const String notebookOriginWithCardId = 'notebook.origin.with_card.v1';
const String notebookOriginFallbackId = 'notebook.origin.fallback.v1';

/// Every copy item UX Part D names. These are stable ids, not wording: the
/// wording lives in the package, the requirement lives here.
const List<String> requiredCheckinCaptureCopyIds = <String>[
  checkinCaptureQuestionId,
  checkinCaptureOptionalLabelId,
  checkinCaptureInterestKindId,
  checkinCaptureEventKindId,
  checkinCaptureKindRequiredHintId,
  checkinCaptureSaveErrorId,
  checkinCaptureRetryId,
  notebookOriginWithCardId,
  notebookOriginFallbackId,
];

/// Which items may declare which parameters. Absent from this map means the item
/// takes none, so a CMS cannot turn a fixed label into a template.
const Map<String, List<String>> checkinCaptureItemParams =
    <String, List<String>>{
  notebookOriginWithCardId: <String>[checkinCaptureCardParam],
};

final RegExp _placeholderPattern = RegExp(r'\{([a-zA-Z0-9_]+)\}');

/// One authored line of check-in capture copy.
class CheckinCaptureCopy implements ContentItem {
  const CheckinCaptureCopy({
    required this.id,
    required this.text,
    required this.params,
  });

  @override
  final String id;

  /// Authored wording. Content, never l10n and never a Dart constant (AC-14).
  final String text;

  /// Declared placeholders, in declaration order. Empty for every fixed label.
  final List<String> params;
}

CheckinCaptureCopy checkinCaptureCopyFromJson(
  Map<String, Object?> json,
  String source,
) {
  final String id = requireContentString(json, 'id', source);
  final String text = requireContentString(json, 'text', source);

  final List<String> declared = json.containsKey('params')
      ? requireContentStringList(json, 'params', source)
      : const <String>[];
  final List<String> supported =
      checkinCaptureItemParams[id] ?? const <String>[];

  for (final String param in declared) {
    if (!supported.contains(param)) {
      throw ContentPackageFormatException(
        source,
        'copy item "$id" declares unsupported parameter "$param"',
      );
    }
  }

  final Set<String> used = _placeholderPattern
      .allMatches(text)
      .map((RegExpMatch match) => match.group(1)!)
      .toSet();
  for (final String param in used) {
    if (!declared.contains(param)) {
      throw ContentPackageFormatException(
        source,
        'copy item "$id" uses undeclared parameter "{$param}"',
      );
    }
  }
  for (final String param in declared) {
    if (!used.contains(param)) {
      throw ContentPackageFormatException(
        source,
        'copy item "$id" declares parameter "$param" but its text never uses it',
      );
    }
  }

  return CheckinCaptureCopy(
    id: id,
    text: text,
    params: List<String>.unmodifiable(declared),
  );
}

/// The resolved copy P3 and P4 consume. Resolution lives here rather than in a
/// widget so no surface can hand-build an origin label.
class CheckinCaptureCopySet {
  const CheckinCaptureCopySet(this.package);

  final ContentPackage<CheckinCaptureCopy> package;

  String text(String id) {
    final CheckinCaptureCopy? item = package.itemById(id);
    if (item == null) {
      throw ContentPackageFormatException(
        package.id,
        'copy item "$id" is missing from the shipped package',
      );
    }
    return item.text;
  }

  /// The origin label for a notebook row. A card title that is absent, blank, or
  /// unreadable degrades to the parameterless line, and the row still renders in
  /// full (AC-9/BR-6).
  String originLabel({String? cardTitle}) {
    final String? title = cardTitle?.trim();
    if (title == null || title.isEmpty) {
      return text(notebookOriginFallbackId);
    }
    return text(notebookOriginWithCardId)
        .replaceAll('{$checkinCaptureCardParam}', title);
  }
}
