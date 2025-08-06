import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:namaz_timing/controller/hadith_controller.dart';
import 'package:namaz_timing/view/home/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
    Get.put(HadithController()).preloadAllHadiths();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home:
          IslamicHomeScreen(), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
