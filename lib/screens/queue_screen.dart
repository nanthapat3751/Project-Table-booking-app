// Import packages ที่จำเป็น
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// สร้างหน้าจอ QueueScreen แบบ StatefulWidget
class QueueScreen extends StatefulWidget {
  const QueueScreen({super.key});

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {
  // รายการคิวของผู้ใช้
  List<Map<String, dynamic>> _items = [];

  // รายการคิวทั้งหมดในแต่ละร้าน/โซน เพื่อใช้คำนวณลำดับคิว
  List<List<QueryDocumentSnapshot>> _shopQueuesList = [];

  // สถานะโหลดข้อมูล
  bool _loading = true;

  // โหลดข้อมูลคิวของผู้ใช้จาก Firestore
  Future<void> _loadQueues() async {
    setState(() => _loading = true); // แสดงสถานะกำลังโหลด

    final uid = FirebaseAuth.instance.currentUser?.uid; // ดึง UID ผู้ใช้
    final snap = await FirebaseFirestore.instance
        .collection('queues')
        .where('userId', isEqualTo: uid) // คิวของผู้ใช้เท่านั้น
        .orderBy('createdAt') // เรียงตามเวลาที่สร้าง
        .get();

    // แปลงข้อมูลเอกสารเป็น Map
    final items = snap.docs.map((doc) {
      final d = doc.data();
      return {
        'id': doc.id,
        'shopName': d['shopName'] ?? '',
        'zone': d['zone'] ?? '',
        'partySize': d['partySize'] ?? 0,
        'createdAt': d['createdAt'],
        'date': d['createdAt'] is Timestamp
            ? (d['createdAt'] as Timestamp).toDate()
            : DateTime.now(),
      };
    }).toList();

    // ดึงคิวทั้งหมดในแต่ละร้าน/โซน เพื่อใช้คำนวณลำดับคิว
    final shopQueuesList = await Future.wait(items.map((b) async {
      final shopSnap = await FirebaseFirestore.instance
          .collection('queues')
          .where('shopName', isEqualTo: b['shopName'] as String)
          .where('zone', isEqualTo: b['zone'] as String)
          .orderBy('createdAt')
          .get();
      return shopSnap.docs;
    }).toList());

    // อัปเดต state หลังโหลดเสร็จ
    setState(() {
      _items = items;
      _shopQueuesList = shopQueuesList;
      _loading = false;
    });
  }

  // ฟังก์ชันยกเลิกคิว
  Future<void> _cancelQueue(String queueId) async {
    // แสดงกล่องยืนยันก่อนลบ
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ยืนยันการยกเลิกคิว'),
        content: const Text('คุณต้องการยกเลิกคิวนี้หรือไม่?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ไม่')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('ใช่')),
        ],
      ),
    );
    if (confirm != true) return;

    // ลบคิวจาก Firestore
    await FirebaseFirestore.instance.collection('queues').doc(queueId).delete();

    // แจ้งเตือนผู้ใช้
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ยกเลิกคิวเรียบร้อย')));

    // โหลดข้อมูลใหม่หลังลบ
    await _loadQueues();
  }

  @override
  void initState() {
    super.initState();
    _loadQueues(); // โหลดข้อมูลเมื่อเปิดหน้าจอ
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 149, 144, 248),
        foregroundColor: Colors.white,
        title: const Text('คิวของฉัน'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator()) // แสดงโหลดข้อมูล
          : _items.isEmpty
              ? const Center(child: Text('ยังไม่มีการจอง')) // ถ้าไม่มีคิว
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length,
                  itemBuilder: (context, idx) {
                    final b = _items[idx]; // ข้อมูลคิวของผู้ใช้
                    final shopQueues = _shopQueuesList[idx]; // คิวทั้งหมดในร้าน/โซนเดียวกัน
                    final myIndex = shopQueues.indexWhere((doc) => doc.id == b['id']); // หาลำดับคิวของผู้ใช้

                    return Dismissible(
                      key: Key(b['id']),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white, size: 32),
                      ),
                      confirmDismiss: (_) async {
                        await _cancelQueue(b['id']); // ยกเลิกคิวเมื่อปัด
                        return false; // ไม่ลบ widget ทันที
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text('${b['shopName']} (${b['zone']})', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('วันที่ ${b['date'].toIso8601String().substring(0,10)}'),
                              Text('จำนวนที่นั่ง ${b['partySize']}'),
                            ],
                          ),
                          trailing: myIndex == 0
                              ? Text('ถึงคิวแล้ว', style: const TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold))
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('จำนวนคิวที่ต้องรอ', style: TextStyle(fontSize: 12)),
                                    Text('$myIndex', style: const TextStyle(fontSize: 21, color: Colors.red, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadQueues, // ปุ่มรีเฟรชข้อมูล
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.refresh, color: Colors.white),
        tooltip: 'รีเฟรชข้อมูล',
      ),
    );
  }
}
