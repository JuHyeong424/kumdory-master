import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'custom_bottom_nav.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  int? selectedIndex; // 어떤 아이템이 선택되었는지 저장
  int tabIndex = 0; // 소비 아이템(0), 치장 아이템(1)

  final String baseUrl = "http://3.36.54.191:8082/api"; // ✅ 서버 주소

  final List<Map<String, dynamic>> consumableItems = [
    {"name": "랜덤 박스", "count": 3, "icon": "assets/랜덤박스.png"},
    {"name": "경험치 쿠폰", "count": 2, "icon": "assets/경험치 증가.png"},
    {"name": "이벤트 티켓", "count": 1, "icon": "assets/티켓.png"},
    {"name": "랜덤 아이템", "count": 2, "icon": "assets/랜덤 아이템.png"},
    {"name": "랜덤 포인트", "count": 1, "icon": "assets/랜덤 포인트.png"},
  ];

  Future<void> _openRandomBox() async {
    try {
      final response = await http.post(Uri.parse("$baseUrl/rewards/open"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"userId": 1})); // ✅ 로그인 연동 후 userId 수정

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reward = data["totalRewardPoints"] ?? 0;

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("🎁 보상 획득!"),
            content: Text("포인트 박스에서 ${reward}p를 얻었습니다."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("확인"),
              ),
            ],
          ),
        );
      } else if (response.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("운영환경에서는 박스를 직접 열 수 없습니다.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("실패: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("에러 발생: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("보관함",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          const SizedBox(height: 9),
          _buildTabs(),
          const SizedBox(height: 16),

          // 아이템 목록
          Expanded(child: _buildItemGrid()),

          // 하단 버튼 (아이템 선택했을 때만 보이게)
          if (selectedIndex != null)
            SafeArea(
              minimum: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final item = consumableItems[selectedIndex!];
                    if (item["name"] == "랜덤 박스") {
                      _openRandomBox(); // ✅ 상자깡 API 호출
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("${item["name"]} 은 아직 구현되지 않았습니다.")));
                    }
                  },
                  child: const Text(
                    "사용하기",
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 2),
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTab("소비 아이템", 0),
          const SizedBox(width: 20),
          _buildTab("치장아이템", 1),
        ],
      ),
    );
  }

  Widget _buildItemGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
      ),
      itemCount: consumableItems.length,
      itemBuilder: (context, index) {
        final item = consumableItems[index];
        final isSelected = selectedIndex == index;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedIndex = index;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFE0B7),
              borderRadius: BorderRadius.circular(16),
              border: isSelected
                  ? Border.all(color: Colors.orange, width: 3)
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(item["icon"], width: 40, height: 40),
                    const SizedBox(height: 6),
                    Text(item["name"],
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                Positioned(
                  right: 6,
                  top: 6,
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.white,
                    child: Text(
                      "${item["count"]}",
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTab(String text, int index) {
    final isSelected = tabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          tabIndex = index;
        });
      },
      child: Column(
        children: [
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isSelected ? Colors.orange : Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          if (isSelected)
            Container(height: 3, width: 80, color: Colors.orange),
        ],
      ),
    );
  }
}
