// ทดสอบว่าหน้าที่ไม่ต้องใช้ Firebase ไม่ล้นจอ (RenderFlex overflow)
// ทั้งบนมือถือจอเล็ก จอทั่วไป แท็บเล็ต และเดสก์ท็อป
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ftf3/screens/home_screen.dart';
import 'package:ftf3/screens/main_screen.dart';
import 'package:ftf3/screens/menu_screen.dart';
import 'package:ftf3/screens/promotions_screen.dart';

// สร้างหน้าโปรโมชั่น (ส่วนหน้าตา) พร้อมตัวนับว่ากดอะไรไปบ้าง
class _PromoHarness {
  final controller = TextEditingController();
  final submitted = <String?>[];
  final openedShops = <int>[];
  int bookTaps = 0;

  Widget build(List<Map<String, dynamic>> coupons, List<String> suggested) {
    return MaterialApp(
      home: Scaffold(
        body: PromotionsView(
          coupons: coupons,
          suggestedCodes: suggested,
          codeController: controller,
          error: null,
          claiming: false,
          onSubmitCode: ([code]) => submitted.add(code),
          onClearError: () {},
          onOpenShop: openedShops.add,
          onBook: () => bookTaps++,
        ),
      ),
    );
  }
}

const sizes = {
  'Galaxy Fold (280x653)': Size(280, 653),
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

  for (final entry in sizes.entries) {
    testWidgets('หน้าโปรโมชั่น (ยังไม่มีคูปอง) ไม่ล้นจอ: ${entry.key}', (
      tester,
    ) async {
      await _setSize(tester, entry.value);
      final h = _PromoHarness();
      await tester.pumpWidget(h.build([], ['pay100', 'duo200']));
      await tester.pump();
      expect(tester.takeException(), isNull);

      // หน้าว่างต้องแสดงโค้ดแนะนำ แตะแล้วต้องส่งโค้ดนั้นไปรับคูปอง
      final chip = find.widgetWithText(ActionChip, 'PAY100');
      await tester.scrollUntilVisible(
        chip,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('ยังไม่มีคูปอง'), findsOneWidget);
      await tester.ensureVisible(chip); // ให้เห็นทั้งชิปก่อนแตะ
      await tester.pumpAndSettle();
      await tester.tap(chip);
      expect(h.submitted, ['pay100']);

      // แตะแบนเนอร์โปรร้านแรก → เปิดร้าน index 0
      await tester.scrollUntilVisible(
        find.text(shabuShops.first['name'] as String),
        -200,
        scrollable: find.byType(Scrollable).first,
      );
      final shopName = find.text(shabuShops.first['name'] as String);
      await tester.ensureVisible(shopName); // ให้เห็นทั้งแบนเนอร์ก่อนแตะ
      await tester.pumpAndSettle();
      await tester.tap(shopName);
      expect(h.openedShops, [0]);
      expect(tester.takeException(), isNull);
    });

    testWidgets('หน้าโปรโมชั่น (มีคูปอง) ไม่ล้นจอ: ${entry.key}', (
      tester,
    ) async {
      await _setSize(tester, entry.value);
      final h = _PromoHarness();
      await tester.pumpWidget(
        h.build([
          {'id': 'a', 'code': 'pay100', 'name': 'ส่วนลด 100 บาท', 'value': 100},
          {'id': 'b', 'code': 'duo200', 'name': 'ส่วนลด 200 บาท', 'value': 200},
        ], []),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(
        find.text('คูปองของฉัน (2)'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      // ปุ่มบนคูปองต้องพาไปจองคิว ไม่ใช่ลบคูปอง
      final book = find.widgetWithText(TextButton, 'จองคิว').first;
      await tester.scrollUntilVisible(
        book,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(book);
      expect(h.bookTaps, 1);
      expect(find.text('ส่วนลด 100 บาท'), findsOneWidget); // คูปองยังอยู่
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('MainTabs.goTo สลับแท็บได้ และแถบล่างไม่ล้นจอเล็ก', (
    tester,
  ) async {
    await _setSize(tester, const Size(320, 568));
    await tester.pumpWidget(const MaterialApp(home: MainTabs()));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(HomeScreen), findsOneWidget);

    MainTabs.goTo(tester.element(find.byType(HomeScreen)), 1);
    await tester.pump();
    expect(find.byType(MenuScreen), findsOneWidget);
    expect(tester.takeException(), isNull);

    // รอให้ตัวเลื่อน banner ของหน้าหลักหมดเวลา (หน้าหลักถูกปิดไปแล้ว)
    await tester.pump(const Duration(seconds: 4));
  });

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
