import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:namaz_timing/AllListScreen/sura_name/suran_nameList.dart';
import 'package:namaz_timing/Widget/All_widgetscreen.dart';
import 'package:namaz_timing/constant/downloadProgress.dart';
import 'package:namaz_timing/controller/AudioPlayerController.dart';
import 'package:namaz_timing/controller/downloadService_controller.dart';
import 'package:namaz_timing/models/audioFile_model.dart';

class AudioPlayerScreen extends StatelessWidget {
  final AudioFile audioFile;
  final List<AudioFile> allAudioFiles;
  final int currentIndex;

  const AudioPlayerScreen({
    Key? key,
    required this.audioFile,
    required this.allAudioFiles,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AudioPlayerController controller = Get.put(AudioPlayerController());
    final storageController = Get.find<StorageController>();
    
    // Initialize player when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initializePlayer(audioFile, allAudioFiles, currentIndex);
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Audio Player',
        subtitle: 'Playing Quran',
      ),
      body: Obx(() {
        final currentAudio = controller.currentAudioFile.value;
        if (currentAudio == null) return LoadingWidget(message: 'Loading...');

        final isDownloaded = storageController.isFileDownloaded(
          currentAudio.chapterId, 
          currentAudio.reciterName
        );

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Chapter Info Card
                    CustomCard(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.primaryLight, AppColors.primary],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 20,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                '${currentAudio.chapterId}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            ChapterNames.getName(currentAudio.chapterId),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            ChapterNames.getArabicName(currentAudio.chapterId),
                            style: TextStyle(
                              fontSize: 20,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                          ),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.mic, color: AppColors.primaryLight, size: 16),
                              SizedBox(width: 8),
                              Text(
                                currentAudio.reciterName,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (controller.isOfflineMode.value) ...[
                                Icon(Icons.offline_pin, color: AppColors.successColor, size: 16),
                                SizedBox(width: 4),
                                Text('Offline', style: TextStyle(color: AppColors.successColor)),
                              ] else ...[
                                Icon(Icons.cloud, color: AppColors.downloadColor, size: 16),
                                SizedBox(width: 4),
                                Text('Online', style: TextStyle(color: AppColors.downloadColor)),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Progress Card
                    CustomCard(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                controller.formatTime(controller.position.value),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                controller.formatTime(controller.duration.value),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppColors.primary,
                              inactiveTrackColor: Colors.grey[300],
                              thumbColor: AppColors.primary,
                              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
                              overlayShape: RoundSliderOverlayShape(overlayRadius: 16),
                            ),
                            child: Slider(
                              min: 0.0,
                              max: controller.duration.value.inSeconds.toDouble(),
                              value: controller.position.value.inSeconds.toDouble(),
                              onChanged: controller.seekTo,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Control Buttons
                    CustomCard(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Previous Button
                          IconButton(
                            onPressed: controller.currentIndex.value > 0 
                                ? controller.playPrevious 
                                : null,
                            icon: Icon(
                              Icons.skip_previous,
                              color: controller.currentIndex.value > 0 
                                  ? AppColors.primary 
                                  : Colors.grey,
                              size: 36,
                            ),
                          ),
                          
                          // Play/Pause Button
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.primaryLight, AppColors.primary],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: controller.togglePlayPause,
                              icon: controller.isLoading.value
                                  ? SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Icon(
                                      controller.isPlaying.value 
                                          ? Icons.pause 
                                          : Icons.play_arrow,
                                      color: Colors.white,
                                      size: 36,
                                    ),
                            ),
                          ),
                          
                          // Next Button
                          IconButton(
                            onPressed: controller.currentIndex.value < controller.audioFiles.length - 1 
                                ? controller.playNext 
                                : null,
                            icon: Icon(
                              Icons.skip_next,
                              color: controller.currentIndex.value < controller.audioFiles.length - 1 
                                  ? AppColors.primary 
                                  : Colors.grey,
                              size: 36,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (!isDownloaded) {
                                controller.downloadCurrentFile(audioFile);
                              } else {
                                Get.snackbar(
                                  'Already Downloaded',
                                  'This audio file is already downloaded.',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: AppColors.successColor,
                                  colorText: Colors.white,
                                );
                              }
                            },
                            child: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppColors.primaryLight, AppColors.primary],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                    isDownloaded ? Icons.done : Icons.download,
                                    color: isDownloaded ? Colors.white : Colors.white,
                                    size: 24,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // SizedBox(height: 20),
                    
                    // // Action Buttons
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: CustomCard(
                    //         padding: EdgeInsets.all(16),
                    //         onTap: !isDownloaded ? controller.downloadCurrentFile : null,
                    //         child: Row(
                    //           mainAxisAlignment: MainAxisAlignment.center,
                    //           children: [
                    //             Icon(
                    //               isDownloaded ? Icons.download_done : Icons.download,
                    //               color: isDownloaded ? AppColors.successColor : AppColors.downloadColor,
                    //               size: 24,
                    //             ),
                    //             SizedBox(width: 8),
                    //             Text(
                    //               isDownloaded ? 'Downloaded' : 'Download',
                    //               style: TextStyle(
                    //                 fontSize: 16,
                    //                 fontWeight: FontWeight.bold,
                    //                 color: isDownloaded ? AppColors.successColor : AppColors.downloadColor,
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     ),
                    //     SizedBox(width: 16),
                    //     Expanded(
                    //       child: CustomCard(
                    //         padding: EdgeInsets.all(16),
                    //         onTap: controller.stopPlayback,
                    //         child: Row(
                    //           mainAxisAlignment: MainAxisAlignment.center,
                    //           children: [
                    //             Icon(
                    //               Icons.stop,
                    //               color: Colors.red[400],
                    //               size: 24,
                    //             ),
                    //             SizedBox(width: 8),
                    //             Text(
                    //               'Stop',
                    //               style: TextStyle(
                    //                 fontSize: 16,
                    //                 fontWeight: FontWeight.bold,
                    //                 color: Colors.red[400],
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}