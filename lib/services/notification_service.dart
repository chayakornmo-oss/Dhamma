import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // ── Initialize ──────────────────────────────
  static Future<void> initialize() async {
    if (kIsWeb) return;
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Bangkok'));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Firebase Messaging
    await FirebaseMessaging.instance.requestPermission(
      alert: true, badge: true, sound: true,
    );

    // Schedule daily rituals
    await scheduleDailyRituals();
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // TODO: Navigate based on payload
    print('Notification tapped: ${response.payload}');
  }

  // ── Daily Rituals Schedule ──────────────────
  static Future<void> scheduleDailyRituals() async {
    await _cancelAll();

    // 06:30 — Morning auspicious colors
    await _scheduleDaily(
      id: 1,
      title: _morningTitles[DateTime.now().weekday % _morningTitles.length],
      body: 'แตะเพื่อดูสีมงคลและคำทำนายวันนี้',
      hour: 6,
      minute: 30,
      payload: '/checkin',
      sound: 'bell_soft',
    );

    // 21:00 — Evening reflection
    await _scheduleDaily(
      id: 2,
      title: '🌙 วันนี้เป็นยังไงบ้าง?',
      body: 'เล่าให้เราฟังได้นะ',
      hour: 21,
      minute: 0,
      payload: '/checkin',
      sound: 'bell_soft',
    );
  }

  // ── Vow Reminder ────────────────────────────
  static Future<void> scheduleVowReminder({
    required String vowId,
    required String templeName,
    required String prayerText,
    required DateTime reminderDate,
  }) async {
    final truncated = prayerText.length > 30
        ? '${prayerText.substring(0, 30)}...'
        : prayerText;

    await _plugin.zonedSchedule(
      vowId.hashCode,
      '📍 ถึงเวลาอัปเดตคำขอพร',
      'ที่ $templeName — "$truncated" เป็นยังไงบ้าง?',
      tz.TZDateTime.from(reminderDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'vow_reminders',
          'Vow Reminders',
          channelDescription: 'Reminders for your prayers and vows',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: '/vow/$vowId',
    );
  }

  // ── Weekly Vow Summary ───────────────────────
  static Future<void> scheduleWeeklyVowSummary(int pendingCount) async {
    // Every Sunday 19:00
    final now = tz.TZDateTime.now(tz.local);
    final daysUntilSunday = (7 - now.weekday) % 7;
    final nextSunday = tz.TZDateTime(
      tz.local,
      now.year, now.month, now.day + daysUntilSunday,
      19, 0, 0,
    );

    await _plugin.zonedSchedule(
      999,
      '📊 สรุปรายเดือน',
      'คุณมี $pendingCount คำขอ pending อยู่ ลองเช็คซักที',
      nextSunday,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'weekly_summary',
          'Weekly Summary',
          importance: Importance.defaultImportance,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: '/vow',
    );
  }

  // ── Re-engagement ────────────────────────────
  static Future<void> scheduleReEngagement({
    required int daysInactive,
    required String userName,
    required String lastVowTemple,
  }) async {
    final messages = {
      3: (
        title: '🌸 วันนี้มีอะไรอยากบอกเราไหม?',
        body: 'เราอยู่ที่นี่เสมอนะ',
      ),
      7: (
        title: '📍 ผ่านมา 1 สัปดาห์แล้ว',
        body: 'พรที่ขอไว้ที่ $lastVowTemple เป็นยังไงบ้าง?',
      ),
      14: (
        title: '$userName เราคิดถึงนะ',
        body: 'ไม่ต้องทำอะไรมาก แค่บอกให้รู้ว่าเป็นยังไงบ้าง',
      ),
    };

    final msg = messages[daysInactive];
    if (msg == null) return;

    await _plugin.show(
      daysInactive,
      msg.title,
      msg.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          're_engagement',
          'Re-engagement',
          importance: Importance.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: '/home',
    );
  }

  // ── Sangha Update (Photo notification) ──────
  static Future<void> showSanghaUpdate({
    required String orderId,
    required String templeName,
    required String message,
    String? imageUrl,
  }) async {
    await _plugin.show(
      orderId.hashCode,
      '📸 อัปเดตจาก $templeName',
      message,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'sangha_updates',
          'Sangha Updates',
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: imageUrl != null
              ? BigPictureStyleInformation(
                  FilePathAndroidBitmap(imageUrl),
                )
              : null,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
      payload: '/sangha/$orderId',
    );
  }

  // ── Helpers ──────────────────────────────────
  static Future<void> _scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required String payload,
    String? sound,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local, now.year, now.month, now.day, hour, minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_ritual',
          'Daily Ritual',
          importance: Importance.high,
          sound: sound != null ? RawResourceAndroidNotificationSound(sound) : null,
        ),
        iOS: DarwinNotificationDetails(
          sound: sound != null ? '$sound.aiff' : null,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  static Future<void> _cancelAll() async {
    await _plugin.cancelAll();
  }

  // Morning notification variants
  static const _morningTitles = [
    '🌸 วันนี้สีทองรออยู่นะ',
    '🌅 อรุณสวัสดิ์ วันนี้พิเศษมาก',
    '✨ ดาวเข้าข้างคุณวันนี้',
    '🪷 วันที่ดีเริ่มต้นแล้ว',
    '💫 วันนี้มีเกณฑ์ดีรออยู่',
    '🌟 เช้านี้พลังงานดีมากเลย',
    '🎋 สวัสดีวันใหม่ที่ดีงาม',
  ];
}
