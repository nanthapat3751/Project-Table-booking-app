// Import packages ที่จำเป็นสำหรับการทำงานของแอป
import 'package:flutter/material.dart'; // สำหรับ UI
import 'package:firebase_core/firebase_core.dart'; // สำหรับเริ่มต้น Firebase
import 'package:firebase_auth/firebase_auth.dart'; // สำหรับการจัดการผู้ใช้ (Authentication)
import 'package:ftf3/screens/main_screen.dart'; // หน้าหลักของแอป
import 'firebase_options.dart'; // การตั้งค่า Firebase สำหรับแพลตฟอร์มต่าง ๆ
import 'screens/auth_screen.dart'; // หน้าล็อกอิน/สมัครสมาชิก

// ฟังก์ชัน main เป็นจุดเริ่มต้นของแอป
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // เตรียมระบบก่อนเริ่มต้นแอป
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // เริ่มต้น Firebase ด้วย config ที่เหมาะกับแพลตฟอร์ม
  );
  runApp(const MyApp()); // เรียกใช้งานแอปหลัก
}

// คลาสหลักของแอป
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // ซ่อนแถบ debug ด้านขวาบน
      title: 'ShabuQ', // ชื่อแอป
      theme: ThemeData(
        useMaterial3: true, // ใช้ Material Design 3
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5), // สีหลักของธีม
          brightness: Brightness.light, // โหมดสว่าง
        ),
        brightness: Brightness.light, // กำหนดให้ธีมเป็นโหมดสว่าง
      ),
      // ตรวจสอบสถานะการล็อกอินของผู้ใช้แบบเรียลไทม์
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(), // ฟังการเปลี่ยนแปลงสถานะผู้ใช้
        builder: (context, snap) {
          // ถ้ายังโหลดข้อมูลไม่เสร็จ แสดงวงกลมโหลด
          if (snap.connectionState != ConnectionState.active) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          final user = snap.data; // ดึงข้อมูลผู้ใช้
          // ถ้ายังไม่ได้ล็อกอิน แสดงหน้าล็อกอิน
          if (user == null) return const AuthScreen();
          // ถ้าล็อกอินแล้ว แสดงหน้าหลักของแอป
          return const MainTabs();
        },
      ),
      routes: {
        // สามารถเพิ่มเส้นทางไปยังหน้าต่าง ๆ ได้ที่นี่
        // '/admin_manage': (context) => const AdminManageScreen(),
      },
    );
  }
}
