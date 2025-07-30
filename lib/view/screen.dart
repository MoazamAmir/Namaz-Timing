import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
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
    return Scaffold(
      appBar: AppBar(title: Text('Namaz Timings')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListView(
                children: [
                  Card(
                    elevation: 4,
                    child: ListTile(title: Text('City'), subtitle: Text(city)),
                  ),
                  Card(
                    elevation: 4,
                    child: ListTile(
                      title: Text('Country'),
                      subtitle: Text(country),
                    ),
                  ),
                  Card(
                    elevation: 4,
                    child: ListTile(
                      title: Text('Hijri Date'),
                      subtitle: Text(hijriDate),
                    ),
                  ),
                  Card(
                    elevation: 4,
                    child: ListTile(
                      title: Text('Gregorian Date'),
                      subtitle: Text(gregorianDate),
                    ),
                  ),
                  Card(
                    elevation: 4,
                    child: ListTile(
                      title: Text('Timezone'),
                      subtitle: Text(timezone),
                    ),
                  ),
                  Card(
                    elevation: 4,
                    child: ListTile(
                      title: Text('Calculation Method'),
                      subtitle: Text(methodName),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Prayer Timings',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ...timings.entries
                      .map((entry) => buildTile(entry.key, entry.value))
                      .toList(),
                ],
              ),
            ),
    );
  }
}
