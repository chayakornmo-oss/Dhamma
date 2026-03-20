import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/providers/app_state_providers.dart';
import '../../services/firestore_service.dart';
import '../../models/vow_model.dart';
import '../../router/app_router.dart';
import '../../services/fortune_service.dart';
import '../../theme/dhamma_theme.dart';

final _homeVowsProvider = StreamProvider.autoDispose<List<VowModel>>((ref) {
  return ref.watch(firestoreServiceProvider).getVows();
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

// ── Header ────────────────────────────────────────────────────────────
class _HomeHeader extends ConsumerWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(userNameProvider);
    final streak = ref.watch(userStreakProvider);
    final today = FortuneService.thaiDateString(DateTime.now());

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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'สวัสดี, $userName',
                        style: GoogleFonts.notoSerifThai(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        today,
                        style: GoogleFonts.sarabun(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  if (streak > 0)
                    GestureDetector(
                      onTap: () => context.go(AppRoutes.profile),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: DhammaTheme.gold.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Text('🔥', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 4),
                            Text(
                              '$streak วัน',
                              style: GoogleFonts.sarabun(
                                color: DhammaTheme.gold,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
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

// ── Fortune Card ──────────────────────────────────────────────────────
class _FortuneCard extends ConsumerWidget {
  const _FortuneCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final fortune = FortuneService.computeFortune(birthYear: profile?.birthYear);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () => context.go(AppRoutes.fortune),
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
                        'ดวงวันนี้',
                        style: GoogleFonts.notoSerifThai(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: DhammaTheme.gold2,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: List.generate(5, (i) => Icon(
                      Icons.star,
                      size: 14,
                      color: i < fortune.fortuneScore
                          ? DhammaTheme.gold
                          : Colors.white12,
                    )),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                fortune.prediction,
                style: GoogleFonts.sarabun(
                  fontSize: 14,
                  color: Colors.white70,
                  height: 1.6,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'สีมงคล:',
                    style: GoogleFonts.sarabun(
                        color: Colors.white54, fontSize: 13),
                  ),
                  const SizedBox(width: 8),
                  ...fortune.luckyColors.map(
                    (c) => _ColorDot(Color(c.colorValue)),
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn().slideY(begin: 0.1),
      ),
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

// ── Menu Grid ─────────────────────────────────────────────────────────
class _MenuGrid extends StatelessWidget {
  const _MenuGrid();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
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

// ── Vow Dashboard ─────────────────────────────────────────────────────
class _VowDashboard extends ConsumerWidget {
  const _VowDashboard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vowsAsync = ref.watch(_homeVowsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
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
          vowsAsync.when(
            loading: () => const _VowStatsShimmer(),
            error: (_, __) => const SizedBox.shrink(),
            data: (vows) {
              final pending =
                  vows.where((v) => v.status == VowStatus.pending).length;
              final urgent =
                  vows.where((v) => v.status == VowStatus.urgent).length;
              final done =
                  vows.where((v) => v.status == VowStatus.done).length;

              return Column(
                children: [
                  Row(
                    children: [
                      _VowStat(
                          label: 'รอผล',
                          count: '$pending',
                          color: DhammaTheme.gold),
                      _VowStat(
                          label: 'ต้องแก้บน',
                          count: '$urgent',
                          color: DhammaTheme.lotus),
                      _VowStat(
                          label: 'สำเร็จ',
                          count: '$done',
                          color: DhammaTheme.sage),
                    ],
                  ),
                  if (urgent > 0) ...[
                    const SizedBox(height: 16),
                    _UrgentVowBanner(urgentCount: urgent),
                  ],
                ],
              );
            },
          ),
        ],
      ).animate().fadeIn(delay: 400.ms),
    );
  }
}

class _VowStatsShimmer extends StatelessWidget {
  const _VowStatsShimmer();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        3,
        (_) => Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
          ).animate(onPlay: (c) => c.repeat()).shimmer(
                duration: 1500.ms,
                color: Colors.white.withOpacity(0.05),
              ),
        ),
      ),
    );
  }
}

class _VowStat extends StatelessWidget {
  final String label;
  final String count;
  final Color color;

  const _VowStat(
      {required this.label, required this.count, required this.color});

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
              style:
                  GoogleFonts.sarabun(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class _UrgentVowBanner extends StatelessWidget {
  final int urgentCount;
  const _UrgentVowBanner({required this.urgentCount});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(AppRoutes.vow),
      child: Container(
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
                    'มี $urgentCount คำขอที่ต้องแก้บน',
                    style: GoogleFonts.sarabun(
                      fontSize: 12,
                      color: DhammaTheme.gold2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'แตะเพื่อดูรายละเอียดและอัปเดตสถานะ',
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text(
                'อัปเดต',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
