import 'package:flutter/material.dart';

// ตัวอย่างข้อมูลร้านและเมนู (เพิ่ม url รูปภาพ)
final shopMenus = {
  'เฝอแฟมิลี่ ชาบู กำแพงแสน': {
    'image': 'assets/images/pho.jpg', // รูปร้าน
    'menus': {
      'น้ำจิ้ม': [
        {'name': 'ซุปน้ำใส',  'image': 'assets/images/menu/ซุปน้ำใส.jpg'},
        {'name': 'ซุปน้ำดำ',  'image': 'assets/images/menu/ซุปน้ำดำ.jpg'},
        {'name': 'ซุปทงคตสึ',  'image': 'assets/images/menu/ซุปทงคตสึ.jpg'},
        {'name': 'ซุปต้มยำ',  'image': 'assets/images/menu/ซุปต้มยำ.jpg'},
        {'name': 'ซุปต้มแซ่บ',  'image': 'assets/images/menu/ซุปต้มแซ่บ.jpg'},
        {'name': 'ซุปต้มยำ',  'image': 'assets/images/menu/ซุปต้มยำ.jpg'},
      ],
      'เนื้อและลูกชิ้น': [
        {'name': 'เบคอน',  'image': 'assets/images/menu/เบคอน.jpg'},
        {'name': 'หมูสันคอ',  'image': 'assets/images/menu/หมูสันคอ.jpg'},
        {'name': 'หมูไม้ไผ่',  'image': 'assets/images/menu/หมูไม้ไผ่.jpg'},
        {'name': 'ไก่สไลด์',  'image': 'assets/images/menu/ไก่สไลด์.jpg'},
        {'name': 'สันนอก',  'image': 'assets/images/menu/สันนอก.jpg'},
        {'name': 'ตับ',  'image': 'assets/images/menu/ตับ.jpg'},
        {'name': 'ปลาดอลลี่',  'image': 'assets/images/menu/ปลาดอลลี่.jpg'},
        {'name': 'กุ้ง',  'image': 'assets/images/menu/กุ้ง.jpg'},
        {'name': 'ปลาหมึก',  'image': 'assets/images/menu/ปลาหมึก.jpg'},
        {'name': 'หอยแมลงภู่',  'image': 'assets/images/menu/หอยแมลงภู่.jpg'},
        {'name': 'สาหร่ายทรงเครื่อง',  'image': 'assets/images/menu/สาหร่ายทรงเครื่อง.jpg'},
        {'name': 'เกี๊ยวปลา',  'image': 'assets/images/menu/เกี๊ยวปลา.jpg'},
        {'name': 'เกี๊ยวหมู',  'image': 'assets/images/menu/เกี๋ยวหมู.jpg'},
        {'name': 'ไข่ไก่',  'image': 'assets/images/menu/ไข่ไก่.jpg'},
        {'name': 'เต้าหู้ปลา',  'image': 'assets/images/menu/เต้าหู้ปลา.jpg'},
        {'name': 'ฟองเต้าหู้ซีฟู๊ด',  'image': 'assets/images/menu/ฟองเต้าหู่ซีฟู๊ด.jpg'},
        {'name': 'ลูกชิ้นชีส',  'image': 'assets/images/menu/ลูกชิ้นชีส.jpg'},
        {'name': 'ชีส',  'image': 'assets/images/menu/ชีส.jpg'},
        {'name': 'เต้าหู้ไข่',  'image': 'assets/images/menu/เต้าหู้ไข่.jpg'},
      ],
      'ผักและเส้น': [
        {'name': 'กวางตุ้ง',  'image': 'assets/images/menu/กวางตุ้ง.jpg'},
        {'name': 'ผักบุ้ง',  'image': 'assets/images/menu/ผักบุ้ง.jpg'},
        {'name': 'ผักกาดขาว',  'image': 'assets/images/menu/ผักกาดขาว.jpg'},
        {'name': 'ขึ้นฉ่าย',  'image': 'assets/images/menu/ขึ้นฉ่าย.jpg'},
        {'name': 'สาหร่ายวากาเมะ',  'image': 'assets/images/menu/สาหร่ายวากาเมะ.jpg'},
        {'name': 'ข้าวโพดอ่อน',  'image': 'assets/images/menu/ข้าวโพดอ่อน.jpg'},
        {'name': 'ข้าวโพด',  'image': 'assets/images/menu/ข้าวโพด.jpg'},
        {'name': 'แครอท',  'image': 'assets/images/menu/แครอท.jpg'},
        {'name': 'เห็ดเข็มทอง',  'image': 'assets/images/menu/เห็ดเข็มทอง.jpg'},
        {'name': 'เห็ดหอม',  'image': 'assets/images/menu/เห็ดหอม.jpg'},
        {'name': 'เห็ดหูหนูขาว',  'image': 'assets/images/menu/เห็ดหูหนูขาว.jpg'},
        {'name': 'เห็ดหูหนูดำ',  'image': 'assets/images/menu/เห็ดหูหนูดำ.jpg'},
        {'name': 'เห็ดชิเมจิ',  'image': 'assets/images/menu/เห็ดชิเมจิ.jpg'},
        {'name': 'เห็ดออรินจิ',  'image': 'assets/images/menu/เห็ดออรินจิ.jpg'},
        {'name': 'หมี่หยก',  'image': 'assets/images/menu/หมี่หยก.jpg'},
        {'name': 'อุด้ง',  'image': 'assets/images/menu/อุด้ง.jpg'},
        {'name': 'วุ้นเส้น',  'image': 'assets/images/menu/เส้นญี่ปุ่น.jpg'},
        {'name': 'เส้นปลา',  'image': 'assets/images/menu/เส้นปลา.jpg'},
      ],
      'น้ำและของหวาน': [
        {'name': 'ไอศกรีม',  'image': 'assets/images/menu/ไอศครีม.jpg'},
        {'name': 'เป๊ปซี่',  'image': 'assets/images/menu/เป๊ปซี่.jpg'},
        {'name': 'เซเว่นอัพ',  'image': 'assets/images/menu/เซเว่นอัพ.jpg'},
        {'name': 'มิรินด้า รสสตอเบอรี่',  'image': 'assets/images/menu/มิรินด้า รสสตรอเบอรี่.jpg'},
        {'name': 'มิรินด้า รสส้ม',  'image': 'assets/images/menu/มิรินด้า รสส้ม.jpg'},
      ],
      'ของกินเล่นและน้ำจิ้ม': [
        {'name': 'เฟรนช์ฟรายส์',  'image': 'assets/images/menu/เฟรนฟรายส์.jpg'},
        {'name': 'เกี๊ยวซ่า',  'image': 'assets/images/menu/เกี๊ยวซ่า.jpg'},
        {'name': 'ปูอัดทอด',  'image': 'assets/images/menu/ปูอัดทอด.jpg'},
        {'name': 'เห็ดเข็มทองทอด',  'image': 'assets/images/menu/เห็ดเข็มทองทอด.jpg'},
        {'name': 'หนังไก่ทอด',  'image': 'assets/images/menu/หนังไก่ทอด.jpg'},
        {'name': 'นักเก็ตไก่',  'image': 'assets/images/menu/นักเก็ตไก่.jpg'},
        {'name': 'ข้าวผัด',  'image': 'assets/images/menu/ข้าวผัด.jpg'},
        {'name': 'ซูชิ',  'image': 'assets/images/menu/ซูชิ.jpg'},
        {'name': 'ไข่หวานญี่ปุ่น',  'image': 'assets/images/menu/ไข่หวานญี่ปุ่น.jpg'},
        {'name': 'น้ำจิ้มสุกี้',  'image': 'assets/images/menu/น้ำจิ้มสุกี้.jpg'},
        {'name': 'น้ำจิ้มซีฟู้ด',  'image': 'assets/images/menu/น้ำจิ้มซีฟู๊ด.jpg'},
        {'name': 'น้ำจิ้มงา',  'image': 'assets/images/menu/น้ำจิ้มงา.jpg'},
        {'name': 'น้ำจิ้มพอนสึ',  'image': 'assets/images/menu/น้ำจิ้มพอนสึ.jpg'},
        {'name': 'น้ำจิ้มแจ่ว',  'image': 'assets/images/menu/น้ำจิ้มแจ่ว.jpg'},
        {'name': 'น้ำจิ้มสไปซี่',  'image': 'assets/images/menu/น้ำจิ้มสไปซี่.jpg'},
      ],
    }
  },
  'Wiyaki ชาบู&ปิ้งย่าง กำแพงแสน': {
    'image': 'assets/images/wiyaki.jpeg',
    'menus': {
      'น้ำจิ้ม': [
        {'name': 'ซุปน้ำใส',  'image': 'assets/images/menu/ซุปน้ำใส.jpg'},
        {'name': 'ซุปน้ำดำ',  'image': 'assets/images/menu/ซุปน้ำดำ.jpg'},
        {'name': 'ซุปทงคตสึ',  'image': 'assets/images/menu/ซุปทงคตสึ.jpg'},
        {'name': 'ซุปต้มยำ',  'image': 'assets/images/menu/ซุปต้มยำ.jpg'},
        {'name': 'ซุปต้มแซ่บ',  'image': 'assets/images/menu/ซุปต้มแซ่บ.jpg'},
        {'name': 'ซุปต้มยำ',  'image': 'assets/images/menu/ซุปต้มยำ.jpg'},
      ],
      'เนื้อและลูกชิ้น': [
        {'name': 'เบคอน',  'image': 'assets/images/menu/เบคอน.jpg'},
        {'name': 'หมูสันคอ',  'image': 'assets/images/menu/หมูสันคอ.jpg'},
        {'name': 'หมูไม้ไผ่',  'image': 'assets/images/menu/หมูไม้ไผ่.jpg'},
        {'name': 'ไก่สไลด์',  'image': 'assets/images/menu/ไก่สไลด์.jpg'},
        {'name': 'สันนอก',  'image': 'assets/images/menu/สันนอก.jpg'},
        {'name': 'ตับ',  'image': 'assets/images/menu/ตับ.jpg'},
        {'name': 'ปลาดอลลี่',  'image': 'assets/images/menu/ปลาดอลลี่.jpg'},
        {'name': 'กุ้ง',  'image': 'assets/images/menu/กุ้ง.jpg'},
        {'name': 'ปลาหมึก',  'image': 'assets/images/menu/ปลาหมึก.jpg'},
        {'name': 'หอยแมลงภู่',  'image': 'assets/images/menu/หอยแมลงภู่.jpg'},
        {'name': 'สาหร่ายทรงเครื่อง',  'image': 'assets/images/menu/สาหร่ายทรงเครื่อง.jpg'},
        {'name': 'เกี๊ยวปลา',  'image': 'assets/images/menu/เกี๊ยวปลา.jpg'},
        {'name': 'เกี๊ยวหมู',  'image': 'assets/images/menu/เกี๋ยวหมู.jpg'},
        {'name': 'ไข่ไก่',  'image': 'assets/images/menu/ไข่ไก่.jpg'},
        {'name': 'เต้าหู้ปลา',  'image': 'assets/images/menu/เต้าหู้ปลา.jpg'},
        {'name': 'ฟองเต้าหู้ซีฟู๊ด',  'image': 'assets/images/menu/ฟองเต้าหู่ซีฟู๊ด.jpg'},
        {'name': 'ลูกชิ้นชีส',  'image': 'assets/images/menu/ลูกชิ้นชีส.jpg'},
        {'name': 'ชีส',  'image': 'assets/images/menu/ชีส.jpg'},
        {'name': 'เต้าหู้ไข่',  'image': 'assets/images/menu/เต้าหู้ไข่.jpg'},
      ],
      'ผักและเส้น': [
        {'name': 'กวางตุ้ง',  'image': 'assets/images/menu/กวางตุ้ง.jpg'},
        {'name': 'ผักบุ้ง',  'image': 'assets/images/menu/ผักบุ้ง.jpg'},
        {'name': 'ผักกาดขาว',  'image': 'assets/images/menu/ผักกาดขาว.jpg'},
        {'name': 'ขึ้นฉ่าย',  'image': 'assets/images/menu/ขึ้นฉ่าย.jpg'},
        {'name': 'สาหร่ายวากาเมะ',  'image': 'assets/images/menu/สาหร่ายวากาเมะ.jpg'},
        {'name': 'ข้าวโพดอ่อน',  'image': 'assets/images/menu/ข้าวโพดอ่อน.jpg'},
        {'name': 'ข้าวโพด',  'image': 'assets/images/menu/ข้าวโพด.jpg'},
        {'name': 'แครอท',  'image': 'assets/images/menu/แครอท.jpg'},
        {'name': 'เห็ดเข็มทอง',  'image': 'assets/images/menu/เห็ดเข็มทอง.jpg'},
        {'name': 'เห็ดหอม',  'image': 'assets/images/menu/เห็ดหอม.jpg'},
        {'name': 'เห็ดหูหนูขาว',  'image': 'assets/images/menu/เห็ดหูหนูขาว.jpg'},
        {'name': 'เห็ดหูหนูดำ',  'image': 'assets/images/menu/เห็ดหูหนูดำ.jpg'},
        {'name': 'เห็ดชิเมจิ',  'image': 'assets/images/menu/เห็ดชิเมจิ.jpg'},
        {'name': 'เห็ดออรินจิ',  'image': 'assets/images/menu/เห็ดออรินจิ.jpg'},
        {'name': 'หมี่หยก',  'image': 'assets/images/menu/หมี่หยก.jpg'},
        {'name': 'อุด้ง',  'image': 'assets/images/menu/อุด้ง.jpg'},
        {'name': 'วุ้นเส้น',  'image': 'assets/images/menu/เส้นญี่ปุ่น.jpg'},
        {'name': 'เส้นปลา',  'image': 'assets/images/menu/เส้นปลา.jpg'},
      ],
      'น้ำและของหวาน': [
        {'name': 'ไอศกรีม',  'image': 'assets/images/menu/ไอศครีม.jpg'},
        {'name': 'เป๊ปซี่',  'image': 'assets/images/menu/เป๊ปซี่.jpg'},
        {'name': 'เซเว่นอัพ',  'image': 'assets/images/menu/เซเว่นอัพ.jpg'},
        {'name': 'มิรินด้า รสสตอเบอรี่',  'image': 'assets/images/menu/มิรินด้า รสสตรอเบอรี่.jpg'},
        {'name': 'มิรินด้า รสส้ม',  'image': 'assets/images/menu/มิรินด้า รสส้ม.jpg'},
      ],
      'ของกินเล่นและน้ำจิ้ม': [
        {'name': 'เฟรนช์ฟรายส์',  'image': 'assets/images/menu/เฟรนฟรายส์.jpg'},
        {'name': 'เกี๊ยวซ่า',  'image': 'assets/images/menu/เกี๊ยวซ่า.jpg'},
        {'name': 'ปูอัดทอด',  'image': 'assets/images/menu/ปูอัดทอด.jpg'},
        {'name': 'เห็ดเข็มทองทอด',  'image': 'assets/images/menu/เห็ดเข็มทองทอด.jpg'},
        {'name': 'หนังไก่ทอด',  'image': 'assets/images/menu/หนังไก่ทอด.jpg'},
        {'name': 'นักเก็ตไก่',  'image': 'assets/images/menu/นักเก็ตไก่.jpg'},
        {'name': 'ข้าวผัด',  'image': 'assets/images/menu/ข้าวผัด.jpg'},
        {'name': 'ซูชิ',  'image': 'assets/images/menu/ซูชิ.jpg'},
        {'name': 'ไข่หวานญี่ปุ่น',  'image': 'assets/images/menu/ไข่หวานญี่ปุ่น.jpg'},
        {'name': 'น้ำจิ้มสุกี้',  'image': 'assets/images/menu/น้ำจิ้มสุกี้.jpg'},
        {'name': 'น้ำจิ้มซีฟู้ด',  'image': 'assets/images/menu/น้ำจิ้มซีฟู๊ด.jpg'},
        {'name': 'น้ำจิ้มงา',  'image': 'assets/images/menu/น้ำจิ้มงา.jpg'},
        {'name': 'น้ำจิ้มพอนสึ',  'image': 'assets/images/menu/น้ำจิ้มพอนสึ.jpg'},
        {'name': 'น้ำจิ้มแจ่ว',  'image': 'assets/images/menu/น้ำจิ้มแจ่ว.jpg'},
        {'name': 'น้ำจิ้มสไปซี่',  'image': 'assets/images/menu/น้ำจิ้มสไปซี่.jpg'},
      ],
    }
  },
  'สุกี้ตี๋น้อย Meet and Eat นครปฐม': {
    'image': 'assets/images/teenoi.jpg',
    'menus': {
      'น้ำจิ้ม': [
        {'name': 'ซุปน้ำใส',  'image': 'assets/images/menu/ซุปน้ำใส.jpg'},
        {'name': 'ซุปน้ำดำ',  'image': 'assets/images/menu/ซุปน้ำดำ.jpg'},
        {'name': 'ซุปทงคตสึ',  'image': 'assets/images/menu/ซุปทงคตสึ.jpg'},
        {'name': 'ซุปต้มยำ',  'image': 'assets/images/menu/ซุปต้มยำ.jpg'},
        {'name': 'ซุปต้มแซ่บ',  'image': 'assets/images/menu/ซุปต้มแซ่บ.jpg'},
        {'name': 'ซุปต้มยำ',  'image': 'assets/images/menu/ซุปต้มยำ.jpg'},
      ],
      'เนื้อและลูกชิ้น': [
        {'name': 'เบคอน',  'image': 'assets/images/menu/เบคอน.jpg'},
        {'name': 'หมูสันคอ',  'image': 'assets/images/menu/หมูสันคอ.jpg'},
        {'name': 'หมูไม้ไผ่',  'image': 'assets/images/menu/หมูไม้ไผ่.jpg'},
        {'name': 'ไก่สไลด์',  'image': 'assets/images/menu/ไก่สไลด์.jpg'},
        {'name': 'สันนอก',  'image': 'assets/images/menu/สันนอก.jpg'},
        {'name': 'ตับ',  'image': 'assets/images/menu/ตับ.jpg'},
        {'name': 'ปลาดอลลี่',  'image': 'assets/images/menu/ปลาดอลลี่.jpg'},
        {'name': 'กุ้ง',  'image': 'assets/images/menu/กุ้ง.jpg'},
        {'name': 'ปลาหมึก',  'image': 'assets/images/menu/ปลาหมึก.jpg'},
        {'name': 'หอยแมลงภู่',  'image': 'assets/images/menu/หอยแมลงภู่.jpg'},
        {'name': 'สาหร่ายทรงเครื่อง',  'image': 'assets/images/menu/สาหร่ายทรงเครื่อง.jpg'},
        {'name': 'เกี๊ยวปลา',  'image': 'assets/images/menu/เกี๊ยวปลา.jpg'},
        {'name': 'เกี๊ยวหมู',  'image': 'assets/images/menu/เกี๋ยวหมู.jpg'},
        {'name': 'ไข่ไก่',  'image': 'assets/images/menu/ไข่ไก่.jpg'},
        {'name': 'เต้าหู้ปลา',  'image': 'assets/images/menu/เต้าหู้ปลา.jpg'},
        {'name': 'ฟองเต้าหู้ซีฟู๊ด',  'image': 'assets/images/menu/ฟองเต้าหู่ซีฟู๊ด.jpg'},
        {'name': 'ลูกชิ้นชีส',  'image': 'assets/images/menu/ลูกชิ้นชีส.jpg'},
        {'name': 'ชีส',  'image': 'assets/images/menu/ชีส.jpg'},
        {'name': 'เต้าหู้ไข่',  'image': 'assets/images/menu/เต้าหู้ไข่.jpg'},
      ],
      'ผักและเส้น': [
        {'name': 'กวางตุ้ง',  'image': 'assets/images/menu/กวางตุ้ง.jpg'},
        {'name': 'ผักบุ้ง',  'image': 'assets/images/menu/ผักบุ้ง.jpg'},
        {'name': 'ผักกาดขาว',  'image': 'assets/images/menu/ผักกาดขาว.jpg'},
        {'name': 'ขึ้นฉ่าย',  'image': 'assets/images/menu/ขึ้นฉ่าย.jpg'},
        {'name': 'สาหร่ายวากาเมะ',  'image': 'assets/images/menu/สาหร่ายวากาเมะ.jpg'},
        {'name': 'ข้าวโพดอ่อน',  'image': 'assets/images/menu/ข้าวโพดอ่อน.jpg'},
        {'name': 'ข้าวโพด',  'image': 'assets/images/menu/ข้าวโพด.jpg'},
        {'name': 'แครอท',  'image': 'assets/images/menu/แครอท.jpg'},
        {'name': 'เห็ดเข็มทอง',  'image': 'assets/images/menu/เห็ดเข็มทอง.jpg'},
        {'name': 'เห็ดหอม',  'image': 'assets/images/menu/เห็ดหอม.jpg'},
        {'name': 'เห็ดหูหนูขาว',  'image': 'assets/images/menu/เห็ดหูหนูขาว.jpg'},
        {'name': 'เห็ดหูหนูดำ',  'image': 'assets/images/menu/เห็ดหูหนูดำ.jpg'},
        {'name': 'เห็ดชิเมจิ',  'image': 'assets/images/menu/เห็ดชิเมจิ.jpg'},
        {'name': 'เห็ดออรินจิ',  'image': 'assets/images/menu/เห็ดออรินจิ.jpg'},
        {'name': 'หมี่หยก',  'image': 'assets/images/menu/หมี่หยก.jpg'},
        {'name': 'อุด้ง',  'image': 'assets/images/menu/อุด้ง.jpg'},
        {'name': 'วุ้นเส้น',  'image': 'assets/images/menu/เส้นญี่ปุ่น.jpg'},
        {'name': 'เส้นปลา',  'image': 'assets/images/menu/เส้นปลา.jpg'},
      ],
      'น้ำและของหวาน': [
        {'name': 'ไอศกรีม',  'image': 'assets/images/menu/ไอศครีม.jpg'},
        {'name': 'เป๊ปซี่',  'image': 'assets/images/menu/เป๊ปซี่.jpg'},
        {'name': 'เซเว่นอัพ',  'image': 'assets/images/menu/เซเว่นอัพ.jpg'},
        {'name': 'มิรินด้า รสสตอเบอรี่',  'image': 'assets/images/menu/มิรินด้า รสสตรอเบอรี่.jpg'},
        {'name': 'มิรินด้า รสส้ม',  'image': 'assets/images/menu/มิรินด้า รสส้ม.jpg'},
      ],
      'ของกินเล่นและน้ำจิ้ม': [
        {'name': 'เฟรนช์ฟรายส์',  'image': 'assets/images/menu/เฟรนฟรายส์.jpg'},
        {'name': 'เกี๊ยวซ่า',  'image': 'assets/images/menu/เกี๊ยวซ่า.jpg'},
        {'name': 'ปูอัดทอด',  'image': 'assets/images/menu/ปูอัดทอด.jpg'},
        {'name': 'เห็ดเข็มทองทอด',  'image': 'assets/images/menu/เห็ดเข็มทองทอด.jpg'},
        {'name': 'หนังไก่ทอด',  'image': 'assets/images/menu/หนังไก่ทอด.jpg'},
        {'name': 'นักเก็ตไก่',  'image': 'assets/images/menu/นักเก็ตไก่.jpg'},
        {'name': 'ข้าวผัด',  'image': 'assets/images/menu/ข้าวผัด.jpg'},
        {'name': 'ซูชิ',  'image': 'assets/images/menu/ซูชิ.jpg'},
        {'name': 'ไข่หวานญี่ปุ่น',  'image': 'assets/images/menu/ไข่หวานญี่ปุ่น.jpg'},
        {'name': 'น้ำจิ้มสุกี้',  'image': 'assets/images/menu/น้ำจิ้มสุกี้.jpg'},
        {'name': 'น้ำจิ้มซีฟู้ด',  'image': 'assets/images/menu/น้ำจิ้มซีฟู๊ด.jpg'},
        {'name': 'น้ำจิ้มงา',  'image': 'assets/images/menu/น้ำจิ้มงา.jpg'},
        {'name': 'น้ำจิ้มพอนสึ',  'image': 'assets/images/menu/น้ำจิ้มพอนสึ.jpg'},
        {'name': 'น้ำจิ้มแจ่ว',  'image': 'assets/images/menu/น้ำจิ้มแจ่ว.jpg'},
        {'name': 'น้ำจิ้มสไปซี่',  'image': 'assets/images/menu/น้ำจิ้มสไปซี่.jpg'},
      ],
    }
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: selectedShop == null
            // ถ้ายังไม่เลือกร้าน ให้แสดงรายการร้านทั้งหมด
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('เลือกร้านชาบู', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: 1.0,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      children: shopMenus.entries.map((entry) => InkWell(
                        onTap: () => setState(() => selectedShop = entry.key), // เมื่อกดร้าน ให้แสดงเมนูของร้านนั้น
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Theme.of(context).colorScheme.surface,
                            boxShadow: const [BoxShadow(blurRadius: 6, color: Colors.black12)],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.asset(
                                    entry.value['image'] as String, // รูปร้าน
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
                              Text(entry.key, textAlign: TextAlign.center), // ชื่อร้าน
                            ],
                          ),
                        ),
                      )).toList(),
                    ),
                  ),
                ],
              )
            // ถ้าเลือกร้านแล้ว ให้แสดงเมนูของร้านนั้น
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => setState(() => selectedShop = null), // กลับไปเลือกร้านใหม่
                      ),
                      Text(selectedShop!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      children: (shopMenus[selectedShop]!['menus'] as Map<String, dynamic>).entries.map<Widget>((entry) {
                        final category = entry.key; // หมวดหมู่เมนู เช่น "ชาบู", "เครื่องดื่ม"
                        final items = entry.value as List; // รายการเมนูในหมวดนั้น
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(category, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                            const SizedBox(height: 8),
                            ...items.map<Widget>((item) => _MenuCard(
                                  name: item['name'] as String,
                                  imageUrl: item['image'] as String,
                                )),
                            const SizedBox(height: 16),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// การ์ดแสดงเมนูแต่ละรายการ
class _MenuCard extends StatelessWidget {
  final String name;       // ชื่อเมนู
  final String imageUrl;   // รูปภาพเมนู

  const _MenuCard({
    required this.name,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // รูปเมนู
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 56,
                height: 56,
                color: Colors.grey[300],
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // ชื่อเมนู
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
