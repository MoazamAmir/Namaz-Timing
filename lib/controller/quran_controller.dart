import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../models/quran_model.dart';

class QuranController extends GetxController {
  var quranList = <Quran>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadQuranData();
  }

  Future<void> loadQuranData() async {
    final String response = await rootBundle.loadString(
      'assets/images/json_file/quran.json',
    );
    final data = json.decode(response);
    quranList.value = List<Quran>.from(data.map((e) => Quran.fromJson(e)));
  }
}
