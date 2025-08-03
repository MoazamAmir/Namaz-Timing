import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:namaz_timing/constant/appbar_screen.dart';
import 'package:namaz_timing/models/quran_model.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:share_plus/share_plus.dart';

class SurahDetailScreen extends StatelessWidget {
  final Quran surah;

  SurahDetailScreen({required this.surah});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade900, Colors.teal.shade600],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            child: Column(
              children: [
                AppBarScreen(
                  title: "Quran",
                  textColor: Colors.white,
                  iconColor: Colors.black,
                  backgroundColor: Colors.white,
                ),

                /// 🌙 Surah Info Card
                Container(
                  margin: EdgeInsets.only(top: 18, bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white30),
                  ),
                  padding: const EdgeInsets.all(22),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              surah.name ?? '',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.3,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Total Ayahs: ${surah.verses?.length ?? 0}",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Image.asset(
                        "assets/images/home/pngwing.png",
                        height: screenHeight * 0.09,
                      ),
                    ],
                  ),
                ),
 Expanded(
  child: Material(
    elevation: 8,
    borderRadius: BorderRadius.circular(20),
    color: Colors.transparent,
    child: Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: AnimationLimiter(
        child: ClipRRect( // Optional for rounded corners clipping
          borderRadius: BorderRadius.circular(18),
          child: ListView.builder(
            padding: EdgeInsets.only(bottom: 20),
            physics: BouncingScrollPhysics(),
            itemCount: surah.verses?.length ?? 0,
            itemBuilder: (context, index) {
              final verse = surah.verses![index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 400),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: Card(
                      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      elevation: 4,
                      color: Colors.white.withOpacity(0.96),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.teal[800],
                                  radius: 16,
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Spacer(),
                              ],
                            ),
                            SizedBox(height: 14),
                            Text(
                              verse.text ?? '',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal[900],
                                height: 1.8,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                            SizedBox(height: 14),
                            Text(
                              verse.translation ?? '',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[800],
                                fontStyle: FontStyle.italic,
                                height: 1.5,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  tooltip: 'Copy',
                                  icon: Icon(Icons.copy_rounded,
                                      color: Colors.teal[700]),
                                  onPressed: () {
                                    final fullText =
                                        '${verse.text ?? ''}\n${verse.translation ?? ''}';
                                    Clipboard.setData(
                                        ClipboardData(text: fullText));
                                    Get.snackbar(
                                      'Copied',
                                      'Verse copied to clipboard',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.white,
                                      colorText: Colors.teal[900],
                                      margin: EdgeInsets.all(12),
                                      duration: Duration(seconds: 2),
                                    );
                                  },
                                ),
                                IconButton(
                                  tooltip: 'Share',
                                  icon: Icon(Icons.share_rounded,
                                      color: Colors.teal[700]),
                                  onPressed: () {
                                    final fullText =
                                        '${verse.text ?? ''}\n${verse.translation ?? ''}';
                                    Share.share(fullText);
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ),
  ),
),

                /// 📖 Verses List
              

              ],
            ),
          ),
        ),
      ),
    );
  }
}
