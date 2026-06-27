// Import packages ที่จำเป็นสำหรับการชำระเงิน
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart'; // สำหรับเลือกรูปภาพสลิป
import 'package:firebase_storage/firebase_storage.dart'; // สำหรับอัปโหลดรูปสลิป
import 'package:firebase_auth/firebase_auth.dart'; // สำหรับดึงข้อมูลผู้ใช้

// หน้าจอสำหรับชำระเงินหลังจากจองโต๊ะ
class PayScreen extends StatefulWidget {
  final String shopName; // ชื่อร้าน
  final int partySize; // จำนวนที่นั่ง
  final int pricePerPerson; // ราคาต่อคน
  final String? zone; // โซนที่เลือก

  const PayScreen({
    super.key,
    required this.shopName,
    required this.partySize,
    required this.pricePerPerson,
    this.zone,
  });

  @override
  State<PayScreen> createState() => _PayScreenState();
}

class _PayScreenState extends State<PayScreen> {
  int? selectedCouponValue; // มูลค่าส่วนลดที่เลือก
  String? selectedCouponName; // ชื่อคูปองที่เลือก
  String payMethod = 'counter'; // วิธีชำระเงิน (counter หรือ qr)
  XFile? slipFile; // ไฟล์สลิปที่อัปโหลด
  bool loading = false; // สถานะกำลังบันทึกข้อมูล
  List<Map<String, dynamic>> _userCoupons = []; // คูปองของผู้ใช้
  bool _loadingCoupons = true; // สถานะโหลดคูปอง

  // คำนวณยอดรวม
  int get total => widget.partySize * widget.pricePerPerson;
  int get discount => selectedCouponValue ?? 0;
  int get netTotal => total - discount;

  @override
  void initState() {
    super.initState();
    _loadCoupons(); // โหลดคูปองของผู้ใช้
  }

  // โหลดคูปองจาก Firestore
  Future<void> _loadCoupons() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() {
        _userCoupons = [];
        _loadingCoupons = false;
      });
      return;
    }
    final snap =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('coupons')
            .get();
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
      _loadingCoupons = false;
    });
  }

  // เลือกรูปภาพสลิปจากแกลเลอรี
  Future<void> _pickSlip() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => slipFile = file);
  }

  // บันทึกข้อมูลการชำระเงินและจองคิว
  Future<void> _submitPayment() async {
    setState(() => loading = true);
    String? slipUrl;

    // ถ้าเลือกชำระผ่าน QR และมีสลิป ให้บันทึกสลิปลง Firebase Storage
    if (payMethod == 'qr' && slipFile != null) {
      final ref = FirebaseStorage.instance.ref(
        'slips/${DateTime.now().millisecondsSinceEpoch}_${slipFile!.name}',
      );
      await ref.putData(await slipFile!.readAsBytes());
      slipUrl = await ref.getDownloadURL();
    }

    // บันทึกข้อมูลการชำระเงินลง Firestore
    await FirebaseFirestore.instance.collection('payments').add({
      'shopName': widget.shopName,
      'partySize': widget.partySize,
      'pricePerPerson': widget.pricePerPerson,
      'total': total,
      'coupon': selectedCouponName ?? '',
      'discount': discount,
      'netTotal': netTotal,
      'payMethod': payMethod,
      'slipUrl': slipUrl ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // บันทึกข้อมูลคิวหลังจากชำระเงิน
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('queues').add({
        'userId': user.uid,
        'shopName': widget.shopName,
        'zone': widget.zone ?? '',
        'partySize': widget.partySize,
        'payMethod': payMethod,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    // ลบคูปองที่ใช้แล้วออกจาก Firestore
    if (selectedCouponName != null) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      final coupon = _userCoupons.firstWhere(
        (c) => c['name'] == selectedCouponName,
        orElse: () => {},
      );
      if (uid != null && coupon['id'] != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('coupons')
            .doc(coupon['id'])
            .delete();
      }
    }

    setState(() => loading = false);

    // แสดงข้อความแจ้งเตือนและกลับหน้าก่อนหน้า
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('บันทึกข้อมูลชำระเงินเรียบร้อย')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 149, 144, 248),
        foregroundColor: Colors.white,
        title: const Text('ชำระเงิน'),
      ),
      // ถ้ากำลังโหลดข้อมูลคูปองหรือกำลังบันทึกข้อมูล ให้แสดงวงกลมโหลด
      body:
          loading || _loadingCoupons
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: ListView(
                  children: [
                    // แสดงข้อมูลร้านและราคาต่อคน
                    Card(
                      child: ListTile(
                        title: Text(
                          widget.shopName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('จำนวนคน: ${widget.partySize}'),
                        trailing: Text('฿${widget.pricePerPerson}/คน'),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // แสดงยอดรวมก่อนหักส่วนลด
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('ยอดรวม', style: TextStyle(fontSize: 16)),
                        Text(
                          '฿$total',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // เลือกคูปองส่วนลดจาก dropdown
                    DropdownButtonFormField<Map<String, dynamic>>(
                      decoration: const InputDecoration(
                        labelText: 'เลือกคูปองส่วนลด',
                      ),
                      items:
                          _userCoupons.isEmpty
                              ? [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('ไม่มีคูปองส่วนลด'),
                                ),
                              ]
                              : _userCoupons
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(
                                        '${c['name']} (฿${c['value']})',
                                      ),
                                    ),
                                  )
                                  .toList(),
                      onChanged: (c) {
                        setState(() {
                          selectedCouponValue = c?['value'] as int?;
                          selectedCouponName = c?['name'] as String?;
                        });
                      },
                      value:
                          _userCoupons.isEmpty
                              ? null
                              : _userCoupons.firstWhere(
                                (c) => c['name'] == selectedCouponName,
                                orElse: () => _userCoupons[0],
                              ),
                    ),
                    const SizedBox(height: 12),

                    // แสดงส่วนลดที่เลือก
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('ส่วนลด', style: TextStyle(fontSize: 16)),
                        Text(
                          '-฿$discount',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),

                    // แสดงยอดสุทธิหลังหักส่วนลด
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'ยอดสุทธิ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '฿$netTotal',
                          style: const TextStyle(
                            fontSize: 22,
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // เลือกวิธีชำระเงิน
                    const Text(
                      'เลือกวิธีชำระเงิน',
                      style: TextStyle(fontSize: 16),
                    ),
                    ListTile(
                      title: const Text('ชำระที่เคาน์เตอร์'),
                      leading: Radio<String>(
                        value: 'counter',
                        groupValue: payMethod,
                        onChanged: (v) => setState(() => payMethod = v!),
                      ),
                    ),
                    ListTile(
                      title: const Text('สแกน QR Code'),
                      leading: Radio<String>(
                        value: 'qr',
                        groupValue: payMethod,
                        onChanged: (v) => setState(() => payMethod = v!),
                      ),
                    ),

                    // ถ้าเลือกชำระผ่าน QR ให้แสดง QR และอัปโหลดสลิป
                    if (payMethod == 'qr') ...[
                      const SizedBox(height: 12),
                      Container(
                        height: 220,
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: Image.asset(
                          'assets/images/QR.JPG',
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 12),
                      slipFile == null
                          ? ElevatedButton.icon(
                            icon: const Icon(Icons.upload),
                            label: const Text('อัปโหลดสลิป'),
                            onPressed: _pickSlip,
                          )
                          : Column(
                            children: [
                              Image.file(File(slipFile!.path), height: 100),
                              TextButton(
                                child: const Text('เปลี่ยนสลิป'),
                                onPressed: _pickSlip,
                              ),
                            ],
                          ),
                    ],

                    const SizedBox(height: 24),

                    // ปุ่มยืนยันการชำระเงิน
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle),
                        label: const Text(
                          'ยืนยันชำระเงิน',
                          style: TextStyle(fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _submitPayment,
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
