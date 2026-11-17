// ทดสอบหน้าแนะนำแอป + หน้าล็อกอิน/สมัครสมาชิก (ไม่ต้องใช้ Firebase จริง)
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ftf3/screens/auth_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const sizes = {
  'Galaxy Fold (280x653)': Size(280, 653),
  'iPhone SE (320x568)': Size(320, 568),
  'Android ทั่วไป (360x640)': Size(360, 640),
  'iPhone 14 (390x844)': Size(390, 844),
  'แนวนอน (740x360)': Size(740, 360),
  'แท็บเล็ต (768x1024)': Size(768, 1024),
  'เดสก์ท็อป (1920x1080)': Size(1920, 1080),
};

void _setSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

// ไอน้ำวนตลอด ใช้ pumpAndSettle ไม่ได้ จึงเดินเวลาไปทีละช่วงแทน
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

class _Calls {
  final logins = <List<String>>[];
  final signups = <List<String>>[];
  final resets = <String>[];
  String? result; // ค่าที่ callback จะคืน (null = สำเร็จ)

  Widget build() => MaterialApp(
    home: AuthView(
      onLogin: (e, p) async {
        logins.add([e, p]);
        return result;
      },
      onSignup: (e, p) async {
        signups.add([e, p]);
        return result;
      },
      onResetPassword: (e) async {
        resets.add(e);
        return result;
      },
    ),
  );
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await _settle(tester);
  await tester.tap(finder);
  await _settle(tester);
}

void main() {
  for (final entry in sizes.entries) {
    testWidgets('เปิดครั้งแรก: สไลด์แนะนำ → ล็อกอิน ไม่ล้นจอ: ${entry.key}', (
      tester,
    ) async {
      _setSize(tester, entry.value);
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(const MaterialApp(home: AuthScreen()));
      await _settle(tester);
      expect(tester.takeException(), isNull);

      expect(find.text('เลือกร้านชาบูใกล้คุณ'), findsOneWidget);
      await tester.tap(find.text('ถัดไป'));
      await _settle(tester);
      expect(find.text('จองคิวล่วงหน้า'), findsOneWidget);
      await tester.tap(find.text('ถัดไป'));
      await _settle(tester);
      expect(find.text('รู้ว่าอีกกี่คิวถึงตา'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('เริ่มต้นใช้งาน'));
      await _settle(tester);
      expect(find.text('ยินดีต้อนรับกลับ'), findsOneWidget);
      expect(tester.takeException(), isNull);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(AuthScreen.introSeenKey), isTrue);
    });

    testWidgets('หน้าล็อกอิน/สมัคร ไม่ล้นจอ: ${entry.key}', (tester) async {
      _setSize(tester, entry.value);
      final calls = _Calls();
      await tester.pumpWidget(calls.build());
      await _settle(tester);
      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('auth-confirm')), findsNothing);

      // สลับไปสมัครสมาชิก → ช่องยืนยันรหัสผ่านโผล่มา
      await _tapVisible(tester, find.text('สมัครสมาชิก'));
      expect(find.text('สร้างบัญชีใหม่'), findsOneWidget);
      expect(find.byKey(const Key('auth-confirm')), findsOneWidget);
      expect(tester.takeException(), isNull);

      // แสดง error แล้วก็ต้องไม่ล้นจอ
      await _tapVisible(tester, find.text('สร้างบัญชี'));
      expect(find.text('กรุณากรอกอีเมล'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('เคยดูสไลด์แล้ว → เข้าหน้าล็อกอินเลย', (tester) async {
    SharedPreferences.setMockInitialValues({AuthScreen.introSeenKey: true});
    await tester.pumpWidget(const MaterialApp(home: AuthScreen()));
    await _settle(tester);
    expect(find.text('ยินดีต้อนรับกลับ'), findsOneWidget);
    expect(find.text('ถัดไป'), findsNothing);
  });

  testWidgets('กด "ข้าม" ในสไลด์ → เข้าหน้าล็อกอิน', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: AuthScreen()));
    await _settle(tester);
    await tester.tap(find.text('ข้าม'));
    await _settle(tester);
    expect(find.text('ยินดีต้อนรับกลับ'), findsOneWidget);
  });

  testWidgets('ล็อกอิน: ตรวจช่องกรอก ส่งอีเมลที่ตัดช่องว่าง และแสดง error', (
    tester,
  ) async {
    final calls = _Calls();
    await tester.pumpWidget(calls.build());
    await _settle(tester);

    await tester.enterText(find.byKey(const Key('auth-email')), 'abc');
    await _tapVisible(tester, find.widgetWithText(FilledButton, 'เข้าสู่ระบบ'));
    expect(find.text('รูปแบบอีเมลไม่ถูกต้อง'), findsOneWidget);
    expect(calls.logins, isEmpty);

    await tester.enterText(find.byKey(const Key('auth-email')), ' a@b.co ');
    await _settle(tester);
    expect(
      find.text('รูปแบบอีเมลไม่ถูกต้อง'),
      findsNothing,
    ); // พิมพ์แล้ว error หาย
    await _tapVisible(tester, find.widgetWithText(FilledButton, 'เข้าสู่ระบบ'));
    expect(find.text('กรุณากรอกรหัสผ่าน'), findsOneWidget);

    calls.result = 'อีเมลหรือรหัสผ่านไม่ถูกต้อง';
    await tester.enterText(find.byKey(const Key('auth-password')), 'secret1');
    await _tapVisible(tester, find.widgetWithText(FilledButton, 'เข้าสู่ระบบ'));
    expect(calls.logins, [
      ['a@b.co', 'secret1'],
    ]);
    expect(find.text('อีเมลหรือรหัสผ่านไม่ถูกต้อง'), findsOneWidget);
  });

  testWidgets('สมัคร: รหัสสั้น/ไม่ตรงกันต้องไม่ส่ง, ถูกต้องแล้วส่ง', (
    tester,
  ) async {
    final calls = _Calls();
    await tester.pumpWidget(calls.build());
    await _settle(tester);
    await _tapVisible(tester, find.text('สมัครสมาชิก'));

    await tester.enterText(find.byKey(const Key('auth-email')), 'a@b.co');
    await tester.enterText(find.byKey(const Key('auth-password')), '123');
    await _tapVisible(tester, find.text('สร้างบัญชี'));
    expect(find.text('รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('auth-password')), '123456');
    await tester.enterText(find.byKey(const Key('auth-confirm')), '123457');
    await _tapVisible(tester, find.text('สร้างบัญชี'));
    expect(find.text('รหัสผ่านทั้งสองช่องไม่ตรงกัน'), findsOneWidget);
    expect(calls.signups, isEmpty);

    await tester.enterText(find.byKey(const Key('auth-confirm')), '123456');
    await _tapVisible(tester, find.text('สร้างบัญชี'));
    expect(calls.signups, [
      ['a@b.co', '123456'],
    ]);
    expect(calls.logins, isEmpty);
  });

  testWidgets('ปุ่มรูปตาสลับแสดง/ซ่อนรหัสผ่าน', (tester) async {
    await tester.pumpWidget(_Calls().build());
    await _settle(tester);
    TextField field() =>
        tester.widget<TextField>(find.byKey(const Key('auth-password')));
    expect(field().obscureText, isTrue);
    await tester.tap(find.byTooltip('แสดงรหัสผ่าน'));
    await _settle(tester);
    expect(field().obscureText, isFalse);
  });

  testWidgets('ลืมรหัสผ่าน: ต้องกรอกอีเมลก่อน แล้วส่งลิงก์', (tester) async {
    final calls = _Calls();
    await tester.pumpWidget(calls.build());
    await _settle(tester);

    await _tapVisible(tester, find.text('ลืมรหัสผ่าน?'));
    expect(find.textContaining('กรอกอีเมลก่อน'), findsOneWidget);
    expect(calls.resets, isEmpty);

    await tester.enterText(find.byKey(const Key('auth-email')), 'a@b.co');
    await _tapVisible(tester, find.text('ลืมรหัสผ่าน?'));
    expect(calls.resets, ['a@b.co']);
    expect(find.textContaining('ส่งลิงก์ตั้งรหัสผ่านใหม่'), findsOneWidget);
  });

  test('แปลง error ของ Firebase เป็นภาษาไทย', () {
    expect(
      authErrorMessage('invalid-credential'),
      'อีเมลหรือรหัสผ่านไม่ถูกต้อง',
    );
    expect(authErrorMessage('wrong-password'), 'อีเมลหรือรหัสผ่านไม่ถูกต้อง');
    expect(
      authErrorMessage('email-already-in-use'),
      contains('มีบัญชีอยู่แล้ว'),
    );
    expect(authErrorMessage('weird-code'), contains('weird-code'));
  });
}
