import 'package:flutter/material.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  // 질문 1
  final List<String> jobs = ['중학생', '고등학생', '대학생 / 대학원생', '직장인'];
  List<bool> selectedJobs = [false, false, false, false];

  // 질문 2
  final List<String> regions = ['동구', '서구', '유성구', '중구'];
  List<bool> selectedRegions = [false, false, false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('당신을 알려주세요')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('1. 당신의 직업은 무엇인가요?'),
            ),
            const SizedBox(height: 10),
            ...List.generate(jobs.length, (index) {
              return CheckboxListTile(
                title: Text(jobs[index]),
                value: selectedJobs[index],
                onChanged: (val) {
                  setState(() => selectedJobs[index] = val ?? false);
                },
              );
            }),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('2. 당신이 사는 지역은 어디인가요?'),
            ),
            const SizedBox(height: 10),
            ...List.generate(regions.length, (index) {
              return CheckboxListTile(
                title: Text(regions[index]),
                value: selectedRegions[index],
                onChanged: (val) {
                  setState(() => selectedRegions[index] = val ?? false);
                },
              );
            }),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  // 확인 버튼 눌렀을 때 로직
                  debugPrint('선택된 직업: $selectedJobs');
                  debugPrint('선택된 지역: $selectedRegions');
                },
                child: const Text(
                  '확인',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
