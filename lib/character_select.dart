// character_select.dart
import 'package:flutter/material.dart';

class CharacterSelectSheet extends StatefulWidget {
  const CharacterSelectSheet({super.key});

  @override
  State<CharacterSelectSheet> createState() => _CharacterSelectSheetState();
}

class _CharacterSelectSheetState extends State<CharacterSelectSheet> {
  final PageController _pageController = PageController(viewportFraction: 0.65);
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> characters = [
    {"name": "도르", "level": 12, "image": "assets/도르 1.png"},
    {"name": "네브", "level": 12, "image": "assets/네브 2.png"},
    {"name": "꿈돌이", "level": 10, "image": "assets/꿈돌이 2.png"},
    {"name": "꿈누이", "level": 10, "image": "assets/꿈누리 1.png"},
    {"name": "꿈둥이", "level": 10, "image": "assets/꿈둥이 1.png"},
    {"name": "꿈결이", "level": 10, "image": "assets/꿈결이 1.png"},
    {"name": "몽몽", "level": 10, "image": "assets/몽몽 1.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 닫기 버튼
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "캐릭터를 선택해주세요",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            "꿈시 패밀리의 선물을 받아봐요",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // PageView (슬라이드 캐릭터 선택)
          SizedBox(
            height: 220,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              itemCount: characters.length,
              itemBuilder: (context, index) {
                final character = characters[index];
                final selected = index == _selectedIndex;
                return _buildCharacterCard(
                  name: character["name"],
                  level: character["level"],
                  imagePath: character["image"],
                  selected: selected,
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // 선택 버튼
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(context, characters[_selectedIndex]["name"]);
              },
              child: const Text(
                "선택",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterCard({
    required String name,
    required int level,
    required String imagePath,
    required bool selected,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? Colors.orange : Colors.grey.shade300,
          width: 2,
        ),
        boxShadow: [
          if (selected)
            BoxShadow(
              color: Colors.orange.withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "$name Lv.$level",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: selected ? Colors.orange : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "캐쉬 포인트",
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
