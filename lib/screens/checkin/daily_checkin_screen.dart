import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/dhamma_theme.dart';
import '../../router/app_router.dart';
import '../../services/ai_service.dart';

enum Mood { anxious, tired, normal, good, great }

extension MoodExt on Mood {
  String get emoji {
    switch (this) {
      case Mood.anxious: return '😟';
      case Mood.tired:   return '😴';
      case Mood.normal:  return '😐';
      case Mood.good:    return '😊';
      case Mood.great:   return '🌟';
    }
  }

  String get label {
    switch (this) {
      case Mood.anxious: return 'กังวล';
      case Mood.tired:   return 'เหนื่อย';
      case Mood.normal:  return 'ปกติ';
      case Mood.good:    return 'สบายดี';
      case Mood.great:   return 'ดีมาก';
    }
  }
}

// Providers
final selectedMoodProvider = StateProvider<Mood?>((ref) => null);
final aiRecommendationProvider = FutureProvider.family<Map<String, String>, Mood>(
  (ref, mood) => AIService.getPrayerRecommendation(mood),
);

class DailyCheckinScreen extends ConsumerWidget {
  const DailyCheckinScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMood = ref.watch(selectedMoodProvider);
    final userName = 'คุณนุ่น'; // TODO: get from SharedPreferences

    // Today's fortune (mock - replace with real calculation)
    final todayColors = ['ส้ม 🧡', 'ขาว 🤍', 'น้ำเงิน 💙'];
    final todayPrediction =
        'มีเกณฑ์เรื่องการสื่อสาร หยุดคิดก่อนพูดสักนิด ช่วงบ่ายโชคดีเรื่องการเงิน';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              DhammaTheme.ink,
              Color(0xFF2A1550),
              Color(0xFF1A3A2A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),

                      // Greeting
                      Text(
                        '🌅 สวัสดีตอนเช้า $userName',
                        style: GoogleFonts.sarabun(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.45),
                          letterSpacing: 1,
                        ),
                      ).animate().fadeIn(),

                      const SizedBox(height: 8),

                      Text(
                        'วันนี้รู้สึกยังไง\nก่อนออกจากบ้าน?',
                        style: GoogleFonts.notoSerifThai(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),

                      const SizedBox(height: 6),

                      Text(
                        'AI จะแนะนำบทสวดที่เหมาะกับคุณ',
                        style: GoogleFonts.sarabun(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ).animate().fadeIn(delay: 200.ms),

                      const SizedBox(height: 24),

                      // Mood picker
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: Mood.values.map((mood) =>
                          _MoodButton(
                            mood: mood,
                            isSelected: selectedMood == mood,
                            onTap: () => ref.read(selectedMoodProvider.notifier)
                                .state = mood,
                          ).animate().fadeIn(
                            delay: Duration(milliseconds: 300 + Mood.values.indexOf(mood) * 80),
                          ).scale(begin: const Offset(0.8, 0.8)),
                        ).toList(),
                      ),

                      const SizedBox(height: 20),

                      // AI Recommendation
                      if (selectedMood != null)
                        _AIRecommendationCard(mood: selectedMood)
                        .animate().fadeIn().slideY(begin: 0.2),

                      const SizedBox(height: 16),

                      // Today's Banner
                      _TodayBanner(
                        colors: todayColors,
                        prediction: todayPrediction,
                      ).animate().fadeIn(
                        delay: Duration(milliseconds: selectedMood != null ? 200 : 400),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // CTA
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _enterDay(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DhammaTheme.gold,
                    ),
                    child: Text(
                      'เข้าสู่วันนี้ →',
                      style: GoogleFonts.notoSerifThai(
                        fontSize: 16, fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _enterDay(BuildContext context) {
    context.go(AppRoutes.home);
  }
}

// ── Mood Button ──────────────────────────────────
class _MoodButton extends StatelessWidget {
  final Mood mood;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodButton({
    required this.mood,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? DhammaTheme.gold.withOpacity(0.15)
              : Colors.white.withOpacity(0.05),
          border: Border.all(
            color: isSelected
                ? DhammaTheme.gold
                : Colors.white.withOpacity(0.08),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Text(mood.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text(
              mood.label,
              style: GoogleFonts.sarabun(
                fontSize: 11,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── AI Recommendation Card ───────────────────────
class _AIRecommendationCard extends ConsumerWidget {
  final Mood mood;
  const _AIRecommendationCard({required this.mood});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recAsync = ref.watch(aiRecommendationProvider(mood));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border.all(
          color: DhammaTheme.gold.withOpacity(0.25),
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI label
          Row(
            children: [
              Container(
                width: 6, height: 6,
                decoration: const BoxDecoration(
                  color: DhammaTheme.gold2,
                  shape: BoxShape.circle,
                ),
              )
              .animate(onPlay: (c) => c.repeat())
              .fadeIn(duration: 800.ms)
              .then()
              .fadeOut(duration: 800.ms),
              const SizedBox(width: 6),
              Text(
                'AI แนะนำสำหรับวันนี้',
                style: GoogleFonts.sarabun(
                  fontSize: 11,
                  color: DhammaTheme.gold2,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          recAsync.when(
            loading: () => _shimmerText(),
            error: (e, _) => Text(
              'ไม่สามารถโหลดคำแนะนำได้',
              style: GoogleFonts.sarabun(
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            data: (rec) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rec['message'] ?? '',
                  style: GoogleFonts.sarabun(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.85),
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 14),
                // Prayer recommendation
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: DhammaTheme.gold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: DhammaTheme.gold.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text('🙏', style: TextStyle(fontSize: 20)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rec['prayer'] ?? '',
                              style: GoogleFonts.notoSerifThai(
                                fontSize: 14, fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              rec['duration'] ?? '',
                              style: GoogleFonts.sarabun(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.45),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right,
                        color: Colors.white38, size: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerText() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: List.generate(3, (i) =>
      Container(
        margin: const EdgeInsets.only(bottom: 8),
        height: 14,
        width: i == 2 ? 120 : double.infinity,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(7),
        ),
      )
      .animate(onPlay: (c) => c.repeat())
      .shimmer(duration: 1500.ms, color: Colors.white.withOpacity(0.05)),
    ),
  );
}

// ── Today Banner ────────────────────────────────
class _TodayBanner extends StatelessWidget {
  final List<String> colors;
  final String prediction;

  const _TodayBanner({required this.colors, required this.prediction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        border: Border.all(
          color: DhammaTheme.gold.withOpacity(0.15),
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'สีมงคลวันนี้',
                style: GoogleFonts.sarabun(
                  fontSize: 11,
                  color: DhammaTheme.gold2,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                'พฤหัส 19 มี.ค.',
                style: GoogleFonts.sarabun(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: colors.map((c) =>
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  c,
                  style: GoogleFonts.sarabun(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.75),
                  ),
                ),
              ),
            ).toList(),
          ),
          const SizedBox(height: 10),
          Container(height: 1, color: Colors.white.withOpacity(0.06)),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              style: GoogleFonts.sarabun(
                fontSize: 13,
                color: Colors.white.withOpacity(0.6),
                height: 1.6,
              ),
              children: [
                TextSpan(
                  text: 'คำทำนาย: ',
                  style: TextStyle(color: DhammaTheme.gold2),
                ),
                TextSpan(text: prediction),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
