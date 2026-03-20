# 🔧 วิธีแก้ไข Error ทั้งหมด

## ขั้นตอนที่ 1 — แทนที่ไฟล์ใน VS Code

Copy ไฟล์จาก folder นี้ไปแทนที่ใน project ของคุณ:

```
dhamma_fixed/
├── pubspec.yaml  
│   → แทนที่ C:\Users\chaya\Downloads\files\pubspec.yaml
│
├── lib/screens/checkin/daily_checkin_screen.dart
│   → แทนที่ไฟล์เดิม
│
├── lib/screens/vow/vow_tracker_screen.dart  
│   → แทนที่ไฟล์เดิม
│
└── lib/services/ai_service.dart
    → แทนที่ไฟล์เดิม
```

## ขั้นตอนที่ 2 — แก้ไฟล์อื่นๆ ที่ Antigravity สร้าง

เปิดไฟล์เหล่านี้แล้วเพิ่ม imports ด้านบน:

### ทุกไฟล์ที่มี error GoogleFonts ให้เพิ่ม:
```dart
import 'package:google_fonts/google_fonts.dart';
```

### ทุกไฟล์ที่มี error .animate() ให้เพิ่ม:
```dart
import 'package:flutter_animate/flutter_animate.dart';
```

### ไฟล์ที่มีทั้งคู่ ให้เพิ่มทั้ง 2 บรรทัด

## ขั้นตอนที่ 3 — รันใหม่

```bash
flutter pub upgrade
flutter run -d chrome
```

## สาเหตุของ Error

1. **GoogleFonts not found** = ขาด `import 'package:google_fonts/google_fonts.dart';`
2. **.animate() not found** = ขาด `import 'package:flutter_animate/flutter_animate.dart';`  
3. **Firebase version error** = pubspec.yaml ใช้ Firebase เวอร์ชันเก่าเกินไป → แก้ด้วย pubspec.yaml ใหม่
4. **http.post not found** = ai_service.dart ใช้ http package ไม่ถูกต้อง → แก้ด้วยไฟล์ใหม่
