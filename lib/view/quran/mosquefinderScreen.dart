import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';

class MosqueFinderScreen extends StatefulWidget {
  @override
  _MosqueFinderScreenState createState() => _MosqueFinderScreenState();
}

class _MosqueFinderScreenState extends State<MosqueFinderScreen> {
  LocationData? _locationData;
  List<dynamic> _mosques = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchLocationAndMosques();
  }

Future<void> _fetchLocationAndMosques() async {
  setState(() {
    _isLoading = true;
    _error = null;
  });

  try {
    final location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        setState(() {
          _error = "Location service is disabled.";
        });
        return;
      }
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        setState(() {
          _error = "Location permission denied.";
        });
        return;
      }
    }

    final locData = await location.getLocation();
    _locationData = locData;

    // Step 1: Reverse geocoding to get city
    final reverseUrl =
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${locData.latitude}&lon=${locData.longitude}&zoom=10&addressdetails=1';

    final reverseResponse = await http.get(Uri.parse(reverseUrl), headers: {
      'User-Agent': 'FlutterMosqueFinderApp/1.0'
    });

    if (reverseResponse.statusCode != 200) {
      throw Exception("Failed to get city name");
    }

    final reverseData = json.decode(reverseResponse.body);
    final city = reverseData['address']['city'] ??
        reverseData['address']['town'] ??
        reverseData['address']['village'] ??
        reverseData['address']['county'] ??
        reverseData['address']['state'];

    if (city == null) {
      setState(() {
        _error = "Could not determine your city.";
        _isLoading = false;
      });
      return;
    }

    // Step 2: Search mosques in the detected city
    final url =
        'https://nominatim.openstreetmap.org/search?q=mosque in $city&format=json&limit=20';

    final response = await http.get(Uri.parse(url), headers: {
      'User-Agent': 'FlutterMosqueFinderApp/1.0'
    });

    if (response.statusCode == 200) {
      setState(() {
        _mosques = json.decode(response.body);
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = "Failed to fetch mosques.";
        _isLoading = false;
      });
    }
  } catch (e) {
    setState(() {
      _error = "Error: $e";
      _isLoading = false;
    });
  }
}


  void _openMap(String lat, String lon) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lon');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not open map.")),
      );
    }
  }

 String _buildStaticMapUrl(String lat, String lon) {
  return 'https://staticmap.openstreetmap.de/staticmap.php?center=$lat,$lon&zoom=15&size=600x300&markers=$lat,$lon,green';
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearby Mosques'),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _mosques.isEmpty
                  ? Center(child: Text('No mosques found nearby.'))
                  : ListView.builder(
                      padding: EdgeInsets.all(12),
                      itemCount: _mosques.length,
                      itemBuilder: (context, index) {
                        final mosque = _mosques[index];
                        final lat = mosque['lat'];
                        final lon = mosque['lon'];
                        final name = mosque['display_name'] ?? 'Mosque';

                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: () => _openMap(lat, lon),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                                  child: Image.network(
                                    _buildStaticMapUrl(lat, lon),
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      height: 200,
                                      color: Colors.grey.shade300,
                                      child: Center(child: Icon(Icons.map, size: 50)),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: [
                                      Icon(Icons.mosque, color: Colors.green),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
