// receipt_api.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ParseResult {
  final String storeName;
  final int totalPrice;
  final String rawText;
  final double confidence;

  ParseResult({
    required this.storeName,
    required this.totalPrice,
    required this.rawText,
    required this.confidence,
  });
}

class RegisterResult {
  final int receiptId;
  final int expAwarded;
  final int totalExpAfter;
  final int levelAfter;
  final String matchedStoreName;
  final double confidence;

  RegisterResult({
    required this.receiptId,
    required this.expAwarded,
    required this.totalExpAfter,
    required this.levelAfter,
    required this.matchedStoreName,
    required this.confidence,
  });
}

class ReceiptListItem {
  final int id;
  final String storeName;
  final String categoryCode;
  final int totalAmount;
  final int expAwarded;

  ReceiptListItem({
    required this.id,
    required this.storeName,
    required this.categoryCode,
    required this.totalAmount,
    required this.expAwarded,
  });
}

class UserXp {
  final int totalExp;
  final int level;

  UserXp({required this.totalExp, required this.level});
}

class ReceiptApi {
  // ⚠️ 여기에는 절대 '/api'를 붙이지 않습니다. (폴백에서 붙여 드림)
  static const String _host = 'http://3.36.54.191:8082';
  // 우선순위: /api → /
  static const List<String> _prefixes = ['/api', ''];
  static const Duration _timeout = Duration(seconds: 15);

  static Map<String, String> get _jsonHeaders =>
      const {'Content-Type': 'application/json'};

  // ────────────────────────────────────────────────────────────────────────────
  // 내부 공통: POST/GET 폴백 로직
  // ────────────────────────────────────────────────────────────────────────────
  static Future<http.Response> _postJsonWithFallback(
      String path, {
        Map<String, dynamic>? body,
      }) async {
    http.Response? last;
    final encoded = jsonEncode(body ?? {});
    for (final p in _prefixes) {
      final url = '$_host$p$path';
      try {
        debugPrint('📤 POST $url  body=$encoded');
        final res = await http
            .post(Uri.parse(url), headers: _jsonHeaders, body: encoded)
            .timeout(_timeout);
        // 404는 경로 불일치 가능성 → 다음 프리픽스로 자동 재시도
        if (res.statusCode == 404) {
          debugPrint('⚠️ 404 on $url, retrying with next prefix...');
          last = res;
          continue;
        }
        return res;
      } catch (e) {
        debugPrint('❗ POST failed $url  error=$e');
        last = null;
        // 네트워크 에러면 다음 prefix로 계속 시도
        continue;
      }
    }
    if (last != null) return last!;
    throw Exception('모든 경로에서 POST 실패: $path');
  }

  static Future<http.Response> _getWithFallback(
      String path, {
        Map<String, String>? query,
      }) async {
    http.Response? last;
    for (final p in _prefixes) {
      final uri = Uri.parse('$_host$p$path').replace(queryParameters: query);
      try {
        debugPrint('📥 GET $uri');
        final res = await http.get(uri).timeout(_timeout);
        if (res.statusCode == 404) {
          debugPrint('⚠️ 404 on $uri, retrying with next prefix...');
          last = res;
          continue;
        }
        return res;
      } catch (e) {
        debugPrint('❗ GET failed $uri  error=$e');
        last = null;
        continue;
      }
    }
    if (last != null) return last!;
    throw Exception('모든 경로에서 GET 실패: $path');
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 1) OCR 파싱 (현재 비활성: 서버가 빈 결과를 반환)
  // ────────────────────────────────────────────────────────────────────────────
  static Future<ParseResult> parseReceiptDummy() async {
    // 서버가 현재 비활성이라, 앱에서는 사용하지 않도록 더미만 유지
    return ParseResult(
      storeName: '',
      totalPrice: 0,
      rawText: '',
      confidence: 0.0,
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 2) 영수증 등록 (가이드: ocrRaw는 null 또는 문자열)
  //    여기서는 OCR 생략 케이스를 기본으로 지원 (ocrRaw=null 권장)
  // ────────────────────────────────────────────────────────────────────────────
  static Future<RegisterResult> registerReceiptDirect({
    required int userId,
    required String storeName,
    required int totalAmount,
    required String categoryCode, // FRANCHISE / LOCAL / MARKET
    String? ocrRaw, // null 권장
  }) async {
    final res = await _postJsonWithFallback(
      '/receipts',
      body: {
        'userId': userId,
        'storeName': storeName,
        'totalAmount': totalAmount,
        'categoryCode': categoryCode,
        'ocrRaw': ocrRaw, // 가이드 준수: null 또는 문자열
      },
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('영수증 등록 실패 (${res.statusCode}) : ${res.body}');
    }

    final data = jsonDecode(res.body);
    return RegisterResult(
      receiptId: (data['receiptId'] ?? 0) as int,
      expAwarded: (data['expAwarded'] ?? 0) as int,
      totalExpAfter: (data['totalExpAfter'] ?? 0) as int,
      levelAfter: (data['levelAfter'] ?? 1) as int,
      matchedStoreName: (data['matchedStoreName'] ?? '') as String,
      confidence: ((data['confidence'] ?? 0.0) as num).toDouble(),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 3) 등록된 영수증 조회 (페이지에서 id 찾아서 1건 반환)
  // ────────────────────────────────────────────────────────────────────────────
  static Future<ReceiptListItem?> fetchReceiptById({
    required int userId,
    required int receiptId,
  }) async {
    final res = await _getWithFallback(
      '/receipts/users/$userId/receipts',
      query: const {'page': '0', 'size': '20'},
    );

    if (res.statusCode != 200) {
      throw Exception('영수증 목록 조회 실패 (${res.statusCode}) : ${res.body}');
    }

    final data = jsonDecode(res.body);
    final List content = (data['content'] as List? ?? []);
    for (final raw in content) {
      if ((raw['id'] ?? -1) == receiptId) {
        return ReceiptListItem(
          id: raw['id'] as int,
          storeName: (raw['storeName'] ?? '') as String,
          categoryCode: (raw['categoryCode'] ?? '') as String,
          totalAmount: (raw['totalAmount'] ?? 0) as int,
          expAwarded: (raw['expAwarded'] ?? 0) as int,
        );
      }
    }
    return null;
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 4) 사용자 경험치/레벨 조회
  // ────────────────────────────────────────────────────────────────────────────
  static Future<UserXp> fetchUserXp(int userId) async {
    final res = await _getWithFallback('/receipts/users/$userId/xp');

    if (res.statusCode != 200) {
      throw Exception('경험치 조회 실패 (${res.statusCode}) : ${res.body}');
    }

    final data = jsonDecode(res.body);
    return UserXp(
      totalExp: (data['totalExp'] ?? 0) as int,
      level: (data['level'] ?? 1) as int,
    );
  }
}
