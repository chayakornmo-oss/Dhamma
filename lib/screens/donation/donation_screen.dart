import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/dhamma_theme.dart';

class DonationScreen extends StatelessWidget {
  const DonationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DhammaTheme.ink,
      appBar: AppBar(title: const Text('💚 ทำบุญออนไลน์')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF2E6B4B).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF2E6B4B).withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  Text(
                    'ยอดสะสมบุญของคุณ',
                    style: GoogleFonts.sarabun(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '฿ 1,200',
                    style: GoogleFonts.notoSerifThai(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF7BC47B),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.1),
            const SizedBox(height: 32),
            Text(
              'เลือกมูลนิธิ',
              style: GoogleFonts.notoSerifThai(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 16),
            const _DonationOrgCard(
              name: 'มูลนิธิป่อเต็กตึ๊ง',
              desc: 'บริจาคโลงศพและสงเคราะห์ผู้ยากไร้',
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 12),
            const _DonationOrgCard(
              name: 'โรงพยาบาลสงฆ์',
              desc: 'รักษาสงฆ์อาพาธ',
            ).animate().fadeIn(delay: 400.ms),
          ],
        ),
      ),
    );
  }
}

class _DonationOrgCard extends StatelessWidget {
  final String name;
  final String desc;

  const _DonationOrgCard({required this.name, required this.desc});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 80),
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
              width: 50, height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF2E6B4B).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Center(child: Text('🏥', style: TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: GoogleFonts.notoSerifThai(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(desc, style: GoogleFonts.sarabun(color: Colors.white54, fontSize: 13)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E6B4B),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('บริจาค', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
