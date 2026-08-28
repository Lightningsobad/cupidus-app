import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cupid_api/cupid_api.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../design_system/theme/cupid_platform.dart';
import '../di/service_locator.dart';
import '../../features/in_app_notifications/presentation/dialogs/alarm_request_dialog.dart';
import '../../features/in_app_notifications/presentation/dialogs/contract_signing_dialog.dart';
import '../../features/in_app_notifications/presentation/dialogs/dream_jar_approval_dialog.dart';
import '../../features/in_app_notifications/presentation/dialogs/ghost_config_approval_dialog.dart';
import '../../features/in_app_notifications/presentation/dialogs/theme_request_dialog.dart';
import '../../features/in_app_notifications/presentation/widgets/alarm_ringing_overlay.dart';
import '../../features/in_app_notifications/presentation/widgets/emoji_storm_overlay.dart';
import '../../features/in_app_notifications/presentation/widgets/in_app_toast_banner.dart';
import '../../features/themes/data/themes_repository.dart';
import '../../features/themes/presentation/theme_cubit.dart';
import '../../features/vibes/presentation/vibe_cubit.dart';
import '../../features/dream_jar/data/dream_jar_repository.dart';
import '../../features/love_contracts/data/love_contract_repository.dart';
import '../../features/anti_ghosting/data/ghost_config_repository.dart';
import 'backend_user_id_store.dart';
import 'cupid_realtime.dart';

/// Central in-app notification manager that receives realtime events
/// and dispatches the corresponding interactive dialog, fullscreen overlay, or toast.
class InAppNotificationManager {
  InAppNotificationManager({
    required this.navigatorKey,
    required RealtimeCoordinator coordinator,
  }) : _coordinator = coordinator {
    _subscription = _coordinator.events().listen(_handleRealtimeEvent);
    _initFcm();
  }

  final GlobalKey<NavigatorState> navigatorKey;
  final RealtimeCoordinator _coordinator;
  StreamSubscription<RealtimeEvent>? _subscription;

  BuildContext? get _currentContext => navigatorKey.currentContext;
  OverlayState? get _currentOverlay => navigatorKey.currentState?.overlay;

  Future<void> _initFcm() async {
    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        final token = await messaging.getToken();
        if (token != null) {
          await _registerTokenWithBackend(token);
        }
      }

      messaging.onTokenRefresh.listen((token) {
        _registerTokenWithBackend(token);
      });
    } catch (e) {
      debugPrint('[InAppNotificationManager] FCM init error: $e');
    }
  }

  Future<void> _registerTokenWithBackend(String token) async {
    try {
      if (getIt.isRegistered<CupidApi>()) {
        final api = getIt<CupidApi>();
        final platformStr = CupidPlatform.resolveDefault() == CupidPlatform.ios ? 'ios' : 'android';
        await api.dio.post(
          '/users/fcm-token',
          data: {
            'token': token,
            'platform': platformStr,
          },
        );
        debugPrint('[InAppNotificationManager] Registered FCM token with backend.');
      }
    } catch (e) {
      debugPrint('[InAppNotificationManager] Failed to register FCM token: $e');
    }
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }


  void _handleRealtimeEvent(RealtimeEvent event) {
    final context = _currentContext;
    if (context == null) return;

    final name = event.name;
    final data = event.data;

    switch (name) {
      // 1. Interactive Dialogs
      case 'theme:request':
        final themeName = data['themeName'] as String? ?? 'mới';
        final themeId = data['themeId'] as String? ?? '';
        final price = (data['price'] as num?)?.toInt() ?? 0;

        ThemeRequestDialog.show(
          context,
          themeName: themeName,
          themeId: themeId,
          price: price,
          onApprove: () async {
            if (getIt.isRegistered<ThemesRepository>()) {
              try {
                await getIt<ThemesRepository>().approveTheme();
                if (getIt.isRegistered<ThemeCubit>()) {
                  getIt<ThemeCubit>().loadThemeState();
                }
              } catch (_) {}
            }
          },
          onReject: () async {
            if (getIt.isRegistered<ThemesRepository>()) {
              try {
                await getIt<ThemesRepository>().rejectTheme();
                if (getIt.isRegistered<ThemeCubit>()) {
                  getIt<ThemeCubit>().loadThemeState();
                }
              } catch (_) {}
            }
          },
        );
        break;


      case 'dream_jar:created':
        final rawName = (data['name'] as String?)?.trim() ?? (data['jarName'] as String?)?.trim() ?? '';
        final jarName = rawName.isNotEmpty && rawName != '_' ? rawName : 'Ước mơ mới';
        final target = (data['targetAmount'] as num?) ?? (data['target_amount'] as num?) ?? 0;
        final currency = data['currency'] as String? ?? 'VND';
        final jarId = data['id'] as String? ?? (data['jarId'] as String? ?? '');

        DreamJarApprovalDialog.show(
          context,
          jarName: jarName,
          targetAmount: target,
          currency: currency,
          onApprove: () async {
            if (jarId.isNotEmpty && getIt.isRegistered<DreamJarRepository>()) {
              try {
                await getIt<DreamJarRepository>().approveJar(jarId);
              } catch (_) {}
            }
          },
          onReject: () async {
            if (jarId.isNotEmpty && getIt.isRegistered<DreamJarRepository>()) {
              try {
                await getIt<DreamJarRepository>().rejectJar(jarId);
              } catch (_) {}
            }
          },
        );
        break;

      case 'contract:created':
        final contractId = data['id'] as String? ?? '';
        final rawClauses = data['clauses'];
        final List<String> clauses = rawClauses is List
            ? rawClauses.map((e) => e.toString()).toList()
            : [];

        ContractSigningDialog.show(
          context,
          contractId: contractId,
          clauses: clauses,
          onSign: () async {
            if (getIt.isRegistered<LoveContractRepository>()) {
              try {
                await getIt<LoveContractRepository>().sign();
              } catch (_) {}
            }
          },
          onDismiss: () {},
        );
        break;

      case 'ghost_config:requested':
        final configId = data['id'] as String? ?? '';
        final threshold = (data['thresholdMinutes'] as num?)?.toInt() ?? 30;
        final penalty = data['penalty'] as String? ?? 'emoji_storm';

        GhostConfigApprovalDialog.show(
          context,
          thresholdMinutes: threshold,
          penalty: penalty,
          onApprove: () async {
            if (configId.isNotEmpty && getIt.isRegistered<GhostConfigRepository>()) {
              try {
                await getIt<GhostConfigRepository>().approve(configId);
              } catch (_) {}
            }
          },
          onReject: () async {
            if (configId.isNotEmpty && getIt.isRegistered<GhostConfigRepository>()) {
              try {
                await getIt<GhostConfigRepository>().reject(configId);
              } catch (_) {}
            }
          },
        );
        break;


      case 'alarm:newAlarmRequest':
        final alarmTime = data['time'] as String? ?? '07:00';
        final rawDays = data['days'];
        final List<String> days = rawDays is List
            ? rawDays.map((e) => e.toString()).toList()
            : [];

        AlarmRequestDialog.show(
          context,
          alarmTime: alarmTime,
          days: days,
          onConfirm: () {},
          onDismiss: () {},
        );
        break;

      // 2. Fullscreen Takeovers
      case 'alarm:triggerAlarm':
        AlarmRingingOverlay.show(
          context,
          overlay: _currentOverlay,
          title: '⏰ BÁO THỨC ĐÔI ĐANG REO! ⏰',
          message: 'Bae và bạn cùng thức dậy nào!',
          onDismiss: () {},
        );
        break;

      case 'chat:emojiStormReceived':
      case 'emojiStormReceived':
        final penalty = data['penalty'] as String? ?? 'emoji_storm';
        EmojiStormOverlay.show(context, penalty: penalty, overlay: _currentOverlay);
        break;

      // 3. In-App Toast Banners
      case 'chat:newMessage':
      case 'newMessage':
        final senderId = data['senderId'] as String?;
        if (senderId != null && getIt.isRegistered<BackendUserIdStore>()) {
          final currentUserId = getIt<BackendUserIdStore>().backendUserId;
          if (currentUserId != null && currentUserId == senderId) {
            // Ignore self notifications
            break;
          }
        }
        final content = data['content'] as String? ?? 'Tin nhắn mới';
        InAppToastBanner.show(
          context,
          overlay: _currentOverlay,
          title: 'Bae 💬',
          message: content,
          iconEmoji: '💬',
        );
        break;

      case 'pet:adopted':
        final petName = data['name'] as String? ?? 'Bé Pet';
        final species = data['species'] as String? ?? 'thú cưng';
        InAppToastBanner.show(
          context,
          overlay: _currentOverlay,
          title: 'Nhận nuôi thú cưng mới! 🐾',
          message: 'Bae vừa đón bé $species tên là "$petName" về nhà!',
          iconEmoji: '🐾',
        );
        break;

      case 'pet:interacted':
        final pet = data['pet'] as Map<String, dynamic>?;
        final petName = pet?['name'] as String? ?? 'Bé Pet';
        final happiness = pet?['happiness'] ?? 50;
        final isLevelUp = data['isLevelUp'] == true;

        InAppToastBanner.show(
          context,
          overlay: _currentOverlay,
          title: isLevelUp ? 'Bé Pet tăng cấp! 🌟' : 'Bae vừa chăm sóc Pet! 🍖',
          message: isLevelUp
              ? 'Bé "$petName" vừa đạt cấp độ mới! 🎉'
              : 'Bé "$petName" được cho ăn no nê (Hạnh phúc: $happiness%)!',
          iconEmoji: isLevelUp ? '🌟' : '🍖',
        );
        break;

      case 'vibe:posted':
        final senderUserId = data['userId'] as String?;
        if (senderUserId != null && getIt.isRegistered<BackendUserIdStore>()) {
          final currentUserId = getIt<BackendUserIdStore>().backendUserId;
          if (currentUserId != null && currentUserId == senderUserId) {
            // Ignore self notifications
            break;
          }
        }
        if (getIt.isRegistered<VibeCubit>()) {
          getIt<VibeCubit>().refresh();
        }
        final mood = data['mood'] as String? ?? 'tươi vui';
        final note = data['note'] as String?;
        InAppToastBanner.show(
          context,
          overlay: _currentOverlay,
          title: 'Vibe Check 💕',
          message: 'Bae đang cảm thấy: $mood${note != null ? " - \"$note\"" : ""}',
          iconEmoji: '💕',
        );
        break;

      case 'expense:created':
        final desc = data['description'] as String? ?? data['category'] as String? ?? 'Khoản chi';
        final amount = data['amount'];
        InAppToastBanner.show(
          context,
          overlay: _currentOverlay,
          title: 'Khoản chi tiêu mới 💸',
          message: 'Bae vừa thêm: $desc (${amount.toString()} VND)',
          iconEmoji: '💸',
        );
        break;

      case 'gallery:item_added':
        InAppToastBanner.show(
          context,
          overlay: _currentOverlay,
          title: 'Kho ảnh kỷ niệm 📸',
          message: 'Bae vừa thêm một bức ảnh mới vào album bí mật!',
          iconEmoji: '📸',
        );
        break;

      case 'timeline:event_added':
        final eventTitle = data['title'] as String? ?? 'Kỷ niệm mới';
        InAppToastBanner.show(
          context,
          overlay: _currentOverlay,
          title: 'Kỷ niệm tình yêu 💕',
          message: 'Đã lưu lại: "$eventTitle"',
          iconEmoji: '💝',
        );
        break;

      case 'pairing:success':
        InAppToastBanner.show(
          context,
          overlay: _currentOverlay,
          title: 'Ghép đôi thành công! 🎉💕',
          message: 'Hai bạn đã chính thức kết đôi trên Cupid!',
          iconEmoji: '🎉',
        );
        break;

      case 'vow:partner_ready':
        InAppToastBanner.show(
          context,
          overlay: _currentOverlay,
          title: 'Lời thề tình yêu 🤝',
          message: 'Bae đang chờ bạn cùng chạm ngón tay để hoàn tất Lời thề!',
          iconEmoji: '🤝',
        );
        break;

      case 'theme:approved':
        final themeName = data['themeName'] as String? ?? 'mới';
        InAppToastBanner.show(
          context,
          overlay: _currentOverlay,
          title: 'Giao diện mới đã áp dụng! 🎨',
          message: 'Giao diện "$themeName" đã được kích hoạt.',
          iconEmoji: '🎨',
        );
        break;

      case 'theme:rejected':
        InAppToastBanner.show(
          context,
          overlay: _currentOverlay,
          title: 'Đề xuất đổi giao diện',
          message: 'Bae chưa muốn đổi giao diện lúc này.',
          iconEmoji: 'ℹ️',
        );
        break;

      case 'theme:wishlist_updated':
        final themeName = data['themeName'] as String? ?? 'mới';
        InAppToastBanner.show(
          context,
          overlay: _currentOverlay,
          title: 'Wishlist cập nhật 💕',
          message: 'Bae vừa thêm theme "$themeName" vào Wishlist!',
          iconEmoji: '✨',
        );
        break;

      case 'dream_jar:status_changed':
        InAppToastBanner.show(
          context,
          overlay: _currentOverlay,
          title: 'Hũ ước mơ 🍯',
          message: 'Trạng thái hũ ước mơ của bạn đã được cập nhật.',
          iconEmoji: '🍯',
        );
        break;

      case 'dream_jar:contributed':
        final contributorId = data['contributorId'] as String?;
        final currentUserId = getIt.isRegistered<BackendUserIdStore>()
            ? getIt<BackendUserIdStore>().backendUserId
            : null;
        if (contributorId != null &&
            currentUserId != null &&
            contributorId == currentUserId) {
          break;
        }
        InAppToastBanner.show(
          context,
          overlay: _currentOverlay,
          title: 'Đóng góp hũ ước mơ 💰',
          message: 'Bae vừa tích lũy thêm tiền vào hũ ước mơ chung!',
          iconEmoji: '💰',
        );
        break;

      case 'dream_jar:completed':
        InAppToastBanner.show(
          context,
          overlay: _currentOverlay,
          title: 'Hoàn thành mục tiêu! 🏆🎉',
          message: 'Chúc mừng hai bạn đã đạt 100% mục tiêu hũ ước mơ!',
          iconEmoji: '🏆',
        );
        break;


      default:
        break;
    }
  }
}
