import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/dhamma_theme.dart';
import '../../models/vow_model.dart';
import '../../router/app_router.dart';

// Filter enum
enum VowFilter { all, pending, urgent, done }

// Providers
final vowFilterProvider = StateProvider<VowFilter>((ref) => VowFilter.all);
final vowsProvider = StreamProvider<List<VowModel>>((ref) {
  // TODO: replace 'user_id' with actual user ID from auth
  return FirebaseFirestore.instance
      .collection('vows')
      .where('userId', isEqualTo: 'user_id')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => VowModel.fromFirestore(d))
          .toList());
});

class VowTrackerScreen extends ConsumerWidget {
  const VowTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(vowFilterProvider);
    final vowsAsync = ref.watch(vowsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: _VowHeader(
              onAdd: () => context.push(AppRoutes.addVow),
            ),
          ),

          // Smart Notifications
          SliverToBoxAdapter(
            child: vowsAsync.when(
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
              data: (vows) {
                final urgent = vows.where((v) => v.status == VowStatus.urgent).toList();
                final weekOld = vows.where((v) =>
                  v.status == VowStatus.pending &&
                  DateTime.now().difference(v.createdAt).inDays >= 7
                ).toList();

                if (urgent.isEmpty && weekOld.isEmpty) return const SizedBox();

                return Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🔔 แจ้งเตือนอัจฉริยะ',
                        style: GoogleFonts.sarabun(
                          fontSize: 12,
                          color: DhammaTheme.textLight,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (urgent.isNotEmpty)
                        _SmartNotificationCard(
                          icon: '🔴',
                          color: const Color(0xFFFCE4EC),
                          title: 'ต้องแก้บนด่วน!',
                          desc: '${urgent.first.templeName} — สำเร็จแล้ว ยังไม่ได้แก้บน',
                          time: '${DateTime.now().difference(urgent.first.updatedAt).inDays} วัน',
                        ).animate().fadeIn().slideX(begin: -0.1),
                      if (weekOld.isNotEmpty)
                        _SmartNotificationCard(
                          icon: '⏰',
                          color: const Color(0xFFFDF3DC),
                          title: 'ผ่าน 7 วันแล้ว',
                          desc: 'พรเรื่อง "${weekOld.first.prayerText}" — อัปเดตสถานะ?',
                          time: '7 วัน',
                        ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),
                    ],
                  ),
                );
              },
            ),
          ),

          // Filter tabs
          SliverToBoxAdapter(
            child: _FilterTabs(
              current: filter,
              onSelect: (f) => ref.read(vowFilterProvider.notifier).state = f,
            ),
          ),

          // Vow list
          vowsAsync.when(
            loading: () => SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _VowCardSkeleton(),
                childCount: 3,
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Center(
                child: Text('เกิดข้อผิดพลาด: $e'),
              ),
            ),
            data: (vows) {
              final filtered = _filterVows(vows, filter);
              if (filtered.isEmpty) {
                return SliverToBoxAdapter(
                  child: _EmptyState(filter: filter),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => VowCard(
                    vow: filtered[i],
                  ).animate().fadeIn(
                    delay: Duration(milliseconds: i * 60),
                  ).slideY(begin: 0.1),
                  childCount: filtered.length,
                ),
              );
            },
          ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  List<VowModel> _filterVows(List<VowModel> vows, VowFilter filter) {
    switch (filter) {
      case VowFilter.all:     return vows;
      case VowFilter.pending: return vows.where((v) => v.status == VowStatus.pending).toList();
      case VowFilter.urgent:  return vows.where((v) => v.status == VowStatus.urgent).toList();
      case VowFilter.done:    return vows.where((v) => v.status == VowStatus.done).toList();
    }
  }
}

// ── Vow Header ───────────────────────────────────
class _VowHeader extends ConsumerWidget {
  final VoidCallback onAdd;
  const _VowHeader({required this.onAdd});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vowsAsync = ref.watch(vowsProvider);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A3A2A), Color(0xFF2A1A3A)],
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        22,
        MediaQuery.of(context).padding.top + 16,
        22,
        22,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📍 คำขอพรของฉัน',
                    style: GoogleFonts.notoSerifThai(
                      fontSize: 22, fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'อัปเดตและติดตามความสำเร็จ',
                    style: GoogleFonts.sarabun(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.45),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: DhammaTheme.gold.withOpacity(0.2),
                    border: Border.all(
                      color: DhammaTheme.gold.withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add, color: DhammaTheme.gold2),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Stats
          vowsAsync.when(
            loading: () => _StatsRowSkeleton(),
            error: (_, __) => const SizedBox(),
            data: (vows) => Row(
              children: [
                _StatChip(
                  num: vows.where((v) => v.status == VowStatus.pending).length.toString(),
                  label: '⏳ รอผล',
                  color: DhammaTheme.gold2,
                ),
                const SizedBox(width: 10),
                _StatChip(
                  num: vows.where((v) => v.status == VowStatus.urgent).length.toString(),
                  label: '🔴 ต้องแก้บน',
                  color: DhammaTheme.lotus,
                ),
                const SizedBox(width: 10),
                _StatChip(
                  num: vows.where((v) => v.status == VowStatus.done).length.toString(),
                  label: '✅ สำเร็จ',
                  color: const Color(0xFF7BC47B),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String num;
  final String label;
  final Color color;
  const _StatChip({required this.num, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            num,
            style: GoogleFonts.notoSerifThai(
              fontSize: 26, fontWeight: FontWeight.w700, color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.sarabun(
              fontSize: 11, color: Colors.white.withOpacity(0.45),
            ),
          ),
        ],
      ),
    ),
  );
}

// ── Smart Notification Card ─────────────────────
class _SmartNotificationCard extends StatelessWidget {
  final String icon;
  final Color color;
  final String title;
  final String desc;
  final String time;

  const _SmartNotificationCard({
    required this.icon, required this.color,
    required this.title, required this.desc, required this.time,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10, offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(10),
          ),
          child: Center(child: Text(icon)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.sarabun(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: DhammaTheme.textDark,
              )),
              Text(desc, style: GoogleFonts.sarabun(
                fontSize: 12, color: DhammaTheme.textLight,
              )),
            ],
          ),
        ),
        Text(time, style: GoogleFonts.sarabun(
          fontSize: 11, color: DhammaTheme.textLight,
        )),
      ],
    ),
  );
}

// ── Filter Tabs ──────────────────────────────────
class _FilterTabs extends StatelessWidget {
  final VowFilter current;
  final Function(VowFilter) onSelect;

  const _FilterTabs({required this.current, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      (VowFilter.all,     'ทั้งหมด'),
      (VowFilter.pending, '⏳ รอผล'),
      (VowFilter.urgent,  '🔴 ต้องแก้บน'),
      (VowFilter.done,    '✅ สำเร็จ'),
    ];

    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        itemCount: tabs.length,
        itemBuilder: (_, i) {
          final isSelected = current == tabs[i].$1;
          return GestureDetector(
            onTap: () => onSelect(tabs[i].$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? DhammaTheme.goldPale : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? DhammaTheme.gold.withOpacity(0.4)
                      : Colors.transparent,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                tabs[i].$2,
                style: GoogleFonts.sarabun(
                  fontSize: 13,
                  color: isSelected ? DhammaTheme.gold : DhammaTheme.textLight,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Vow Card ─────────────────────────────────────
class VowCard extends StatelessWidget {
  final VowModel vow;
  const VowCard({super.key, required this.vow});

  @override
  Widget build(BuildContext context) {
    final (statusColor, pillBg, pillText, pillLabel) = switch (vow.status) {
      VowStatus.urgent  => (DhammaTheme.lotus,   const Color(0xFFFCE4EC), DhammaTheme.lotus,  '🔴 ต้องแก้บน'),
      VowStatus.pending => (DhammaTheme.gold,     DhammaTheme.goldPale,   DhammaTheme.gold,   '⏳ รอผล'),
      VowStatus.done    => (DhammaTheme.sage,     const Color(0xFFE8F5E9), DhammaTheme.sage,  '✅ แก้บนแล้ว'),
    };

    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12, offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Status indicator
              Container(width: 4, color: statusColor),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '🏛️ ${vow.templeName}',
                                  style: GoogleFonts.sarabun(
                                    fontSize: 11, color: DhammaTheme.textLight,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  vow.prayerText,
                                  style: GoogleFonts.notoSerifThai(
                                    fontSize: 15, fontWeight: FontWeight.w600,
                                    color: DhammaTheme.textDark, height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: pillBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              pillLabel,
                              style: GoogleFonts.sarabun(
                                fontSize: 11, fontWeight: FontWeight.w600,
                                color: pillText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(height: 1, color: Colors.black.withOpacity(0.05)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'บนเมื่อ ${_formatDate(vow.createdAt)}',
                            style: GoogleFonts.sarabun(
                              fontSize: 12, color: DhammaTheme.textLight,
                            ),
                          ),
                          Text(
                            'อัปเดต →',
                            style: GoogleFonts.sarabun(
                              fontSize: 12, fontWeight: FontWeight.w600,
                              color: DhammaTheme.gold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['ม.ค.','ก.พ.','มี.ค.','เม.ย.','พ.ค.','มิ.ย.',
                    'ก.ค.','ส.ค.','ก.ย.','ต.ค.','พ.ย.','ธ.ค.'];
    return '${date.day} ${months[date.month - 1]}';
  }
}

// Skeleton loaders
class _VowCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(18, 0, 18, 12),
    height: 100,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
  ).animate(onPlay: (c) => c.repeat()).shimmer(
    duration: 1200.ms,
    color: Colors.grey.withOpacity(0.05),
  );
}

class _StatsRowSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
    children: List.generate(3, (i) =>
      Expanded(
        child: Container(
          margin: EdgeInsets.only(right: i < 2 ? 10 : 0),
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  final VowFilter filter;
  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(40),
    child: Column(
      children: [
        const Text('🙏', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 16),
        Text(
          filter == VowFilter.all
              ? 'ยังไม่มีคำขอพร\nกดปุ่ม + เพื่อเริ่มต้น'
              : 'ไม่มีรายการในหมวดนี้',
          textAlign: TextAlign.center,
          style: GoogleFonts.notoSerifThai(
            fontSize: 16, color: DhammaTheme.textMid, height: 1.6,
          ),
        ),
      ],
    ),
  );
}
