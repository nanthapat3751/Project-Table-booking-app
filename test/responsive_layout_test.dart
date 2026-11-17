// ทดสอบว่าหน้าที่ไม่ต้องใช้ Firebase ไม่ล้นจอ (RenderFlex overflow)
// ทั้งบนมือถือจอเล็ก จอทั่วไป แท็บเล็ต และเดสก์ท็อป
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ftf3/screens/home_screen.dart';
import 'package:ftf3/screens/menu_screen.dart';

const sizes = {
  'iPhone SE (320x568)': Size(320, 568),
  'Android ทั่วไป (360x640)': Size(360, 640),
  'iPhone 14 (390x844)': Size(390, 844),
  'แนวนอน (740x360)': Size(740, 360),
  'แท็บเล็ต (768x1024)': Size(768, 1024),
  'เดสก์ท็อป (1920x1080)': Size(1920, 1080),
};

Future<void> _setSize(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  for (final entry in sizes.entries) {
    testWidgets('หน้าหลักไม่ล้นจอ: ${entry.key}', (tester) async {
      await _setSize(tester, entry.value);
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('เลือกร้านชาบู'), findsOneWidget);

      // ร้านสุดท้ายต้องเลื่อนไปถึงได้ (เดิมล้นจอจนมองไม่เห็น)
      final lastShop = find.text(shopMenus.keys.last);
      await tester.scrollUntilVisible(
        lastShop,
        200,
        scrollable:
            find.byType(Scrollable).first, // ตัวเลื่อนทั้งหน้า (ไม่ใช่ banner)
      );
      expect(lastShop, findsOneWidget);
      expect(tester.takeException(), isNull);

      // ปิดหน้าเพื่อหยุดตัวเลื่อน banner อัตโนมัติ
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('หน้าเมนูไม่ล้นจอ (ทุกร้าน): ${entry.key}', (tester) async {
      await _setSize(tester, entry.value);
      await tester.pumpWidget(const MaterialApp(home: MenuScreen()));
      await tester.pump();
      expect(tester.takeException(), isNull);

      for (final shop in shopMenus.keys) {
        final shopTile = find.text(shop);
        await tester.scrollUntilVisible(
          shopTile,
          200,
        ); // grid สร้างการ์ดแบบ lazy
        await tester.ensureVisible(shopTile); // เลื่อนให้เห็นทั้งการ์ดก่อนกด
        await tester.pumpAndSettle();
        await tester.tap(shopTile);
        await tester.pump();
        expect(tester.takeException(), isNull, reason: 'เมนูร้าน $shop');

        // แตะชิปทีละหมวด: ต้องเลื่อนไปถึงหัวข้อหมวด และชิปนั้นต้องถูกเลือก
        final menus =
            shopMenus[shop]!['menus'] as Map<String, List<Map<String, String>>>;
        final bodyTop = tester.getTopLeft(find.byType(Divider)).dy;
        for (final c in menus.keys) {
          final chip = find.widgetWithText(ChoiceChip, c);
          await tester.ensureVisible(chip);
          await tester.pumpAndSettle();
          await tester.tap(chip);
          await tester.pumpAndSettle();
          expect(
            tester.widget<ChoiceChip>(chip).selected,
            isTrue,
            reason: 'ชิป $c ต้องถูกเลือก ($shop)',
          );
          final header = find.text('$c (${menus[c]!.length})');
          expect(header, findsOneWidget);
          final y = tester.getTopLeft(header).dy;
          expect(
            y,
            greaterThanOrEqualTo(bodyTop),
            reason: 'หัวข้อ $c ต้องอยู่ในจอ',
          );
          expect(
            y,
            lessThan(entry.value.height),
            reason: 'หัวข้อ $c ต้องอยู่ในจอ',
          );
        }
        expect(tester.takeException(), isNull);

        // เลื่อนกลับขึ้นบนสุดเอง → ชิปหมวดแรกต้องถูกเลือก (scrollspy)
        final scroll = find.byType(SingleChildScrollView).last;
        await tester.fling(scroll, const Offset(0, 20000), 5000);
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<ChoiceChip>(
                find.widgetWithText(ChoiceChip, menus.keys.first),
              )
              .selected,
          isTrue,
          reason: 'เลื่อนขึ้นบนสุดแล้วต้องไฮไลต์หมวดแรก',
        );

        // เลื่อนลงล่างสุดเอง → ชิปหมวดสุดท้ายต้องถูกเลือก
        await tester.fling(scroll, const Offset(0, -20000), 5000);
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<ChoiceChip>(
                find.widgetWithText(ChoiceChip, menus.keys.last),
              )
              .selected,
          isTrue,
          reason: 'เลื่อนลงล่างสุดแล้วต้องไฮไลต์หมวดสุดท้าย',
        );

        // กลับไปหน้าเลือกร้าน
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pump();
      }
    });
  }

  test('รูปเมนูทุกรูปที่อ้างถึงมีอยู่ใน assets', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final assets = manifest.listAssets().toSet();
    final missing = <String>{};
    for (final shop in shopMenus.values) {
      final menus = shop['menus'] as Map<String, dynamic>;
      for (final items in menus.values) {
        for (final item in items as List) {
          final path = item['image'] as String;
          if (!assets.contains(path)) missing.add(path);
        }
      }
    }
    expect(missing, isEmpty);
  });

  test('ไม่มีเมนูซ้ำ (ทั้งร้าน)', () {
    for (final entry in shopMenus.entries) {
      final menus =
          entry.value['menus'] as Map<String, List<Map<String, String>>>;
      final names = [
        for (final items in menus.values)
          for (final item in items) item['name']!,
      ];
      final dupes = {
        for (final n in names)
          if (names.where((x) => x == n).length > 1) n,
      };
      expect(dupes, isEmpty, reason: 'ร้าน ${entry.key}');
    }
  });
}
