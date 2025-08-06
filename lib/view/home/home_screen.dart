import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_core/get_core.dart';
import 'package:http/http.dart' as http;
import 'package:namaz_timing/view/Hadith/select_hadith_screen.dart';
import 'package:namaz_timing/view/Voice/RecitersScreen.dart';
import 'package:namaz_timing/view/community.dart';
import 'package:namaz_timing/view/quran/mosquefinderScreen.dart' show MosqueFinderScreen;
import 'package:namaz_timing/view/quran/surah_listScreen.dart';
import 'package:namaz_timing/view/screen.dart';

class IslamicHomeScreen extends StatefulWidget {
  const IslamicHomeScreen({super.key});

  @override
  State<IslamicHomeScreen> createState() => _IslamicHomeScreenState();
}

class _IslamicHomeScreenState extends State<IslamicHomeScreen> {
  Map<String, String> timings = {};
  String currentPrayer = '';
  String currentTime = '';
  String nextPrayer = '';
  String nextTime = '';
  bool isLoading = false;
  String city = '';
  String country = '';
  @override
  void initState() {
    super.initState();
    fetchNamazTimings();
  }

  Future<void> fetchNamazTimings() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Location permission permanently denied. Please enable it from app settings.',
        );
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final url =
          'https://api.aladhan.com/v1/timings?latitude=${position.latitude}&longitude=${position.longitude}&method=2';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("body data${response.body}");
        final timingData = Map<String, String>.from(data['data']['timings']);

        final now = TimeOfDay.now();
        final nowMinutes = now.hour * 60 + now.minute;

        final prayerOrder = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

        String? currPrayer;
        String? currTime;
        String? nextPray;
        String? nextPrayTime;

        for (int i = 0; i < prayerOrder.length; i++) {
          final time = timingData[prayerOrder[i]]!;
          final split = time.split(":");
          final tHour = int.parse(split[0]);
          final tMin = int.parse(split[1]);
          final totalMin = tHour * 60 + tMin;

          if (nowMinutes < totalMin) {
            currPrayer = i == 0 ? prayerOrder.last : prayerOrder[i - 1];
            currTime = i == 0
                ? timingData[prayerOrder.last]
                : timingData[prayerOrder[i - 1]];
            nextPray = prayerOrder[i];
            nextPrayTime = time;
            break;
          }
        }

        // If no next found (after Isha), loop to Fajr
        if (currPrayer == null) {
          currPrayer = prayerOrder.last;
          currTime = timingData[prayerOrder.last];
          nextPray = prayerOrder.first;
          nextPrayTime = timingData[prayerOrder.first];
        }

        setState(() {
          timings = timingData;
          currentPrayer = currPrayer!;
          currentTime = currTime!;
          nextPrayer = nextPray!;
          nextTime = nextPrayTime!;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load namaz timings');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 400,
            decoration:  BoxDecoration(
             color: Colors.teal[800]
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
                  style: TextStyle(  color: Colors.white,),
                ),
                const Text(
                  'Green Campus, Central university, Ganderbal',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                    
                // 🕌 Prayer Time Card
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color:  Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currentPrayer,
                                      style:  TextStyle(
                                         color: Colors.teal[800]
                                      ),
                                    ),
                                    Text(
                                      currentTime,
                                      style: TextStyle(
                                        fontSize: 36,
                                         color: Colors.teal[800],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Next Pray: $nextPrayer\n$nextTime',
                                      style:  TextStyle(
                                         color: Colors.teal[800],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Image.asset(
                                "assets/images/home/jama.png",
                                height: 128,
                                  color: Colors.teal[800]
                              ),
                            ],
                          ),
                        ),
                      ),
              ],
            ),
          ),
          
          // ✅ Overlapping container (shown above top container)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
               
                color: Colors.transparent, // 👈 Material background transparent
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
                        'Prayer Times',
                        "assets/images/home/dua.png",  
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NamazTimeScreen(),
                            ),
                          );
                        },
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
                      onTap: () {
          // Navigator.push(
          //           context,
          //           MaterialPageRoute(
          //             builder: (context) => RecitersScreen(),
          //           ),
          // );
                      },
                    ),
                    
                     
                      _featureButton(
                        'Maps',
                        "assets/images/home/map.png",
                       onTap: ()  {
                Get.to(MosqueFinderScreen());
                },
                
                      ),
                      // _featureButton('More', Icons.more_horiz),
                       _featureButton(
                        'Voice',
                        "assets/images/home/voice.png",
                       onTap: ()  {
                Get.to(RecitersScreen());
                },
                
                      ),
                    ],
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
        GestureDetector(
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
