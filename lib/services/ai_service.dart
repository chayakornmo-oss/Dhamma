import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/config/app_env.dart';
import '../screens/checkin/daily_checkin_screen.dart' show Mood, MoodExt;

class AIService {
  AIService._();

  static String get _baseUrl => AppEnv.aiServiceBaseUrl;

  // ── Mood-specific fallback prayers ───────────────────────────────
  static const Map<String, Map<String, String>> _fallbacks = {
    'กังวล': {
      'message':
          'จิตใจที่เต็มไปด้วยความกังวลนั้น ต้องการพื้นที่สงบ ลองหายใจลึกๆ แล้วมอบความไว้วางใจให้กับพระรัตนตรัย',
      'prayer': 'พุทโธ ธัมโม สังโฆ — ระลึกถึงสรณะสาม',
      'duration': '⏱ 10 นาที',
    },
    'เหนื่อย': {
      'message':
          'ความเหนื่อยล้าเป็นสัญญาณให้หยุดพัก ไม่ใช่ล้มแพ้ บทสวดสั้นๆ จะช่วยเติมพลังงานให้ร่างกายและจิตใจ',
      'prayer': 'อิติปิโส ภควา — บทสรรเสริญพระคุณ',
      'duration': '⏱ 5 นาที',
    },
    'ปกติ': {
      'message':
          'วันนี้เป็นวันที่ดี จงเริ่มต้นด้วยความตั้งใจที่บริสุทธิ์ และกตัญญูต่อทุกสิ่งที่มีอยู่',
      'prayer': 'อิติปิโส ภควา — บทสรรเสริญพระคุณ',
      'duration': '⏱ 5 นาที',
    },
    'สบายดี': {
      'message':
          'พลังงานดีของคุณวันนี้เป็นของขวัญ แบ่งปันความรู้สึกนี้ผ่านการสวดมนต์เพื่ออุทิศบุญให้ผู้อื่น',
      'prayer': 'กรณียเมตตสุตตัง — เมตตาแผ่ไปทุกทิศ',
      'duration': '⏱ 7 นาที',
    },
    'ดีมาก': {
      'message':
          'วันนี้ดาวเข้าข้างคุณ! เป็นโอกาสดีที่จะอุทิศบุญกุศลและตั้งจิตทำความดี เพื่อเพิ่มบารมีในวันที่ดาวส่องสว่าง',
      'prayer': 'มหามงคลสุตตัง — บทมงคลสูตร 38 ประการ',
      'duration': '⏱ 15 นาที',
    },
  };

  static Future<Map<String, String>> getPrayerRecommendation(
      Mood mood) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/recommend-prayer'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'mood': mood.label,
              'day': DateTime.now().weekday,
              'hour': DateTime.now().hour,
            }),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final message = data['message']?.toString() ?? '';
        final prayer = data['prayer']?.toString() ?? '';
        final duration = data['duration']?.toString() ?? '';

        if (message.isNotEmpty && prayer.isNotEmpty) {
          return {
            'message': message,
            'prayer': prayer,
            'duration': duration,
          };
        }
      }
    } catch (e) {
      debugPrint('[AIService] Server unavailable, using fallback: $e');
    }

    return _fallbacks[mood.label] ??
        _fallbacks['ปกติ']!;
  }
}
