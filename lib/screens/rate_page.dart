import 'package:flutter/material.dart';

class RatePage extends StatefulWidget {
  const RatePage({super.key});

  @override
  State<RatePage> createState() => _RatePageState();
}

class _RatePageState extends State<RatePage> {
  int rating = 0;

  Widget buildStar(int index) {
    return IconButton(
      onPressed: () {
        setState(() {
          rating = index;
        });
      },
      icon: Icon(
        index <= rating ? Icons.star : Icons.star_border,
        color: Colors.amber,
        size: 45,
      ),
      splashRadius: 30,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101418),
      appBar: AppBar(
        title: const Text("قيّم التطبيق"),
        centerTitle: true,
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.mosque,
                size: 80,
                color: Color(0xFF4CAF50),
              ),
              const SizedBox(height: 20),
              const Text(
                "ما رأيك بتطبيق مواقيت الصلاة؟",
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "تقييمك يساعدنا على التحسين",
                textDirection: TextDirection.rtl,
                style: TextStyle(fontSize: 16, color: Colors.white54),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => buildStar(index + 1),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                rating > 0 ? "شكراً لتقييمك بـ $rating نجوم 🌟" : "اختر عدد النجوم",
                style: TextStyle(
                  fontSize: 16,
                  color: rating > 0 ? const Color(0xFF4CAF50) : Colors.white54,
                  fontWeight: rating > 0 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: rating > 0
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("شكراً لتقييمك ❤️ ($rating نجوم)"),
                            backgroundColor: const Color(0xFF1B5E20),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    : null,
                child: const Text(
                  "إرسال التقييم",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}