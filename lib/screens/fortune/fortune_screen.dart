import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/providers/app_state_providers.dart';
import '../../services/fortune_service.dart';
import '../../theme/dhamma_theme.dart';

class FortuneScreen extends ConsumerWidget {
  const FortuneScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final fortune =
        FortuneService.computeFortune(birthYear: profile?.birthYear);
    final isPremium = ref.watch(isPremiumProvider);
    final todayString = FortuneService.thaiDateString(DateTime.now());

    return Scaffold(
      backgroundColor: DhammaTheme.ink,
      appBar: AppBar(title: const Text('✨ เช็คดวงประจำวัน')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DailyPredictionCard(
              fortune: fortune,
              todayString: todayString,
            ).animate().fadeIn().slideY(begin: 0.1),
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
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: fortune.luckyColors
                  .map((c) => _LuckyColorChip(
                        color: Color(c.colorValue),
                        label: '${c.name} — ${c.category}',
                      ))
                  .toList(),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 24),
            _LuckyInfoRow(
              icon: '🕐',
              label: 'ฤกษ์มงคล',
              value: fortune.luckyTime,
            ).animate().fadeIn(delay: 250.ms),
            const SizedBox(height: 8),
            _LuckyInfoRow(
              icon: '🧭',
              label: 'ทิศมงคล',
              value: fortune.luckyDirection,
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 8),
            _LuckyInfoRow(
              icon: '🌿',
              label: 'ธาตุประจำตัว',
              value: fortune.elementName,
            ).animate().fadeIn(delay: 350.ms),
            const SizedBox(height: 32),
            _PremiumContent(isPremium: isPremium, fortune: fortune)
                .animate()
                .fadeIn(delay: 400.ms),
          ],
        ),
      ),
    );
  }
}

// ── Daily Prediction Card ─────────────────────────────────────────────
class _DailyPredictionCard extends StatelessWidget {
  final DailyFortune fortune;
  final String todayString;

  const _DailyPredictionCard({
    required this.fortune,
    required this.todayString,
  });

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
              const Text('ดวงรายวัน',
                  style: TextStyle(color: DhammaTheme.gold2)),
              const Spacer(),
              Text(todayString,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.5), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(
              5,
              (i) => Icon(
                Icons.star,
                size: 18,
                color: i < fortune.fortuneScore
                    ? DhammaTheme.gold
                    : Colors.white12,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            fortune.prediction,
            style: GoogleFonts.sarabun(
              fontSize: 16,
              color: Colors.white,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Lucky Color Chip ──────────────────────────────────────────────────
class _LuckyColorChip extends StatelessWidget {
  final Color color;
  final String label;

  const _LuckyColorChip({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(label,
              style: GoogleFonts.sarabun(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }
}

// ── Lucky Info Row ────────────────────────────────────────────────────
class _LuckyInfoRow extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _LuckyInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.sarabun(color: Colors.white54, fontSize: 13),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.sarabun(
              color: DhammaTheme.gold2,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Premium Content ───────────────────────────────────────────────────
class _PremiumContent extends StatelessWidget {
  final bool isPremium;
  final DailyFortune fortune;

  const _PremiumContent({required this.isPremium, required this.fortune});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ฤกษ์ยามและทิศมงคลรายชั่วโมง',
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
              children: _premiumCards(fortune),
            ),
          ],
        ),
        if (!isPremium)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(
                  color: DhammaTheme.ink.withOpacity(0.5),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lock,
                            color: DhammaTheme.gold, size: 32),
                        const SizedBox(height: 12),
                        Text(
                          'เฉพาะสมาชิก Premium',
                          style: GoogleFonts.notoSerifThai(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _showUpgradeSheet(context),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
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

  List<Widget> _premiumCards(DailyFortune fortune) {
    final items = [
      ('⏰', 'ฤกษ์ดีช่วงเช้า', '07:00 – 09:00'),
      ('💼', 'ฤกษ์ดีทำธุรกิจ', '10:00 – 12:00'),
      ('💰', 'ฤกษ์ดีการเงิน', '13:00 – 15:00'),
      ('❤️', 'ฤกษ์ดีความรัก', '18:00 – 20:00'),
    ];

    return items
        .map((item) => Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(item.$1, style: const TextStyle(fontSize: 22)),
                  const SizedBox(height: 6),
                  Text(
                    item.$2,
                    style: GoogleFonts.sarabun(
                      color: DhammaTheme.gold2,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    item.$3,
                    style: GoogleFonts.sarabun(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ))
        .toList();
  }

  void _showUpgradeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1528),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌟', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'อัปเกรดเป็น Premium',
              style: GoogleFonts.notoSerifThai(
                color: DhammaTheme.gold,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ปลดล็อคฤกษ์รายชั่วโมง ทิศมงคลแบบละเอียด\nและการอ่านดวงเชิงลึกตามธาตุของคุณ',
              style: GoogleFonts.sarabun(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('สมัครสมาชิก ฿199/เดือน'),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'ไว้ทีหลัง',
                style: TextStyle(color: Colors.white38),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
