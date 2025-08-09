import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:get/get.dart';
import 'package:namaz_timing/constant/downloadProgress.dart';
import 'package:namaz_timing/controller/recitersController.dart';
import 'package:namaz_timing/view/Voice/DownloadsScreen.dart';
import 'package:namaz_timing/view/Voice/SuraListScreen.dart';
import 'package:namaz_timing/view/Community/community.dart';

import '../../Widget/All_widgetscreen.dart';

class RecitersScreen extends StatelessWidget {
  final RecitersController controller = Get.put(RecitersController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        
        title: 'القرآن الكريم - Quran Reciters',
        actions: [
          IconButton(
            icon: Icon(Icons.download, color: Colors.white),
            onPressed: () => Get.to(() => DownloadsScreen()),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return LoadingWidget(message: 'Loading Reciters...');
        }

        if (controller.error.value.isNotEmpty) {
          return ErrorWidget(
            error: controller.error.value,
            onRetry: controller.retry,
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: controller.reciterIds.length,
          itemBuilder: (context, index) {
            final reciterId = controller.reciterIds[index];
            final audioFiles = controller.reciterAudioFiles[reciterId]!;
            final firstAudio = audioFiles.first;
            
            return CustomCard(
              margin: EdgeInsets.only(bottom: 16),
              padding: EdgeInsets.all(20),
              onTap: () => Get.to(() => SuraListScreen(
                reciterName: firstAudio.reciterName,
                audioFiles: audioFiles,
              )),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primaryLight, AppColors.primary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.mic, color: Colors.white, size: 28),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          firstAudio.reciterName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${audioFiles.length} Chapters Available',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.primaryLight,
                    size: 20,
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}