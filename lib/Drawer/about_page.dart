import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101418), // ✅ خلفية داكنة
      appBar: AppBar(
        title: const Text("من نحن"),
        centerTitle: true,
        backgroundColor: const Color(0xFF1B5E20), // ✅ أخضر داكن
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 55,
              backgroundColor: Color(0xFF1B5E20),
              child: Icon(
                Icons.mosque,
                color: Colors.white,
                size: 60,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "مواقيت الصلاة",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "الإصدار 1.0.0",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "تطبيق مواقيت الصلاة هو أداة دقيقة لحساب أوقات الصلاة "
              "لمدينة دمشق وسوريا، معتمداً على طريقة رابطة العالم الإسلامي "
              "التي تعتمدها وزارة الأوقاف السورية رسمياً، مع إمكانية "
              "التعديل اليدوي لمطابقة تقويم مسجدك.",
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, height: 1.8, color: Colors.white70),
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.white24),
            const SizedBox(height: 20),
            const Text(
              "💡 مميزات التطبيق:",
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(height: 10),
            _buildFeature("مواقيت دقيقة لدمشق"),
            _buildFeature("التاريخ الهجري والميلادي"),
            _buildFeature("تشغيل الأذان من ملفاتك الخاصة"),
            _buildFeature("تعديل يدوي بالدقائق لكل صلاة"),
            _buildFeature("وضع مظلم مريح للعين"),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              textDirection: TextDirection.rtl,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}