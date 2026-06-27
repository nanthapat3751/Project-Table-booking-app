// Import Firebase Firestore และ Authentication สำหรับจัดการข้อมูลและผู้ใช้
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/booking.dart'; // โมเดล Booking ที่ใช้เก็บข้อมูลการจอง

// คลาส BookingService สำหรับจัดการการจองโต๊ะ
class BookingService {
  // อ้างอิงไปยัง collection 'bookings' ใน Firestore
  final _col = FirebaseFirestore.instance.collection('bookings');

  // ตรวจสอบว่าโต๊ะถูกจองแล้วหรือยังในวันและช่วงเวลาที่กำหนด
  Future<bool> isTableTaken({
    required DateTime date,
    required String timeSlot,
    required int tableId,
  }) async {
    // แปลงวันที่ให้เป็นรูปแบบ ISO โดยไม่รวมเวลา
    final d = DateTime(date.year, date.month, date.day).toIso8601String();

    // ค้นหาเอกสารที่ตรงกับวัน, ช่วงเวลา และหมายเลขโต๊ะ
    final snap = await _col
        .where('date', isEqualTo: d)
        .where('timeSlot', isEqualTo: timeSlot)
        .where('tableId', isEqualTo: tableId)
        .limit(1) // จำกัดผลลัพธ์แค่ 1 รายการ
        .get();

    // ถ้ามีเอกสารแสดงว่าโต๊ะถูกจองแล้ว
    return snap.docs.isNotEmpty;
  }

  // สร้างการจองใหม่และบันทึกลงใน Firestore
  Future<String> create(Booking b) async {
    final data = {
      'date': DateTime(b.date.year, b.date.month, b.date.day).toIso8601String(), // แปลงวันที่
      'timeSlot': b.timeSlot,
      'tableId': b.tableId,
      'partySize': b.partySize,
      'customerName': b.customerName,
      'customerPhone': b.customerPhone,
      'userId': b.userId,
      'shopName': b.shopName,
      'zone': b.zone,
      'status': b.status,
      'queueLeft': b.queueLeft,
      'createdAt': FieldValue.serverTimestamp(), // เวลาที่สร้างโดยเซิร์ฟเวอร์
    };

    // เพิ่มข้อมูลลงใน collection และคืนค่า ID ของเอกสาร
    final doc = await _col.add(data);
    return doc.id;
  }

  // ยกเลิกการจองโดยลบเอกสารตาม ID
  Future<void> cancel(String id) async => _col.doc(id).delete();

  // ดึงรายการจองของผู้ใช้ที่ล็อกอินอยู่
  Future<List<Booking>> getMine() async {
    final uid = FirebaseAuth.instance.currentUser?.uid; // ดึง UID ของผู้ใช้
    if (uid == null) return []; // ถ้าไม่มีผู้ใช้ให้คืนค่าว่าง

    // ค้นหาการจองที่ตรงกับ UID
    final snap = await _col.where('userId', isEqualTo: uid).get();

    // แปลงข้อมูลจาก Firestore เป็น Booking objects
    final items = snap.docs.map((doc) {
      final d = doc.data();
      DateTime? created;
      final raw = d['createdAt'];

      // แปลง timestamp เป็น DateTime
      if (raw is Timestamp) created = raw.toDate();
      else if (raw is String) created = DateTime.tryParse(raw);

      return Booking(
        id: doc.id,
        date: DateTime.parse(d['date'] as String),
        timeSlot: d['timeSlot'] as String,
        tableId: d['tableId'] as int,
        partySize: d['partySize'] as int,
        customerName: d['customerName'] as String? ?? '',
        customerPhone: d['customerPhone'] as String? ?? '',
        userId: d['userId'] as String,
        shopName: d['shopName'] as String? ?? '',
        zone: d['zone'] as String? ?? '',
        status: d['status'] as String? ?? '',
        queueLeft: d['queueLeft'] is int ? d['queueLeft'] as int? : null,
        createdAt: created,
      );
    }).toList();

    // ถ้าไม่มีเวลาให้ใช้ fallback เพื่อจัดเรียง
    final fallback = DateTime.fromMillisecondsSinceEpoch(0);
    items.sort((a, b) => (b.createdAt ?? fallback).compareTo(a.createdAt ?? fallback));

    return items;
  }
}
