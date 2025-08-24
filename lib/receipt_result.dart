// receipt_result.dart
import 'package:flutter/material.dart';
import 'receipt_api.dart';

class ReceiptResultPage extends StatelessWidget {
  final RegisterResult registerResult;
  final ReceiptListItem? receipt; // 카테고리/금액 확인용 (null일 수 있음)

  const ReceiptResultPage({
    super.key,
    required this.registerResult,
    required this.receipt,
  });

  @override
  Widget build(BuildContext context) {
    final int totalPrice = receipt?.totalAmount ?? 0;
    final String category = receipt?.categoryCode.isNotEmpty == true
        ? receipt!.categoryCode
        : "일반";
    final int gainedExp = registerResult.expAwarded;
    final int totalExp = registerResult.totalExpAfter;
    final int currentLevel = registerResult.levelAfter;

    // 레벨 경험치 기준 (가이드: 6~30은 1000XP/레벨, UI용)
    const int expPerLevel = 1000;
    final int expThisLevel = totalExp % expPerLevel;
    final double progress = expPerLevel == 0 ? 0 : expThisLevel / expPerLevel;

    return Scaffold(
      appBar: AppBar(title: const Text("영수증 결과")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            const Text(
              "경험치 보상 결과",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 총 결제금액 + 분류 카드
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const _KeyColumn(labels: ["총 결제금액", "분류"]),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("$totalPrice 원"),
                      const SizedBox(height: 8),
                      Text(category),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 경험치 카드
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("현재 레벨: Lv.$currentLevel",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 12,
                    borderRadius: BorderRadius.circular(8),
                    backgroundColor: Colors.white,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "$expThisLevel / $expPerLevel exp",
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("획득 경험치"),
                      Text("+$gainedExp exp"),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("누적 경험치"),
                      Text("$totalExp exp"),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 매칭 가게 / 신뢰도 표시 (응답에 있을 때만)
            if (registerResult.matchedStoreName.isNotEmpty)
              Text(
                '매칭 가게: ${registerResult.matchedStoreName} '
                    '(신뢰도 ${(registerResult.confidence * 100).toStringAsFixed(1)}%)',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),

            const Spacer(),

            // 확인 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  // SnackBar를 보여주는 것은 좋지만, pop하기 전에 보여줘야 합니다.
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("+$gainedExp 경험치 지급 완료!")),
                  );

                  // [핵심 수정] 그냥 닫는 것이 아니라, registerResult 데이터를 가지고 닫습니다.
                  Navigator.pop(context, registerResult);
                },
                child: const Text("확인"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KeyColumn extends StatelessWidget {
  final List<String> labels;
  const _KeyColumn({required this.labels});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: labels
          .map((t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(t),
      ))
          .toList(),
    );
  }
}
