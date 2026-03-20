/// Pure-Dart service for computing daily Buddhist fortune data.
/// All logic is deterministic and works fully offline.
library;

import 'package:intl/intl.dart';

enum ThaiElement { wood, fire, earth, metal, water }

class DailyFortune {
  final String prediction;
  final List<LuckyColor> luckyColors;
  final String luckyTime;
  final String luckyDirection;
  final int fortuneScore; // 1–5
  final String elementName;

  const DailyFortune({
    required this.prediction,
    required this.luckyColors,
    required this.luckyTime,
    required this.luckyDirection,
    required this.fortuneScore,
    required this.elementName,
  });
}

class LuckyColor {
  final String name;
  final int colorValue; // ARGB hex
  final String category;

  const LuckyColor({
    required this.name,
    required this.colorValue,
    required this.category,
  });
}

class FortuneService {
  FortuneService._();

  // ── Element from birth year ──────────────────────────────────────
  static ThaiElement elementFromBirthYear(int year) {
    switch (year % 10) {
      case 4:
      case 5:
        return ThaiElement.wood;
      case 6:
      case 7:
        return ThaiElement.fire;
      case 8:
      case 9:
        return ThaiElement.earth;
      case 0:
      case 1:
        return ThaiElement.metal;
      default:
        return ThaiElement.water; // 2, 3
    }
  }

  static String elementThaiName(ThaiElement el) {
    switch (el) {
      case ThaiElement.wood:
        return 'ธาตุไม้';
      case ThaiElement.fire:
        return 'ธาตุไฟ';
      case ThaiElement.earth:
        return 'ธาตุดิน';
      case ThaiElement.metal:
        return 'ธาตุทอง';
      case ThaiElement.water:
        return 'ธาตุน้ำ';
    }
  }

  // ── Lucky colors by weekday (Thai tradition) ─────────────────────
  static List<LuckyColor> luckyColorsForDay(int weekday) {
    // weekday: 1=Mon … 7=Sun
    switch (weekday) {
      case 1: // Monday — Yellow
        return [
          const LuckyColor(name: 'เหลือง', colorValue: 0xFFFFEB3B, category: 'การงาน'),
          const LuckyColor(name: 'ครีม', colorValue: 0xFFFFFDE7, category: 'การเงิน'),
          const LuckyColor(name: 'ส้มอ่อน', colorValue: 0xFFFFE0B2, category: 'ความรัก'),
        ];
      case 2: // Tuesday — Pink
        return [
          const LuckyColor(name: 'ชมพู', colorValue: 0xFFF48FB1, category: 'ความรัก'),
          const LuckyColor(name: 'แดงอ่อน', colorValue: 0xFFEF9A9A, category: 'การงาน'),
          const LuckyColor(name: 'ม่วงอ่อน', colorValue: 0xFFCE93D8, category: 'การเงิน'),
        ];
      case 3: // Wednesday — Green
        return [
          const LuckyColor(name: 'เขียว', colorValue: 0xFF81C784, category: 'การงาน'),
          const LuckyColor(name: 'เขียวเข้ม', colorValue: 0xFF388E3C, category: 'การเงิน'),
          const LuckyColor(name: 'ฟ้าอ่อน', colorValue: 0xFF80DEEA, category: 'ความรัก'),
        ];
      case 4: // Thursday — Orange
        return [
          const LuckyColor(name: 'ส้ม', colorValue: 0xFFFFB74D, category: 'การงาน'),
          const LuckyColor(name: 'เหลือง', colorValue: 0xFFFFEB3B, category: 'การเงิน'),
          const LuckyColor(name: 'น้ำตาล', colorValue: 0xFFBCAAA4, category: 'ความรัก'),
        ];
      case 5: // Friday — Blue
        return [
          const LuckyColor(name: 'ฟ้า', colorValue: 0xFF64B5F6, category: 'ความรัก'),
          const LuckyColor(name: 'น้ำเงิน', colorValue: 0xFF42A5F5, category: 'การเงิน'),
          const LuckyColor(name: 'เขียวมรกต', colorValue: 0xFF4DB6AC, category: 'การงาน'),
        ];
      case 6: // Saturday — Purple
        return [
          const LuckyColor(name: 'ม่วง', colorValue: 0xFFBA68C8, category: 'การงาน'),
          const LuckyColor(name: 'ดำ', colorValue: 0xFF616161, category: 'การเงิน'),
          const LuckyColor(name: 'น้ำเงินเข้ม', colorValue: 0xFF5C6BC0, category: 'ความรัก'),
        ];
      default: // Sunday — Red
        return [
          const LuckyColor(name: 'แดง', colorValue: 0xFFEF5350, category: 'การงาน'),
          const LuckyColor(name: 'ส้มแดง', colorValue: 0xFFFF7043, category: 'การเงิน'),
          const LuckyColor(name: 'ชมพูเข้ม', colorValue: 0xFFEC407A, category: 'ความรัก'),
        ];
    }
  }

  // ── Predictions: element × weekday matrix ─────────────────────────
  static String _prediction(ThaiElement el, int weekday) {
    final key = '${el.name}_$weekday';
    const map = <String, String>{
      // Wood element
      'wood_1': 'เส้นทางการงานเปิดกว้าง มีโอกาสพัฒนาทักษะใหม่ ระวังอย่าวางแผนเกินกำลัง',
      'wood_2': 'ความสัมพันธ์ฉันมิตรราบรื่น เพื่อนเก่าอาจกลับมาพบ ระวังเรื่องการกู้ยืมเงิน',
      'wood_3': 'ความคิดสร้างสรรค์พุ่งสูง เหมาะเริ่มโปรเจกต์ใหม่ แต่ตรวจสอบรายละเอียดให้ดี',
      'wood_4': 'ดาวพฤหัสช่วยส่งเสริม มีผู้ใหญ่ให้การสนับสนุน การเงินมีเกณฑ์ดีขึ้น',
      'wood_5': 'เสน่ห์ของคุณสูงมากวันนี้ ความรักมีความก้าวหน้า แต่อย่าตัดสินใจรีบร้อน',
      'wood_6': 'วันนี้ต้องการความอดทน อุปสรรคเล็กน้อยเป็นบทเรียน การทำบุญช่วยแก้ดวง',
      'wood_7': 'พลังงานดีจากดวงอาทิตย์ เหมาะออกสังคมและนำเสนองาน โชคลาภมีเกณฑ์ปรากฏ',
      // Fire element
      'fire_1': 'ไฟในตัวคุณลุกโชนวันนี้ ผู้นำเด่น คนมองเห็นคุณค่า ระวังความเร่งร้อนในการตัดสินใจ',
      'fire_2': 'ความหลงใหลและความรักสูง ช่วงเวลาดีสำหรับความรัก แต่ควบคุมอารมณ์ให้ดี',
      'fire_3': 'สมองลุกโชน ความคิดไหลลื่น เหมาะงานสร้างสรรค์และการนำเสนอ',
      'fire_4': 'ความกระตือรือร้นดึงดูดโอกาส มีเกณฑ์ได้รับข่าวดีจากทางไกล',
      'fire_5': 'เสน่ห์พุ่งสูง แต่ระวังเรื่องการเงินจากความหุนหันพลันแล่น ควรยั้งคิดก่อนใช้',
      'fire_6': 'พลังงานสูงแต่ต้องหาทางออก หากิจกรรมสร้างสรรค์แทนความขัดแย้ง',
      'fire_7': 'วันเด่นมาก! ผู้นำที่แท้จริง ทุกอย่างที่ตั้งใจจะสำเร็จหากลงมือวันนี้',
      // Earth element
      'earth_1': 'ความมั่นคงคือคำสำคัญวันนี้ การงานก้าวหน้าอย่างมั่นคง อย่าเสี่ยงสิ่งใหม่วันนี้',
      'earth_2': 'ความอดทนให้ผล ความสัมพันธ์ลึกซึ้งขึ้น เหมาะพูดคุยเรื่องสำคัญ',
      'earth_3': 'งานที่ต้องการความละเอียดจะออกมาดี ระวังการสื่อสารที่คลุมเครือ',
      'earth_4': 'พระคุ้มครอง การลงทุนระยะยาวมีแนวโน้มดี อย่าโลภจนเกินงาม',
      'earth_5': 'ความเป็นจริงและความฝันอยู่ใกล้กัน ความรักที่มั่นคงจะเบ่งบาน',
      'earth_6': 'ภาระหน้าที่หนักแต่คุ้มค่า ทำงานช้าแต่ชัวร์ คนรอบข้างไว้วางใจ',
      'earth_7': 'รากฐานแข็งแกร่ง โชคลาภจากที่ดินหรืออสังหาริมทรัพย์มีเกณฑ์ดี',
      // Metal element
      'metal_1': 'ความคมคายและตรงไปตรงมานำพาความสำเร็จ แต่ระวังพูดจาทิ่มแทงผู้อื่น',
      'metal_2': 'วินัยและความแม่นยำเป็นอาวุธ งานที่ต้องการความละเอียดจะสำเร็จงดงาม',
      'metal_3': 'สื่อสารตรงและชัดเจน แต่อ่อนนุ่มอารมณ์สักนิด คนรอบข้างจะร่วมมือดีขึ้น',
      'metal_4': 'ทองคำอยู่ในมือ โอกาสทางการเงินปรากฏ แต่ต้องพิจารณาอย่างรอบคอบ',
      'metal_5': 'มาตรฐานสูงของคุณดึงดูดคนที่มีคุณภาพ ความรักจริงใจมีเกณฑ์ปรากฏ',
      'metal_6': 'ระเบียบวินัยเป็นกุญแจ ทำตามแผนที่วางไว้ ไม่ต้องปรับเปลี่ยนอะไรเพิ่ม',
      'metal_7': 'ความสำเร็จที่วางแผนไว้จะมาถึง ดาวส่องสว่างต่อสิ่งที่ทำด้วยความสุจริต',
      // Water element
      'water_1': 'ความยืดหยุ่นคือพลัง ปรับตัวตามสถานการณ์ โอกาสซ่อนอยู่ในสิ่งที่เปลี่ยนแปลง',
      'water_2': 'ความรู้สึกเป็นสัญญาณ เชื่อสัญชาตญาณ ความสัมพันธ์ลึกซึ้งจะแน่นแฟ้นขึ้น',
      'water_3': 'ความคิดไหลลื่นเหมือนน้ำ งานศิลปะหรืองานสร้างสรรค์จะออกมาดีเยี่ยม',
      'water_4': 'ปัญญาและการมองการณ์ไกลจะนำพาโชคลาภ อย่าตัดสินใจตามกระแส',
      'water_5': 'ความอ่อนโยนดึงดูดใจ ความรักที่นุ่มนวลจะเบ่งบาน ระวังความอ่อนแอเกินไป',
      'water_6': 'ช่วงสงบนิ่ง เหมาะสมาธิและการวางแผนระยะยาว หลีกเลี่ยงความขัดแย้ง',
      'water_7': 'พลังงานจักรวาลหนุนนำ สิ่งที่ไหลตามธรรมชาติจะลงเอยดี วางใจในกระแส',
    };
    return map[key] ??
        'วันนี้เป็นวันที่ดี จงตั้งจิตมั่นและทำความดีด้วยความบริสุทธิ์ใจ';
  }

  // ── Lucky time by weekday ─────────────────────────────────────────
  static String _luckyTime(int weekday) {
    const times = {
      1: '09:00 – 11:00 น.',
      2: '14:00 – 16:00 น.',
      3: '07:00 – 09:00 น.',
      4: '13:00 – 15:00 น.',
      5: '11:00 – 13:00 น.',
      6: '16:00 – 18:00 น.',
      7: '08:00 – 10:00 น.',
    };
    return times[weekday] ?? '09:00 – 11:00 น.';
  }

  // ── Lucky direction by element ────────────────────────────────────
  static String _luckyDirection(ThaiElement el) {
    switch (el) {
      case ThaiElement.wood:
        return 'ทิศตะวันออก 🌿';
      case ThaiElement.fire:
        return 'ทิศใต้ 🔥';
      case ThaiElement.earth:
        return 'ทิศตะวันตกเฉียงใต้ 🌍';
      case ThaiElement.metal:
        return 'ทิศตะวันตก ⚙️';
      case ThaiElement.water:
        return 'ทิศเหนือ 💧';
    }
  }

  // ── Fortune score: how compatible is today's day with element ─────
  static int _fortuneScore(ThaiElement el, int weekday) {
    const matrix = <String, int>{
      'wood_3': 5, 'wood_4': 5,
      'fire_2': 5, 'fire_7': 5,
      'earth_6': 5, 'earth_1': 4,
      'metal_7': 5, 'metal_4': 4,
      'water_5': 5, 'water_1': 4,
    };
    return matrix['${el.name}_$weekday'] ?? 3;
  }

  // ── Public API ───────────────────────────────────────────────────
  static DailyFortune computeFortune({int? birthYear}) {
    final now = DateTime.now();
    final el = birthYear != null
        ? elementFromBirthYear(birthYear)
        : ThaiElement.earth;

    return DailyFortune(
      prediction: _prediction(el, now.weekday),
      luckyColors: luckyColorsForDay(now.weekday),
      luckyTime: _luckyTime(now.weekday),
      luckyDirection: _luckyDirection(el),
      fortuneScore: _fortuneScore(el, now.weekday),
      elementName: elementThaiName(el),
    );
  }

  /// Thai-formatted date string e.g. "พฤหัสบดีที่ 21 มีนาคม 2568"
  static String thaiDateString(DateTime date) {
    final dayNames = [
      '', 'จันทร์', 'อังคาร', 'พุธ', 'พฤหัสบดี', 'ศุกร์', 'เสาร์', 'อาทิตย์'
    ];
    final monthNames = [
      '', 'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
      'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
    ];
    final buddhistYear = date.year + 543;
    return 'วัน${dayNames[date.weekday]}ที่ ${date.day} ${monthNames[date.month]} $buddhistYear';
  }

  /// Short date e.g. "พฤหัส 21 มี.ค."
  static String shortThaiDate(DateTime date) {
    final dayNames = [
      '', 'จ.', 'อ.', 'พ.', 'พฤ.', 'ศ.', 'ส.', 'อา.'
    ];
    final monthShort = DateFormat('MMM').format(date);
    return '${dayNames[date.weekday]} ${date.day} $monthShort';
  }
}
