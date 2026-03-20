import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/dhamma_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DhammaTheme.ink,
      appBar: AppBar(title: const Text('ตั้งค่าบัญชี')),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: DhammaTheme.gold.withOpacity(0.2),
            child: const Text('N', style: TextStyle(fontSize: 40, color: DhammaTheme.gold)),
          ),
          const SizedBox(height: 16),
          Text(
            'คุณนุ่น',
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSerifThai(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            'Premium Member 🌟',
            textAlign: TextAlign.center,
            style: GoogleFonts.sarabun(fontSize: 14, color: DhammaTheme.gold2),
          ),
          const SizedBox(height: 48),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.white54),
            title: const Text('แก้ไขข้อมูลส่วนตัว', style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white54),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.notifications, color: Colors.white54),
            title: const Text('การแจ้งเตือน', style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white54),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.star, color: DhammaTheme.gold2),
            title: const Text('สถานะ Premium', style: TextStyle(color: DhammaTheme.gold2)),
            trailing: const Icon(Icons.chevron_right, color: DhammaTheme.gold2),
            onTap: () {},
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () {},
            child: const Text('ออกจากระบบ', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
