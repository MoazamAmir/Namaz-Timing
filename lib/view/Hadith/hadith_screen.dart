import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:namaz_timing/controller/hadithbookslist/hadit_data_array.dart';
import 'package:namaz_timing/models/hadith_model.dart';
import 'package:share_plus/share_plus.dart';
import 'package:translator/translator.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class HadithScreen extends StatefulWidget {
  final int selectedId;
  HadithScreen({required this.selectedId});

  @override
  _HadithScreenState createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  late Future<List<HadithElement>> _hadithDataFuture;
  final translator = GoogleTranslator();
  final storage = GetStorage();

  Map<int, String> _translatedTextMap = {};
  Set<int> _showTranslation = {};
  Set<int> _translatingIndices = {};
  int selectedIndex = 0;
  String selectedHadithName = '';

  @override
  void initState() {
    super.initState();
    _hadithDataFuture = loadAllHadiths(widget.selectedId);
  }

  Future<List<HadithElement>> loadAllHadiths(int selectedId) async {
    final combined = [...array1, ...array2];
    final matchingFiles = combined.where((e) => e['id'] == selectedId).toList();

    List<HadithElement> allHadiths = [];

    for (var file in matchingFiles) {
      final String response = await rootBundle.loadString(file['path']);
      final data = jsonDecode(response);
      final hadith = Hadith.fromJson(data);
      allHadiths.addAll(hadith.hadiths);
    }

    return allHadiths;
  }

  Future<void> toggleTranslation(int index, String originalText) async {
    if (_showTranslation.contains(index)) {
      setState(() {
        _showTranslation.remove(index);
      });
    } else {
      setState(() {
        _translatingIndices.add(index);
      });

      final cached = storage.read(originalText);
      if (cached != null) {
        _translatedTextMap[index] = cached;
      } else {
        try {
          final translation = await translator.translate(
            originalText,
            from: 'en',
            to: 'ur',
          );
          _translatedTextMap[index] = translation.text;
          storage.write(originalText, translation.text);
        } catch (e) {
          _translatedTextMap[index] = originalText;
        }
      }

      setState(() {
        _translatingIndices.remove(index);
        _showTranslation.add(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;

    return SafeArea(
      child: Scaffold(
         backgroundColor:  Colors.teal[800],
        body: Padding(
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
                          "Hadith",
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
              Image.asset("assets/images/home/Rectangle.png"),
              Expanded(
                child: FutureBuilder<List<HadithElement>>(
                  future: _hadithDataFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text("No Hadiths Found"));
                    }

                    final hadithList = snapshot.data!;

                    return AnimationLimiter(
                      child: ListView.builder(
                        physics: BouncingScrollPhysics(),
                        itemCount: hadithList.length,
                        itemBuilder: (context, index) {
                          final hadith = hadithList[index];
                          final englishText = hadith.english?.text ?? "";
                          final translatedText =
                              _translatedTextMap[index] ?? "";
                          final isTranslated = _showTranslation.contains(index);
                          final isTranslating = _translatingIndices.contains(
                            index,
                          );

                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 400),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: Card(
                                  color: Colors.white.withOpacity(0.8),
                                  margin: EdgeInsets.only(top: 10),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          hadith.arabic ?? "",
                                          textAlign: TextAlign.right,
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        SizedBox(height: 8),
                                        if (hadith.english?.narrator != null)
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              "${hadith.english?.narrator}",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        SizedBox(height: 4),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            hadith.english?.text ?? "",
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                final shareText =
                                                    '''
📜 *Hadith*

🕌 Arabic:
${hadith.arabic ?? ""}

👤 Narrator:
${hadith.english?.narrator ?? "N/A"}

📖 Translation:
${isTranslated ? translatedText : englishText}
''';
                                                Share.share(shareText);
                                              },
                                              icon: Icon(
                                                Icons.share,
                                                color: const Color.fromARGB(
                                                  255,
                                                  250,
                                                  181,
                                                  156,
                                                ),
                                              ),
                                              tooltip: "Share Hadith",
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
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
