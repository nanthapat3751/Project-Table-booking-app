// สไลด์แนะนำแอป 3 หน้า แสดงเฉพาะครั้งแรกที่เปิดแอป
// (AuthScreen เป็นคนจำว่าเคยดูแล้วหรือยัง)
import 'dart:math' as math;

import 'package:flutter/material.dart';

class _Slide {
  final IconData icon;
  final String title;
  final String text;
  final Color color; // สีไอคอน/ปุ่ม
  final Color tint; // สีพื้นวงกลม
  const _Slide(this.icon, this.title, this.text, this.color, this.tint);
}

const _slides = [
  _Slide(
    Icons.storefront,
    'เลือกร้านชาบูใกล้คุณ',
    'ดูเมนูและโปรโมชั่นของแต่ละร้านได้ในแอปเดียว',
    Color(0xFFD85A30),
    Color(0xFFFAECE7),
  ),
  _Slide(
    Icons.confirmation_number_outlined,
    'จองคิวล่วงหน้า',
    'เลือกโซนและจำนวนคน ชำระผ่าน QR แล้วแนบสลิปในแอปได้เลย',
    Color(0xFF534AB7),
    Color(0xFFEEEDFE),
  ),
  _Slide(
    Icons.notifications_active_outlined,
    'รู้ว่าอีกกี่คิวถึงตา',
    'เช็กคิวที่เหลือได้ทุกเมื่อ ไม่ต้องยืนรอหน้าร้าน',
    Color(0xFF0F6E56),
    Color(0xFFE1F5EE),
  ),
];

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key, required this.onDone});

  // เรียกเมื่อดูจบหรือกด "ข้าม"
  final VoidCallback onDone;

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final _pageController = PageController();
  int _page = 0;

  bool get _isLast => _page == _slides.length - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_isLast) {
      widget.onDone();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_page];
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _slides.length,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemBuilder:
                        (_, i) =>
                            _SlidePage(slide: _slides[i], active: i == _page),
                  ),
                ),
                // จุดบอกหน้า: หน้าปัจจุบันยืดเป็นแถบยาว
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < _slides.length; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        height: 8,
                        width: i == _page ? 24 : 8,
                        decoration: BoxDecoration(
                          color:
                              i == _page ? slide.color : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 20, 16),
                  child: Row(
                    children: [
                      // หน้าสุดท้ายไม่ต้องมี "ข้าม" แต่เว้นที่ไว้ให้ปุ่มไม่กระโดด
                      Visibility(
                        visible: !_isLast,
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        child: TextButton(
                          onPressed: widget.onDone,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey.shade600,
                          ),
                          child: const Text('ข้าม'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TweenAnimationBuilder<Color?>(
                          tween: ColorTween(end: slide.color),
                          duration: const Duration(milliseconds: 300),
                          builder:
                              (_, color, _) => SizedBox(
                                height: 52,
                                child: FilledButton(
                                  onPressed: _next,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: color,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: Text(
                                    _isLast ? 'เริ่มต้นใช้งาน' : 'ถัดไป',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// หนึ่งหน้าสไลด์: ไอคอนในวงกลมเด้งขึ้นมาเมื่อเป็นหน้าปัจจุบัน
class _SlidePage extends StatelessWidget {
  const _SlidePage({required this.slide, required this.active});

  final _Slide slide;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        // จอเตี้ย (แนวนอน) ให้วงกลมเล็กลง ข้อความจะได้ไม่ล้น
        final size = math.min(170.0, box.maxHeight * 0.4);
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedScale(
                  scale: active ? 1 : 0.5,
                  duration: const Duration(milliseconds: 550),
                  curve: Curves.easeOutBack,
                  child: AnimatedOpacity(
                    opacity: active ? 1 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        color: slide.tint,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        slide.icon,
                        size: size * 0.48,
                        color: slide.color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  slide.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  slide.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
