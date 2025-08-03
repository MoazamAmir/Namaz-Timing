import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppBarScreen extends StatelessWidget {
  final String title;
  final Color textColor;
  final Color iconColor;
  final Color backgroundColor;

  const AppBarScreen({
    super.key,
    required this.title,
    this.textColor = Colors.white,
    this.iconColor = Colors.black,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Icon(Icons.arrow_back, color: iconColor),
            ),
          ),
          SizedBox(width: 10),
          Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
