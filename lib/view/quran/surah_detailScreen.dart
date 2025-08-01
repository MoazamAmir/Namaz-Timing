import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
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
     backgroundColor:  Colors.teal[800],
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          child: Column(
            children: [
              Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Icon(Icons.arrow_back, color: Colors.black),
                        ),
                      ),
                      SizedBox(width: 10),
                      Center(
                        child: Text(
                          "Quran",
                          style: TextStyle(
                            fontSize:20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
              SizedBox(height: screenHeight * 0.02),

              // 📚 Surah Display Box
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color:  Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.all(screenWidth * 0.02),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Sura ${surah.name ?? ""}",
                            style: TextStyle(
                             color:   Colors.teal[800],
                              fontSize: screenWidth * 0.06,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Image.asset(
                      "assets/images/home/pngwing.png",
                      height: screenHeight * 0.15,
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              // 🔄 Scrolling Animation for Verses
              Expanded(
                child: AnimationLimiter(
                  child: ListView.builder(
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
                              elevation: 0,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      verse.text ?? '',
                                      style: TextStyle(
                                        fontSize: 20,
                                         color:   Colors.teal[800],
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.right,
                                      textDirection: TextDirection
                                          .ltr, // 👈 This makes the Arabic text start from right
                                    ),

                                    SizedBox(height: 8),
                                    Text(
                                      verse.translation ?? '',
                                      style: TextStyle(fontSize: 16),
                                      textAlign: TextAlign.right,
                                      textDirection: TextDirection.rtl,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.copy,
                                            color:   Colors.teal[800],
                                          ),
                                          onPressed: () {
                                            final fullText =
                                                '${verse.text ?? ''}\n${verse.translation ?? ''}';
                                            Clipboard.setData(
                                              ClipboardData(text: fullText),
                                            );
                                            Get.snackbar(
                                              'Copied',
                                              'Verse copied to clipboard',
                                              snackPosition:
                                                  SnackPosition.BOTTOM,
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.share,
                                            color:   Colors.teal[800],
                                          ),
                                          onPressed: () {
                                            final fullText =
                                                '${verse.text ?? ''}\n${verse.translation ?? ''}';
                                            Share.share(fullText);
                                          },
                                        ),
                                      ],
                                    ),
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
            ],
          ),
        ),
      ),
    );
  }
}
