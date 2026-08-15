import 'package:flutter/widgets.dart';

/// Timeline copy introduced by the design-fidelity pass, resolved from the
/// ambient [Locale] rather than the generated `AppL10n` ARB pipeline
/// (`mobile/lib/l10n/**` is outside this phase's write scope -- same
/// precedent as `expense_strings.dart`/`auth_strings.dart`).
extension TimelineLocaleText on BuildContext {
  bool get _isVi => Localizations.localeOf(this).languageCode == 'vi';

  String timelineCountdownHeadline(int days) =>
      _isVi ? 'Còn $days ngày' : '$days days to go';

  String timelineCountdownSubtitle(int milestoneDays, String milestoneDate) =>
      _isVi
      ? 'tới mốc $milestoneDays ngày · $milestoneDate'
      : 'until the $milestoneDays-day mark · $milestoneDate';

  String get timelinePhotoPlaceholder => _isVi ? 'Ảnh kỷ niệm' : 'Memory photo';
}
