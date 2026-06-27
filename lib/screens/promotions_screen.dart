// Import packages ที่จำเป็น
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// หน้าจอสำหรับจัดการโปรโมชั่นและคูปองของผู้ใช้
class PromotionsScreen extends StatefulWidget {
  const PromotionsScreen({super.key});

  @override
  State<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends State<PromotionsScreen> {
  final TextEditingController _codeController =
      TextEditingController(); // สำหรับกรอกโค้ด
  List<Map<String, dynamic>> _userCoupons = []; // คูปองที่ผู้ใช้มี
  List<String> _usedCodes = []; // โค้ดที่เคยใช้แล้ว
  String? _error; // ข้อผิดพลาดที่จะแสดง
  bool _loading = true; // สถานะโหลดข้อมูล

  // โค้ดโปรโมชั่นที่ระบบรองรับ
  final Map<String, Map<String, dynamic>> _promoCodes = {
    'pay100': {'name': 'ส่วนลด 100 บาท', 'value': 100},
    'duo200': {'name': 'ส่วนลด 200 บาท', 'value': 200},
  };

  // ดึง UID ของผู้ใช้ที่ล็อกอิน
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _loadCoupons(); // โหลดคูปองที่มี
    _loadUsedCodes(); // โหลดโค้ดที่เคยใช้
  }

  @override
  void dispose() {
    _codeController.dispose(); // เคลียร์ controller เมื่อ widget ถูก dispose
    super.dispose();
  }

  // โหลดคูปองของผู้ใช้จาก Firestore
  Future<void> _loadCoupons() async {
    if (_uid == null) return;
    final snap =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_uid)
            .collection('coupons')
            .get();
    if (!mounted) return;
    setState(() {
      _userCoupons =
          snap.docs.map((doc) {
            final d = doc.data();
            return {
              'id': doc.id,
              'code': d['code'],
              'name': d['name'],
              'value': d['value'],
            };
          }).toList();
      _loading = false;
    });
  }

  // โหลดโค้ดที่เคยใช้แล้ว และลบโค้ดที่เกิน 30 วัน
  Future<void> _loadUsedCodes() async {
    if (_uid == null) return;
    final snap =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_uid)
            .collection('used_codes')
            .get();
    if (!mounted) return;
    setState(() {
      _usedCodes = snap.docs.map((doc) => doc.id).toList();
    });

    // ลบโค้ดที่เกิน 30 วัน
    for (var doc in snap.docs) {
      final createdAt = doc['createdAt'];
      if (createdAt is Timestamp) {
        final dt = createdAt.toDate();
        if (DateTime.now().difference(dt).inDays > 30) {
          await doc.reference.delete();
        }
      }
    }
  }

  // เพิ่มคูปองจากโค้ดที่กรอก
  Future<void> _addCoupon() async {
    final code = _codeController.text.trim().toLowerCase();

    // ตรวจสอบว่าโค้ดถูกต้อง
    if (_promoCodes.containsKey(code)) {
      // ตรวจสอบว่าเคยใช้โค้ดนี้แล้วหรือยัง
      if (_uid != null) {
        final usedDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(_uid)
                .collection('used_codes')
                .doc(code)
                .get();
        final usedVal = usedDoc.exists ? usedDoc['used'] : null;
        if (usedVal == 1 || usedVal == 0) {
          setState(() => _error = 'คุณกรอกโค้ดนี้ไปแล้ว');
          _codeController.clear();
          return;
        }
      }

      // ตรวจสอบว่ามีคูปองนี้อยู่แล้วหรือไม่
      final used = _userCoupons.any(
        (c) => (c['code'] as String).toLowerCase() == code,
      );
      if (used) {
        setState(() => _error = 'คุณกรอกโค้ดนี้ไปแล้ว');
      } else {
        final coupon = {'code': code, ..._promoCodes[code]!};
        if (_uid != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_uid)
              .collection('coupons')
              .add(coupon);

          // บันทึกว่าโค้ดนี้ถูกใช้แล้ว
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_uid)
              .collection('used_codes')
              .doc(code)
              .set({'used': 1, 'createdAt': FieldValue.serverTimestamp()});
        }
        setState(() {
          _userCoupons.add(coupon);
          _error = null;
        });
      }
    } else {
      setState(() => _error = 'โค้ดไม่ถูกต้อง');
    }
    _codeController.clear();
  }

  // ใช้คูปองและลบออกจากรายการ
  Future<void> _useCoupon(String id) async {
    if (_uid != null) {
      final coupon = _userCoupons.firstWhere(
        (c) => c['id'] == id,
        orElse: () => {},
      );
      final code = coupon['code'];

      // ลบคูปองออกจาก Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_uid)
          .collection('coupons')
          .doc(id)
          .delete();

      // บันทึกว่าโค้ดนี้ถูกใช้แล้ว (used = 0)
      if (code != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_uid)
            .collection('used_codes')
            .doc(code)
            .set({'used': 0, 'createdAt': FieldValue.serverTimestamp()});
        setState(() {
          _usedCodes.add(code);
        });
      }
    }

    // ลบคูปองออกจาก state
    setState(() {
      _userCoupons.removeWhere((c) => c['id'] == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 149, 144, 248),
        foregroundColor: Colors.white,
        title: const Text('โปรโมชั่น'),
      ),
      body:
          _loading
              ? const Center(
                child: CircularProgressIndicator(),
              ) // แสดงโหลดข้อมูล
              : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Divider(height: 32),
                  const Text(
                    'กรอกโค้ดโปรโมชั่นเพื่อรับส่วนลด',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _codeController,
                          decoration: const InputDecoration(
                            hintText: 'กรอกโค้ดที่นี่',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _addCoupon,
                        child: const Text('เพิ่ม'),
                      ),
                    ],
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Text(
                        'ส่วนลดของคุณ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${_userCoupons.length} คูปอง',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_userCoupons.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'ยังไม่มีส่วนลด',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  // แสดงรายการคูปอง
                  ..._userCoupons.map(
                    (c) => Card(
                      child: ListTile(
                        title: Text(c['name']),
                        subtitle: Text('โค้ด: ${c['code']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '-฿${c['value']}',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(
                                Icons.check_circle,
                                color: Colors.deepPurple,
                              ),
                              tooltip: 'ใช้คูปองนี้',
                              onPressed: () => _useCoupon(c['id']),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
