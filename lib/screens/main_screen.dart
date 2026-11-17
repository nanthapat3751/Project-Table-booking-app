// Import หน้าจอต่าง ๆ ที่จะใช้ใน Tab
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'menu_screen.dart';
import 'queue_screen.dart';
import 'promotions_screen.dart';
import 'profile_screen.dart';

// Widget หลักที่ใช้แสดงแถบเมนูด้านล่างและเนื้อหาของแต่ละ Tab
class MainTabs extends StatefulWidget {
  const MainTabs({super.key});

  // สลับไปแท็บที่ index (0 = หน้าหลัก) จากหน้าที่อยู่ใน MainTabs
  static void goTo(BuildContext context, int index) =>
      _MainTabsState.goTo(context, index);

  @override
  State<MainTabs> createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> {
  int _index = 0; // แท็บที่เลือกอยู่

  // ให้หน้าอื่นสั่งสลับแท็บได้ เช่น ปุ่ม "จองคิว" ในหน้าโปรโมชั่น → หน้าหลัก
  static void goTo(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_MainTabsState>();
    state?.setState(() => state._index = index);
  }

  // สร้างหน้าใหม่ทุกครั้งที่สลับแท็บ (เหมือน TabBarView เดิม)
  // เพื่อให้หน้า "คิวของฉัน" โหลดข้อมูลล่าสุดหลังจองคิว
  Widget _buildPage(int index) {
    switch (index) {
      case 1:
        return const MenuScreen(); // เมนูอาหาร
      case 2:
        return const QueueScreen(); // คิวของฉัน
      case 3:
        return const PromotionsScreen(); // ส่วนลด/โปรโมชั่น
      case 4:
        return const ProfileScreen(); // โปรไฟล์ผู้ใช้
      default:
        return const HomeScreen(); // หน้าหลัก
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // สีพื้นหลังของหน้าจอ
      body: KeyedSubtree(key: ValueKey(_index), child: _buildPage(_index)),
      // ใช้ NavigationBar (Material 3) แทน TabBar:
      // - เว้นพื้นที่ safe area ด้านล่าง (ขีด home ของ iPhone) ให้อัตโนมัติ
      // - ไม่มีการปัดซ้าย/ขวาเปลี่ยนแท็บ ซึ่งเคยชนกับการปัดยกเลิกคิว
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        // ใช้ความสูงมาตรฐาน (80) — เดิมตั้ง 68 เตี้ยไป สระล่างภาษาไทยโดนตัด
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'หน้าหลัก',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu),
            label: 'เมนู',
          ),
          NavigationDestination(
            icon: Icon(Icons.queue_outlined),
            selectedIcon: Icon(Icons.queue),
            label: 'คิวของฉัน',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_offer_outlined),
            selectedIcon: Icon(Icons.local_offer),
            label: 'ส่วนลด',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'โปรไฟล์',
          ),
        ],
      ),
    );
  }
}
