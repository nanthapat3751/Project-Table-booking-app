# ShabuQ — Shabu Restaurant Queue & Table Reservation App


![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-%5E3.7.2-0175C2?logo=dart)
![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore%20%7C%20Storage-FFCA28?logo=firebase)

---


### เกี่ยวกับโปรเจกต์

**ShabuQ** เป็นแอปพลิเคชันมือถือที่พัฒนาด้วย **Flutter** และ **Firebase** สำหรับจองคิวและที่นั่งร้านชาบูในพื้นที่กำแพงแสนและนครปฐม ผู้ใช้สามารถเลือกร้าน ดูเมนูอาหาร เลือกโซนที่นั่ง ระบุจำนวนคน ชำระเงิน (พร้อมใช้คูปองส่วนลด) และติดตามลำดับคิวของตัวเองได้จากในแอป

ร้านที่มีในระบบ:

| ร้าน | โซนที่นั่ง |
|---|---|
| เฝอแฟมิลี่ ชาบู กำแพงแสน | หน้าร้าน, กลางร้าน, ห้องส่วนตัว |
| Wiyaki ชาบู&ปิ้งย่าง กำแพงแสน | หน้าร้าน, กลางร้าน |
| สุกี้ตี๋น้อย Meet and Eat นครปฐม | หน้าร้าน, กลางร้าน |

### ฟีเจอร์หลัก

- **สมัครสมาชิก / เข้าสู่ระบบ** ด้วยอีเมลและรหัสผ่าน (Firebase Authentication + `flutter_login`)
- **หน้าหลัก** มีแบนเนอร์โปรโมชั่นที่เลื่อนเองทุก 3 วินาที และรายการร้านชาบูให้เลือก
- **จองคิว** เลือกโซนที่นั่ง ระบุจำนวนคน (1–10 คน) และดูจำนวนคิวที่รออยู่ของร้าน
- **ชำระเงิน**
  - ราคา 299 บาท/คน คำนวณยอดรวม ส่วนลด และยอดสุทธิให้
  - เลือกใช้คูปองส่วนลดที่ผู้ใช้มี
  - เลือกจ่ายที่เคาน์เตอร์ หรือสแกน QR Code แล้วอัปโหลดสลิป (เก็บไว้ใน Firebase Storage)
- **คิวของฉัน** ดูคิวทั้งหมดที่จองไว้ พร้อมจำนวนคิวที่ต้องรอ (นับจากคิวในร้านและโซนเดียวกัน) ปัดซ้ายเพื่อยกเลิกคิว และกดปุ่มเพื่อรีเฟรช
- **เมนูอาหาร** ดูเมนูของแต่ละร้านแยกตามหมวดหมู่ พร้อมรูปภาพ
- **โปรโมชั่น / คูปอง** กรอกโค้ดเพื่อรับคูปอง โค้ดหนึ่งใช้ได้ครั้งเดียวต่อบัญชี
  - `pay100` — ส่วนลด 100 บาท
  - `duo200` — ส่วนลด 200 บาท
- **โปรไฟล์** แก้ไขชื่อ วันเกิด เพศ เบอร์โทร เลือกไอคอนและสีของรูปโปรไฟล์ ดูข้อกำหนดการใช้งาน/นโยบายความเป็นส่วนตัว ลบบัญชี และออกจากระบบ

### เทคโนโลยีที่ใช้

| ส่วน | เครื่องมือ |
|---|---|
| Framework | Flutter (Material 3), Dart SDK `^3.7.2` |
| Authentication | `firebase_auth` |
| Database | `cloud_firestore` |
| File storage | `firebase_storage` (เก็บรูปสลิป) |
| หน้าล็อกอิน | `flutter_login` |
| อื่น ๆ | `image_picker`, `shared_preferences`, `http`, `font_awesome_flutter`, `flutter_launcher_icons` |

### โครงสร้างโปรเจกต์

```
lib/
├── main.dart                   # จุดเริ่มต้นแอป, เริ่ม Firebase, เช็คสถานะล็อกอิน
├── firebase_options.dart       # ค่า config Firebase (สร้างโดย FlutterFire CLI)
├── models/
│   └── booking.dart            # โมเดลข้อมูลการจอง
├── services/
│   └── booking_service.dart    # ฟังก์ชันจัดการการจอง (collection bookings)
└── screens/
    ├── auth_screen.dart        # หน้าเข้าสู่ระบบ / สมัครสมาชิก
    ├── main_screen.dart        # แถบเมนูด้านล่าง 5 แท็บ
    ├── home_screen.dart        # หน้าหลัก: แบนเนอร์ + รายการร้าน
    ├── booking_screen.dart     # หน้าจองคิว: เลือกโซนและจำนวนคน
    ├── pay_screen.dart         # หน้าชำระเงิน: คูปอง, QR, อัปโหลดสลิป
    ├── queue_screen.dart       # หน้าคิวของฉัน
    ├── menu_screen.dart        # หน้าเมนูอาหารของแต่ละร้าน
    ├── promotions_screen.dart  # หน้าโปรโมชั่น / คูปอง
    └── profile_screen.dart     # หน้าโปรไฟล์ผู้ใช้
assets/
├── icon/                       # ไอคอนแอป
└── images/                     # รูปร้าน, QR Code, รูปเมนู, แบนเนอร์โปรโมชั่น
```

### โครงสร้างข้อมูลใน Firestore

| Collection | ข้อมูลที่เก็บ |
|---|---|
| `users/{uid}` | `email`, `displayName`, `birthday`, `gender`, `phone`, `avatarIcon`, `avatarColor`, `createdAt` |
| `users/{uid}/coupons` | คูปองของผู้ใช้: `code`, `name`, `value` |
| `users/{uid}/used_codes` | โค้ดโปรโมชั่นที่ผู้ใช้เคยกรอกแล้ว |
| `queues` | คิวที่จอง: `userId`, `shopName`, `zone`, `partySize`, `payMethod`, `createdAt` |
| `payments` | การชำระเงิน: `shopName`, `partySize`, `pricePerPerson`, `total`, `coupon`, `discount`, `netTotal`, `payMethod`, `slipUrl`, `createdAt` |

### ขั้นตอนการใช้งาน

```
สมัคร/ล็อกอิน → เลือกร้าน → เลือกโซนและจำนวนคน → ชำระเงิน (ใช้คูปองได้) → ดูลำดับคิวในแท็บ "คิว/ร้านที่จอง"
```

### วิธีติดตั้งและรันโปรเจกต์

**สิ่งที่ต้องมี:** Flutter SDK (Dart `^3.7.2` ขึ้นไป), Android Studio หรือ Xcode, บัญชี Firebase

1. Clone โปรเจกต์
   ```bash
   git clone <repository-url>
   cd "Table Reservation System"
   ```
2. ติดตั้ง dependencies
   ```bash
   flutter pub get
   ```
3. ตั้งค่า Firebase ของตัวเอง
   - สร้างโปรเจกต์ใน [Firebase Console](https://console.firebase.google.com/)
   - เปิดใช้ **Authentication** (Email/Password), **Cloud Firestore** และ **Storage**
   - รันคำสั่งต่อไปนี้เพื่อสร้าง `lib/firebase_options.dart` และ `google-services.json`
     ```bash
     dart pub global activate flutterfire_cli
     flutterfire configure
     ```
4. รันแอป
   ```bash
   flutter run
   ```

> **หมายเหตุ:** หน้าคิวของฉันใช้คำสั่ง query `where('userId') + orderBy('createdAt')` และ `where('shopName') + where('zone') + orderBy('createdAt')` ซึ่ง Firestore จะขอให้สร้าง **composite index** ตอนรันครั้งแรก ให้กดลิงก์ที่แสดงใน log เพื่อสร้าง index

---

### About

**ShabuQ** is a mobile app built with **Flutter** and **Firebase** for booking queues and seats at shabu (hot pot) restaurants in Kamphaeng Saen and Nakhon Pathom, Thailand. Users can pick a restaurant, browse its menu, choose a seating zone and party size, pay (with optional discount coupons), and track their position in the queue.

Restaurants in the app:

| Restaurant | Seating zones |
|---|---|
| Pho Family Shabu, Kamphaeng Saen | Front, Middle, Private room |
| Wiyaki Shabu & Grill, Kamphaeng Saen | Front, Middle |
| Suki Teenoi Meet and Eat, Nakhon Pathom | Front, Middle |

### Features

- **Sign up / Log in** with email and password (Firebase Authentication + `flutter_login`)
- **Home**: promotion banner that auto-scrolls every 3 seconds, plus a grid of restaurants
- **Queue booking**: choose a seating zone, set party size (1–10), and see how many queues are waiting at the restaurant
- **Payment**
  - 299 THB per person; shows subtotal, discount, and net total
  - Apply a discount coupon the user owns
  - Pay at the counter, or scan a QR code and upload the payment slip (stored in Firebase Storage)
- **My Queues**: list of booked queues with the number of queues ahead (counted within the same restaurant and zone); swipe left to cancel, tap the button to refresh
- **Food menu**: each restaurant's menu grouped by category, with images
- **Promotions / Coupons**: redeem a promo code to get a coupon; each code can be used once per account
  - `pay100` — 100 THB off
  - `duo200` — 200 THB off
- **Profile**: edit name, birthday, gender, and phone number; pick an avatar icon and color; view terms of use and privacy policy; delete account; log out

### Tech stack

| Area | Tools |
|---|---|
| Framework | Flutter (Material 3), Dart SDK `^3.7.2` |
| Authentication | `firebase_auth` |
| Database | `cloud_firestore` |
| File storage | `firebase_storage` (payment slips) |
| Login UI | `flutter_login` |
| Other | `image_picker`, `shared_preferences`, `http`, `font_awesome_flutter`, `flutter_launcher_icons` |

### Project structure

```
lib/
├── main.dart                   # App entry point, Firebase init, auth-state routing
├── firebase_options.dart       # Firebase config (generated by FlutterFire CLI)
├── models/
│   └── booking.dart            # Booking data model
├── services/
│   └── booking_service.dart    # Booking helpers (bookings collection)
└── screens/
    ├── auth_screen.dart        # Log in / sign up
    ├── main_screen.dart        # Bottom navigation with 5 tabs
    ├── home_screen.dart        # Home: banner + restaurant list
    ├── booking_screen.dart     # Queue booking: zone and party size
    ├── pay_screen.dart         # Payment: coupons, QR code, slip upload
    ├── queue_screen.dart       # My queues
    ├── menu_screen.dart        # Restaurant menus
    ├── promotions_screen.dart  # Promotions / coupons
    └── profile_screen.dart     # User profile
assets/
├── icon/                       # App icon
└── images/                     # Restaurant photos, QR code, menu images, promo banners
```

### Firestore data model

| Collection | Fields |
|---|---|
| `users/{uid}` | `email`, `displayName`, `birthday`, `gender`, `phone`, `avatarIcon`, `avatarColor`, `createdAt` |
| `users/{uid}/coupons` | User's coupons: `code`, `name`, `value` |
| `users/{uid}/used_codes` | Promo codes the user has already redeemed |
| `queues` | Booked queues: `userId`, `shopName`, `zone`, `partySize`, `payMethod`, `createdAt` |
| `payments` | Payments: `shopName`, `partySize`, `pricePerPerson`, `total`, `coupon`, `discount`, `netTotal`, `payMethod`, `slipUrl`, `createdAt` |

### User flow

```
Sign up / Log in → Pick a restaurant → Choose zone and party size → Pay (coupon optional) → Track position in the "Queue" tab
```

### Getting started

**Requirements:** Flutter SDK (Dart `^3.7.2` or later), Android Studio or Xcode, a Firebase account

1. Clone the repository
   ```bash
   git clone <repository-url>
   cd "Table Reservation System"
   ```
2. Install dependencies
   ```bash
   flutter pub get
   ```
3. Set up your own Firebase project
   - Create a project in the [Firebase Console](https://console.firebase.google.com/)
   - Enable **Authentication** (Email/Password), **Cloud Firestore**, and **Storage**
   - Generate `lib/firebase_options.dart` and `google-services.json`:
     ```bash
     dart pub global activate flutterfire_cli
     flutterfire configure
     ```
4. Run the app
   ```bash
   flutter run
   ```

> **Note:** The My Queues screen runs `where('userId') + orderBy('createdAt')` and `where('shopName') + where('zone') + orderBy('createdAt')` queries. Firestore will ask for **composite indexes** on first run; open the link printed in the log to create them.
