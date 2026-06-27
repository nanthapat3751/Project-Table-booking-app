// Import packages และหน้าจอที่เกี่ยวข้อง
import 'package:flutter/material.dart';
import 'booking_screen.dart';

// รายการรูปภาพโปรโมชั่นที่ใช้ใน banner
final bannerImages = [
  'assets/images/promotion/pho_promotion.jpeg',
  'assets/images/promotion/wiyaki_promotion.jpeg',
  'assets/images/promotion/teenoi_promotion.jpg',
];

// รายละเอียดร้านชาบูที่ให้ผู้ใช้เลือก
final shabuShops = [
  {
    'name': 'เฝอแฟมิลี่ ชาบู กำแพงแสน',
    'image': 'assets/images/pho.jpg',
    'location': '80 8 ตำบล กำแพงแสน อำเภอกำแพงแสน นครปฐม 73140',
    'phone': '098-819-4590',
    'zones': ['โซนหน้าร้าน', 'โซนกลางร้าน', 'โซนห้องส่วนตัว'],
  },
  {
    'name': 'Wiyaki ชาบู&ปิ้งย่าง กำแพงแสน',
    'image': 'assets/images/wiyaki.jpeg',
    'location': '127 กำแพงแสน 128 ม.2 ต.กำแพงแสน อำเภอกำแพงแสน นครปฐม 73140',
    'phone': '063-592-9293',
    'zones': ['โซนหน้าร้าน', 'โซนกลางร้าน'],
  },
  {
    'name': 'สุกี้ตี๋น้อย Meet and Eat นครปฐม',
    'image': 'assets/images/teenoi.jpg',
    'location': '161 ถนน เทศา ตำบลพระปฐมเจดีย์ อำเภอเมืองนครปฐม นครปฐม 73000',
    'phone': '083-126-7347',
    'zones': ['โซนหน้าร้าน', 'โซนกลางร้าน'],
  },
];

// หน้าหลักของแอป
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _bannerController = PageController(); // ควบคุมการเลื่อน banner
  int _bannerIndex = 0; // ตำแหน่งปัจจุบันของ banner

  @override
  void initState() {
    super.initState();
    // เริ่มเลื่อน banner อัตโนมัติหลังจาก 3 วินาที
    Future.delayed(const Duration(seconds: 3), _autoScrollBanner);
  }

  // ฟังก์ชันเลื่อน banner แบบวนลูป
  void _autoScrollBanner() {
    if (!mounted) return;
    setState(() {
      _bannerIndex = (_bannerIndex + 1) % bannerImages.length;
      _bannerController.animateToPage(
        _bannerIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
    Future.delayed(const Duration(seconds: 3), _autoScrollBanner);
  }

  @override
  Widget build(BuildContext context) {
    // สร้างรายการร้านชาบูเป็น tiles สำหรับแสดงใน Grid
    final menuTiles = shabuShops.map((shop) => _Tile(
      shop['name'] as String,
      shop['image'] as String,
      () {
        // เมื่อกดร้าน จะไปยังหน้าจองโต๊ะ พร้อมส่งข้อมูลร้านไปด้วย
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookingScreen(shopInfo: shop),
          ),
        );
      }
    )).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 149, 144, 248),
        foregroundColor: Colors.white,
        title: const Text('ShabuQ'),
      ),
      body: Column(
        children: [
          // แสดง banner โปรโมชั่นแบบเลื่อนอัตโนมัติ
          SizedBox(
            height: 160,
            child: PageView.builder(
              controller: _bannerController,
              itemCount: bannerImages.length,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    bannerImages[i],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, size: 48),
                    ),
                  ),
                ),
              ),
              onPageChanged: (i) => setState(() => _bannerIndex = i),
            ),
          ),
          const SizedBox(height: 8),
          // จุดบอกตำแหน่ง banner ปัจจุบัน
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              bannerImages.length,
              (i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == _bannerIndex ? Colors.deepPurple : Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // ข้อความหัวข้อ "เลือกร้านชาบู"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'เลือกร้านชาบู',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(height: 17),
          // แสดงร้านชาบูในรูปแบบ Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GridView.count(
              crossAxisCount: 2, // จำนวนคอลัมน์
              shrinkWrap: true, // ให้ GridView ขยายตามเนื้อหา
              physics: const NeverScrollableScrollPhysics(), // ไม่ให้ scroll ซ้อนกับ Column
              childAspectRatio: 1.0,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: menuTiles.map((tile) => _MenuCard(tile: tile)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// คลาสแทนข้อมูลแต่ละร้าน
class _Tile {
  final String title;
  final String imagePath;
  final VoidCallback onTap;
  _Tile(this.title, this.imagePath, this.onTap);
}

// การ์ดแสดงร้านชาบูพร้อมรูปภาพ
class _MenuCard extends StatelessWidget {
  final _Tile tile;
  const _MenuCard({required this.tile});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: tile.onTap, // เมื่อกดจะเรียกฟังก์ชัน onTap
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).colorScheme.surface,
          boxShadow: const [BoxShadow(blurRadius: 6, color: Colors.black12)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // แสดงรูปภาพร้าน
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  tile.imagePath,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, size: 48),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // ชื่อร้าน
            Text(tile.title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
