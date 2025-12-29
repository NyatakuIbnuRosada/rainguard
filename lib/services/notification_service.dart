import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    try {
      const androidInit =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const initSettings = InitializationSettings(
        android: androidInit,
      );

      await _notifications.initialize(initSettings);

      // 🔥 WAJIB UNTUK ANDROID 13+
      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      // 🔥 BUAT CHANNEL (AMAN)
      const AndroidNotificationChannel channel =
          AndroidNotificationChannel(
        'rain_channel',
        'Rain Notification',
        description: 'Notifikasi hujan RainGuard',
        importance: Importance.high,
      );

      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      print('NotificationService INIT OK');
    } catch (e) {
      // 🔥 PENTING: JANGAN SAMPAI APP CRASH
      print('NotificationService INIT ERROR: $e');
    }
  }

  static Future<void> showRainAlert(String intensity) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'rain_channel',
        'Rain Notification',
        channelDescription: 'Notifikasi hujan RainGuard',
        importance: Importance.high,
        priority: Priority.high,
      );

      const notifDetails = NotificationDetails(
        android: androidDetails,
      );

      await _notifications.show(
        0,
        '🌧️ Hujan Terdeteksi',
        'Intensitas: $intensity',
        notifDetails,
      );
    } catch (e) {
      print('SHOW NOTIF ERROR: $e');
    }
  }
}
