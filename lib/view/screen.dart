import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class NamazTimeScreen extends StatefulWidget {
  @override
  _NamazTimeScreenState createState() => _NamazTimeScreenState();
}

class _NamazTimeScreenState extends State<NamazTimeScreen> {
  Map<String, String> timings = {};
  String hijriDate = '';
  String gregorianDate = '';
  String timezone = '';
  String methodName = '';
  bool isLoading = true;
  String city = '';
  String country = '';

  @override
  void initState() {
    super.initState();
    getLocationAndFetchTimings();
  }

  Future<void> getLocationAndFetchTimings() async {
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
          'Location permission permanently denied. Enable from settings.',
        );
      }

      // Get current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Reverse geocoding to get city and country
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        city = placemarks.first.locality ?? '';
        country = placemarks.first.country ?? '';

        fetchNamazTimingsByCity();
      } else {
        throw Exception('Unable to determine city and country');
      }
    } catch (e) {
      setState(() => isLoading = false);
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> fetchNamazTimingsByCity() async {
    setState(() => isLoading = true);
    final url =
        'https://api.aladhan.com/v1/timingsByCity?city=$city&country=$country&method=2';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timingData = data['data']['timings'];
        final date = data['data']['date'];
        final hijri = date['hijri'];
        final gregorian = date['gregorian'];
        final meta = data['data']['meta'];

        setState(() {
          timings = Map<String, String>.from(timingData);
          hijriDate =
              '${hijri['date']} (${hijri['weekday']['en']}) - ${hijri['month']['en']}';
          gregorianDate =
              '${gregorian['date']} (${gregorian['weekday']['en']}) - ${gregorian['month']['en']}';
          timezone = meta['timezone'];
          methodName = meta['method']['name'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load namaz timings');
      }
    } catch (e) {
      setState(() => isLoading = false);
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Widget buildTile(String title, String value) {
    return ListTile(
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      trailing: Text(value),
    );
  }

 @override
Widget build(BuildContext context) {
  final Size screenSize = MediaQuery.of(context).size;
  final double screenHeight = screenSize.height;
  final double screenWidth = screenSize.width;

  return SafeArea(
    child: Scaffold(
      backgroundColor:  Colors.teal,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.02),

                  // AppBar Row
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
                      SizedBox(width: screenWidth * 0.2),
                      Text(
                        "Prayer Times",
                        style: TextStyle(
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: screenHeight * 0.03),

                  // Location Info
                  Center(
                    child: Column(
                      children: [
                        Text(
                          "$city, $country",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Timezone: $timezone',
                          style: TextStyle(  color: Colors.white,),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Method: $methodName',
                          style: TextStyle(  color: Colors.white,),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.03),

                  // Dates
                  Center(
                    child: Column(
                      children: [
                        Text(
                          hijriDate,
                          style: TextStyle(
                            fontSize: 16,
                             color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          gregorianDate,
                          style: TextStyle(
                            fontSize: 14,
                             color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.04),

                  // Prayer Times Container
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            "Today's Prayer Timings",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal[700],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Divider(thickness: 1),
                        SizedBox(height: 10),
                        prayerTimeCard('Fajr', timings['Fajr'] ?? 'N/A'),
                        prayerTimeCard('Dhuhr', timings['Dhuhr'] ?? 'N/A'),
                        prayerTimeCard('Asr', timings['Asr'] ?? 'N/A'),
                        prayerTimeCard('Maghrib', timings['Maghrib'] ?? 'N/A'),
                        prayerTimeCard('Isha', timings['Isha'] ?? 'N/A'),
                      ],
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.04),
                ],
              ),
            ),
    ),
  );
}
Widget prayerTimeCard(String title, String time) {
  return Container(
    margin: EdgeInsets.symmetric(vertical: 8),
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.shade300,
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Text(
          time,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.teal[800],
          ),
        ),
      ],
    ),
  );
}

}
