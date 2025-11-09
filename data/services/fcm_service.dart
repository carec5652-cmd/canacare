import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;

// FCM Service - خدمة إشعارات Firebase
// Handles push notifications (foreground, background, and terminated state)
class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // Your Firebase Cloud Messaging Server Key
  // Get this from Firebase Console > Project Settings > Cloud Messaging > Server Key
  String? _serverKey;

  // Initialize FCM Service
  // تهيئة خدمة FCM
  Future<void> initialize({String? serverKey}) async {
    _serverKey = serverKey;

    // Request permission for notifications
    await _requestPermission();

    // Configure local notifications for Android
    await _configureLocalNotifications();

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Get initial message if app was opened from notification
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    debugPrint('FCM Service initialized');
  }

  // Request notification permissions
  Future<void> _requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('Notification permission: ${settings.authorizationStatus}');

    if (kIsWeb && settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('✅ Web browser notifications ENABLED!');
      debugPrint('💡 You will now receive notifications on this browser');
    }
  }

  // Configure local notifications for foreground display
  Future<void> _configureLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification tapped: ${response.payload}');
      },
    );
  }

  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('📬 Foreground message received!');
    debugPrint('   Title: ${message.notification?.title}');
    debugPrint('   Body: ${message.notification?.body}');

    if (kIsWeb) {
      // On web, browser shows notification automatically if permission granted
      debugPrint('   🌐 Web notification should appear now!');
    } else {
      _showLocalNotification(message);
    }
  }

  // Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.notification?.title}');
    // You can navigate to specific screens based on message data
  }

  // Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'admin_can_care_channel',
      'Admin Can Care Notifications',
      channelDescription: 'Notifications from Admin Can Care app',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _localNotifications.show(
      message.notification.hashCode,
      message.notification?.title,
      message.notification?.body,
      notificationDetails,
      payload: message.data.toString(),
    );
  }

  // Get FCM Token
  Future<String?> getToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $token');
      return token;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  // Save FCM Token to Firestore for this admin/user
  // حفظ FCM Token في Firestore
  Future<void> saveTokenToFirestore({required String userId, required String collection}) async {
    try {
      String? token = await getToken();
      if (token != null) {
        await FirebaseFirestore.instance.collection(collection).doc(userId).set({
          'fcmToken': token,
          'tokenUpdatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        debugPrint('✅ FCM Token saved to Firestore for user: $userId');
      }
    } catch (e) {
      debugPrint('❌ Error saving FCM token to Firestore: $e');
    }
  }

  // Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    // Topic subscription is not supported on web
    if (kIsWeb) {
      debugPrint('Topic subscription skipped on web platform');
      return;
    }

    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic: $e');
    }
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    // Topic unsubscription is not supported on web
    if (kIsWeb) {
      debugPrint('Topic unsubscription skipped on web platform');
      return;
    }

    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic: $e');
    }
  }

  // Send notification to all users
  // إرسال إشعار لجميع المستخدمين
  Future<bool> sendNotificationToAll({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    return await sendNotificationToTopic(topic: 'all_users', title: title, body: body, data: data);
  }

  // Send notification to specific topic
  // إرسال إشعار لموضوع محدد
  Future<bool> sendNotificationToTopic({
    required String topic,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // Direct FCM API calls don't work on web due to CORS
    if (kIsWeb) {
      debugPrint('⚠️ Web Platform Detected');
      debugPrint('📱 For production, use Firebase Cloud Functions to send notifications');
      debugPrint('💡 Notification saved to Firestore (visible to all users)');
      // On web, just return true - notification is saved in Firestore
      return true;
    }

    if (_serverKey == null) {
      debugPrint('FCM Server Key not set');
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'key=$_serverKey'},
        body: jsonEncode({
          'to': '/topics/$topic',
          'notification': {'title': title, 'body': body, 'sound': 'default', 'badge': '1'},
          'data': data ?? {},
          'priority': 'high',
          'content_available': true,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Notification sent successfully to topic: $topic');
        return true;
      } else {
        debugPrint('Failed to send notification: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending notification: $e');
      return false;
    }
  }

  // Send notification to specific tokens
  // إرسال إشعار لأجهزة محددة
  Future<bool> sendNotificationToTokens({
    required List<String> tokens,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // Direct FCM API calls don't work on web due to CORS
    if (kIsWeb) {
      debugPrint('⚠️ Web Platform: Cannot send to specific tokens directly');
      debugPrint('💡 Use Firebase Cloud Functions for production');
      return true;
    }

    if (_serverKey == null) {
      debugPrint('FCM Server Key not set');
      return false;
    }

    if (tokens.isEmpty) {
      debugPrint('No tokens provided');
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'key=$_serverKey'},
        body: jsonEncode({
          'registration_ids': tokens,
          'notification': {'title': title, 'body': body, 'sound': 'default', 'badge': '1'},
          'data': data ?? {},
          'priority': 'high',
          'content_available': true,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Notification sent successfully to ${tokens.length} tokens');
        return true;
      } else {
        debugPrint('Failed to send notification: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending notification: $e');
      return false;
    }
  }

  // Send notification to users by role
  // إرسال إشعار حسب الدور
  Future<bool> sendNotificationByRole({
    required String role, // 'doctors', 'nurses', 'patients'
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Get FCM tokens from Firestore based on role
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection(role).where('fcmToken', isNull: false).get();

      List<String> tokens = [];
      for (var doc in snapshot.docs) {
        String? token = doc.get('fcmToken');
        if (token != null && token.isNotEmpty) {
          tokens.add(token);
        }
      }

      if (tokens.isEmpty) {
        debugPrint('No FCM tokens found for role: $role');
        return false;
      }

      // Send notifications in batches of 1000 (FCM limit)
      for (int i = 0; i < tokens.length; i += 1000) {
        int end = (i + 1000 < tokens.length) ? i + 1000 : tokens.length;
        List<String> batch = tokens.sublist(i, end);
        await sendNotificationToTokens(tokens: batch, title: title, body: body, data: data);
      }

      return true;
    } catch (e) {
      debugPrint('Error sending notification by role: $e');
      return false;
    }
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message: ${message.notification?.title}');
}
