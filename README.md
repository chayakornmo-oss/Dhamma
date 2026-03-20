# 🪷 ธรรมะ+ (Dhamma+) — Setup Guide

## วิธีเริ่มต้นเร็วที่สุด (Firebase Studio)

### ขั้นตอนที่ 1 — เปิด Firebase Studio
1. เปิด Chrome บน ROG
2. ไปที่ **studio.firebase.google.com**
3. Sign in with Google
4. กด "New Project" หรือ "Start with App Prototyping"

### ขั้นตอนที่ 2 — Paste Prompt
1. เปิดไฟล์ `FIREBASE_STUDIO_PROMPT.md`
2. Copy ข้อความทั้งหมดใน section "PROMPT สำหรับ Firebase Studio"
3. Paste ใน Firebase Studio chat box
4. กด Enter รอ 2-3 นาที

### ขั้นตอนที่ 3 — ดู Preview
- Firebase Studio จะแสดง preview ทางขวา
- กด Preview เพื่อดูแอปจริงๆ
- แก้ไขได้โดยพิมพ์ต่อใน chat

---

## วิธีเริ่มต้นแบบ Flutter (สำหรับ native app)

### Prerequisites
```bash
# 1. ติดตั้ง Flutter
# ไปที่ flutter.dev แล้วดาวน์โหลด Flutter SDK

# 2. ตรวจสอบ
flutter doctor

# 3. ติดตั้ง dependencies
flutter pub get

# 4. รัน app
flutter run
```

### Firebase Setup
1. ไปที่ **console.firebase.google.com**
2. สร้าง project ใหม่ชื่อ "dhamma-plus"
3. เพิ่ม Android app + iOS app
4. ดาวน์โหลด `google-services.json` → วางใน `android/app/`
5. ดาวน์โหลด `GoogleService-Info.plist` → วางใน `ios/Runner/`

---

## Project Structure

```
dhamma_plus/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── router/
│   │   └── app_router.dart          # Navigation
│   ├── theme/
│   │   └── dhamma_theme.dart        # Colors, typography
│   ├── screens/
│   │   ├── splash_screen.dart       # ✅ Done
│   │   ├── main_shell.dart          # ✅ Done (bottom nav)
│   │   ├── onboarding/
│   │   │   ├── onboarding_screen.dart  # ✅ Done
│   │   │   └── birth_date_screen.dart  # 🔄 TODO
│   │   ├── checkin/
│   │   │   └── daily_checkin_screen.dart  # ✅ Done
│   │   ├── home/
│   │   │   └── home_screen.dart    # 🔄 TODO
│   │   ├── vow/
│   │   │   ├── vow_tracker_screen.dart  # ✅ Done
│   │   │   └── add_vow_screen.dart      # 🔄 TODO
│   │   ├── fortune/
│   │   │   └── fortune_screen.dart  # 🔄 TODO
│   │   ├── prayer/
│   │   │   ├── prayer_screen.dart   # 🔄 TODO
│   │   │   └── prayer_detail_screen.dart  # 🔄 TODO
│   │   ├── donation/
│   │   │   └── donation_screen.dart  # 🔄 TODO
│   │   └── profile/
│   │       └── profile_screen.dart  # 🔄 TODO
│   ├── models/
│   │   └── vow_model.dart           # ✅ Done
│   └── services/
│       ├── ai_service.dart          # ✅ Done
│       └── notification_service.dart  # ✅ Done
├── pubspec.yaml                     # ✅ Done
└── FIREBASE_STUDIO_PROMPT.md        # ✅ Done
```

---

## Claude API Backend (Node.js)

สร้าง backend ง่ายๆ สำหรับ AI features:

```javascript
// server.js
const express = require('express');
const Anthropic = require('@anthropic-ai/sdk');

const app = express();
const client = new Anthropic({ apiKey: process.env.CLAUDE_API_KEY });

app.post('/api/ai/recommend-prayer', async (req, res) => {
  const { mood, day, hour } = req.body;
  
  const dayNames = ['', 'จันทร์', 'อังคาร', 'พุธ', 'พฤหัส', 'ศุกร์', 'เสาร์', 'อาทิตย์'];
  
  const message = await client.messages.create({
    model: 'claude-sonnet-4-20250514',
    max_tokens: 300,
    messages: [{
      role: 'user',
      content: `คุณเป็น AI ที่เชี่ยวชาญด้านพุทธศาสนาและการทำนายตามโหราศาสตร์ไทย
      
      วันนี้: วัน${dayNames[day]}, เวลา ${hour}:00
      ความรู้สึกของผู้ใช้: ${mood}
      
      กรุณาแนะนำ:
      1. ข้อความสั้นๆ เกี่ยวกับพลังงานวันนี้และคำเตือน (2-3 ประโยค)
      2. ชื่อบทสวดที่เหมาะสม
      3. ระยะเวลาและเหตุผล
      
      ตอบเป็น JSON: {"message": "...", "prayer": "...", "duration": "..."}`
    }]
  });
  
  try {
    const text = message.content[0].text;
    const json = JSON.parse(text.replace(/```json\n?|\n?```/g, ''));
    res.json(json);
  } catch {
    res.json({
      message: 'วันนี้เป็นวันที่ดี จงเริ่มต้นด้วยความตั้งใจที่บริสุทธิ์',
      prayer: 'อิติปิโส ภควา',
      duration: '⏱ 5 นาที'
    });
  }
});

app.listen(3000, () => console.log('AI Backend running on port 3000'));
```

---

## Next Steps

1. **วันนี้** → เปิด Firebase Studio แล้ว paste prompt
2. **พรุ่งนี้** → แก้ไข UI ให้ตรงกับ design
3. **สัปดาห์นี้** → เชื่อม Firebase Auth + Firestore
4. **เดือนนี้** → deploy + test กับ user จริง 10 คน
5. **เดือนหน้า** → Corporate Admin dashboard

---

## Questions?

บอก Claude ได้เลย — พร้อม build ต่อทุกขั้นตอน 🙏
