import 'dart:math';
import 'package:flutter/material.dart';
import 'custom_bottom_nav.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  int? selectedIndex; // 어떤 아이템이 선택되었는지 저장
  int tabIndex = 0; // 소비 아이템(0), 치장 아이템(1)

  final List<Map<String, dynamic>> consumableItems = [
    {"name": "랜덤 박스", "count": 3, "icon": "assets/랜덤박스.png"},
    {"name": "경험치 쿠폰", "count": 2, "icon": "assets/경험치 증가.png"},
    {"name": "이벤트 티켓", "count": 1, "icon": "assets/티켓.png"},
    {"name": "랜덤 아이템", "count": 2, "icon": "assets/랜덤 아이템.png"},
    {"name": "랜덤 포인트", "count": 1, "icon": "assets/랜덤 포인트.png"},
  ];

  /// ✅ 랜덤 박스 열기 (API X, 로컬 랜덤 효과)
  Future<void> _openRandomBox() async {
    final reward = 50 + Random().nextInt(251); // 50 ~ 300 포인트 랜덤

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🎁 랜덤 박스 애니메이션
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.8, end: 1.2),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeInOut,
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: Image.asset(
                          "assets/랜덤박스.png",
                          width: 100,
                          height: 100,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    "🎉 축하합니다!",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "$reward 포인트를 획득했습니다.",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "확인",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(
          "보관함",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
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
                child: GestureDetector(
                  onTap: () {
                    final item = consumableItems[selectedIndex!];
                    if (item["name"] == "랜덤 박스") {
                      _openRandomBox(); // ✅ 로컬 랜덤 보상
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("${item["name"]} 은 아직 구현되지 않았습니다.")));
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.orange, Colors.deepOrange],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "✨ 사용하기 ✨",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(1, 1),
                          )
                        ],
                      ),
                    ),
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
                        style:
                        const TextStyle(fontWeight: FontWeight.w600)),
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
