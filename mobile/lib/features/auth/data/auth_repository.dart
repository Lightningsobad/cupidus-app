import 'package:cupid_mobile/core/auth/cupid_auth.dart';
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/network/cupid_api_failure.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_sign_in_gateway.dart';

/// `AuthRepository` managing user authentication, OTP verification,
/// and session persistence.
class AuthRepository {
  AuthRepository({
    FirebaseSignInGateway? gateway,
    required CupidApi api,
    required Future<void> Function() signOut,
    CupidSession? cupidSession,
    BackendUserIdStore? backendUserIdStore,
    AuthHistoryStore? authHistoryStore,
  })  : _gateway = gateway,
        _api = api,
        _signOut = signOut,
        _cupidSession = cupidSession,
        _backendUserIdStore = backendUserIdStore,
        _authHistoryStore = authHistoryStore;

  final FirebaseSignInGateway? _gateway;
  final CupidApi _api;
  final CupidSession? _cupidSession;
  final BackendUserIdStore? _backendUserIdStore;
  final AuthHistoryStore? _authHistoryStore;
  final Future<void> Function() _signOut;

  String? _pendingEmail;
  String? get pendingEmail => _pendingEmail;

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _pendingEmail = email.trim().toLowerCase();
    await _onAuthenticated(email);
    try {
      final response = await _api.dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {
          'email': email.trim().toLowerCase(),
          'password': password,
        },
      );
      final data = response.data;
      if (data != null && data['requireVerification'] == true) {
        throw EmailNotVerifiedFailure(email: email.trim().toLowerCase());
      }
      if (data != null && data['accessToken'] != null) {
        final token = data['accessToken'] as String;
        final user = data['user'] as Map<String, dynamic>?;
        final userId = user?['id'] as String? ?? '';
        final userEmail = user?['email'] as String? ?? email;
        await _cupidSession?.setSession(
          token: token,
          email: userEmail,
          userId: userId,
        );
        _backendUserIdStore?.updateFromLoginResponse(user);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const InvalidCredentialFailure();
      }
      final errorData = e.response?.data;
      final message = errorData is Map ? errorData['message'] : null;
      throw e.error ?? UnexpectedAuthFailure(message?.toString());
    }
  }

  Future<void> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _pendingEmail = email.trim().toLowerCase();
    await _onAuthenticated(email);
    try {
      await _api.dio.post<Map<String, dynamic>>(
        '/auth/register',
        data: {
          'email': email.trim().toLowerCase(),
          'password': password,
          if (displayName != null && displayName.isNotEmpty)
            'displayName': displayName,
        },
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw const EmailAlreadyInUseFailure();
      }
      final errorData = e.response?.data;
      final message = errorData is Map ? errorData['message'] : null;
      throw e.error ?? UnexpectedAuthFailure(message?.toString());
    }
  }

  /// Verify 6-digit OTP code received in email
  Future<void> verifyOtp({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _api.dio.post<Map<String, dynamic>>(
        '/auth/verify-otp',
        data: {'email': email.trim().toLowerCase(), 'code': code.trim()},
      );
      final data = response.data;
      if (data != null && data['accessToken'] != null) {
        final token = data['accessToken'] as String;
        final user = data['user'] as Map<String, dynamic>?;
        final userId = user?['id'] as String? ?? '';
        final userEmail = user?['email'] as String? ?? email;
        await _cupidSession?.setSession(
          token: token,
          email: userEmail,
          userId: userId,
        );
        await _onAuthenticated(email);
        _backendUserIdStore?.updateFromLoginResponse(user);
      }
    } on DioException catch (e) {
      final errorData = e.response?.data;
      String? message;
      if (errorData is Map) {
        final msg = errorData['message'];
        if (msg is List) {
          message = msg.join(', ');
        } else if (msg is String) {
          message = msg;
        }
      }
      throw OtpInvalidFailure(message);
    }
  }

  /// Resend 6-digit OTP code with 60s cooldown
  Future<void> resendOtp({
    required String email,
  }) async {
    try {
      await _api.dio.post<Map<String, dynamic>>(
        '/auth/resend-otp',
        data: {'email': email.trim().toLowerCase()},
      );
    } on DioException catch (e) {
      final errorData = e.response?.data;
      String? message;
      if (errorData is Map) {
        final msg = errorData['message'];
        if (msg is List) {
          message = msg.join(', ');
        } else if (msg is String) {
          message = msg;
        }
      }
      throw OtpInvalidFailure(message);
    }
  }

  /// Social sign-in delegators
  Future<void> signInWithGoogle() async {
    if (_gateway != null) {
      await _gateway!.signInWithGoogle();
    }
    await _onAuthenticated(null);
    await _syncBackendProfile();
  }

  Future<void> signInWithApple() async {
    if (_gateway != null) {
      await _gateway!.signInWithApple();
    }
    await _onAuthenticated(null);
    await _syncBackendProfile();
  }

  Future<void> signInWithFacebook() async {
    if (_gateway != null) {
      await _gateway!.signInWithFacebook();
    }
    await _onAuthenticated(null);
    await _syncBackendProfile();
  }

  Future<void> _onAuthenticated(String? email) async {
    await _authHistoryStore?.markAuthenticated(email: email);
  }

  Future<void> sendEmailVerification() async {
    if (_gateway != null) {
      await _gateway!.sendEmailVerification();
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    if (_gateway != null) {
      await _gateway!.sendPasswordResetEmail(email);
      return;
    }
    try {
      await _api.dio.post<Map<String, dynamic>>(
        '/auth/forgot-password',
        data: {'email': email.trim().toLowerCase()},
      );
    } on DioException catch (e) {
      final errorData = e.response?.data;
      final message = errorData is Map ? errorData['message'] : null;
      throw e.error ?? UnexpectedAuthFailure(message?.toString());
    }
  }

  Future<bool> reloadEmailVerified() async {
    if (_gateway != null) {
      return _gateway!.reloadEmailVerified();
    }
    return true;
  }

  Future<void> signOut() => _signOut();

  Future<void> _syncBackendProfile() async {
    try {
      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await _api.dio.post<Map<String, dynamic>>(
        '/auth/firebase-login',
        data: {'idToken': idToken},
        options: Options(
          headers: {
            if (idToken != null && idToken.isNotEmpty)
              'Authorization': 'Bearer $idToken',
          },
        ),
      );
      final data = response.data;
      if (data != null && data['accessToken'] != null) {
        final token = data['accessToken'] as String;
        final user = data['user'] as Map<String, dynamic>?;
        final userId = user?['id'] as String? ?? '';
        final userEmail = user?['email'] as String? ?? '';
        await _cupidSession?.setSession(
          token: token,
          email: userEmail,
          userId: userId,
        );
        _backendUserIdStore?.updateFromLoginResponse(user ?? data);
      } else {
        _backendUserIdStore?.updateFromLoginResponse(data);
      }
    } on DioException catch (e) {
      final failure = e.error;
      throw failure ?? const UnexpectedFailure();
    }
  }
}
