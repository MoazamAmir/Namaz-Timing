// controllers/hadith_controller.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../models/hadith_model.dart';
import '../hadithbookslist/hadit_data_array.dart';

class HadithController extends GetxController {
  final hadithsMap = <int, List<HadithElement>>{}.obs;

  Future<void> loadHadiths(int selectedId) async {
    // Check if already loaded
    if (hadithsMap.containsKey(selectedId)) return;

    final combined = [...array1, ...array2];
    final matchingFiles = combined.where((e) => e['id'] == selectedId).toList();

    List<HadithElement> allHadiths = [];

    for (var file in matchingFiles) {
      final String response = await rootBundle.loadString(file['path']);
      final data = jsonDecode(response);
      final hadith = Hadith.fromJson(data);
      allHadiths.addAll(hadith.hadiths);
    }

    hadithsMap[selectedId] = allHadiths;
  }

  List<HadithElement> getHadiths(int id) => hadithsMap[id] ?? [];
}
