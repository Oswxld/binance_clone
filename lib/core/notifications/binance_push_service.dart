import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../firebase_options.dart';
import '../theme/binance_palette.dart';

/// Root UI messenger for FCM when the Binance app is in the foreground.
final binanceScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Notification payloads are displayed by Android in background/terminated
/// states. This handler doesn't trigger another duplicate notification.
@pragma('vm:entry-point')
Future<void> binanceBackgroundFcmHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class BinancePushService {
  BinancePushService(this._client, this._messengerKey);

  final SupabaseClient _client;
  final GlobalKey<ScaffoldMessengerState> _messengerKey;
  StreamSubscription<String>? _tokenChanges;
  StreamSubscription<RemoteMessage>? _foregroundMessages;
  StreamSubscription<RemoteMessage>? _openedMessages;
  String? _ownerId;
  String? _currentToken;

  Future<void> start(String ownerId) async {
    if (_ownerId == ownerId) return;
    await stop();
    _ownerId = ownerId;
    try {
      if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;

      final messaging = FirebaseMessaging.instance;
      final permission = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (permission.authorizationStatus != AuthorizationStatus.authorized &&
          permission.authorizationStatus != AuthorizationStatus.provisional) {
        debugPrint('Binance notifications: permission not granted.');
        return;
      }
      if (_ownerId != ownerId) return;

      final token = await messaging.getToken();
      if (token != null && _ownerId == ownerId) {
        await _saveToken(ownerId, token);
      }
      _tokenChanges = messaging.onTokenRefresh.listen((value) {
        if (_ownerId == ownerId) {
          unawaited(_saveToken(ownerId, value));
        }
      });
      _foregroundMessages = FirebaseMessaging.onMessage.listen(_present);
      _openedMessages = FirebaseMessaging.onMessageOpenedApp.listen(_present);
      final initial = await messaging.getInitialMessage();
      if (initial != null && _ownerId == ownerId) _present(initial);
    } catch (error) {
      // Wallet login/balance must still work if Firebase isn't available.
      debugPrint('Binance FCM registration could not start: $error');
    }
  }

  Future<void> _saveToken(String ownerId, String token) async {
    if (_ownerId != ownerId || _client.auth.currentUser?.id != ownerId) return;
    try {
      await _client.from('b_device_tokens').upsert(
        {
          'owner_id': ownerId,
          'fcm_target': token,
          'platform': 'android',
          'last_seen_at': DateTime.now().toUtc().toIso8601String(),
        },
        onConflict: 'fcm_target',
      );
      if (_ownerId == ownerId) _currentToken = token;
    } catch (error) {
      debugPrint('Binance FCM token registration failed: $error');
    }
  }

  void _present(RemoteMessage message) {
    final title = message.notification?.title ??
        message.data['sender_name'] ??
        'Notification';
    final body = message.notification?.body ??
        message.data['body'] ?? '';
    if (message.data['type'] != 'binance_notification') return;

    final messenger = _messengerKey.currentState;
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: BinancePalette.raised,
          duration: const Duration(seconds: 5),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                    color: BinancePalette.textPrimary,
                    fontWeight: FontWeight.w600,
                  )),
              if (body.isNotEmpty)
                Text(body,
                    style: const TextStyle(
                      color: BinancePalette.textSecondary,
                    )),
            ],
          ),
        ),
      );
  }

  Future<void> stop({bool unregister = false}) async {
    final owner = _ownerId;
    final token = _currentToken;
    _ownerId = null;
    _currentToken = null;
    await _tokenChanges?.cancel();
    await _foregroundMessages?.cancel();
    await _openedMessages?.cancel();
    _tokenChanges = null;
    _foregroundMessages = null;
    _openedMessages = null;
    // Signing out must remove this account/device registration, otherwise
    // the next person using the phone could see notifications meant for it.
    if (unregister &&
        owner != null && token != null &&
        _client.auth.currentUser?.id == owner) {
      try {
        await _client.from('b_device_tokens').delete()
            .eq('owner_id', owner).eq('fcm_target', token);
      } catch (error) {
        debugPrint('Binance token deregistration failed: $error');
      }
    }
  }
}
