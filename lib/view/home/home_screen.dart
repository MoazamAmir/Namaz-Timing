import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/get_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:namaz_timing/view/Hadith/select_hadith_screen.dart';
import 'package:namaz_timing/view/quran/surah_listScreen.dart';

class IslamicHomeScreen extends StatelessWidget {
  const IslamicHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none, // 👈 Add this to allow overflow (important)
        children: [
          // 🔶 Top Gradient Container
          Container(
            height: 450,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xffF7CCB8), Color(0xffFFE5D4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔍 Search bar and profile icon
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.search, color: Colors.grey),
                            SizedBox(width: 8),
                            Text('Find', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.notifications, color: Colors.blue),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 📍 Location
                Text(
                  'Your Location',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const Text(
                  'Green Campus, Central university, Ganderbal',
                  style: TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // 🕌 Prayer Time Card
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xffF9C9B7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Duhar',
                              style: TextStyle(color: Colors.white70),
                            ),
                            Text(
                              '01:15 PM',
                              style: GoogleFonts.lato(
                                fontSize: 36,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Next Pray: Asr\n05:32 PM',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Image.asset("assets/images/home/jama.png", height: 128),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ✅ Overlapping container (shown above top container)
          Positioned(
            top: 370,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(20),
                color: Colors.transparent, // 👈 Material background transparent
                child: Container(
                  height: 250,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(
                      0.5,
                    ), // 👈 semi-transparent background
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(0),
                    child: GridView.count(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _featureButton(
                          'Hadith',
                          "assets/images/home/man.png",
                          onTap: () {
                            Get.to(SelectHadithScreen());
                          },
                        ),
                        _featureButton(
                          'Dua',
                          "assets/images/home/dua.png",
                          onTap: () {},
                        ),
                        _featureButton(
                          'Daily Verse',
                          "assets/images/home/quran.png",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SurahListScreen(),
                              ),
                            );
                          },
                        ),
                        _featureButton(
                          'Community',
                          "assets/images/home/partners.png",
                          onTap: () {},
                        ),
                        _featureButton(
                          'Maps',
                          "assets/images/home/map.png",
                          onTap: () {},
                        ),
                        // _featureButton('More', Icons.more_horiz),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureButton(String title, String imagePath, {VoidCallback? onTap}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xffEEF7FF).withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Image.asset(imagePath, width: 35, height: 35),
          ),
        ),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
