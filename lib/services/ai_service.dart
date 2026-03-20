import 'dart:convert';
import 'package:http/http.dart' as http;
import '../screens/checkin/daily_checkin_screen.dart' show Mood, MoodExt;

class AIService {
  static const String _baseUrl = 'http://localhost:3000/api/ai';

  static Future<Map<String, String>> getPrayerRecommendation(Mood mood) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/recommend-prayer'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mood': mood.label,
          'day': DateTime.now().weekday,
          'hour': DateTime.now().hour,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return {
          'message': data['message']?.toString() ?? '',
          'prayer': data['prayer']?.toString() ?? '',
          'duration': data['duration']?.toString() ?? '',
        };
      }
    } catch (_) {}

    return {
      'message': 'วันนี้เป็นวันที่ดี จงเริ่มต้นด้วยความตั้งใจที่บริสุทธิ์',
      'prayer': 'อิติปิโส ภควา',
      'duration': '⏱ 5 นาที'
    };
  }
}
