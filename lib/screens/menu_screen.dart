import 'package:flutter/material.dart';

// เมนูที่ทุกร้านใช้ร่วมกัน (ตอนนี้ทั้ง 3 ร้านมีเมนูเหมือนกันทุกรายการ)
// ถ้าร้านไหนมีเมนูต่างออกไป ให้สร้าง Map แยกแล้วใส่ใน shopMenus ของร้านนั้น
const sharedMenu = <String, List<Map<String, String>>>{
  'น้ำซุป': [
    {'name': 'ซุปน้ำใส', 'image': 'assets/images/menu/ซุปน้ำใส.jpg'},
    {'name': 'ซุปน้ำดำ', 'image': 'assets/images/menu/ซุปน้ำดำ.jpg'},
    {'name': 'ซุปทงคตสึ', 'image': 'assets/images/menu/ซุปทงคตสึ.jpg'},
    {'name': 'ซุปต้มยำ', 'image': 'assets/images/menu/ซุปต้มยำ.jpg'},
    {'name': 'ซุปต้มแซ่บ', 'image': 'assets/images/menu/ซุปต้มแซ่บ.jpg'},
    {'name': 'ซุปมิโซะ', 'image': 'assets/images/menu/ซุปมิโซะ.jpg'},
  ],
  'เนื้อและลูกชิ้น': [
    {'name': 'เบคอน', 'image': 'assets/images/menu/เบคอน.jpg'},
    {'name': 'หมูสันคอ', 'image': 'assets/images/menu/หมูสันคอ.jpg'},
    {'name': 'หมูไม้ไผ่', 'image': 'assets/images/menu/หมูไม้ไผ่.jpg'},
    {'name': 'ไก่สไลด์', 'image': 'assets/images/menu/ไก่สไลด์.jpg'},
    {'name': 'สันนอก', 'image': 'assets/images/menu/สันนอก.jpg'},
    {'name': 'ตับ', 'image': 'assets/images/menu/ตับ.jpg'},
    {'name': 'ปลาดอลลี่', 'image': 'assets/images/menu/ปลาดอลลี่.jpg'},
    {'name': 'กุ้ง', 'image': 'assets/images/menu/กุ้ง.jpg'},
    {'name': 'ปลาหมึก', 'image': 'assets/images/menu/ปลาหมึก.jpg'},
    {'name': 'หอยแมลงภู่', 'image': 'assets/images/menu/หอยแมลงภู่.jpg'},
    {
      'name': 'สาหร่ายทรงเครื่อง',
      'image': 'assets/images/menu/สาหร่ายทรงเครื่อง.jpg',
    },
    {'name': 'เกี๊ยวปลา', 'image': 'assets/images/menu/เกี๊ยวปลา.jpg'},
    {'name': 'เกี๊ยวหมู', 'image': 'assets/images/menu/เกี๋ยวหมู.jpg'},
    {'name': 'ไข่ไก่', 'image': 'assets/images/menu/ไข่ไก่.jpg'},
    {'name': 'เต้าหู้ปลา', 'image': 'assets/images/menu/เต้าหู้ปลา.jpg'},
    {
      'name': 'ฟองเต้าหู้ซีฟู้ด',
      'image': 'assets/images/menu/ฟองเต้าหู่ซีฟู๊ด.jpg',
    },
    {'name': 'ลูกชิ้นชีส', 'image': 'assets/images/menu/ลูกชิ้นชีส.jpg'},
    {'name': 'ชีส', 'image': 'assets/images/menu/ชีส.jpg'},
    {'name': 'เต้าหู้ไข่', 'image': 'assets/images/menu/เต้าหู้ไข่.jpg'},
  ],
  'ผักและเส้น': [
    {'name': 'กวางตุ้ง', 'image': 'assets/images/menu/กวางตุ้ง.jpg'},
    {'name': 'ผักบุ้ง', 'image': 'assets/images/menu/ผักบุ้ง.jpg'},
    {'name': 'ผักกาดขาว', 'image': 'assets/images/menu/ผักกาดขาว.jpg'},
    {'name': 'ขึ้นฉ่าย', 'image': 'assets/images/menu/ขึ้นฉ่าย.jpg'},
    {
      'name': 'สาหร่ายวากาเมะ',
      'image': 'assets/images/menu/สาหร่ายวากาเมะ.jpg',
    },
    {'name': 'ข้าวโพดอ่อน', 'image': 'assets/images/menu/ข้าวโพดอ่อน.jpg'},
    {'name': 'ข้าวโพด', 'image': 'assets/images/menu/ข้าวโพด.jpg'},
    {'name': 'แครอท', 'image': 'assets/images/menu/แครอท.jpg'},
    {'name': 'เห็ดเข็มทอง', 'image': 'assets/images/menu/เห็ดเข็มทอง.jpg'},
    {'name': 'เห็ดหอม', 'image': 'assets/images/menu/เห็ดหอม.jpg'},
    {'name': 'เห็ดหูหนูขาว', 'image': 'assets/images/menu/เห็ดหูหนูขาว.jpg'},
    {'name': 'เห็ดหูหนูดำ', 'image': 'assets/images/menu/เห็ดหูหนูดำ.jpg'},
    {'name': 'เห็ดชิเมจิ', 'image': 'assets/images/menu/เห็ดชิเมจิ.jpg'},
    {'name': 'เห็ดออรินจิ', 'image': 'assets/images/menu/เห็ดออรินจิ.jpg'},
    {'name': 'หมี่หยก', 'image': 'assets/images/menu/หมี่หยก.jpg'},
    {'name': 'อุด้ง', 'image': 'assets/images/menu/อุด้ง.jpg'},
    {'name': 'วุ้นเส้น', 'image': 'assets/images/menu/เส้นญี่ปุ่น.jpg'},
    {'name': 'เส้นปลา', 'image': 'assets/images/menu/เส้นปลา.jpg'},
  ],
  'ของทานเล่น': [
    {'name': 'เฟรนช์ฟรายส์', 'image': 'assets/images/menu/เฟรนฟรายส์.jpg'},
    {'name': 'เกี๊ยวซ่า', 'image': 'assets/images/menu/เกี๊ยวซ่า.jpg'},
    {'name': 'ปูอัดทอด', 'image': 'assets/images/menu/ปูอัดทอด.jpg'},
    {
      'name': 'เห็ดเข็มทองทอด',
      'image': 'assets/images/menu/เห็ดเข็มทองทอด.jpg',
    },
    {'name': 'หนังไก่ทอด', 'image': 'assets/images/menu/หนังไก่ทอด.jpg'},
    {'name': 'นักเก็ตไก่', 'image': 'assets/images/menu/นักเก็ตไก่.jpg'},
    {'name': 'ข้าวผัด', 'image': 'assets/images/menu/ข้าวผัด.jpg'},
    {'name': 'ซูชิ', 'image': 'assets/images/menu/ซูชิ.jpg'},
    {
      'name': 'ไข่หวานญี่ปุ่น',
      'image': 'assets/images/menu/ไข่หวานญี่ปุ่น.jpg',
    },
  ],
  'น้ำจิ้ม': [
    {'name': 'น้ำจิ้มสุกี้', 'image': 'assets/images/menu/น้ำจิ้มสุกี้.jpg'},
    {'name': 'น้ำจิ้มซีฟู้ด', 'image': 'assets/images/menu/น้ำจิ้มซีฟู๊ด.jpg'},
    {'name': 'น้ำจิ้มงา', 'image': 'assets/images/menu/น้ำจิ้มงา.jpg'},
    {'name': 'น้ำจิ้มพอนสึ', 'image': 'assets/images/menu/น้ำจิ้มพอนสึ.jpg'},
    {'name': 'น้ำจิ้มแจ่ว', 'image': 'assets/images/menu/น้ำจิ้มแจ่ว.jpg'},
    {'name': 'น้ำจิ้มสไปซี่', 'image': 'assets/images/menu/น้ำจิ้มสไปซี่.jpg'},
  ],
  'น้ำและของหวาน': [
    {'name': 'ไอศกรีม', 'image': 'assets/images/menu/ไอศครีม.jpg'},
    {'name': 'เป๊ปซี่', 'image': 'assets/images/menu/เป๊ปซี่.jpg'},
    {'name': 'เซเว่นอัพ', 'image': 'assets/images/menu/เซเว่นอัพ.jpg'},
    {
      'name': 'มิรินด้า รสสตรอว์เบอร์รี',
      'image': 'assets/images/menu/มิรินด้า รสสตรอเบอรี่.jpg',
    },
    {
      'name': 'มิรินด้า รสส้ม',
      'image': 'assets/images/menu/มิรินด้า รสส้ม.jpg',
    },
  ],
};

// รูปร้านและเมนูของแต่ละร้าน
final shopMenus = <String, Map<String, Object>>{
  'เฝอแฟมิลี่ ชาบู กำแพงแสน': {
    'image': 'assets/images/pho.jpg',
    'menus': sharedMenu,
  },
  'Wiyaki ชาบู&ปิ้งย่าง กำแพงแสน': {
    'image': 'assets/images/wiyaki.jpeg',
    'menus': sharedMenu,
  },
  'สุกี้ตี๋น้อย Meet and Eat นครปฐม': {
    'image': 'assets/images/teenoi.jpg',
    'menus': sharedMenu,
  },
};

// หน้าจอแสดงเมนูอาหารของแต่ละร้าน
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String? selectedShop; // เก็บชื่อร้านที่ผู้ใช้เลือก

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 149, 144, 248),
        foregroundColor: Colors.white,
        title: const Text('เมนูอาหาร'),
      ),
      body:
          selectedShop == null
              // ถ้ายังไม่เลือกร้าน ให้แสดงรายการร้านทั้งหมด
              ? _ShopPicker(
                onSelect: (shop) => setState(() => selectedShop = shop),
              )
              // ถ้าเลือกร้านแล้ว ให้แสดงเมนูของร้านนั้น
              : _ShopMenuView(
                key: ValueKey(selectedShop),
                shopName: selectedShop!,
                onBack: () => setState(() => selectedShop = null),
              ),
    );
  }
}

// ตารางให้เลือกร้าน
class _ShopPicker extends StatelessWidget {
  final ValueChanged<String> onSelect;
  const _ShopPicker({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'เลือกร้านชาบู',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView(
              // จำนวนคอลัมน์ปรับตามความกว้างจอ (มือถือ 2, จอใหญ่มากขึ้น)
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 320,
                childAspectRatio: 0.85,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              children:
                  shopMenus.entries
                      .map(
                        (entry) => InkWell(
                          onTap: () => onSelect(entry.key),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Theme.of(context).colorScheme.surface,
                              boxShadow: const [
                                BoxShadow(blurRadius: 6, color: Colors.black12),
                              ],
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.asset(
                                      entry.value['image'] as String, // รูปร้าน
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                color: Colors.grey[300],
                                                child: const Icon(
                                                  Icons.image_not_supported,
                                                  size: 48,
                                                ),
                                              ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    8,
                                    0,
                                    8,
                                    8,
                                  ),
                                  child: Text(
                                    entry.key, // ชื่อร้าน
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// เมนูของร้านที่เลือก:
// - แถบชิปหมวดติดอยู่ด้านบน แตะแล้วเลื่อนไปที่หมวดนั้น
// - เลื่อนรายการเอง ชิปจะเปลี่ยนตามหมวดที่กำลังดูอยู่
// - รายการแสดงเป็นการ์ดรูป (มือถือ 2 คอลัมน์ จอใหญ่มากขึ้น)
class _ShopMenuView extends StatefulWidget {
  final String shopName;
  final VoidCallback onBack;
  const _ShopMenuView({
    super.key,
    required this.shopName,
    required this.onBack,
  });

  @override
  State<_ShopMenuView> createState() => _ShopMenuViewState();
}

class _ShopMenuViewState extends State<_ShopMenuView> {
  late final Map<String, List<Map<String, String>>> _menus =
      shopMenus[widget.shopName]!['menus']
          as Map<String, List<Map<String, String>>>;
  late final List<String> _categories = _menus.keys.toList();

  final _scrollController = ScrollController();
  final _bodyKey = GlobalKey(); // กรอบรายการเมนู ใช้หาตำแหน่งขอบบน
  late final _sectionKeys = {for (final c in _categories) c: GlobalKey()};
  late final _chipKeys = {for (final c in _categories) c: GlobalKey()};

  late String _active = _categories.first; // หมวดที่ชิปไฮไลต์อยู่
  bool _jumping = false; // กำลังเลื่อนเพราะแตะชิป (ไม่ต้องคำนวณหมวดระหว่างทาง)

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // หาหมวดที่หัวข้ออยู่บนสุดของจอ ณ ตอนนี้
  String _currentCategory() {
    final body = _bodyKey.currentContext?.findRenderObject() as RenderBox?;
    if (body == null || !_scrollController.hasClients) return _active;
    final pos = _scrollController.position;
    // เลื่อนจนสุดแล้ว ให้ไฮไลต์หมวดสุดท้าย (หมวดสุดท้ายสั้นจนขึ้นไปไม่ถึงบนสุด)
    if (pos.pixels >= pos.maxScrollExtent - 4) return _categories.last;

    final top = body.localToGlobal(Offset.zero).dy;
    var current = _categories.first;
    for (final c in _categories) {
      final box =
          _sectionKeys[c]!.currentContext?.findRenderObject() as RenderBox?;
      if (box == null) continue;
      if (box.localToGlobal(Offset.zero).dy - top <= 24) {
        current = c;
      } else {
        break;
      }
    }
    return current;
  }

  void _onScroll() {
    if (_jumping) return;
    final c = _currentCategory();
    if (c != _active) {
      setState(() => _active = c);
      _revealChip(c);
    }
  }

  // เลื่อนแถบชิปให้ชิปที่เลือกอยู่กลางจอ
  void _revealChip(String c) {
    final ctx = _chipKeys[c]!.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      alignment: 0.5,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  // แตะชิป: เลื่อนรายการไปที่หัวข้อหมวดนั้น
  Future<void> _jumpTo(String c) async {
    setState(() => _active = c);
    _revealChip(c);
    final ctx = _sectionKeys[c]!.currentContext;
    if (ctx == null) return;
    _jumping = true;
    await Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
    _jumping = false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ชื่อร้าน + ปุ่มย้อนกลับ
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'เลือกร้านอื่น',
                onPressed: widget.onBack,
              ),
              // Expanded กันชื่อร้านยาว ๆ ล้นจอมือถือ
              Expanded(
                child: Text(
                  widget.shopName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        // แถบชิปหมวด (อยู่นอกส่วนที่เลื่อน จึงติดอยู่ด้านบนเสมอ)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Row(
            children: [
              for (final c in _categories)
                Padding(
                  key: _chipKeys[c],
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(c),
                    selected: c == _active,
                    showCheckmark: false,
                    selectedColor: Colors.deepPurple.shade50,
                    side: BorderSide(
                      color:
                          c == _active
                              ? Colors.deepPurple
                              : Colors.grey.shade300,
                    ),
                    labelStyle: TextStyle(
                      color: c == _active ? Colors.deepPurple : Colors.black87,
                      fontWeight:
                          c == _active ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (_) => _jumpTo(c),
                  ),
                ),
            ],
          ),
        ),
        const Divider(height: 1),
        // รายการเมนูทุกหมวดต่อกัน
        Expanded(
          child: SingleChildScrollView(
            key: _bodyKey,
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final c in _categories) _buildSection(c, _menus[c]!),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // หัวข้อหมวด + ตารางการ์ดเมนูในหมวดนั้น
  Widget _buildSection(String category, List<Map<String, String>> items) {
    return Column(
      key: _sectionKeys[category],
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 10),
          child: Text(
            '$category (${items.length})',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200, // มือถือได้ 2 คอลัมน์
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemCount: items.length,
          itemBuilder:
              (context, i) => _MenuCard(
                name: items[i]['name']!,
                imagePath: items[i]['image']!,
              ),
        ),
      ],
    );
  }
}

// การ์ดเมนู: รูปด้านบน ชื่อด้านล่าง
class _MenuCard extends StatelessWidget {
  final String name; // ชื่อเมนู
  final String imagePath; // รูปภาพเมนู (ใน assets)

  const _MenuCard({required this.name, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // รูปเมนู กินพื้นที่ที่เหลือทั้งหมด ชื่อจึงไม่ล้นการ์ด
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                cacheWidth: 400, // ย่อรูปตอนโหลด ประหยัดหน่วยความจำบนมือถือ
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported),
                    ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
            child: Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
