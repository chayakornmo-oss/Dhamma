import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../../theme/dhamma_theme.dart';

class FortuneScreen extends StatelessWidget {
  const FortuneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DhammaTheme.ink,
      appBar: AppBar(
        title: const Text('✨ เช็คดวงประจำวัน'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _DailyPredictionCard().animate().fadeIn().slideY(begin: 0.1),
            const SizedBox(height: 24),
            Text(
              'สีมงคลประจำวัน',
              style: GoogleFonts.notoSerifThai(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 12),
            const Row(
              children: [
                _LuckyColorChip(color: Colors.orange, label: 'การงาน'),
                _LuckyColorChip(color: Colors.white, label: 'การเงิน'),
                _LuckyColorChip(color: Colors.blue, label: 'ความรัก'),
              ],
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 32),
            const _PremiumContent().animate().fadeIn(delay: 300.ms),
          ],
        ),
      ),
    );
  }
}

class _DailyPredictionCard extends StatelessWidget {
  const _DailyPredictionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DhammaTheme.gold.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('ดวงรายวัน', style: TextStyle(color: DhammaTheme.gold2)),
              const Spacer(),
              Text('19 มีนาคม', style: TextStyle(color: Colors.white.withOpacity(0.5))),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'การงานจะมีผู้ใหญ่เข้าช่วยเหลือ แต่ให้ระวังคำพูดช่วงบ่าย อาจมีปัญหาจากการสื่อสารที่ผิดพลาด',
            style: GoogleFonts.sarabun(
              fontSize: 16,
              color: Colors.white,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _LuckyColorChip extends StatelessWidget {
  final Color color;
  final String label;

  const _LuckyColorChip({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12, height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.sarabun(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }
}

class _PremiumContent extends StatelessWidget {
  const _PremiumContent();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ฤกษ์ยามและทิศมงคล',
              style: GoogleFonts.notoSerifThai(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: List.generate(4, (index) => Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
              )),
            ),
          ],
        ),
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: DhammaTheme.ink.withOpacity(0.4),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock, color: DhammaTheme.gold, size: 32),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text('สมัคร Premium ฿199/เดือน'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
