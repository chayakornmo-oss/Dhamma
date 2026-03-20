import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/providers/app_state_providers.dart';
import '../../models/user_model.dart';
import '../../router/app_router.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/dhamma_theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: DhammaTheme.ink,
      appBar: AppBar(title: const Text('ตั้งค่าบัญชี')),
      body: profileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: DhammaTheme.gold),
        ),
        error: (e, _) => Center(
          child: Text(
            'ไม่สามารถโหลดข้อมูลได้',
            style: GoogleFonts.sarabun(color: Colors.white54),
          ),
        ),
        data: (profile) => _ProfileBody(profile: profile),
      ),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  final UserModel? profile;
  const _ProfileBody({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = profile?.name ?? 'ผู้ใช้';
    final initial = profile?.initial ?? 'ก';
    final isPremium = profile?.isPremium ?? false;
    final streak = profile?.streakDays ?? 0;
    final authService = ref.read(authServiceProvider);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // ── Avatar ────────────────────────────────────────────────
        Center(
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 52,
                backgroundColor: DhammaTheme.gold.withOpacity(0.2),
                backgroundImage: profile?.photoUrl != null
                    ? NetworkImage(profile!.photoUrl!)
                    : null,
                child: profile?.photoUrl == null
                    ? Text(
                        initial,
                        style: const TextStyle(
                            fontSize: 40, color: DhammaTheme.gold),
                      )
                    : null,
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: DhammaTheme.gold,
                  shape: BoxShape.circle,
                  border: Border.all(color: DhammaTheme.ink, width: 2),
                ),
                child: const Icon(Icons.edit, size: 14, color: DhammaTheme.ink),
              ),
            ],
          ),
        ).animate().fadeIn(),

        const SizedBox(height: 16),

        // ── Name ────────────────────────────────────────────────
        Text(
          name,
          textAlign: TextAlign.center,
          style: GoogleFonts.notoSerifThai(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ).animate().fadeIn(delay: 50.ms),

        const SizedBox(height: 4),

        Text(
          isPremium ? 'สมาชิก Premium 🌟' : 'สมาชิกฟรี',
          textAlign: TextAlign.center,
          style: GoogleFonts.sarabun(
            fontSize: 14,
            color: isPremium ? DhammaTheme.gold2 : Colors.white38,
          ),
        ).animate().fadeIn(delay: 80.ms),

        const SizedBox(height: 24),

        // ── Stats Row ────────────────────────────────────────────
        _StatsRow(streak: streak, profile: profile)
            .animate()
            .fadeIn(delay: 150.ms),

        const SizedBox(height: 32),

        // ── Sign-in status banner for anonymous users ────────────
        if (authService.isAnonymous) ...[
          _AnonymousUserBanner(ref: ref).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 24),
        ],

        // ── Settings List ────────────────────────────────────────
        _SettingsTile(
          icon: Icons.person_outline,
          label: 'แก้ไขข้อมูลส่วนตัว',
          onTap: () => _showEditNameSheet(context, ref, name),
        ),
        _SettingsTile(
          icon: Icons.notifications_none,
          label: 'การแจ้งเตือน',
          onTap: () {},
        ),
        _SettingsTile(
          icon: Icons.history,
          label: 'ประวัติการเช็กอิน',
          onTap: () {},
        ),
        if (!isPremium)
          _SettingsTile(
            icon: Icons.star_border,
            label: 'สมัคร Premium',
            valueColor: DhammaTheme.gold2,
            onTap: () {},
          ),
        _SettingsTile(
          icon: Icons.info_outline,
          label: 'เกี่ยวกับแอป',
          onTap: () {},
        ),

        const SizedBox(height: 32),

        // ── Sign Out ─────────────────────────────────────────────
        TextButton(
          onPressed: () => _confirmSignOut(context, ref),
          child: const Text(
            'ออกจากระบบ',
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
      ],
    );
  }

  // ── Edit Name Sheet ──────────────────────────────────────────────
  void _showEditNameSheet(
      BuildContext context, WidgetRef ref, String currentName) {
    final controller = TextEditingController(text: currentName);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1528),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'แก้ไขชื่อ',
              style: GoogleFonts.notoSerifThai(
                color: DhammaTheme.gold,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'ชื่อของคุณ',
                hintStyle: const TextStyle(color: Colors.white38),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: DhammaTheme.gold.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: DhammaTheme.gold),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final newName = controller.text.trim();
                  if (newName.isEmpty) return;
                  Navigator.pop(sheetCtx);
                  await ref
                      .read(firestoreServiceProvider)
                      .updateUserName(newName);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('อัปเดตชื่อเรียบร้อยแล้ว'),
                        backgroundColor: DhammaTheme.gold,
                      ),
                    );
                  }
                },
                child: const Text('บันทึก'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Confirm Sign Out ─────────────────────────────────────────────
  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1528),
        title: Text(
          'ออกจากระบบ?',
          style: GoogleFonts.notoSerifThai(color: Colors.white),
        ),
        content: Text(
          'คุณแน่ใจหรือไม่ว่าต้องการออกจากระบบ?',
          style: GoogleFonts.sarabun(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก',
                style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) {
                context.go(AppRoutes.splash);
              }
            },
            child: const Text('ออกจากระบบ',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

// ── Stats Row ─────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final int streak;
  final UserModel? profile;

  const _StatsRow({required this.streak, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
          emoji: '🔥',
          value: '$streak',
          label: 'วันติดต่อกัน',
        ),
        const SizedBox(width: 12),
        _StatCard(
          emoji: '📅',
          value: _memberSince(profile),
          label: 'เริ่มใช้งาน',
        ),
      ],
    );
  }

  String _memberSince(UserModel? profile) {
    if (profile?.lastCheckin == null) return '—';
    final d = profile!.lastCheckin!;
    return '${d.day}/${d.month}/${d.year + 543}';
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;

  const _StatCard({
    required this.emoji,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.notoSerifThai(
                color: DhammaTheme.gold,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.sarabun(
                  color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Anonymous User Banner ─────────────────────────────────────────────
class _AnonymousUserBanner extends ConsumerWidget {
  final WidgetRef ref;
  const _AnonymousUserBanner({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DhammaTheme.gold.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DhammaTheme.gold.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🔐 บันทึกบัญชีของคุณ',
            style: GoogleFonts.notoSerifThai(
              color: DhammaTheme.gold2,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ตอนนี้คุณใช้งานในฐานะผู้เยี่ยมชม ข้อมูลอาจหายหากถอนการติดตั้งแอป ลงชื่อเข้าใช้เพื่อบันทึกข้อมูลถาวร',
            style: GoogleFonts.sarabun(
                color: Colors.white70, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _signInWithGoogle(context, ref),
                  icon: const Text('G', style: TextStyle(fontWeight: FontWeight.bold)),
                  label: const Text('Google'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              if (AuthService.isAppleSignInAvailable) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _signInWithApple(context, ref),
                    icon: const Icon(Icons.apple, size: 18),
                    label: const Text('Apple'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _signInWithGoogle(BuildContext context, WidgetRef ref) async {
    final user = await ref.read(authServiceProvider).signInWithGoogle();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            user != null
                ? 'ลงชื่อเข้าใช้ด้วย Google เรียบร้อยแล้ว'
                : 'ไม่สามารถลงชื่อเข้าใช้ได้ กรุณาลองใหม่',
          ),
          backgroundColor:
              user != null ? DhammaTheme.sage : Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _signInWithApple(BuildContext context, WidgetRef ref) async {
    final user = await ref.read(authServiceProvider).signInWithApple();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            user != null
                ? 'ลงชื่อเข้าใช้ด้วย Apple เรียบร้อยแล้ว'
                : 'ไม่สามารถลงชื่อเข้าใช้ได้ กรุณาลองใหม่',
          ),
          backgroundColor:
              user != null ? DhammaTheme.sage : Colors.redAccent,
        ),
      );
    }
  }
}

// ── Settings Tile ─────────────────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? valueColor;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = valueColor ?? Colors.white;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: Icon(icon, color: color.withOpacity(0.7)),
      title: Text(label, style: TextStyle(color: color)),
      trailing: Icon(Icons.chevron_right, color: color.withOpacity(0.4)),
      onTap: onTap,
    );
  }
}
