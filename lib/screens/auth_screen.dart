// หน้าเข้าสู่ระบบ/สมัครสมาชิก
// - ครั้งแรกที่เปิดแอป แสดงสไลด์แนะนำแอป (OnboardingView) ก่อน
// - หัวสีแบรนด์ มีหม้อชาบูเด้งเข้ามาพร้อมไอน้ำลอย
// - แผ่นสีขาวด้านล่าง สลับ "เข้าสู่ระบบ / สมัครสมาชิก" ได้ในหน้าเดียว
// เมื่อล็อกอินสำเร็จ StreamBuilder ใน main.dart จะพาไปหน้าหลักเอง
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'onboarding_screen.dart';

// คืนค่า null = สำเร็จ, ข้อความ = error ที่จะแสดงให้ผู้ใช้เห็น
typedef AuthAction = Future<String?> Function(String email, String password);

// แปลง error code ของ Firebase เป็นข้อความภาษาไทยที่เข้าใจง่าย
String authErrorMessage(String code) {
  switch (code) {
    case 'invalid-email':
      return 'รูปแบบอีเมลไม่ถูกต้อง';
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
    case 'INVALID_LOGIN_CREDENTIALS':
      return 'อีเมลหรือรหัสผ่านไม่ถูกต้อง';
    case 'user-disabled':
      return 'บัญชีนี้ถูกระงับการใช้งาน';
    case 'email-already-in-use':
      return 'อีเมลนี้มีบัญชีอยู่แล้ว ลองเข้าสู่ระบบแทน';
    case 'weak-password':
      return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
    case 'too-many-requests':
      return 'ลองหลายครั้งเกินไป กรุณารอสักครู่แล้วลองใหม่';
    case 'network-request-failed':
      return 'เชื่อมต่ออินเทอร์เน็ตไม่ได้ ลองใหม่อีกครั้ง';
    default:
      return 'เกิดข้อผิดพลาด ($code) ลองใหม่อีกครั้ง';
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  // key ใน SharedPreferences ที่จำว่าเคยดูสไลด์แนะนำแอปแล้ว
  static const introSeenKey = 'seen_intro';

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool? _showIntro; // null = กำลังอ่านค่าจากเครื่อง

  @override
  void initState() {
    super.initState();
    _loadIntroFlag();
  }

  Future<void> _loadIntroFlag() async {
    var seen = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      seen = prefs.getBool(AuthScreen.introSeenKey) ?? false;
    } catch (_) {
      // อ่านไม่ได้ก็แค่แสดงสไลด์อีกรอบ ไม่ใช่เรื่องใหญ่
    }
    if (mounted) setState(() => _showIntro = !seen);
  }

  Future<void> _finishIntro() async {
    setState(() => _showIntro = false);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AuthScreen.introSeenKey, true);
    } catch (_) {}
  }

  Future<String?> _login(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return authErrorMessage(e.code);
    } catch (_) {
      return 'เข้าสู่ระบบไม่สำเร็จ ลองใหม่อีกครั้ง';
    }
  }

  Future<String?> _signup(String email, String password) async {
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // บันทึกข้อมูลผู้ใช้ลง Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set({
            'email': cred.user!.email,
            'createdAt': FieldValue.serverTimestamp(), // เวลาที่สมัคร
          }, SetOptions(merge: true));
      return null;
    } on FirebaseAuthException catch (e) {
      return authErrorMessage(e.code);
    } catch (_) {
      return 'สมัครสมาชิกไม่สำเร็จ ลองใหม่อีกครั้ง';
    }
  }

  Future<String?> _resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return authErrorMessage(e.code);
    } catch (_) {
      return 'ส่งอีเมลไม่สำเร็จ ลองใหม่อีกครั้ง';
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget child;
    if (_showIntro == null) {
      child = const Scaffold(backgroundColor: Colors.white);
    } else if (_showIntro!) {
      child = OnboardingView(
        key: const ValueKey('intro'),
        onDone: _finishIntro,
      );
    } else {
      child = AuthView(
        key: const ValueKey('auth'),
        onLogin: _login,
        onSignup: _signup,
        onResetPassword: _resetPassword,
      );
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: child,
    );
  }
}

// ส่วนหน้าตาของหน้าล็อกอิน แยกออกมาเพื่อทดสอบได้โดยไม่ต้องมี Firebase
class AuthView extends StatefulWidget {
  const AuthView({
    super.key,
    required this.onLogin,
    required this.onSignup,
    required this.onResetPassword,
  });

  final AuthAction onLogin;
  final AuthAction onSignup;
  final Future<String?> Function(String email) onResetPassword;

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _signup = false; // false = เข้าสู่ระบบ, true = สมัครสมาชิก
  bool _busy = false;
  bool _hidePassword = true;
  bool _hideConfirm = true;
  String? _error;

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _setMode(bool signup) {
    if (_busy || signup == _signup) return;
    setState(() {
      _signup = signup;
      _error = null;
      _confirm.clear();
    });
  }

  String? _validate({bool emailOnly = false}) {
    final email = _email.text.trim();
    if (email.isEmpty) return 'กรุณากรอกอีเมล';
    if (!_emailPattern.hasMatch(email)) return 'รูปแบบอีเมลไม่ถูกต้อง';
    if (emailOnly) return null;
    if (_password.text.isEmpty) return 'กรุณากรอกรหัสผ่าน';
    if (_signup) {
      if (_password.text.length < 6) {
        return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
      }
      if (_confirm.text != _password.text) {
        return 'รหัสผ่านทั้งสองช่องไม่ตรงกัน';
      }
    }
    return null;
  }

  Future<void> _submit() async {
    if (_busy) return;
    FocusScope.of(context).unfocus();
    final invalid = _validate();
    if (invalid != null) {
      setState(() => _error = invalid);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final action = _signup ? widget.onSignup : widget.onLogin;
    final error = await action(_email.text.trim(), _password.text);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = error;
    });
  }

  Future<void> _forgotPassword() async {
    if (_busy) return;
    final invalid = _validate(emailOnly: true);
    if (invalid != null) {
      setState(
        () =>
            _error =
                _email.text.trim().isEmpty
                    ? 'กรอกอีเมลก่อน แล้วกด "ลืมรหัสผ่าน?" อีกครั้ง'
                    : invalid,
      );
      return;
    }
    final email = _email.text.trim();
    setState(() {
      _busy = true;
      _error = null;
    });
    final error = await widget.onResetPassword(email);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = error;
    });
    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ส่งลิงก์ตั้งรหัสผ่านใหม่ไปที่ $email แล้ว')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.primary,
      body: SafeArea(
        bottom: false, // ให้แผ่นสีขาวยาวถึงขอบล่างจอ
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _Header(color: cs.onPrimary)),
                // แผ่นล่างสูงตามเนื้อหา ถ้าจอเตี้ย/คีย์บอร์ดขึ้น ก็เลื่อนได้
                SliverToBoxAdapter(
                  child: _SlideUp(child: _buildSheet(context, cs)),
                ),
                // เติมสีขาวใต้แผ่นจนถึงขอบล่างจอ (จอสูงกว่าเนื้อหา)
                // แยกเป็นตัวเติมว่าง ๆ เพราะถ้าให้แผ่นยืดเองต้องวัดความสูง
                // ล่วงหน้า ซึ่งคลาดตอนช่องยืนยันรหัสผ่าน/กล่อง error ขยาย
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _SlideUp(child: ColoredBox(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSheet(BuildContext context, ColorScheme cs) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 24 + bottomInset),
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ModeSwitch(signup: _signup, onChanged: _setMode),
            const SizedBox(height: 20),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              // ชิดซ้ายให้ตรงกับช่องกรอก (ค่าเริ่มต้นของ AnimatedSwitcher จัดกึ่งกลาง)
              layoutBuilder:
                  (current, previous) => Stack(
                    alignment: Alignment.topLeft,
                    children: [...previous, if (current != null) current],
                  ),
              child: Column(
                key: ValueKey(_signup),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _signup ? 'สร้างบัญชีใหม่' : 'ยินดีต้อนรับกลับ',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _signup
                        ? 'สมัครฟรี แล้วจองคิวร้านโปรดได้ทันที'
                        : 'เข้าสู่ระบบเพื่อจองคิวร้านโปรดของคุณ',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _field(
              cs,
              key: const Key('auth-email'),
              controller: _email,
              label: 'อีเมล',
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              action: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            _field(
              cs,
              key: const Key('auth-password'),
              controller: _password,
              label: 'รหัสผ่าน',
              icon: Icons.lock_outline,
              hidden: _hidePassword,
              onToggleHidden:
                  () => setState(() => _hidePassword = !_hidePassword),
              autofillHints: [
                _signup ? AutofillHints.newPassword : AutofillHints.password,
              ],
              action: _signup ? TextInputAction.next : TextInputAction.done,
              onSubmitted: _signup ? null : _submit,
            ),
            // ช่องยืนยันรหัสผ่าน ค่อย ๆ ขยายออกมาเมื่อสลับไปสมัครสมาชิก
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child:
                  _signup
                      ? Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: _field(
                          cs,
                          key: const Key('auth-confirm'),
                          controller: _confirm,
                          label: 'ยืนยันรหัสผ่าน',
                          icon: Icons.lock_reset,
                          hidden: _hideConfirm,
                          onToggleHidden:
                              () =>
                                  setState(() => _hideConfirm = !_hideConfirm),
                          autofillHints: const [AutofillHints.newPassword],
                          action: TextInputAction.done,
                          onSubmitted: _submit,
                        ),
                      )
                      : const SizedBox(width: double.infinity),
            ),
            if (_signup)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 4),
                child: Text(
                  'รหัสผ่านอย่างน้อย 6 ตัวอักษร',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              )
            else
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _forgotPassword,
                  child: const Text('ลืมรหัสผ่าน?'),
                ),
              ),
            // กล่องแจ้ง error
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.topCenter,
              child:
                  _error == null
                      ? const SizedBox(width: double.infinity)
                      : Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cs.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Semantics(
                          liveRegion: true,
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: cs.onErrorContainer,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: TextStyle(color: cs.onErrorContainer),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child:
                      _busy
                          ? SizedBox(
                            key: const ValueKey('busy'),
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: cs.onPrimary,
                            ),
                          )
                          : Text(
                            _signup ? 'สร้างบัญชี' : 'เข้าสู่ระบบ',
                            key: ValueKey(_signup),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    ColorScheme cs, {
    required Key key,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool hidden = false,
    VoidCallback? onToggleHidden,
    TextInputType? keyboardType,
    Iterable<String>? autofillHints,
    TextInputAction? action,
    VoidCallback? onSubmitted,
  }) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color, width: width),
        );
    return TextField(
      key: key,
      controller: controller,
      obscureText: hidden,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      textInputAction: action,
      autocorrect: false,
      enableSuggestions: onToggleHidden == null,
      onSubmitted: onSubmitted == null ? null : (_) => onSubmitted(),
      onChanged: (_) {
        if (_error != null) setState(() => _error = null);
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: cs.primary),
        suffixIcon:
            onToggleHidden == null
                ? null
                : IconButton(
                  tooltip: hidden ? 'แสดงรหัสผ่าน' : 'ซ่อนรหัสผ่าน',
                  icon: Icon(
                    hidden
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: onToggleHidden,
                ),
        filled: true,
        fillColor: cs.primary.withValues(alpha: 0.04),
        border: border(Colors.grey.shade300),
        enabledBorder: border(Colors.grey.shade300),
        focusedBorder: border(cs.primary, 2),
      ),
    );
  }
}

// หัวสีแบรนด์: หม้อชาบูเด้งเข้ามา มีไอน้ำลอยขึ้น
class _Header extends StatelessWidget {
  const _Header({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 28),
      child: Column(
        children: [
          _Steam(color: color.withValues(alpha: 0.7)),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 900),
            curve: Curves.elasticOut,
            builder: (_, v, child) => Transform.scale(scale: v, child: child),
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(Icons.soup_kitchen, size: 40, color: cs.primary),
            ),
          ),
          const SizedBox(height: 12),
          _FadeUp(
            child: Column(
              children: [
                Text(
                  'ShabuQ',
                  style: TextStyle(
                    color: color,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'จองคิวชาบู ไม่ต้องยืนรอ',
                  style: TextStyle(color: color.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ไอน้ำ 3 เส้นลอยขึ้นแล้วจางหาย วนไปเรื่อย ๆ
// (ถ้าผู้ใช้ตั้งค่าลดการเคลื่อนไหวไว้ จะหยุดนิ่ง)
class _Steam extends StatefulWidget {
  const _Steam({required this.color});

  final Color color;

  @override
  State<_Steam> createState() => _SteamState();
}

class _SteamState extends State<_Steam> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 26,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            children: [
              for (var i = 0; i < 3; i++)
                Builder(
                  builder: (_) {
                    final t = (_controller.value + i / 3) % 1;
                    final opacity = t < 0.4 ? t / 0.4 : (1 - t) / 0.6;
                    return Positioned(
                      left: 8 + i * 14,
                      bottom: 0,
                      child: Transform.translate(
                        offset: Offset(0, 4 - 18 * t),
                        child: Opacity(
                          opacity: (opacity * 0.9).clamp(0.0, 1.0),
                          child: Container(
                            width: 4,
                            height: 14,
                            decoration: BoxDecoration(
                              color: widget.color,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

// ข้อความค่อย ๆ เลื่อนขึ้นพร้อมจางเข้า (หลังหม้อเด้งเล็กน้อย)
class _FadeUp extends StatelessWidget {
  const _FadeUp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: const Interval(0.3, 1, curve: Curves.easeOut),
      builder:
          (_, v, child) => Opacity(
            opacity: v,
            child: Transform.translate(
              offset: Offset(0, 12 * (1 - v)),
              child: child,
            ),
          ),
      child: child,
    );
  }
}

// แผ่นล่างเลื่อนขึ้นมาตอนเปิดหน้า
class _SlideUp extends StatelessWidget {
  const _SlideUp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder:
          (_, v, child) => Transform.translate(
            offset: Offset(0, 60 * (1 - v)),
            child: child,
          ),
      child: child,
    );
  }
}

// ปุ่มสลับ "เข้าสู่ระบบ / สมัครสมาชิก" มีแถบสีขาวเลื่อนไปมา
class _ModeSwitch extends StatelessWidget {
  const _ModeSwitch({required this.signup, required this.onChanged});

  final bool signup;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Widget tab(String label, bool selected, bool value) {
      return Expanded(
        child: Semantics(
          button: true,
          selected: selected,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onChanged(value),
            child: Center(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? cs.primary : Colors.grey.shade600,
                ),
                child: Text(label),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: signup ? Alignment.centerRight : Alignment.centerLeft,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              tab('เข้าสู่ระบบ', !signup, false),
              tab('สมัครสมาชิก', signup, true),
            ],
          ),
        ],
      ),
    );
  }
}
