import 'package:flutter/material.dart';
import 'package:kumdori/main.dart';
import 'my_page.dart';
import 'custom_bottom_nav.dart';

class CouponPage extends StatelessWidget {
  const CouponPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "쿠폰함",
          style: TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              "사용한 쿠폰보기",
              style: TextStyle(
                color: Color(0xFF267DFF),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          CouponCard(
            color: Color(0xBBFFE4D4),
            borderColor: Color(0xFFFFA64C),
            amount: "1000",
            expireDate: "2026.04.21",
          ),
          CouponCard(
            color: Color(0xBBFDE9E9),
            borderColor: Color(0xFFFF5A5A),
            amount: "5000",
            expireDate: "2026.04.21",
          ),
          CouponCard(
            color: Color(0xFFFDFFEE),
            borderColor: Color(0xFFB8D000),
            amount: "3000",
            expireDate: "2026.04.21",
          ),
          CouponCard(
            color: Color(0xFFFAEEE1),
            borderColor: Color(0xFFFFA64C),
            amount: "1000",
            expireDate: "2026.04.21",
          ),
        ],
      ),

        bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
    );
  }
}

class CouponCard extends StatelessWidget {
  final Color color;
  final Color borderColor;
  final String amount;
  final String expireDate;
  final Color textColor;

  const CouponCard({
    super.key,
    required this.color,
    required this.borderColor,
    required this.amount,
    required this.expireDate,
    this.textColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.local_movies, color: Colors.black87),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "유성시장 $amount원",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "사용기간 $expireDate 까지",
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ],
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              "사용하기",
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
