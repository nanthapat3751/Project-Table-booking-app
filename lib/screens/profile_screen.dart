import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  DocumentReference<Map<String, dynamic>>? get userDoc =>
      user != null
          ? FirebaseFirestore.instance.collection('users').doc(user!.uid)
          : null;

  // เก็บ controller ไว้ใน State — เดิมสร้างใหม่ทุกครั้งที่ build
  // ทำให้พิมพ์เบอร์โทรแล้วเคอร์เซอร์เด้งกลับไปต้นช่อง (ตัวเลขกลับด้าน)
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  Timer?
  _saveDebounce; // หน่วงการบันทึกขณะพิมพ์ ไม่ให้เขียน Firestore ทุกตัวอักษร

  bool _loading = true;
  String birthday = '';
  String gender = '';
  String avatarIcon = 'person';
  int avatarColor = Colors.grey.toARGB32();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // โหลดข้อมูลโปรไฟล์ครั้งเดียวตอนเปิดหน้า
  Future<void> _loadProfile() async {
    Map<String, dynamic> data = {};
    try {
      data = (await userDoc?.get())?.data() ?? {};
    } catch (_) {
      // โหลดไม่สำเร็จ แสดงค่าว่างแทนการค้างโหลด
    }
    if (!mounted) return;
    setState(() {
      birthday = data['birthday'] ?? '';
      gender = data['gender'] ?? '';
      avatarIcon = data['avatarIcon'] ?? 'person';
      avatarColor = data['avatarColor'] ?? Colors.grey.toARGB32();
      _nameController.text = data['displayName'] ?? user?.displayName ?? '';
      _phoneController.text = data['phone'] ?? '';
      _loading = false;
    });
  }

  // บันทึกฟิลด์ข้อความหลังหยุดพิมพ์ 600ms
  void _saveFieldDebounced(String field, String value) {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 600), () {
      userDoc?.set({field: value}, SetOptions(merge: true));
    });
  }

  // แปลง yyyy-m-d เป็น d/m/yyyy
  String _formatBirthday(String b) {
    final parts = b.split('-');
    if (parts.length == 3) return '${parts[2]}/${parts[1]}/${parts[0]}';
    return b;
  }

  // เลือกวันเกิดและบันทึก
  Future<void> _pickBirthday() async {
    final parts = birthday.split('-').map(int.tryParse).toList();
    final initial =
        parts.length == 3 && !parts.contains(null)
            ? DateTime(parts[0]!, parts[1]!, parts[2]!)
            : DateTime(2000);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked == null || userDoc == null) return;
    final newBirthday = '${picked.year}-${picked.month}-${picked.day}';
    await userDoc!.set({'birthday': newBirthday}, SetOptions(merge: true));
    if (!mounted) return;
    setState(() => birthday = newBirthday);
  }

  // เลือกไอคอนและสีของรูปโปรไฟล์
  Future<void> _pickAvatar() async {
    await showDialog(
      context: context,
      builder: (ctx) {
        String tempIcon = avatarIcon;
        int tempColor = avatarColor;
        final icons = ['person', 'face', 'star', 'pets', 'emoji_emotions'];
        final colors = [
          Colors.grey,
          Colors.blue,
          Colors.red,
          Colors.green,
          Colors.orange,
          Colors.purple,
        ];
        return StatefulBuilder(
          builder:
              (context, setDialogState) => AlertDialog(
                title: const Text('เลือกไอคอนและสี'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          icons.map((iconName) {
                            final selected = tempIcon == iconName;
                            return GestureDetector(
                              onTap:
                                  () =>
                                      setDialogState(() => tempIcon = iconName),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        selected
                                            ? Colors.blue
                                            : Colors.transparent,
                                    width: 3,
                                  ),
                                  color:
                                      selected
                                          ? Colors.blue.withValues(alpha: 0.15)
                                          : Colors.transparent,
                                ),
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  _iconFromName(iconName),
                                  size: 32,
                                  color:
                                      selected ? Colors.blue : Colors.black54,
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          colors.map((c) {
                            final selected = tempColor == c.toARGB32();
                            return GestureDetector(
                              onTap:
                                  () => setDialogState(
                                    () => tempColor = c.toARGB32(),
                                  ),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: c,
                                  border: Border.all(
                                    color:
                                        selected
                                            ? Colors.blue
                                            : Colors.transparent,
                                    width: 3,
                                  ),
                                ),
                                child:
                                    selected
                                        ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 20,
                                        )
                                        : null,
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    child: const Text('ยกเลิก'),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                  TextButton(
                    child: const Text('บันทึก'),
                    onPressed: () async {
                      await userDoc?.set({
                        'avatarIcon': tempIcon,
                        'avatarColor': tempColor,
                      }, SetOptions(merge: true));
                      if (mounted) {
                        setState(() {
                          avatarIcon = tempIcon;
                          avatarColor = tempColor;
                        });
                      }
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
        );
      },
    );
  }

  // แถว "หัวข้อ ... ค่า" ในการ์ดข้อมูลส่วนตัว
  Widget _infoRow(String label, Widget value, Color? textColor) {
    return Row(
      children: [
        Text(label, style: TextStyle(fontSize: 16, color: textColor)),
        const SizedBox(width: 16),
        Expanded(child: Align(alignment: Alignment.centerRight, child: value)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;
    final cardColor = theme.cardColor;
    final divider = Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Divider(height: 1, color: theme.dividerColor, thickness: 1),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 149, 144, 248),
        foregroundColor: Colors.white,
        title: const Text('โปรไฟล์'),
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : Center(
                child: ConstrainedBox(
                  // จำกัดความกว้างบนจอใหญ่; บนมือถือใช้เต็มจอ
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // รูปโปรไฟล์ (กดเพื่อเลือกไอคอนและสี)
                      Center(
                        child: GestureDetector(
                          onTap: _pickAvatar,
                          child: CircleAvatar(
                            radius: 48,
                            backgroundColor: Color(avatarColor),
                            child: Icon(
                              _iconFromName(avatarIcon),
                              size: 48,
                              color: textColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // ชื่อผู้ใช้ (แก้ไขได้)
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 260),
                          child: TextField(
                            controller: _nameController,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'ชื่อผู้ใช้',
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged:
                                (val) =>
                                    _saveFieldDebounced('displayName', val),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // ข้อมูลส่วนตัว
                      Card(
                        color: cardColor,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Padding(
                          // padding เล็กลงจาก 28 ให้เหลือพื้นที่บนจอมือถือแคบ
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 24,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ข้อมูลส่วนตัว',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 18),
                              _infoRow(
                                'อีเมล',
                                Text(
                                  user?.email ?? '-',
                                  textAlign: TextAlign.right,
                                  maxLines: 1,
                                  overflow:
                                      TextOverflow.ellipsis, // อีเมลยาวไม่ล้นจอ
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: textColor,
                                  ),
                                ),
                                textColor,
                              ),
                              divider,
                              // วันเกิด
                              _infoRow(
                                'วันเกิด',
                                InkWell(
                                  onTap: _pickBirthday,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child:
                                        birthday.isNotEmpty
                                            ? Text(
                                              _formatBirthday(birthday),
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: textColor,
                                              ),
                                            )
                                            : const Text(
                                              'กรอกวันเกิด',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.blue,
                                              ),
                                            ),
                                  ),
                                ),
                                textColor,
                              ),
                              divider,
                              // เพศ
                              _infoRow(
                                'เพศ',
                                DropdownButton<String>(
                                  isDense: true,
                                  value:
                                      ['ชาย', 'หญิง', 'อื่นๆ'].contains(gender)
                                          ? gender
                                          : null,
                                  hint: const Text(
                                    'เลือกเพศ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  items:
                                      ['ชาย', 'หญิง', 'อื่นๆ'].map((g) {
                                        return DropdownMenuItem(
                                          value: g,
                                          child: Text(
                                            g,
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                  onChanged: (val) async {
                                    if (val == null || userDoc == null) return;
                                    setState(() => gender = val);
                                    await userDoc!.set({
                                      'gender': val,
                                    }, SetOptions(merge: true));
                                  },
                                  underline: const SizedBox.shrink(),
                                ),
                                textColor,
                              ),
                              divider,
                              // เบอร์โทรศัพท์
                              _infoRow(
                                'เบอร์โทรศัพท์',
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 160,
                                  ),
                                  child: TextField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    decoration: const InputDecoration(
                                      hintText: 'กรอกเบอร์',
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 8,
                                      ),
                                      border: InputBorder.none,
                                      counterText: '',
                                    ),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: textColor,
                                    ),
                                    textAlign: TextAlign.right,
                                    maxLength: 10,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(10),
                                    ],
                                    // ไม่เรียก setState ระหว่างพิมพ์ เคอร์เซอร์จึงไม่เด้ง
                                    onChanged:
                                        (val) =>
                                            _saveFieldDebounced('phone', val),
                                  ),
                                ),
                                textColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          'เวอร์ชั่นแอป 1.0.0',
                          style: TextStyle(color: theme.disabledColor),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ListTile(
                        leading: const Icon(Icons.help_outline),
                        title: Text(
                          'การช่วยเหลือ',
                          style: TextStyle(color: textColor),
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder:
                                (_) => AlertDialog(
                                  backgroundColor: cardColor,
                                  title: Text(
                                    'ช่วยเหลือ',
                                    style: TextStyle(color: textColor),
                                  ),
                                  content: Text(
                                    'ติดต่อทีมงานได้ที่ support@shabuq.com',
                                    style: TextStyle(color: textColor),
                                  ),
                                  actions: [
                                    TextButton(
                                      child: Text(
                                        'ปิด',
                                        style: TextStyle(color: textColor),
                                      ),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                ),
                          );
                        },
                      ),
                      // ข้อกำหนดและเงื่อนไขการใช้งาน
                      ListTile(
                        leading: const Icon(Icons.article_outlined),
                        title: Text(
                          'ข้อกำหนดและเงื่อนไขการใช้งาน',
                          style: TextStyle(color: textColor),
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder:
                                (_) => AlertDialog(
                                  backgroundColor: cardColor,
                                  title: Text(
                                    'ข้อกำหนดและเงื่อนไขการใช้งาน',
                                    style: TextStyle(color: textColor),
                                  ),
                                  content: SingleChildScrollView(
                                    child: Text(
                                      'ข้อกำหนดและเงื่อนไขการใช้งาน\n\n'
                                      '1. ผู้ใช้ต้องปฏิบัติตามกฎระเบียบของแอปพลิเคชัน\n'
                                      '2. ห้ามใช้แอปเพื่อวัตถุประสงค์ที่ผิดกฎหมายหรือสร้างความเสียหาย\n'
                                      '3. ข้อมูลส่วนตัวของผู้ใช้จะถูกเก็บรักษาอย่างปลอดภัย\n'
                                      '4. แอปขอสงวนสิทธิ์ในการเปลี่ยนแปลงข้อกำหนดโดยไม่ต้องแจ้งให้ทราบล่วงหน้า\n'
                                      '5. การใช้งานแอปถือว่าผู้ใช้ยอมรับข้อกำหนดทั้งหมด\n'
                                      '6. หากมีข้อสงสัย กรุณาติดต่อทีมงาน\n'
                                      '7. ข้อกำหนดเพิ่มเติมสามารถดูได้ที่เว็บไซต์ของเรา\n'
                                      '8. การละเมิดข้อกำหนดอาจนำไปสู่การระงับบัญชี\n'
                                      '9. แอปไม่รับผิดชอบต่อความเสียหายที่เกิดจากการใช้งาน\n'
                                      '10. ผู้ใช้ควรตรวจสอบข้อกำหนดเป็นระยะ\n',
                                      style: TextStyle(color: textColor),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      child: Text(
                                        'ปิด',
                                        style: TextStyle(color: textColor),
                                      ),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                ),
                          );
                        },
                      ),
                      // นโยบายความเป็นส่วนตัว
                      ListTile(
                        leading: const Icon(Icons.privacy_tip_outlined),
                        title: Text(
                          'นโยบายความเป็นส่วนตัว',
                          style: TextStyle(color: textColor),
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder:
                                (_) => AlertDialog(
                                  backgroundColor: cardColor,
                                  title: Text(
                                    'นโยบายความเป็นส่วนตัว',
                                    style: TextStyle(color: textColor),
                                  ),
                                  content: SingleChildScrollView(
                                    child: Text(
                                      'นโยบายความเป็นส่วนตัว\n\n'
                                      'เราให้ความสำคัญกับข้อมูลส่วนตัวของผู้ใช้:\n'
                                      '- ข้อมูลที่เก็บรวบรวมจะใช้เพื่อปรับปรุงบริการเท่านั้น\n'
                                      '- เราจะไม่เปิดเผยข้อมูลส่วนตัวแก่บุคคลที่สามโดยไม่ได้รับอนุญาต\n'
                                      '- ผู้ใช้สามารถร้องขอให้ลบหรือแก้ไขข้อมูลส่วนตัวได้\n'
                                      '- ข้อมูลจะถูกเก็บรักษาอย่างปลอดภัยตามมาตรฐานสากล\n'
                                      '- หากมีการเปลี่ยนแปลงนโยบายจะแจ้งให้ผู้ใช้ทราบ\n'
                                      '- ผู้ใช้สามารถติดต่อสอบถามเกี่ยวกับข้อมูลส่วนตัวได้ที่ support@shabuq.com\n'
                                      '- การใช้งานแอปถือว่าผู้ใช้ยอมรับนโยบายนี้\n'
                                      '- ข้อมูลการใช้งานจะถูกนำไปวิเคราะห์เพื่อปรับปรุงประสบการณ์ผู้ใช้\n'
                                      '- เราใช้เทคโนโลยีเพื่อป้องกันการเข้าถึงข้อมูลโดยไม่ได้รับอนุญาต\n'
                                      '- หากพบการละเมิดความเป็นส่วนตัว กรุณาแจ้งทีมงานทันที\n',
                                      style: TextStyle(color: textColor),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      child: Text(
                                        'ปิด',
                                        style: TextStyle(color: textColor),
                                      ),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                ),
                          );
                        },
                      ),
                      // ตั้งค่าบัญชีผู้ใช้
                      ListTile(
                        leading: const Icon(Icons.settings),
                        title: Text(
                          'ตั้งค่าบัญชีผู้ใช้',
                          style: TextStyle(color: textColor),
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder:
                                (_) => AlertDialog(
                                  backgroundColor: cardColor,
                                  title: Text(
                                    'ลบบัญชีผู้ใช้',
                                    style: TextStyle(color: textColor),
                                  ),
                                  content: Text(
                                    'คุณแน่ใจหรือไม่ว่าต้องการลบบัญชีผู้ใช้?\n'
                                    'การลบนี้จะไม่สามารถย้อนกลับได้ และข้อมูลทั้งหมดจะถูกลบถาวร',
                                    style: TextStyle(color: textColor),
                                  ),
                                  actions: [
                                    TextButton(
                                      child: Text(
                                        'ยกเลิก',
                                        style: TextStyle(color: textColor),
                                      ),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                    TextButton(
                                      child: Text(
                                        'ยืนยันลบ',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      onPressed: () async {
                                        try {
                                          await user?.delete();
                                          if (!context.mounted) return;
                                          Navigator.of(
                                            context,
                                          ).popUntil((route) => route.isFirst);
                                        } catch (e) {
                                          if (!context.mounted) return;
                                          Navigator.pop(context);
                                          showDialog(
                                            context: context,
                                            builder:
                                                (_) => AlertDialog(
                                                  backgroundColor: cardColor,
                                                  title: Text(
                                                    'เกิดข้อผิดพลาด',
                                                    style: TextStyle(
                                                      color: textColor,
                                                    ),
                                                  ),
                                                  content: Text(
                                                    'ไม่สามารถลบบัญชีได้: ${e.toString()}',
                                                    style: TextStyle(
                                                      color: textColor,
                                                    ),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      child: Text(
                                                        'ปิด',
                                                        style: TextStyle(
                                                          color: textColor,
                                                        ),
                                                      ),
                                                      onPressed:
                                                          () => Navigator.pop(
                                                            context,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.logout),
                          label: const Text('ออกจากระบบ'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            if (!context.mounted) return;
                            Navigator.of(
                              context,
                            ).popUntil((route) => route.isFirst);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  // เพิ่มฟังก์ชันแปลงชื่อไอคอนเป็น IconData
  IconData _iconFromName(String name) {
    switch (name) {
      case 'face':
        return Icons.face;
      case 'star':
        return Icons.star;
      case 'pets':
        return Icons.pets;
      case 'emoji_emotions':
        return Icons.emoji_emotions;
      default:
        return Icons.person;
    }
  }
}
