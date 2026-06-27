// คลาส Booking ใช้แทนข้อมูลการจองโต๊ะในร้านชาบู
class Booking {
  final String id;               // รหัสการจอง (Document ID จาก Firestore)
  final DateTime date;          // วันที่จอง
  final String timeSlot;        // ช่วงเวลาที่จอง เช่น "18:00 - 19:30"
  final int tableId;            // หมายเลขโต๊ะที่จอง
  final int partySize;          // จำนวนคนที่มารับประทาน
  final String customerName;    // ชื่อลูกค้า
  final String customerPhone;   // เบอร์โทรลูกค้า
  final String userId;          // รหัสผู้ใช้ (UID จาก Firebase Authentication)
  final DateTime? createdAt;    // เวลาที่สร้างการจอง (อาจเป็น null ถ้ายังไม่ได้บันทึก)
  final String shopName;        // ชื่อร้านที่จอง
  final String zone;            // โซนที่เลือก เช่น "โซนหน้าร้าน"
  final String status;          // สถานะของการจอง เช่น waiting, active, done, cancelled
  final int? queueLeft;         // จำนวนคิวที่ต้องรอก่อนถึงคิวนี้ (อาจเป็น null ถ้ายังไม่คำนวณ)

  // Constructor สำหรับสร้าง Booking object โดยกำหนดค่าทั้งหมด
  Booking({
    required this.id,
    required this.date,
    required this.timeSlot,
    required this.tableId,
    required this.partySize,
    required this.customerName,
    required this.customerPhone,
    required this.userId,
    this.createdAt,
    required this.shopName,
    required this.zone,
    required this.status,
    this.queueLeft,
  });
}
