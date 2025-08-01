import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:namaz_timing/controller/quran_controller.dart';
import 'package:namaz_timing/view/quran/surah_detailScreen.dart';

class SurahListScreen extends StatefulWidget {
  const SurahListScreen({super.key});

  @override
  State<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends State<SurahListScreen> {
  int selectedIndex = 0;
  String selectedHadithName = 'الفاتحة';
  final QuranController controller = Get.put(QuranController());
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔙 Back and Title
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

              // 📚 Selected Hadith Display Box
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color:  Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.all(screenWidth * 0.02),
                child: Row(
                  children: [
                    // Hadith Info
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quran',
                              style: TextStyle(
                                color: Colors.teal[800],
                                fontSize: screenWidth * 0.06,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              selectedHadithName.replaceFirst('-', '\n'),
                              style: TextStyle(
                              color: Colors.teal[800],
                                                      
                                fontSize: screenWidth * 0.06,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
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

              // 📖 List of Hadith Books
              Expanded(
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.transparent,
                  child: Container(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Obx(() {
                        if (controller.quranList.isEmpty) {
                          return Center(child: CircularProgressIndicator());
                        }

                        return AnimationLimiter(
                          child: ListView.builder(
                            itemCount: controller.quranList.length,
                            physics: BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              final isSelected = selectedIndex == index;
                              final surah = controller.quranList[index];

                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 400),
                                child: SlideAnimation(
                                  verticalOffset: 50.0,
                                  child: FadeInAnimation(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedIndex = index;
                                          selectedHadithName = surah.name ?? "";
                                        });
                                        Get.to(
                                          () => SurahDetailScreen(surah: surah),
                                        );
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        height: screenHeight * 0.07,
                                        margin: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: isSelected
                                              ? Border.all(
                                                 color: Colors.teal[800]!,
                                                  width: 2,
                                                )
                                              : null,
                                         
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Image.asset(
                                              "assets/images/home/pngwing.png",
                                              height: 50,
                                              width: 50,
                                            ),
                                            Text(
                                              surah.name ?? "",
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.06,
                                                fontWeight: FontWeight.w500,
                                                color: 
                                                    Colors.teal[800]!
                                                   
                                              ),
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
                        );
                      }),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
