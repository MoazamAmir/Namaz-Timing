import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:namaz_timing/controller/downloadService_controller.dart';
import 'package:namaz_timing/models/audioFile_model.dart';

class AudioPlayerController extends GetxController {
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  final RxBool isPlaying = false.obs;
  final RxBool isLoading = false.obs;
  final Rx<Duration> duration = Duration.zero.obs;
  final Rx<Duration> position = Duration.zero.obs;
  final RxInt currentIndex = 0.obs;
  final Rx<AudioFile?> currentAudioFile = Rx<AudioFile?>(null);
  final RxList<AudioFile> audioFiles = <AudioFile>[].obs;
  final RxBool isOfflineMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      isPlaying.value = state == PlayerState.playing;
    });

    _audioPlayer.onDurationChanged.listen((Duration newDuration) {
      duration.value = newDuration;
      isLoading.value = false;
    });

    _audioPlayer.onPositionChanged.listen((Duration newPosition) {
      position.value = newPosition;
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      playNext();
    });
  }

  void initializePlayer(AudioFile audioFile, List<AudioFile> allAudioFiles, int index) {
    currentAudioFile.value = audioFile;
    audioFiles.value = allAudioFiles;
    currentIndex.value = index;
    playAudio();
  }

  Future<void> playAudio() async {
    try {
      isLoading.value = true;
      final storageController = Get.find<StorageController>();
      
      // Check if file is downloaded and available offline
      final downloadedFile = storageController.getDownloadedFile(
        currentAudioFile.value!.chapterId, 
        currentAudioFile.value!.reciterName
      );
      
      String audioSource;
      if (downloadedFile != null && File(downloadedFile.localPath!).existsSync()) {
        audioSource = downloadedFile.localPath!;
        isOfflineMode.value = true;
        await _audioPlayer.play(DeviceFileSource(audioSource));
      } else {
        audioSource = currentAudioFile.value!.audioUrl;
        isOfflineMode.value = false;
        await _audioPlayer.play(UrlSource(audioSource));
      }

    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to play audio: $e',
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
      );
      isLoading.value = false;
    }
  }

  Future<void> downloadCurrentFile(AudioFile audioFile) async {
    if (currentAudioFile.value != null) {
      final downloadService = Get.find<DownloadService>();
      await downloadService.downloadAudioFile(currentAudioFile.value!);
    }
  }

  Future<void> togglePlayPause() async {
    if (isPlaying.value) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
  }

  Future<void> stopPlayback() async {
    await _audioPlayer.stop();
    position.value = Duration.zero;
  }

  void playNext() {
    if (currentIndex.value < audioFiles.length - 1) {
      currentIndex.value++;
      currentAudioFile.value = audioFiles[currentIndex.value];
      position.value = Duration.zero;
      duration.value = Duration.zero;
      playAudio();
    }
  }

  void playPrevious() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
      currentAudioFile.value = audioFiles[currentIndex.value];
      position.value = Duration.zero;
      duration.value = Duration.zero;
      playAudio();
    }
  }

  void seekTo(double value) {
    final newPosition = Duration(seconds: value.toInt());
    _audioPlayer.seek(newPosition);
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0 ? "$hours:$minutes:$seconds" : "$minutes:$seconds";
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }
}