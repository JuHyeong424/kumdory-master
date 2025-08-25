import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'ScannerPage.dart'; // 영수증 촬영 화면
import 'my_page.dart';
import 'character_select.dart';
import 'custom_bottom_nav.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'receipt_api.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6EEDD), // 부드러운 베이지 톤
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCharacterName = '꿈돌이';
  String _selectedCharacterImage = 'assets/꿈돌이 2.png';

  /// 경험치 상태
  int _level = 1;
  double _progress = 0.0;
  int _totalExp = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchXpData();
  }

  /// API에서 경험치 데이터 가져오기 (앱 시작 시 호출)
  Future<void> _fetchXpData() async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });
    }
    try {
      const userId = 999;
      final userXp = await ReceiptApi.fetchUserXp(userId);
      _updateStateWithXpData(level: userXp.level, totalExp: userXp.totalExp);
    } catch (e) {
      debugPrint('XP 불러오기 오류: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _level = 1;
          _progress = 0.0;
        });
      }
    }
  }

  /// [핵심] 레벨과 경험치 데이터로 UI 상태를 업데이트하는 공통 함수
  void _updateStateWithXpData({required int level, required int totalExp}) {
    final calculatedLevel = _calculateLevelFromXp(totalExp);
    setState(() {
      _level = level;
      _totalExp = totalExp;
      _progress =
          _calculateProgressFromXp(level: _level, totalExp: _totalExp);
      _isLoading = false;
    });
  }

  /// 총 경험치(totalExp)만으로 현재 레벨을 계산하는 함수 (서버 데이터 보정용)
  int _calculateLevelFromXp(int totalExp) {
    if (totalExp >= 5000) {
      int level = 6 + ((totalExp - 5000) / 1000).floor();
      return level > 30 ? 30 : level;
    }
    if (totalExp >= 2000) return 5;
    if (totalExp >= 1000) return 4;
    if (totalExp >= 500) return 3;
    if (totalExp >= 100) return 2;
    return 1;
  }

  /// 레벨과 총 경험치로 프로그레스 바(0.0 ~ 1.0) 계산
  double _calculateProgressFromXp(
      {required int level, required int totalExp}) {
    if (level >= 30) return 1.0;

    const Map<int, int> requiredTotalExpForLevel = {
      2: 100,
      3: 500,
      4: 1000,
      5: 2000,
      6: 5000,
    };

    final int currentLevelStartExp = (level == 1)
        ? 0
        : requiredTotalExpForLevel[level] ??
        (5000 + (level - 6) * 1000);
    final int nextLevelStartExp =
        requiredTotalExpForLevel[level + 1] ??
            (5000 + (level + 1 - 6) * 1000);

    final double expNeededForThisLevel =
    (nextLevelStartExp - currentLevelStartExp).toDouble();
    final double expInThisLevel =
    (totalExp - currentLevelStartExp).toDouble();

    if (expNeededForThisLevel <= 0) return 0.0;

    final progress = expInThisLevel / expNeededForThisLevel;
    return progress.clamp(0.0, 1.0);
  }

  /// 다음 보상까지 남은 레벨 텍스트를 생성하는 함수
  String _getNextRewardLevelText() {
    if (_level >= 30) return '모든 보상을 달성했어요!';
    final nextRewardLevel = (((_level / 5).floor()) + 1) * 5;
    final remainingLevels = nextRewardLevel - _level;
    if (remainingLevels == 0) return '다음 보상까지 5레벨!';
    return '다음 보상까지 ${remainingLevels}레벨';
  }

  /// +EXP 애니메이션 띄우기
  void _showFloatingExp(BuildContext context, int exp) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.4,
        left: MediaQuery.of(context).size.width * 0.35,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: -80.0),
          duration: const Duration(seconds: 3),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, value),
              child: Opacity(
                opacity: 1 - (value.abs() / 80),
                child: child,
              ),
            );
          },
          child: Text(
            "+$exp EXP",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
              shadows: [
                Shadow(color: Colors.black26, blurRadius: 8),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 1), () => entry.remove());
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 90),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _selectedCharacterName,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF66A7FF)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          backgroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          final selected =
                          await showModalBottomSheet<String>(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => const CharacterSelectSheet(),
                          );
                          if (selected != null) {
                            setState(() {
                              _selectedCharacterName = selected;
                              switch (selected) {
                                case '도르':
                                  _selectedCharacterImage =
                                  'assets/도르 1.png';
                                  break;
                                case '네브':
                                  _selectedCharacterImage =
                                  'assets/네브 2.png';
                                  break;
                                case '몽몽':
                                  _selectedCharacterImage =
                                  'assets/몽몽 1.png';
                                  break;
                                case '꿈결이':
                                  _selectedCharacterImage =
                                  'assets/꿈결이 1.png';
                                  break;
                                case '꿈누리':
                                  _selectedCharacterImage =
                                  'assets/꿈누리 1.png';
                                  break;
                                case '꿈둥이':
                                  _selectedCharacterImage =
                                  'assets/꿈둥이 1.png';
                                  break;
                                case '꿈돌이':
                                default:
                                  _selectedCharacterImage =
                                  'assets/꿈돌이 2.png';
                              }
                            });
                          }
                        },
                        child: const Text(
                          '캐릭터변경',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF2D7CFF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ]),
                const SizedBox(height: 20),
                SizedBox(
                  width: w * 0.7,
                  height: w * 0.7,
                  child: Image.asset(
                    _selectedCharacterImage,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => _MascotPlaceholder(),
                  ),
                ),
                const SizedBox(height: 12),
                if (!_isLoading)
                  Text(
                    _getNextRewardLevelText(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFFBE6F39),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding:
                    const EdgeInsets.fromLTRB(18, 12, 18, 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _isLoading
                        ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                        : Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            _LevelBadge(levelText: 'Lv. $_level'),
                            Text(
                              '${(_progress * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: SizedBox(
                            height: 10,
                            child: Stack(
                              children: [
                                Container(
                                    color: const Color(0xFFE6E6E6)),
                                FractionallySizedBox(
                                  widthFactor: _progress,
                                  child: Container(
                                      color:
                                      const Color(0xFFF07B2A)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                const SizedBox(height: 120),
              ],
            ),

            // 스캔 버튼
            Positioned(
              right: 24,
              bottom: 50,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 5),
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shadows: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        )
                      ],
                      shape: const _SpeechBubbleBorderRight(
                          radius: 16, nipSize: 12),
                    ),
                    child: const Text(
                      '영수증 스캔하고 레벨업!',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8D2B),
                      shape: const CircleBorder(),
                      elevation: 8,
                      padding: const EdgeInsets.all(18),
                    ),
                    onPressed: () async {
                      final result =
                      await Navigator.push<RegisterResult?>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ScannerPage(),
                        ),
                      );

                      if (result != null && mounted) {
                        // 🔹 SnackBar 대신 떠오르는 EXP 애니메이션
                        _showFloatingExp(context, result.expAwarded);

                        _updateStateWithXpData(
                          level: result.levelAfter,
                          totalExp: result.totalExpAfter,
                        );
                      }
                    },
                    child: Image.asset(
                      'assets/union.png',
                      width: 28,
                      height: 28,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
    );
  }
}

/// "Lv. 4" 같은 작은 캡슐 배지
class _LevelBadge extends StatelessWidget {
  final String levelText;
  const _LevelBadge({required this.levelText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        levelText,
        style: const TextStyle(
          color: Color(0xFFEF7A29),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// 캐릭터 자리용 임시 플레이스홀더
class _MascotPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MascotPainter(),
      child: const SizedBox.expand(),
    );
  }
}

/// 말풍선
class _SpeechBubbleBorderRight extends ShapeBorder {
  final double radius;
  final double nipSize;

  const _SpeechBubbleBorderRight(
      {this.radius = 12, this.nipSize = 8});

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final r = Radius.circular(radius);
    final body = RRect.fromRectAndRadius(rect, r);
    final path = Path()..addRRect(body);

    final double x = rect.right;
    final double y = rect.center.dy;
    path.moveTo(x, y - nipSize);
    path.quadraticBezierTo(x + nipSize, y, x, y + nipSize);

    return path;
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect, textDirection: textDirection);

  @override
  void paint(Canvas canvas, Rect rect,
      {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) =>
      _SpeechBubbleBorderRight(radius: radius * t, nipSize: nipSize * t);
}

class _MascotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final body = Paint()..color = const Color(0xFFFFD39C);
    final blush =
    Paint()..color = const Color(0xFFFFA67A).withOpacity(0.6);
    final shadow = Paint()..color = Colors.black12;

    // 바닥 그림자
    canvas.drawOval(
        Rect.fromLTWH(size.width * 0.25, size.height * 0.82,
            size.width * 0.5, size.height * 0.08),
        shadow);

    // 몸통
    final bodyRect = Rect.fromCircle(
        center: Offset(size.width * 0.5, size.height * 0.5),
        radius: size.width * 0.28);
    canvas.drawRRect(
        RRect.fromRectAndRadius(bodyRect, const Radius.circular(60)),
        body);

    // 귀
    canvas.drawOval(
        Rect.fromLTWH(size.width * 0.18, size.height * 0.42,
            size.width * 0.16, size.height * 0.1),
        body);
    canvas.drawOval(
        Rect.fromLTWH(size.width * 0.66, size.height * 0.42,
            size.width * 0.16, size.height * 0.1),
        body);

    // 얼굴 홍조
    canvas.drawCircle(
        Offset(size.width * 0.38, size.height * 0.55),
        size.width * 0.08,
        blush);
    canvas.drawCircle(
        Offset(size.width * 0.62, size.height * 0.55),
        size.width * 0.08,
        blush);

    // 눈
    final eye = Paint()..color = Colors.black;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(
                size.width * 0.47, size.height * 0.50, 6, 18),
            const Radius.circular(3)),
        eye);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(
                size.width * 0.52, size.height * 0.50, 6, 18),
            const Radius.circular(3)),
        eye);

    // 팔/다리
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width * 0.31, size.height * 0.60,
                size.width * 0.16, size.height * 0.08),
            const Radius.circular(20)),
        body);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width * 0.53, size.height * 0.60,
                size.width * 0.16, size.height * 0.08),
            const Radius.circular(20)),
        body);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width * 0.40, size.height * 0.72,
                size.width * 0.08, size.height * 0.10),
            const Radius.circular(16)),
        body);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width * 0.52, size.height * 0.72,
                size.width * 0.08, size.height * 0.10),
            const Radius.circular(16)),
        body);

    // 머리 장식 (파란별)
    final star = Path();
    final cx = size.width * 0.30;
    final cy = size.height * 0.33;
    final rOuter = size.width * 0.06;
    final rInner = rOuter * 0.55;
    const deg = math.pi / 180;

    for (int i = 0; i < 10; i++) {
      final angle = (-90 + i * 36) * deg;
      final rad = i.isEven ? rOuter : rInner;
      final x = cx + rad * math.cos(angle);
      final y = cy + rad * math.sin(angle);
      if (i == 0) {
        star.moveTo(x, y);
      } else {
        star.lineTo(x, y);
      }
    }
    star.close();
    canvas.drawPath(star, Paint()..color = const Color(0xFF88B7FF));

    // 안테나
    final antenna = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    final path = Path()
      ..moveTo(size.width * 0.36, size.height * 0.36)
      ..cubicTo(size.width * 0.40, size.height * 0.28, size.width * 0.53,
          size.height * 0.32, size.width * 0.48, size.height * 0.40);
    canvas.drawPath(path, antenna);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
