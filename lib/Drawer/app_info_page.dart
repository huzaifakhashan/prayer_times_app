import 'package:flutter/material.dart';

class AppInfoPage extends StatelessWidget {
  const AppInfoPage({super.key});

  Widget _buildFeature(String text, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF4CAF50)),
      title: Text(
        text,
        textDirection: TextDirection.rtl,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101418),
      appBar: AppBar(
        title: const Text("نبذة عن التطبيق"),
        centerTitle: true,
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1B5E20).withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.mosque,
                  size: 60,
                  color: Color(0xFF4CAF50),
                ),
                SizedBox(height: 10),
                Text(
                  "مواقيت الصلاة",
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "مواقيت دقيقة لدمشق وسوريا",
                  textDirection: TextDirection.rtl,
                  style: TextStyle(fontSize: 16, color: Colors.white54),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            "✨ مميزات التطبيق",
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(height: 10),
          _buildFeature("حساب فلكي دقيق", Icons.calculate),
          _buildFeature("رابطة العالم الإسلامي", Icons.public),
          _buildFeature("إحداثيات دمشق الثابتة", Icons.location_on),
          _buildFeature("التاريخ الهجري", Icons.calendar_month),
          _buildFeature("تشغيل الأذان المخصص", Icons.music_note),
          _buildFeature("تعديل يدوي بالدقائق", Icons.tune),
          const SizedBox(height: 30),
          const Divider(color: Colors.white24),
          const SizedBox(height: 10),
          const Text(
            "🔧 التقنيات المستخدمة",
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(height: 8),
          _buildFeature("Flutter Framework", Icons.code),
          _buildFeature("adhan_dart لحساب المواقيت", Icons.calculate),
          _buildFeature("hijri للتاريخ الهجري", Icons.calendar_month),
          _buildFeature("just_audio لتشغيل الأذان", Icons.audiotrack),
        ],
      ),
    );
  }
}