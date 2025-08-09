import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:namaz_timing/AllListScreen/sura_name/suran_nameList.dart';
import 'package:namaz_timing/Widget/All_widgetscreen.dart';
import 'package:namaz_timing/constant/downloadProgress.dart';
import 'package:namaz_timing/controller/downloadService_controller.dart';
import 'package:namaz_timing/models/audioFile_model.dart';
import 'package:namaz_timing/view/Voice/AudioPlayerScreen.dart';
import 'package:namaz_timing/view/Community/community.dart';

class SuraListScreen extends StatelessWidget {
  final String reciterName;
  final List<AudioFile> audioFiles;

  const SuraListScreen({
    Key? key,
    required this.reciterName,
    required this.audioFiles,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final storageController = Get.find<StorageController>();
    final downloadService = Get.find<DownloadService>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: reciterName, subtitle: 'Select Surah'),
      body:  ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: audioFiles.length,
        itemBuilder: (context, index) {
          final audioFile = audioFiles[index];
          final isDownloaded = storageController.isFileDownloaded(
            audioFile.chapterId, 
            audioFile.reciterName
          );
          
          return CustomCard(
            margin: EdgeInsets.only(bottom: 12),
            onTap: () => Get.to(() => AudioPlayerScreen(
              audioFile: audioFile,
              allAudioFiles: audioFiles,
              currentIndex: index,
            )),
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              ChapterNames.getName(audioFile.chapterId),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (isDownloaded)
                            Icon(
                              Icons.download_done,
                              color: AppColors.successColor,
                              size: 20,
                            ),
                        ],
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
                    ],
                  ),
                ),
                Row(
                  children: [
                    DownloadProgressWidget(
                      chapterId: audioFile.chapterId,
                      reciterName: audioFile.reciterName,
                    ),
                    SizedBox(width: 8),
                    if (!isDownloaded)
                      InkWell(
                        onTap: () => downloadService.downloadAudioFile(audioFile),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.downloadColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.download,
                            color: AppColors.downloadColor,
                            size: 20,
                          ),
                        ),
                      ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.teal[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        color: AppColors.primaryLight,
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
    );
  }
}