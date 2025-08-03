// controllers/namaz_time_controller.dart

import 'dart:convert';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

class NamazTimeController extends GetxController {
  var timings = <String, String>{}.obs;
  var hijriDate = ''.obs;
  var gregorianDate = ''.obs;
  var timezone = ''.obs;
  var methodName = ''.obs;
  var city = ''.obs;
  var country = ''.obs;
  var isLoading = true.obs;
  var isDataFetched = false.obs;

  Future<void> getLocationAndFetchTimings() async {
    try {
      isLoading.value = true;

      if (isDataFetched.value) {
        isLoading.value = false;
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        city.value = placemarks.first.locality ?? '';
        country.value = placemarks.first.country ?? '';

        await fetchNamazTimingsByCity();
      } else {
        throw Exception('Unable to determine city and country');
      }
    } catch (e) {
      isLoading.value = false;
      rethrow;
    }
  }

  Future<void> fetchNamazTimingsByCity() async {
    final url =
        'https://api.aladhan.com/v1/timingsByCity?city=${city.value}&country=${country.value}&method=2';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timingData = data['data']['timings'];
        final date = data['data']['date'];
        final hijri = date['hijri'];
        final gregorian = date['gregorian'];
        final meta = data['data']['meta'];

        timings.value = Map<String, String>.from(timingData);
       hijriDate.value = '${hijri['date']} (${hijri['weekday']['en']}) - ${hijri['month']['en']}';

        gregorianDate.value =
            '${gregorian['date']} (${gregorian['weekday']['en']}) - ${gregorian['month']['en']}';
        timezone.value = meta['timezone'];
        methodName.value = meta['method']['name'];
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
