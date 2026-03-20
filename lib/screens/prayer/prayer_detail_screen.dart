import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/dhamma_theme.dart';

class PrayerDetailScreen extends StatelessWidget {
  const PrayerDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DhammaTheme.ink,
      appBar: AppBar(
        title: const Text('อิติปิโส ภควา'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
        child: Center(
          child: Column(
            children: [
              Text(
                'บทบทสวดสรรเสริญพระพุทธคุณ',
                style: GoogleFonts.sarabun(
                  fontSize: 16,
                  color: DhammaTheme.gold2,
                ),
              ),
              const SizedBox(height: 48),
              Text(
                '''อิติปิ โส ภะคะวา อะระหัง สัมมาสัมพุทโธ
วิชชาจะระณะสัมปันโน สุคะโต โลกะวิทู
อะนุตตะโร ปุริสะทัมมะสาระถิ สัตถา
เทวะมะนุสสานัง พุทโธ ภะคะวาติ''',
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSerifThai(
                  fontSize: 22,
                  color: Colors.white,
                  height: 2.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
