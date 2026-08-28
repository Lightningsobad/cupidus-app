import 'package:flutter/widgets.dart';

import '../../auth/presentation/auth_strings.dart';

/// Canonical vi/en copy for the Synced Reminder feature
/// (`ux/uiux-spec.md` §2-§4, ADR-002/D1). This is the only file in the
/// feature allowed to contain literal user-facing text (AC2/AC3); every
/// screen/widget in `features/reminders/presentation/` must read its copy
/// from here. Every string uses "nhắc nhở đồng bộ" / "synced reminder" and
/// never "báo thức", "Synced Alarm", "reo"/"ring" bell language, or any
/// Do-Not-Disturb claim -- statically enforced by
/// `reminder_copy_guard_test.dart` (P4). Resolved from the ambient [Locale]
/// via [AuthLocaleText.viEn] (STORY-003 pattern), not the `AppL10n` ARB
/// pipeline.
extension ReminderStrings on BuildContext {
  // -- Schedule screen (`ux/uiux-spec.md` §2) --

  String get reminderScreenTitle =>
      viEn('Nhắc nhở đồng bộ', 'Synced Reminder');

  String get reminderYouLabel => viEn('Bạn', 'You');

  String get reminderPartnerLabel => viEn('Đối tác', 'Partner');

  /// Hero card eyebrow label. ASSUMPTION-1: kept verbatim from the design
  /// source per the architecture solution's decision to flag, not block, the
  /// "mỗi sáng / every morning" recurrence-wording question -- the
  /// implementation itself sends only a single absolute occurrence.
  String get reminderHeroEyebrow =>
      viEn('Nhắc nhở đồng bộ mỗi sáng', 'Shared morning reminder');

  String get reminderConfirmCta =>
      viEn('Xác nhận giờ này', 'Confirm this time');

  String get reminderSetupCta =>
      viEn('Thiết lập nhắc nhở đồng bộ', 'Set up synced reminder');

  String get reminderSaveSetupCta =>
      viEn('Lưu thiết lập nhắc nhở', 'Save synced reminder');

  /// No partner display name is available on [SyncedReminder] (only
  /// `partnerId`/`requesterId`), so this renders the generic form of the
  /// raw `{{waitingAlarmCopy}}` binding rather than inventing a name lookup
  /// outside this phase's scope.
  String get reminderWaitingPartnerCta => viEn(
    'Đang đợi đối tác xác nhận nhắc nhở đồng bộ…',
    'Waiting for your partner to confirm the synced reminder…',
  );

  String get reminderTryItNowCta =>
      viEn('Thử nhắc ngay (demo)', 'Try it now (demo)');

  /// The canonical, user-facing statement of the 5-minute timeout behavior
  /// backing AC4 (P3 must preserve the timeout this describes). Split into
  /// four runs because the design source renders the lead-in and the
  /// "cả hai"/"both" clause as emphasized spans in `colorText` inside an
  /// otherwise muted paragraph; concatenating the four in order reproduces
  /// the full sentence.
  String get reminderRuleCardLeadIn => viEn('Luật chơi:', 'The rule:');

  String get reminderRuleCardBeforeEmphasis =>
      viEn(' nhắc nhở chỉ tắt khi ', ' the reminder stops only when ');

  String get reminderRuleCardEmphasis => viEn('cả hai', 'both');

  String get reminderRuleCardAfterEmphasis => viEn(
    ' cùng vuốt. Một người dậy trước thì máy người kia vẫn nhắc — hoặc '
    'tự tắt sau 5 phút.',
    ' swipe. If one wakes first the other keeps prompting — or times out '
    'after 5 minutes.',
  );

  String get reminderRetryCta => viEn('Thử lại', 'Retry');

  String get reminderLoadFailure =>
      viEn('Không tải được nhắc nhở đồng bộ.', 'Could not load the synced reminder.');

  String get reminderEmptyState => viEn(
    'Chưa có nhắc nhở đồng bộ nào. Chỉnh giờ bên dưới để bắt đầu.',
    'No synced reminder yet. Adjust the time below to get started.',
  );

  /// The design source's trailing tick is rendered as `CupidIcons.check`, not
  /// a U+2713 in the string: Nunito has no glyph for it, so the raw character
  /// captures as a missing-glyph box.
  String get reminderYouConfirmed => viEn('Bạn đã xác nhận', 'You confirmed');

  String get reminderPartnerConfirmed => viEn('Đã xác nhận', 'Confirmed');

  String get reminderNotConfirmedYet => viEn('Chưa xác nhận', 'Not confirmed yet');

  String get reminderIncreaseTimeLabel => viEn('Tăng giờ', 'Increase time');

  String get reminderDecreaseTimeLabel => viEn('Giảm giờ', 'Decrease time');

  /// Abbreviated chip label for [weekday] (`DateTime.monday`(1)..
  /// `DateTime.sunday`(7)).
  String reminderWeekdayShortLabel(int weekday) {
    const vi = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    const en = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return viEn(vi[weekday - 1], en[weekday - 1]);
  }

  /// Full weekday name for [weekday], used as the chip's accessible label
  /// since the visible short label alone is ambiguous to screen readers.
  String reminderWeekdayFullLabel(int weekday) {
    const vi = [
      'Thứ Hai',
      'Thứ Ba',
      'Thứ Tư',
      'Thứ Năm',
      'Thứ Sáu',
      'Thứ Bảy',
      'Chủ Nhật',
    ];
    const en = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return viEn(vi[weekday - 1], en[weekday - 1]);
  }

  // -- Firing overlay (`ux/uiux-spec.md` §3), reused by P3 --

  String get reminderFiringBody =>
      viEn('Chỉ tắt khi cả hai cùng vuốt nha.', 'It stops only when both of you swipe.');

  String get reminderDismissCta => viEn('Vuốt để dậy', 'Swipe to wake');

  String get reminderDismissAccessibleLabel =>
      viEn('Tắt nhắc nhở', 'Dismiss reminder');

  /// Trailing tick rendered as `CupidIcons.check`; see [reminderYouConfirmed].
  String get reminderYouAwake => viEn('đã dậy', 'awake');

  String get reminderStillAsleep => viEn('còn ngủ', 'still asleep');

  String get reminderTimedOutNotice =>
      viEn('Nhắc nhở đã tự tắt', 'Reminder timed out');

  // -- Multi-Alarm / Schedule List Strings --

  String get reminderAddNewCta =>
      viEn('Thêm nhắc nhở mới', 'Add new reminder');

  String get reminderCreateTitle =>
      viEn('Tạo nhắc nhở đồng bộ', 'Create synced reminder');

  String get reminderEditTitle =>
      viEn('Chỉnh sửa nhắc nhở', 'Edit reminder');

  String get reminderDescriptionLabel =>
      viEn('Ghi chú / Nhãn', 'Label / Note');

  String get reminderDescriptionHint =>
      viEn('Nhập nhãn nhắc nhở...', 'Enter reminder label...');

  String get reminderSelectTimeTitle =>
      viEn('Chọn giờ & phút', 'Select hour & minute');

  String get reminderHourLabel => viEn('Giờ', 'Hour');

  String get reminderMinuteLabel => viEn('Phút', 'Minute');

  String get reminderRepeatTitle => viEn('Lặp lại các ngày', 'Repeat on days');

  String get reminderEveryDay => viEn('Hàng ngày', 'Every day');

  String get reminderOnce => viEn('Một lần', 'Once');

  String get reminderDeleteCta => viEn('Xoá nhắc nhở', 'Delete reminder');

  String get reminderCancelCta => viEn('Huỷ', 'Cancel');

  String get reminderSaveCta => viEn('Lưu nhắc nhở', 'Save reminder');

  String get reminderSendProposalCta =>
      viEn('Gửi đề xuất nhắc nhở', 'Send reminder proposal');

  String get reminderAwaitingPartnerStatus =>
      viEn('Chờ đối tác đồng ý', 'Awaiting partner approval');

  String get reminderPartnerRequestedToggle =>
      viEn('Đối tác đề xuất đổi trạng thái', 'Partner proposed status change');

  String get reminderPartnerRequestedEdit =>
      viEn('Đối tác đề xuất sửa giờ', 'Partner proposed edit');

  String get reminderPartnerRequestedDelete =>
      viEn('Đối tác đề xuất xoá', 'Partner proposed deletion');

  String get reminderAcceptCta => viEn('Đồng ý', 'Accept');

  String get reminderRejectCta => viEn('Từ chối', 'Decline');

  String get reminderNoAlarmsYet =>
      viEn('Chưa có nhắc nhở đồng bộ nào', 'No synced reminders yet');

  String get reminderNoAlarmsSub => viEn(
    'Bấm nút + bên trên để cùng đối tác tạo nhắc nhở đôi nhé!',
    'Tap + above to create a synced reminder together!',
  );

  String get reminderTagWakeUp => viEn('🌅 Thức dậy', '🌅 Wake up');
  String get reminderTagDrinkWater => viEn('💧 Uống nước', '💧 Drink water');
  String get reminderTagPills => viEn('💊 Uống thuốc', '💊 Take medicine');
  String get reminderTagDate => viEn('💖 Hẹn hò', '💖 Date time');
  String get reminderTagSleep => viEn('💤 Đi ngủ', '💤 Sleep');

  // -- Notifications settings screen row (`ux/uiux-spec.md` §4), reused by
  //    the future notifications story. This screen is not built in this
  //    story (D9) -- only its canonical copy is transcribed here.

  String get reminderNotificationsRowTitle =>
      viEn('Nhắc nhở đồng bộ', 'Synced Reminder');

  String get reminderNotificationsRowSubtitle =>
      viEn('Nhắc trên cả hai máy', 'Prompts on both phones');

  /// DND-override clause deleted outright, not softened (§4 resolution).
  String get reminderNotificationsBanner =>
      viEn('Tối đa 15 thông báo/ngày.', 'Max 15 pushes/day.');
}
