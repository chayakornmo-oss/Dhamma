import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/dhamma_theme.dart';
import '../../router/app_router.dart';

class PrayerScreen extends StatelessWidget {
  const PrayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DhammaTheme.ink,
      appBar: AppBar(
        title: const Text('📿 บทสวดมนต์'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _AiAnalyzerCard().animate().fadeIn().slideY(begin: 0.1),
            const SizedBox(height: 32),
            Text(
              'บทสวดแนะนำ',
              style: GoogleFonts.notoSerifThai(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 16),
            _PrayerCard(
              title: 'อิติปิโส ภควา',
              desc: 'บทสวดสรรเสริญพระพุทธคุณ',
              duration: '⏱ 5 นาที',
              onTap: () => context.push(AppRoutes.prayer + '/' + 'detail'),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 12),
            _PrayerCard(
              title: 'ยอดพระกัณฑ์ไตรปิฎก',
              desc: 'เสริมบารมีและสิริมงคลสูงสุด',
              duration: '⏱ 15 นาที',
              onTap: () => context.push(AppRoutes.prayer + '/' + 'detail'),
            ).animate().fadeIn(delay: 400.ms),
          ],
        ),
      ),
    );
  }
}

class _AiAnalyzerCard extends StatelessWidget {
  const _AiAnalyzerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF6B4B8E).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF6B4B8E).withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('✨', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ให้ AI แนะนำบทสวด',
                    style: GoogleFonts.notoSerifThai(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'ปรับแต่งตามเวลาของคุณ',
                    style: GoogleFonts.sarabun(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip('5 นาที'),
                _FilterChip('15 นาที'),
                _FilterChip('30 นาที', selected: true),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6B4B8E)),
              child: const Text('ค้นหาบทสวดที่เหมาะสม', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;

  const _FilterChip(this.label, {this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF6B4B8E) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? Colors.transparent : Colors.white24),
      ),
      child: Text(
        label,
        style: GoogleFonts.sarabun(color: Colors.white, fontWeight: selected ? FontWeight.bold : FontWeight.normal),
      ),
    );
  }
}

class _PrayerCard extends StatelessWidget {
  final String title;
  final String desc;
  final String duration;
  final VoidCallback onTap;

  const _PrayerCard({required this.title, required this.desc, required this.duration, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF6B4B8E).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('📿', style: TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.notoSerifThai(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    desc,
                    style: GoogleFonts.sarabun(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
            ),
            Text(duration, style: GoogleFonts.sarabun(color: DhammaTheme.gold2, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
