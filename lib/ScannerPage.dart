// ScannerPage.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'receipt_api.dart';
import 'receipt_result.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final ImagePicker _picker = ImagePicker();
  bool _loading = false;

  static const int _userId = 999; // TODO: 로그인 연동 시 교체

  Future<void> _scanReceipt() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() => _loading = true);

      // 1. 영수증 등록 API 호출
      final regResult = await ReceiptApi.registerReceiptDirect(
        userId: _userId,
        storeName: "한돈당",
        totalAmount: 217000,
        categoryCode: "FRANCHISE",
        ocrRaw: null,
      );
      debugPrint("✅ 등록 성공: receiptId=${regResult.receiptId}");

      // 2. 등록된 영수_MascotPainter증의 상세 정보 추가 조회 (ReceiptResultPage에서 필요)
      final item = await ReceiptApi.fetchReceiptById(
        userId: _userId,
        receiptId: regResult.receiptId,
      );
      debugPrint("✅ 조회 성공: ${item?.storeName}");

      if (!mounted) return;

      // 3. [핵심] ReceiptResultPage를 띄우고, 그 페이지가 닫히면서 주는 결과를 기다립니다.
      final finalResultFromReceiptPage = await Navigator.push<RegisterResult?>(
        context,
        MaterialPageRoute(
          builder: (_) => ReceiptResultPage(
            registerResult: regResult,
            receipt: item,
          ),
        ),
      );

      // 4. ReceiptResultPage에서 "확인" 버튼을 눌러 결과(finalResultFromReceiptPage)를 가지고 돌아왔다면,
      //    이제 ScannerPage도 닫으면서 그 결과값을 HomeScreen으로 전달(pop)합니다.
      if (finalResultFromReceiptPage != null && mounted) {
        Navigator.pop(context, finalResultFromReceiptPage);
      }

    } catch (e, stack) {
      debugPrint("❌ 오류 발생: $e");
      debugPrint("STACKTRACE: $stack");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('처리에 실패했습니다: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("영수증 스캔 (테스트용)")),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : ElevatedButton(
          onPressed: _scanReceipt,
          child: const Text("갤러리에서 영수증 선택"),
        ),
      ),
    );
  }
}
