import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:namaz_timing/controller/namaz_timeController.dart';

class NamazTimeScreen extends StatelessWidget {
  final controller = Get.put(NamazTimeController());

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;

    controller.getLocationAndFetchTimings();

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.teal[800],
        body: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.02),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
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
                Center(
                  child: Column(
                    children: [
                      Text(
                        "${controller.city}, ${controller.country}",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      SizedBox(height: 4),
                      Text('Timezone: ${controller.timezone}', style: TextStyle(color: Colors.white)),
                      SizedBox(height: 4),
                      Text('Method: ${controller.methodName}', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                Center(
                  child: Column(
                    children: [
                     Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
 Text(
        controller.hijriDate.value,
        style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500),
      ),
      SizedBox(width: 8,), 
       Text(
        controller.hijriDate.split('-').first.trim(), // Just the date and weekday
        style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500),
      ),
                      ],
                     ),
      Text(
        controller.gregorianDate.value,
        style: TextStyle(fontSize: 14, color: Colors.white),
      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
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
                      ...['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'].map((name) => prayerTimeCard(
                            name,
                            controller.timings[name] ?? 'N/A',
                          )),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
              ],
            ),
          );
        }),
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
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
          Text(time, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal[800])),
        ],
      ),
    );
  }
}
