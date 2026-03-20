import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/dhamma_theme.dart';

class AddVowScreen extends StatefulWidget {
  const AddVowScreen({super.key});

  @override
  State<AddVowScreen> createState() => _AddVowScreenState();
}

class _AddVowScreenState extends State<AddVowScreen> {
  final _templeController = TextEditingController();
  final _prayerController = TextEditingController();
  final _fulfillmentController = TextEditingController();
  DateTime? _reminderDate;

  @override
  void dispose() {
    _templeController.dispose();
    _prayerController.dispose();
    _fulfillmentController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: DhammaTheme.gold,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _reminderDate = picked);
  }

  void _saveVow() {
    if (_templeController.text.isNotEmpty && _prayerController.text.isNotEmpty) {
      // Save logic goes here.
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกสถานที่และเรื่องที่ขอพรให้ครบถ้วน')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DhammaTheme.ink,
      appBar: AppBar(
        title: const Text('📍 สร้างคำขอพร'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ขอพรเรื่องอะไรดี?',
              style: GoogleFonts.notoSerifThai(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: DhammaTheme.gold,
              ),
            ).animate().fadeIn().slideX(),
            const SizedBox(height: 32),
            _buildTextField(
              controller: _templeController,
              label: 'สถานที่ / วัด',
              hint: 'เช่น ศาลพระพรหม เอราวัณ',
              icon: Icons.account_balance,
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _prayerController,
              label: 'เรื่องที่ขอพร',
              hint: 'เช่น ขอให้สอบผ่านรอบนี้',
              icon: Icons.favorite_border,
              maxLines: 3,
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _fulfillmentController,
              label: 'สิ่งที่จะแก้บน (ถ้ามี)',
              hint: 'เช่น ถวายพวงมาลัย 9 พวง',
              icon: Icons.card_giftcard,
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 20),
            Text('วันที่ต้องการให้แจ้งเตือน', style: GoogleFonts.sarabun(color: Colors.white70)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: DhammaTheme.gold, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      _reminderDate == null
                          ? 'เลือกวันที่สำหรับแจ้งเตือน'
                          : '${_reminderDate!.day}/${_reminderDate!.month}/${_reminderDate!.year}',
                      style: GoogleFonts.sarabun(
                        fontSize: 16,
                        color: _reminderDate == null ? Colors.white30 : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveVow,
                child: const Text('บันทึกคำขอพร'),
              ),
            ).animate().fadeIn(delay: 500.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.sarabun(color: Colors.white70)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white30),
            prefixIcon: maxLines == 1 ? Icon(icon, color: DhammaTheme.gold.withOpacity(0.5)) : null,
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: DhammaTheme.gold),
            ),
          ),
        ),
      ],
    );
  }
}
