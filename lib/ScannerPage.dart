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

  @override
  void initState() {
    super.initState();
    // 페이지 진입 후 프레임이 그려지고 나서 자동 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scanReceipt();
    });
  }

  Future<void> _scanReceipt() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) {
        // 유저가 취소하면 현재 페이지 닫기
        if (mounted) Navigator.pop(context);
        return;
      }

      setState(() => _loading = true);

      // 1. 영수증 등록 API 호출
      final regResult = await ReceiptApi.registerReceiptDirect(
        userId: _userId,
        storeName: "성심당",
        totalAmount: 32000,
        categoryCode: "FRANCHISE",
        ocrRaw: null,
      );
      debugPrint("✅ 등록 성공: receiptId=${regResult.receiptId}");

      // 2. 등록된 영수증 상세 조회
      final item = await ReceiptApi.fetchReceiptById(
        userId: _userId,
        receiptId: regResult.receiptId,
      );
      debugPrint("✅ 조회 성공: ${item?.storeName}");

      if (!mounted) return;

      // 3. ReceiptResultPage 이동
      final finalResultFromReceiptPage = await Navigator.push<RegisterResult?>(
        context,
        MaterialPageRoute(
          builder: (_) => ReceiptResultPage(
            registerResult: regResult,
            receipt: item,
          ),
        ),
      );

      // 4. ReceiptResultPage에서 확인 버튼을 누른 결과가 있다면 HomeScreen으로 전달
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
      Navigator.pop(context); // 오류 발생 시에도 ScannerPage 닫기
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("영수증 스캔")),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : const Text("갤러리 열리는 중..."),
      ),
    );
  }
}
