// Import packages ที่จำเป็น
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'booking_screen.dart';
import 'home_screen.dart' show bannerImages, shabuShops;
import 'main_screen.dart';

// โค้ดโปรโมชั่นที่ระบบรองรับ
const promoCodes = <String, Map<String, dynamic>>{
  'pay100': {'name': 'ส่วนลด 100 บาท', 'value': 100},
  'duo200': {'name': 'ส่วนลด 200 บาท', 'value': 200},
};

// หน้าจอสำหรับจัดการโปรโมชั่นและคูปองของผู้ใช้ (ส่วนข้อมูล/Firebase)
class PromotionsScreen extends StatefulWidget {
  const PromotionsScreen({super.key});

  @override
  State<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends State<PromotionsScreen> {
  final TextEditingController _codeController =
      TextEditingController(); // สำหรับกรอกโค้ด
  List<Map<String, dynamic>> _userCoupons = []; // คูปองที่ผู้ใช้มี
  List<String> _usedCodes = []; // โค้ดที่เคยรับไปแล้ว
  String? _error; // ข้อผิดพลาดที่จะแสดง
  bool _loading = true; // สถานะโหลดข้อมูล
  bool _claiming = false; // กำลังบันทึกคูปอง

  // ดึง UID ของผู้ใช้ที่ล็อกอิน
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _loadCoupons(); // โหลดคูปองที่มี
    _loadUsedCodes(); // โหลดโค้ดที่เคยรับ
  }

  @override
  void dispose() {
    _codeController.dispose(); // เคลียร์ controller เมื่อ widget ถูก dispose
    super.dispose();
  }

  // โหลดคูปองของผู้ใช้จาก Firestore
  Future<void> _loadCoupons() async {
    if (_uid == null) {
      setState(() => _loading = false);
      return;
    }
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

  // โหลดโค้ดที่เคยรับแล้ว และลบโค้ดที่เกิน 30 วัน
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

  // โค้ดแนะนำ = โค้ดที่ระบบมี แต่ผู้ใช้ยังไม่เคยรับ
  List<String> get _suggestedCodes =>
      promoCodes.keys
          .where(
            (code) =>
                !_usedCodes.contains(code) &&
                !_userCoupons.any((c) => c['code'] == code),
          )
          .toList();

  // รับคูปองจากโค้ดที่กรอก (หรือโค้ดแนะนำที่แตะ)
  Future<void> _addCoupon([String? tappedCode]) async {
    final code = (tappedCode ?? _codeController.text).trim().toLowerCase();
    if (code.isEmpty) {
      setState(() => _error = 'กรอกโค้ดก่อน');
      return;
    }
    if (!promoCodes.containsKey(code)) {
      setState(() => _error = 'โค้ดไม่ถูกต้อง');
      return;
    }
    if (_userCoupons.any((c) => (c['code'] as String).toLowerCase() == code)) {
      setState(() => _error = 'คุณมีคูปองนี้อยู่แล้ว');
      return;
    }

    setState(() {
      _claiming = true;
      _error = null;
    });
    try {
      if (_uid != null) {
        // ตรวจสอบว่าเคยรับโค้ดนี้แล้วหรือยัง
        final usedDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(_uid)
                .collection('used_codes')
                .doc(code)
                .get();
        if (usedDoc.exists) {
          if (!mounted) return;
          setState(() {
            _error = 'คุณเคยรับโค้ดนี้ไปแล้ว';
            _claiming = false;
          });
          return;
        }
      }

      final Map<String, dynamic> coupon = {'code': code, ...promoCodes[code]!};
      if (_uid != null) {
        final ref = await FirebaseFirestore.instance
            .collection('users')
            .doc(_uid)
            .collection('coupons')
            .add(coupon);
        coupon['id'] = ref.id;

        // บันทึกว่าโค้ดนี้ถูกรับแล้ว (รับซ้ำไม่ได้)
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_uid)
            .collection('used_codes')
            .doc(code)
            .set({'used': 1, 'createdAt': FieldValue.serverTimestamp()});
      }
      if (!mounted) return;
      setState(() {
        _userCoupons.add(coupon);
        _usedCodes.add(code);
        _claiming = false;
      });
      _codeController.clear();
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ได้รับคูปอง${coupon['name']}แล้ว')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'รับคูปองไม่สำเร็จ ลองใหม่อีกครั้ง';
        _claiming = false;
      });
    }
  }

  // แตะแบนเนอร์โปรร้าน → ไปหน้าจองคิวของร้านนั้น
  void _openShop(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingScreen(shopInfo: shabuShops[index]),
      ),
    );
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
              ? const Center(child: CircularProgressIndicator())
              : PromotionsView(
                coupons: _userCoupons,
                suggestedCodes: _suggestedCodes,
                codeController: _codeController,
                error: _error,
                claiming: _claiming,
                onSubmitCode: _addCoupon,
                onClearError: () {
                  if (_error != null) setState(() => _error = null);
                },
                onOpenShop: _openShop,
                // คูปองใช้ได้ตอนชำระเงิน → พาไปหน้าหลักเพื่อเลือกร้านและจองคิว
                // (เดิมปุ่ม ✓ ลบคูปองทิ้งโดยไม่ได้ส่วนลด)
                onBook: () => MainTabs.goTo(context, 0),
              ),
    );
  }
}

// หน้าตาของหน้าโปรโมชั่น (ไม่ยุ่งกับ Firebase จึงเทสต์เลย์เอาต์ได้)
class PromotionsView extends StatelessWidget {
  final List<Map<String, dynamic>> coupons;
  final List<String> suggestedCodes;
  final TextEditingController codeController;
  final String? error;
  final bool claiming;
  final void Function([String? code]) onSubmitCode;
  final VoidCallback onClearError;
  final void Function(int shopIndex) onOpenShop;
  final VoidCallback onBook;

  const PromotionsView({
    super.key,
    required this.coupons,
    required this.suggestedCodes,
    required this.codeController,
    required this.error,
    required this.claiming,
    required this.onSubmitCode,
    required this.onClearError,
    required this.onOpenShop,
    required this.onBook,
  });

  static const _heading = TextStyle(fontSize: 17, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        // จำกัดความกว้างบนจอใหญ่ บนมือถือใช้เต็มจอ
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _buildCodeInput(context),
            const SizedBox(height: 24),
            const Text('โปรจากร้าน', style: _heading),
            const SizedBox(height: 10),
            _buildShopPromos(context),
            const SizedBox(height: 24),
            Text('คูปองของฉัน (${coupons.length})', style: _heading),
            const SizedBox(height: 10),
            if (coupons.isEmpty)
              _buildEmptyState()
            else
              for (final c in coupons)
                _CouponTicket(
                  name: (c['name'] ?? '') as String,
                  code: (c['code'] ?? '') as String,
                  value: (c['value'] ?? 0) as num,
                  onBook: onBook,
                ),
          ],
        ),
      ),
    );
  }

  // ช่องกรอกโค้ด
  Widget _buildCodeInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'มีโค้ดส่วนลด?',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: codeController,
                  textCapitalization: TextCapitalization.characters,
                  textInputAction: TextInputAction.done,
                  onChanged: (_) => onClearError(),
                  onSubmitted: (_) => onSubmitCode(),
                  decoration: InputDecoration(
                    hintText: 'กรอกโค้ด',
                    prefixIcon: const Icon(Icons.confirmation_number_outlined),
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: claiming ? null : () => onSubmitCode(),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                child:
                    claiming
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text('รับคูปอง'),
              ),
            ],
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(error!, style: const TextStyle(color: Colors.red)),
            ),
        ],
      ),
    );
  }

  // แบนเนอร์โปรของแต่ละร้าน เลื่อนแนวนอน แตะแล้วไปจองคิวร้านนั้น
  Widget _buildShopPromos(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;
    final cardW = (screenW * 0.72).clamp(220.0, 300.0);
    final count =
        bannerImages.length < shabuShops.length
            ? bannerImages.length
            : shabuShops.length;
    return SizedBox(
      height: cardW * 0.5 + 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder:
            (context, i) => SizedBox(
              width: cardW,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onOpenShop(i),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        bannerImages[i],
                        width: cardW,
                        height: cardW * 0.5,
                        fit: BoxFit.cover,
                        cacheWidth: 600,
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              width: cardW,
                              height: cardW * 0.5,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image_not_supported),
                            ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      shabuShops[i]['name'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  // ตอนยังไม่มีคูปอง: ไอคอน + คำอธิบาย + โค้ดแนะนำให้แตะรับ
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.deepPurple.shade50,
            child: const Icon(
              Icons.confirmation_number_outlined,
              size: 30,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'ยังไม่มีคูปอง',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            suggestedCodes.isEmpty
                ? 'กรอกโค้ดด้านบนเพื่อรับคูปองส่วนลด'
                : 'กรอกโค้ดด้านบน หรือแตะโค้ดแนะนำเพื่อรับเลย',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700),
          ),
          if (suggestedCodes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                for (final code in suggestedCodes)
                  ActionChip(
                    avatar: const Icon(Icons.add, size: 18),
                    label: Text(code.toUpperCase()),
                    onPressed: claiming ? null : () => onSubmitCode(code),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// คูปองทรงตั๋ว: ด้านซ้ายเป็นมูลค่า ด้านขวาเป็นรายละเอียด คั่นด้วยเส้นประ
class _CouponTicket extends StatelessWidget {
  final String name;
  final String code;
  final num value;
  final VoidCallback onBook;

  const _CouponTicket({
    required this.name,
    required this.code,
    required this.value,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.deepPurple.shade100),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // มูลค่าส่วนลด
            Container(
              width: 92,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(14),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    child: Text(
                      '฿$value',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                  Text(
                    'ส่วนลด',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.deepPurple.shade300,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 1,
              child: CustomPaint(painter: _DashPainter()),
            ),
            // รายละเอียด
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 4, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'โค้ด ${code.toUpperCase()}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'เลือกใช้ได้ตอนชำระเงิน',
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: onBook,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.deepPurple,
                            visualDensity: VisualDensity.compact,
                          ),
                          child: const Text('จองคิว'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// เส้นประแนวตั้งระหว่างสองฝั่งของตั๋ว
class _DashPainter extends CustomPainter {
  const _DashPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.deepPurple.shade100
          ..strokeWidth = 1.5;
    const dash = 5.0, gap = 4.0;
    for (double y = 4; y < size.height - 4; y += dash + gap) {
      canvas.drawLine(Offset(0.5, y), Offset(0.5, y + dash), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
