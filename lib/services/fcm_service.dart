import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';

/// Top-level background message handler.
/// Harus berada di luar class (top-level) dan diberi anotasi @pragma('vm:entry-point')
/// agar tidak terkena tree-shaking saat dijalankan di isolate terpisah (background).
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Inisialisasi Firebase agar bisa menggunakan service Firebase lainnya di background
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  debugPrint('=== [FCM Service] BACKGROUND MESSAGE RECEIVED ===');
  debugPrint('Message ID: ${message.messageId}');
  if (message.notification != null) {
    debugPrint('Notification Title: ${message.notification!.title}');
    debugPrint('Notification Body: ${message.notification!.body}');
  }
  debugPrint('Payload Data: ${message.data}');
  debugPrint('=================================================');
}

class FCMService {
  // Singleton instance
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Inisialisasi FCM Service
  static Future<void> initialize() async {
    debugPrint('=== [FCM Service] START INITIALIZATION ===');

    try {
      // 1. Request Permission (terutama untuk iOS dan Android 13+)
      await _requestPermission();

      // 2. Ambil FCM Token awal
      await _getAndLogToken();

      // 3. Register Background Message Handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      debugPrint('[FCM Service] Background message handler registered.');

      // 4. Setup Listeners untuk Foreground dan Clicks
      _setupMessageListeners();

      debugPrint('=== [FCM Service] INITIALIZATION COMPLETED SUCCESSFUL ===');
    } catch (e, stackTrace) {
      debugPrint('[FCM Service] Error during initialization: $e');
      debugPrint('[FCM Service] StackTrace: $stackTrace');
    }
  }

  /// Request izin notifikasi ke user
  static Future<void> _requestPermission() async {
    debugPrint('[FCM Service] Requesting notification permission...');
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('[FCM Service] Permission Status: ${settings.authorizationStatus}');
  }

  /// Mengambil FCM Token saat ini dan menampilkan ke console
  static Future<void> _getAndLogToken() async {
    try {
      String? token = await _messaging.getToken();
      if (token != null) {
        debugPrint('[FCM Service] Current FCM Token: $token');
      } else {
        debugPrint('[FCM Service] Failed to get FCM Token: token is null');
      }
    } catch (e) {
      debugPrint('[FCM Service] Error getting FCM Token: $e');
    }
  }

  /// Mengatur semua listener (foreground, click, token refresh)
  static void _setupMessageListeners() {
    // 1. Listener untuk refresh token
    _messaging.onTokenRefresh.listen((String newToken) {
      debugPrint('[FCM Service] FCM Token Refreshed: $newToken');
      // Di sini Anda bisa mengirim token baru ke API Backend Anda jika diperlukan
    }).onError((error) {
      debugPrint('[FCM Service] Error refreshing token: $error');
    });

    // 2. Listener untuk notifikasi yang masuk ketika aplikasi dalam keadaan FOREGROUND
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('=== [FCM Service] FOREGROUND MESSAGE RECEIVED ===');
      if (message.notification != null) {
        debugPrint('Notification Title: ${message.notification!.title}');
        debugPrint('Notification Body: ${message.notification!.body}');
      }
      debugPrint('Payload Data: ${message.data}');
      debugPrint('==================================================');
      
      // Contoh local handling untuk foreground notification
      _handleLocalNotification(message);
    });

    // 3. Listener ketika notifikasi diklik dan aplikasi dalam keadaan BACKGROUND (belum ditutup sepenuhnya)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('=== [FCM Service] NOTIFICATION CLICKED (App in Background) ===');
      if (message.notification != null) {
        debugPrint('Notification Title: ${message.notification!.title}');
      }
      debugPrint('Payload Data: ${message.data}');
      debugPrint('================================================================');
      
      _handleNotificationClick(message.data);
    });

    // 4. Cek apakah aplikasi dibuka dari keadaan TERMINATED (mati total) lewat klik notifikasi
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('=== [FCM Service] NOTIFICATION CLICKED (App from Terminated) ===');
        if (message.notification != null) {
          debugPrint('Notification Title: ${message.notification!.title}');
        }
        debugPrint('Payload Data: ${message.data}');
        debugPrint('==================================================================');
        
        _handleNotificationClick(message.data);
      }
    });
  }

  /// Contoh penanganan notifikasi ketika aplikasi terbuka (Foreground)
  static void _handleLocalNotification(RemoteMessage message) {
    // Menampilkan debugPrint title dan body sesuai request no 6
    if (message.notification != null) {
      final title = message.notification!.title ?? 'No Title';
      final body = message.notification!.body ?? 'No Body';
      debugPrint('[Local Handling] Notification Received - Title: "$title", Body: "$body"');
    }
  }

  /// Contoh penanganan ketika notifikasi diklik
  static void _handleNotificationClick(Map<String, dynamic> data) {
    // Menampilkan debugPrint payload sesuai request no 6
    debugPrint('[Local Handling] Notification Clicked - Payload: $data');
  }
}
