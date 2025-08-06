import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:namaz_timing/AllListScreen/sura_name/suran_nameList.dart';
import 'package:namaz_timing/Widget/All_widgetscreen.dart';
import 'package:namaz_timing/constant/downloadProgress.dart';
import 'package:namaz_timing/controller/downloadService_controller.dart';
import 'package:namaz_timing/view/Voice/AudioPlayerScreen.dart';

class DownloadsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final storageController = Get.find<StorageController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Downloaded Files',
        subtitle: 'Offline Audio',
      ),
      body: Obx(() {
        if (storageController.downloadedFiles.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.download_outlined,
                  size: 80,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: 20),
                Text(
                  'No Downloaded Files',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Download some Surahs to listen offline',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Storage Info
            CustomCard(
              margin: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.storage, color: AppColors.primaryLight, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Downloaded',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${storageController.downloadedFiles.length} files • ${storageController.getTotalDownloadedSize()}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Downloaded Files List
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: storageController.downloadedFiles.length,
                itemBuilder: (context, index) {
                  final audioFile = storageController.downloadedFiles[index];
                  
                  return CustomCard(
                    margin: EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.primaryLight, AppColors.primary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '${audioFile.chapterId}',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ChapterNames.getName(audioFile.chapterId),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                ChapterNames.getArabicName(audioFile.chapterId),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                                textDirection: TextDirection.rtl,
                              ),
                              SizedBox(height: 2),
                              Text(
                                audioFile.reciterName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                Get.to(() => AudioPlayerScreen(
                                  audioFile: audioFile,
                                  allAudioFiles: [audioFile],
                                  currentIndex: 0,
                                ));
                              },
                              icon: Icon(
                                Icons.play_arrow,
                                color: AppColors.primaryLight,
                                size: 28,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Get.dialog(
                                  AlertDialog(
                                    title: Text('Delete File'),
                                    content: Text(
                                      'Are you sure you want to delete ${ChapterNames.getName(audioFile.chapterId)}?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Get.back(),
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Get.back();
                                          storageController.deleteDownloadedFile(audioFile);
                                        },
                                        child: Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red[400],
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}

