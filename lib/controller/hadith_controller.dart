// import 'dart:convert';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:namaz_timing/models/hadith_model.dart';

// class HadithController extends GetxController {
//   var hadithData = Rxn<Hadith>();
//   var isLoading = true.obs;

//   @override
//   void onInit() {
//     loadHadithData();
//     super.onInit();
//   }

//   Future<void> loadHadithData() async {
//     try {
//       isLoading.value = true;

//       final String jsonString = await rootBundle.loadString(
//         'assets/images/bukhari.json',
//       );

//       // Decode JSON
//       final Map<String, dynamic> jsonMap = json.decode(jsonString);

//       // Print full JSON (as formatted string)
//       print(
//         "Full JSON Data:\n${const JsonEncoder.withIndent('  ').convert(jsonMap)}",
//       );

//       // Then assign to model
//       hadithData.value = Hadith.fromJson(jsonMap);

//       // Debug prints
//       print("Loaded Hadith Count: ${hadithData.value?.hadiths.length}");
//       print("First Hadith Arabic: ${hadithData.value?.hadiths.first.arabic}");
//     } catch (e) {
//       print("Error loading hadith data: $e");
//     } finally {
//       isLoading.value = false;
//     }
//   }
// }
