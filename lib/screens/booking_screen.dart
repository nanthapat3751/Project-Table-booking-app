// Import packages ที่จำเป็น
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pay_screen.dart'; // หน้าชำระเงิน

// หน้าจอสำหรับจองคิวร้านชาบู
class BookingScreen extends StatefulWidget {
  final Map<String, dynamic> shopInfo; // ข้อมูลร้านที่ส่งเข้ามา
  const BookingScreen({super.key, required this.shopInfo});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late String _selectedZone; // โซนที่เลือก
  int _party = 2; // จำนวนที่นั่งเริ่มต้น
  int _queueCount = 0; // จำนวนคิวที่ต้องรอ
  DocumentSnapshot? _userQueueDoc; // เอกสารคิวของผู้ใช้ (ถ้ามี)

  @override
  void initState() {
    super.initState();
    // กำหนดโซนเริ่มต้นเป็นตัวแรกในรายการ
    _selectedZone = (widget.shopInfo['zones'] as List<String>)[0];
    _fetchQueueCount(); // ดึงจำนวนคิวทั้งหมดของร้าน
    _fetchUserQueue();  // ตรวจสอบว่าผู้ใช้มีคิวอยู่แล้วหรือไม่
  }

  // ดึงจำนวนคิวทั้งหมดของร้านจาก Firestore
  Future<void> _fetchQueueCount() async {
    final snap = await FirebaseFirestore.instance
      .collection('queues')
      .where('shopName', isEqualTo: widget.shopInfo['name'])
      .get();
    setState(() {
      _queueCount = snap.docs.length;
    });
  }

  // ตรวจสอบว่าผู้ใช้มีคิวอยู่แล้วหรือไม่
  Future<void> _fetchUserQueue() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final snap = await FirebaseFirestore.instance
      .collection('queues')
      .where('shopName', isEqualTo: widget.shopInfo['name'])
      .where('userId', isEqualTo: user.uid)
      .get();
    setState(() {
      _userQueueDoc = snap.docs.isNotEmpty ? snap.docs.first : null;
    });
  }

  // เมื่อกดปุ่ม "จองคิว" จะไปหน้าชำระเงิน
  Future<void> _bookQueue() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PayScreen(
          shopName: widget.shopInfo['name'] as String,
          partySize: _party,
          pricePerPerson: 299,
          zone: _selectedZone,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shopInfo = widget.shopInfo;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 149, 144, 248),
        foregroundColor: Colors.white,
        title: const Text('จองคิว'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // แสดงข้อมูลร้าน
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // รูปร้าน
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        shopInfo['image'] as String,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // ข้อมูลร้าน
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(shopInfo['name'] as String, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text(shopInfo['location'] as String, style: const TextStyle(fontSize: 14)),
                          Text('โทร: ${shopInfo['phone'] as String}', style: const TextStyle(fontSize: 14)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.people, color: Colors.deepPurple, size: 20),
                              const SizedBox(width: 4),
                              Text('คิวที่ต้องรอ: ', style: const TextStyle(fontSize: 14)),
                              Text('$_queueCount', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            // เลือกโซนร้าน
            Row(
              children: [
                const Text('เลือกโซนร้าน:', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _selectedZone,
                  items: (shopInfo['zones'] as List<String>).map<DropdownMenuItem<String>>((z) =>
                    DropdownMenuItem(value: z, child: Text(z))).toList(),
                  onChanged: (v) => setState(() => _selectedZone = v!),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // เลือกจำนวนเก้าอี้
            const Text('ระบุจำนวนเก้าอี้', style: TextStyle(fontSize: 16)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle, size: 40, color: Colors.red),
                  onPressed: _party > 1 ? () => setState(() => _party--) : null,
                ),
                Container(
                  width: 100,
                  alignment: Alignment.center,
                  child: Text(
                    '$_party',
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, size: 40, color: Colors.green),
                  onPressed: _party < 10 ? () => setState(() => _party++) : null,
                ),
              ],
            ),
            const SizedBox(height: 32),
            // ปุ่มจองคิว
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.event_available),
                label: const Text('จองคิว', style: TextStyle(fontSize: 20)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _bookQueue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
