// lib/controllers/namaz_controller.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class NamazController extends GetxController {
  var timings = <String, String>{}.obs;
  var currentPrayer = ''.obs;
  var currentTime = ''.obs;
  var nextPrayer = ''.obs;
  var nextTime = ''.obs;
  var isLoading = false.obs;
  var isDataFetched = false.obs;

  Future<void> fetchNamazTimings() async {
    if (isDataFetched.value) return;

    try {
      isLoading.value = true;
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception(
            'Location permission permanently denied. Please enable it from app settings.');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final url =
          'https://api.aladhan.com/v1/timings?latitude=${position.latitude}&longitude=${position.longitude}&method=2';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
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
        currPrayer ??= prayerOrder.last;
        currTime ??= timingData[prayerOrder.last];
        nextPray ??= prayerOrder.first;
        nextPrayTime ??= timingData[prayerOrder.first];

        timings.value = timingData;
        currentPrayer.value = currPrayer;
        currentTime.value = currTime ?? '';
        nextPrayer.value = nextPray;
        nextTime.value = nextPrayTime ?? '';
        isDataFetched.value = true;
      } else {
        throw Exception('Failed to load namaz timings');
      }
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
