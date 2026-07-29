//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:dio/dio.dart';
import 'package:cupid_api/src/auth/api_key_auth.dart';
import 'package:cupid_api/src/auth/basic_auth.dart';
import 'package:cupid_api/src/auth/bearer_auth.dart';
import 'package:cupid_api/src/auth/oauth.dart';
import 'package:cupid_api/src/api/app_api.dart';
import 'package:cupid_api/src/api/epic1_auth_api.dart';
import 'package:cupid_api/src/api/epic1_invitations_api.dart';
import 'package:cupid_api/src/api/epic1_love_contracts_api.dart';
import 'package:cupid_api/src/api/epic1_users_api.dart';
import 'package:cupid_api/src/api/epic23_ghost_config_anti_ghosting_api.dart';
import 'package:cupid_api/src/api/epic2_communication_messages_api.dart';
import 'package:cupid_api/src/api/epic3_daily_vibe_check_api.dart';
import 'package:cupid_api/src/api/epic3_synced_alarms_api.dart';
import 'package:cupid_api/src/api/epic4_love_pet_api.dart';
import 'package:cupid_api/src/api/epic4_love_timeline_api.dart';
import 'package:cupid_api/src/api/epic4_private_gallery_api.dart';
import 'package:cupid_api/src/api/epic5_dream_jar_api.dart';
import 'package:cupid_api/src/api/epic5_expenses_api.dart';
import 'package:cupid_api/src/api/epic6_admin_configurations_api.dart';
import 'package:cupid_api/src/api/epic6_data_export_api.dart';
import 'package:cupid_api/src/api/uploads_api.dart';

class CupidApi {
  static const String basePath = r'http://localhost';

  final Dio dio;
  CupidApi({
    Dio? dio,
    String? basePathOverride,
    List<Interceptor>? interceptors,
  })  : 
        this.dio = dio ??
            Dio(BaseOptions(
              baseUrl: basePathOverride ?? basePath,
              connectTimeout: const Duration(milliseconds: 5000),
              receiveTimeout: const Duration(milliseconds: 3000),
            )) {
    if (interceptors == null) {
      this.dio.interceptors.addAll([
        OAuthInterceptor(),
        BasicAuthInterceptor(),
        BearerAuthInterceptor(),
        ApiKeyAuthInterceptor(),
      ]);
    } else {
      this.dio.interceptors.addAll(interceptors);
    }
  }

  void setOAuthToken(String name, String token) {
    if (this.dio.interceptors.any((i) => i is OAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is OAuthInterceptor) as OAuthInterceptor).tokens[name] = token;
    }
  }

  /// Removes the OAuth token associated with the given [name].
  ///
  /// If no [OAuthInterceptor] is registered or no token exists for the given
  /// [name], this method has no effect.
  void removeOAuthToken(String name) {
    if (this.dio.interceptors.any((i) => i is OAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is OAuthInterceptor) as OAuthInterceptor).tokens.remove(name);
    }
  }

  void setBearerAuth(String name, String token) {
    if (this.dio.interceptors.any((i) => i is BearerAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BearerAuthInterceptor) as BearerAuthInterceptor).tokens[name] = token;
    }
  }

  /// Removes the bearer authentication token associated with the given [name].
  ///
  /// If no [BearerAuthInterceptor] is registered or no token exists for the
  /// given [name], this method has no effect.
  void removeBearerAuth(String name) {
    if (this.dio.interceptors.any((i) => i is BearerAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BearerAuthInterceptor) as BearerAuthInterceptor).tokens.remove(name);
    }
  }

  void setBasicAuth(String name, String username, String password) {
    if (this.dio.interceptors.any((i) => i is BasicAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BasicAuthInterceptor) as BasicAuthInterceptor).authInfo[name] = BasicAuthInfo(username, password);
    }
  }

  /// Removes the basic authentication credentials associated with the given [name].
  ///
  /// If no [BasicAuthInterceptor] is registered or no credentials exist for the
  /// given [name], this method has no effect.
  void removeBasicAuth(String name) {
    if (this.dio.interceptors.any((i) => i is BasicAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BasicAuthInterceptor) as BasicAuthInterceptor).authInfo.remove(name);
    }
  }

  void setApiKey(String name, String apiKey) {
    if (this.dio.interceptors.any((i) => i is ApiKeyAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((element) => element is ApiKeyAuthInterceptor) as ApiKeyAuthInterceptor).apiKeys[name] = apiKey;
    }
  }

  /// Removes the API key associated with the given [name].
  ///
  /// If no [ApiKeyAuthInterceptor] is registered or no API key exists for the
  /// given [name], this method has no effect.
  void removeApiKey(String name) {
    if (this.dio.interceptors.any((i) => i is ApiKeyAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((element) => element is ApiKeyAuthInterceptor) as ApiKeyAuthInterceptor).apiKeys.remove(name);
    }
  }

  /// Get AppApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  AppApi getAppApi() {
    return AppApi(dio);
  }

  /// Get Epic1AuthApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  Epic1AuthApi getEpic1AuthApi() {
    return Epic1AuthApi(dio);
  }

  /// Get Epic1InvitationsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  Epic1InvitationsApi getEpic1InvitationsApi() {
    return Epic1InvitationsApi(dio);
  }

  /// Get Epic1LoveContractsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  Epic1LoveContractsApi getEpic1LoveContractsApi() {
    return Epic1LoveContractsApi(dio);
  }

  /// Get Epic1UsersApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  Epic1UsersApi getEpic1UsersApi() {
    return Epic1UsersApi(dio);
  }

  /// Get Epic23GhostConfigAntiGhostingApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  Epic23GhostConfigAntiGhostingApi getEpic23GhostConfigAntiGhostingApi() {
    return Epic23GhostConfigAntiGhostingApi(dio);
  }

  /// Get Epic2CommunicationMessagesApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  Epic2CommunicationMessagesApi getEpic2CommunicationMessagesApi() {
    return Epic2CommunicationMessagesApi(dio);
  }

  /// Get Epic3DailyVibeCheckApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  Epic3DailyVibeCheckApi getEpic3DailyVibeCheckApi() {
    return Epic3DailyVibeCheckApi(dio);
  }

  /// Get Epic3SyncedAlarmsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  Epic3SyncedAlarmsApi getEpic3SyncedAlarmsApi() {
    return Epic3SyncedAlarmsApi(dio);
  }

  /// Get Epic4LovePetApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  Epic4LovePetApi getEpic4LovePetApi() {
    return Epic4LovePetApi(dio);
  }

  /// Get Epic4LoveTimelineApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  Epic4LoveTimelineApi getEpic4LoveTimelineApi() {
    return Epic4LoveTimelineApi(dio);
  }

  /// Get Epic4PrivateGalleryApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  Epic4PrivateGalleryApi getEpic4PrivateGalleryApi() {
    return Epic4PrivateGalleryApi(dio);
  }

  /// Get Epic5DreamJarApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  Epic5DreamJarApi getEpic5DreamJarApi() {
    return Epic5DreamJarApi(dio);
  }

  /// Get Epic5ExpensesApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  Epic5ExpensesApi getEpic5ExpensesApi() {
    return Epic5ExpensesApi(dio);
  }

  /// Get Epic6AdminConfigurationsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  Epic6AdminConfigurationsApi getEpic6AdminConfigurationsApi() {
    return Epic6AdminConfigurationsApi(dio);
  }

  /// Get Epic6DataExportApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  Epic6DataExportApi getEpic6DataExportApi() {
    return Epic6DataExportApi(dio);
  }

  /// Get UploadsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  UploadsApi getUploadsApi() {
    return UploadsApi(dio);
  }
}
