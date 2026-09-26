import 'dart:async';

import 'package:flutter/foundation.dart' show ValueChanged;
import 'package:flutter/services.dart'
    show MissingPluginException, PlatformException;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// Android channel identifiers. Technical, unaccented, and never drawn: the
/// title and body the user reads come from `nudges.v1.json`, so no display
/// string may appear anywhere in this file (AC-37/BR-15).
const String eveningCheckInChannelId = 'req016_evening_check_in';
const String eveningCheckInChannelName = 'req016 evening check in';

/// Never the exact variant. Android 14 refuses `SCHEDULE_EXACT_ALARM` for a
/// reminder like this one, and ADR-002 D1 forbids system alarms outright, so a
/// nudge that drifts a few minutes is the intended behaviour rather than a
/// compromise.
const AndroidScheduleMode eveningCheckInScheduleMode =
    AndroidScheduleMode.inexactAllowWhileIdle;

/// Everything the evening reminder needs from the notification system, and
/// nothing else. [EveningCheckInScheduler] depends on this instead of the
/// plugin so its one-shot rule can be tested without a platform channel.
abstract class LocalNotificationScheduler {
  /// `true` when the app may post a notification. Asked at the moment of the
  /// first schedule, never at app startup.
  Future<bool> requestPermission();

  Future<void> schedule({
    required int id,
    required DateTime at,
    required String body,
    String? title,
    String? payload,
  });

  Future<void> cancel(int id);

  Future<void> cancelAll();
}

/// The `flutter_local_notifications` implementation.
///
/// Every platform call it makes is either swallowed or unawaited: this runs on
/// the same pass that draws the hub's phase line, and under a test binding a
/// platform channel never completes at all (`home_widget_bridge.dart` takes
/// the same precaution for the widget payload).
class PluginLocalNotificationScheduler implements LocalNotificationScheduler {
  PluginLocalNotificationScheduler({
    FlutterLocalNotificationsPlugin? plugin,
    this.onSelected,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  /// Receives the payload of the notification the user tapped, including the
  /// tap that launched the app from cold.
  final ValueChanged<String?>? onSelected;

  Future<void>? _ready;

  Future<void> _ensureReady() => _ready ??= _initialize();

  Future<void> _initialize() async {
    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
        onDidReceiveNotificationResponse: (NotificationResponse response) =>
            onSelected?.call(response.payload),
      );

      // A tap that started the app from cold never reaches the callback above,
      // so the launch details are drained once on the way in.
      final NotificationAppLaunchDetails? launch =
          await _plugin.getNotificationAppLaunchDetails();
      if (launch != null && launch.didNotificationLaunchApp) {
        onSelected?.call(launch.notificationResponse?.payload);
      }
    } on PlatformException {
      return;
    } on MissingPluginException {
      return;
    }
  }

  @override
  Future<bool> requestPermission() async {
    await _ensureReady();
    try {
      final AndroidFlutterLocalNotificationsPlugin? android =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        return await android.requestNotificationsPermission() ?? false;
      }
      final IOSFlutterLocalNotificationsPlugin? ios =
          _plugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        // Alert only: a badge would be the "one thing left to do" marker
        // AC-17 forbids, and a sound would make this more than a nudge
        // (AC-31).
        return await ios.requestPermissions(
              alert: true,
              badge: false,
              sound: false,
            ) ??
            false;
      }
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
    return false;
  }

  @override
  Future<void> schedule({
    required int id,
    required DateTime at,
    required String body,
    String? title,
    String? payload,
  }) async {
    unawaited(
      _post(id: id, at: at, body: body, title: title, payload: payload),
    );
  }

  Future<void> _post({
    required int id,
    required DateTime at,
    required String body,
    String? title,
    String? payload,
  }) async {
    await _ensureReady();
    try {
      await _plugin.zonedSchedule(
        id: id,
        // `tz.UTC` rather than a named zone: the absolute instant is what a
        // one-shot needs, and reading the device zone name would mean a second
        // plugin for nothing.
        scheduledDate: tz.TZDateTime.from(at.toUtc(), tz.UTC),
        notificationDetails: _gentleDetails,
        androidScheduleMode: eveningCheckInScheduleMode,
        title: title,
        body: body,
        payload: payload,
      );
    } on PlatformException {
      return;
    } on MissingPluginException {
      return;
    }
  }

  @override
  Future<void> cancel(int id) async {
    unawaited(_cancel(id));
  }

  Future<void> _cancel(int id) async {
    await _ensureReady();
    try {
      await _plugin.cancel(id: id);
    } on PlatformException {
      return;
    } on MissingPluginException {
      return;
    }
  }

  @override
  Future<void> cancelAll() async {
    unawaited(_cancelAll());
  }

  Future<void> _cancelAll() async {
    await _ensureReady();
    try {
      await _plugin.cancelAll();
    } on PlatformException {
      return;
    } on MissingPluginException {
      return;
    }
  }
}

/// AC-31: no sound, no vibration, no full-screen intent, no badge and no
/// action button, so the notification can be swiped away and costs nothing to
/// ignore.
const NotificationDetails _gentleDetails = NotificationDetails(
  android: AndroidNotificationDetails(
    eveningCheckInChannelId,
    eveningCheckInChannelName,
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
    playSound: false,
    enableVibration: false,
    channelShowBadge: false,
  ),
  iOS: DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: false,
    presentSound: false,
  ),
);
