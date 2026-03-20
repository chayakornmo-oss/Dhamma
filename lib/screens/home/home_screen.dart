import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/dhamma_theme.dart';
import '../../router/app_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: DhammaTheme.ink,
      body: CustomScrollView(
        slivers: [
          _HomeHeader(),
          SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(child: _FortuneCard()),
          SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(child: _MenuGrid()),
          SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(child: _VowDashboard()),
          SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      backgroundColor: Colors.transparent,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [DhammaTheme.ink, Color(0xFF2A1550)],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'สวัสดี, คุณนุ่น',
                        style: GoogleFonts.notoSerifThai(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'วันพฤหัสบดีที่ 19 มีนาคม',
                        style: GoogleFonts.sarabun(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: DhammaTheme.gold.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          '12 วัน',
                          style: GoogleFonts.sarabun(
                            color: DhammaTheme.gold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FortuneCard extends StatelessWidget {
  const _FortuneCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: DhammaTheme.gold.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('✨', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      'ดวงวันนี้ปังแค่ไหน?',
                      style: GoogleFonts.notoSerifThai(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: DhammaTheme.gold2,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'การงานราบรื่น มีผู้ใหญ่คอยอุปถัมภ์ ระวังแค่คำพูดช่วงบ่าย...',
              style: GoogleFonts.sarabun(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('สีมงคล:', style: GoogleFonts.sarabun(color: Colors.white54, fontSize: 13)),
                const SizedBox(width: 8),
                const _ColorDot(Colors.orange),
                const _ColorDot(Colors.white),
                const _ColorDot(Colors.blue),
              ],
            )
          ],
        ),
      ).animate().fadeIn().slideY(begin: 0.1),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  const _ColorDot(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24),
      ),
    );
  }
}

class _MenuGrid extends StatelessWidget {
  const _MenuGrid();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _MenuShortcut(
            title: 'บทสวด',
            icon: '📿',
            color: const Color(0xFF6B4B8E),
            onTap: () => context.go(AppRoutes.prayer),
          ),
          _MenuShortcut(
            title: 'ขอพร',
            icon: '📍',
            color: const Color(0xFF2E6B4B),
            onTap: () => context.go(AppRoutes.vow),
          ),
          _MenuShortcut(
            title: 'เช็คดวง',
            icon: '✨',
            color: DhammaTheme.gold,
            onTap: () => context.go(AppRoutes.fortune),
          ),
        ],
      ).animate().fadeIn(delay: 200.ms),
    );
  }
}

class _MenuShortcut extends StatelessWidget {
  final String title;
  final String icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuShortcut({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.sarabun(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _VowDashboard extends StatelessWidget {
  const _VowDashboard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'พรอธิษฐานของคุณ',
                style: GoogleFonts.notoSerifThai(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              GestureDetector(
                onTap: () => context.go(AppRoutes.vow),
                child: Text(
                  'ดูทั้งหมด →',
                  style: GoogleFonts.sarabun(
                    fontSize: 14,
                    color: DhammaTheme.gold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              _VowStat(label: 'รอผล', count: '3', color: DhammaTheme.gold),
              _VowStat(label: 'ต้องแก้บน', count: '1', color: DhammaTheme.lotus),
              _VowStat(label: 'สำเร็จ', count: '12', color: DhammaTheme.sage),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DhammaTheme.gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: DhammaTheme.gold.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: DhammaTheme.gold.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Text('🔔', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ผ่านมา 1 สัปดาห์แล้ว',
                        style: GoogleFonts.sarabun(
                          fontSize: 12,
                          color: DhammaTheme.gold2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'พรที่ขอเรื่องงาน เป็นยังไงบ้าง?',
                        style: GoogleFonts.sarabun(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => context.go(AppRoutes.vow),
                  style: TextButton.styleFrom(
                    foregroundColor: DhammaTheme.ink,
                    backgroundColor: DhammaTheme.gold,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('อัปเดตสถานะ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ).animate().fadeIn(delay: 400.ms),
    );
  }
}

class _VowStat extends StatelessWidget {
  final String label;
  final String count;
  final Color color;

  const _VowStat({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: GoogleFonts.notoSerifThai(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.sarabun(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
