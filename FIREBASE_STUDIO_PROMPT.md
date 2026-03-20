# 🪷 DHAMMA+ Firebase Studio Prompt

## วิธีใช้
Copy ข้อความด้านล่างทั้งหมด แล้ว paste ใน Firebase Studio App Prototyping Agent

---

## PROMPT สำหรับ Firebase Studio:

```
Build a Thai Buddhist spiritual companion web app called "ธรรมะ+" (Dhamma+).

## App Overview
A premium spiritual wellness app combining Thai Buddhist practices with AI personalization. The app should feel like a luxury spiritual companion — calm, beautiful, gold-and-deep-purple aesthetic.

## Design System
- Colors: Deep purple/navy (#0F0A1E) background, Gold (#C8912E, #E8B84B) accents, Cream (#FAF6EE) surfaces
- Typography: Noto Serif Thai for headings, Sarabun for body
- Feel: Luxury, calm, sacred — like a digital temple

## Core Screens to Build

### 1. Splash Screen
- Dark gradient background (deep purple to navy)
- Large lotus emoji 🪷 with gold glow animation (floating)
- App name "ธรรมะ+" in gold Noto Serif Thai
- Subtitle "ยินดีต้อนรับกลับบ้าน" in white
- Auto-navigate to onboarding after 3 seconds

### 2. Onboarding Screen
- Dark background with progress dots (4 steps)
- Step 1: "แอปนี้จะช่วยคุณได้ยังไง?" - name input + goal selection grid (6 goals: เริ่มวันดีๆ, หาบทสวด, ติดตามการขอพร, เช็คดวง, ทำบุญ, ท่องเที่ยววัด)
- Step 2: Birth date input → shows day of week + lucky element
- Beautiful animated transitions between steps

### 3. Daily Check-in Screen (shown every morning)
- Dark gradient background
- Greeting: "สวัสดีตอนเช้า [name]"
- Question: "วันนี้รู้สึกยังไงก่อนออกจากบ้าน?"
- 5 mood buttons: 😟กังวล, 😴เหนื่อย, 😐ปกติ, 😊สบายดี, 🌟ดีมาก
- When mood selected → AI recommendation card appears with:
  - Pulsing dot "AI แนะนำสำหรับวันนี้"
  - Message about today's energy + warning (e.g. "วันนี้มีเกณฑ์ปากเสียง หยุดคิดก่อนพูด")
  - Prayer recommendation card with name + duration
- Today's banner: lucky colors chips + daily prediction text
- "เข้าสู่วันนี้ →" gold button at bottom

### 4. Home Screen
- Dark header with gradient (deep purple)
- Greeting + user name + 🔥 streak badge (e.g. "🔥 12 วัน")
- Today's fortune card (expandable, shows prediction + colors)
- 3-column menu grid: บทสวด (purple), ขอพร (green), เช็คดวง (gold)
- Vow mini-dashboard: 3 stats (pending/urgent/done) + smart notification card
  - Notification: "ผ่านมา 1 สัปดาห์แล้ว — พรที่ขอเรื่องงาน เป็นยังไงบ้าง?"
  - Action button: "อัปเดตสถานะ →"
- Bottom navigation: 🏠หน้าหลัก 📿บทสวด 📍ขอพร ✨ดวง 💚บริจาค

### 5. Vow Tracker Screen
- Dark green header gradient
- Stats row: pending/urgent/done counts
- Smart notification cards (red urgent, yellow 7-day reminder)
- Filter tabs: ทั้งหมด / ⏳รอผล / 🔴ต้องแก้บน / ✅สำเร็จ
- Vow cards with colored left border (gold=pending, red=urgent, green=done)
  - Temple name, prayer text, status pill, date, action button
- Floating + button to add new vow

### 6. Add Vow Screen
- Form: temple name (with search), prayer text, fulfillment promise, reminder date
- Beautiful form on dark background

### 7. Fortune Screen  
- Dark background
- Free: daily lucky colors (chips with color dots)
- Free: daily prediction card
- Premium locked: directions grid (4 directions with stars), time slots
- Premium lock: blurred card with "สมัคร Premium ฿199/เดือน" button

### 8. Prayer Screen
- AI analyzer card: time chips (5/15/30/60 min), goal chips, mood chips
- "ให้ AI แนะนำบทสวด" button
- Prayer cards: icon, name, description, tags, duration

## Firebase Integration
- Firebase Authentication (email + Google)
- Cloud Firestore for vows, user profiles, donations
- Firebase Messaging for push notifications

## Data Structure (Firestore)
users/{userId}: { name, birthDate, goals[], streakDays, lastCheckin, subscriptionTier }
vows/{vowId}: { userId, templeName, prayerText, fulfillment, status, createdAt, reminderDate }
checkins/{checkinId}: { userId, date, mood, prayerRecommended }
donations/{donationId}: { userId, orgName, amount, date, type }

## Key UX Principles
1. Every notification feels like a caring friend, never pushy
2. Dark elegant aesthetic throughout
3. Gold accents for premium/important elements
4. Smooth animations on all transitions
5. Thai language throughout

Build this as a Next.js app with Tailwind CSS. Use Firebase for backend.
Make it beautiful, production-quality, and fully functional.
```

---

## หลังจาก paste แล้ว

Firebase Studio จะสร้างแอปให้อัตโนมัติ
รอประมาณ 2-3 นาที แล้ว preview จะขึ้นมา
แก้ไขได้โดย prompt ต่อไปเรื่อยๆ ครับ

## ถ้าอยากเพิ่ม feature

พิมพ์ต่อใน chat เช่น:
- "Add a daily streak system with fire emoji"
- "Make the notification cards more beautiful"  
- "Add smooth page transitions"
- "Connect to Claude API for AI recommendations"
