import 'package:flutter/material.dart';
import 'receipt_api.dart'; // 방금 작성하신 API 파일을 import 합니다.

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  // 테스트에 사용할 고정된 사용자 ID
  final int _testUserId = 999;
  // 가장 최근에 등록된 영수증 ID를 저장할 변수
  int? _lastRegisteredReceiptId;

  // API 호출 결과를 화면에 표시하기 위한 변수
  String _apiResult = '버튼을 눌러 API를 테스트하세요.';

  // API 호출 중인지 상태를 관리 (로딩 인디케이터 표시용)
  bool _isLoading = false;

  // 사용자 경험치 조회 테스트 함수
  void _testXpFetch() async {
    setState(() {
      _isLoading = true;
      _apiResult = '사용자 경험치 조회 중...';
    });

    try {
      final userXp = await ReceiptApi.fetchUserXp(_testUserId);
      _apiResult = '''
[성공] 사용자 경험치 조회
- 레벨: ${userXp.level}
- 총 경험치: ${userXp.totalExp}
      ''';
    } catch (e) {
      _apiResult = '[오류] 사용자 경험치 조회 실패\n$e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 영수증 등록 테스트 함수
  void _testReceiptRegister() async {
    setState(() {
      _isLoading = true;
      _apiResult = '영수증 등록 중...';
    });

    try {
      final result = await ReceiptApi.registerReceiptDirect(
        userId: _testUserId,
        storeName: '테스트 가게',
        totalAmount: 15000,
        categoryCode: 'LOCAL',
      );
      // 다음 테스트를 위해 등록된 ID 저장
      _lastRegisteredReceiptId = result.receiptId;
      _apiResult = '''
[성공] 영수증 등록
- 영수증 ID: ${result.receiptId}
- 획득 경험치: ${result.expAwarded}
- 현재 레벨: ${result.levelAfter}
- 현재 경험치: ${result.totalExpAfter}
      ''';
    } catch (e) {
      _apiResult = '[오류] 영수증 등록 실패\n$e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ID로 영수증 조회 테스트 함수
  void _testFetchReceiptById() async {
    if (_lastRegisteredReceiptId == null) {
      setState(() {
        _apiResult = '먼저 "영수증 등록" 버튼을 눌러 영수증을 등록해주세요.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _apiResult = 'ID로 영수증 조회 중 (ID: $_lastRegisteredReceiptId)...';
    });

    try {
      final item = await ReceiptApi.fetchReceiptById(
        userId: _testUserId,
        receiptId: _lastRegisteredReceiptId!,
      );

      if (item != null) {
        _apiResult = '''
[성공] ID로 영수증 조회
- ID: ${item.id}
- 가게 이름: ${item.storeName}
- 카테고리: ${item.categoryCode}
- 결제 금액: ${item.totalAmount}
        ''';
      } else {
        _apiResult = '[실패] 영수증을 찾을 수 없습니다 (ID: $_lastRegisteredReceiptId).';
      }
    } catch (e) {
      _apiResult = '[오류] ID로 영수증 조회 실패\n$e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KumdoriGrow API 테스트'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // API 테스트 버튼들
            ElevatedButton(
              onPressed: _isLoading ? null : _testXpFetch,
              child: const Text('1. 사용자 경험치 조회'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isLoading ? null : _testReceiptRegister,
              child: const Text('2. 영수증 등록'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isLoading ? null : _testFetchReceiptById,
              child: const Text('3. ID로 영수증 조회'),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            const Text('API 응답 결과:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            // API 결과 표시 영역
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                color: Colors.grey.shade200,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(child: Text(_apiResult)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
