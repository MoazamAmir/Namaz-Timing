import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:namaz_timing/AllListScreen/sura_name/suran_nameList.dart';
import 'package:namaz_timing/constant/downloadProgress.dart';
import 'package:namaz_timing/models/audioFile_model.dart';
import 'package:namaz_timing/view/Community/community.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class DownloadService extends GetxService {
  final Dio _dio = Dio();
  final RxMap<String, DownloadProgress> downloadProgress = <String, DownloadProgress>{}.obs;

  Future<bool> checkPermissions() async {
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }
      return status.isGranted;
    }
    return true; // iOS doesn't need explicit storage permission for app documents
  }

  Future<String> getDownloadPath() async {
    Directory? directory;
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else {
      directory = await getApplicationDocumentsDirectory();
    }
    
    final downloadDir = Directory('${directory!.path}/QuranAudio');
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }
    
    return downloadDir.path;
  }

  Future<bool> downloadAudioFile(AudioFile audioFile) async {
    final hasPermission = await checkPermissions();
    if (!hasPermission) {
      Get.snackbar('Permission Denied', 'Storage permission required for download');
      return false;
    }

    try {
      final downloadPath = await getDownloadPath();
      final filePath = '$downloadPath/${audioFile.fileName}';
      
      final progressKey = '${audioFile.chapterId}_${audioFile.reciterName}';
      
      downloadProgress[progressKey] = DownloadProgress(
        chapterId: audioFile.chapterId,
        reciterName: audioFile.reciterName,
        progress: 0.0,
      );

      await _dio.download(
        audioFile.audioUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            downloadProgress[progressKey] = DownloadProgress(
              chapterId: audioFile.chapterId,
              reciterName: audioFile.reciterName,
              progress: progress,
            );
          }
        },
      );

      downloadProgress[progressKey] = DownloadProgress(
        chapterId: audioFile.chapterId,
        reciterName: audioFile.reciterName,
        progress: 1.0,
        isCompleted: true,
      );

      // Save to downloaded files
      await _saveDownloadedFile(audioFile, filePath);
      
      Get.snackbar(
        'Download Complete', 
        '${ChapterNames.getName(audioFile.chapterId)} downloaded successfully',
        backgroundColor: AppColors.successColor,
        colorText: Colors.white,
      );

      return true;
    } catch (e) {
      final progressKey = '${audioFile.chapterId}_${audioFile.reciterName}';
      downloadProgress[progressKey] = DownloadProgress(
        chapterId: audioFile.chapterId,
        reciterName: audioFile.reciterName,
        progress: 0.0,
        isFailed: true,
      );

      Get.snackbar('Download Failed', 'Error: ${e.toString()}');
      return false;
    }
  }

  Future<void> _saveDownloadedFile(AudioFile audioFile, String localPath) async {
    final storageController = Get.find<StorageController>();
    audioFile.isDownloaded = true;
    audioFile.localPath = localPath;
    await storageController.saveDownloadedFile(audioFile);
  }

  DownloadProgress? getDownloadProgress(int chapterId, String reciterName) {
    final key = '${chapterId}_$reciterName';
    return downloadProgress[key];
  }
}
class StorageController extends GetxController {
  final RxList<AudioFile> downloadedFiles = <AudioFile>[].obs;
  late Directory appDir;

  @override
  void onInit() {
    super.onInit();
    initializeStorage();
  }

  Future<void> initializeStorage() async {
    appDir = await getApplicationDocumentsDirectory();
    await loadDownloadedFiles();
  }

  Future<void> saveDownloadedFile(AudioFile audioFile) async {
    final file = File('${appDir.path}/downloaded_files.json');
    
    List<Map<String, dynamic>> files = [];
    if (await file.exists()) {
      final content = await file.readAsString();
      if (content.isNotEmpty) {
        files = List<Map<String, dynamic>>.from(json.decode(content));
      }
    }
    
    // Remove existing entry if any
    files.removeWhere((f) => 
        f['chapter_id'] == audioFile.chapterId && 
        f['reciterName'] == audioFile.reciterName);
    
    // Add new entry
    files.add(audioFile.toJson());
    
    await file.writeAsString(json.encode(files));
    await loadDownloadedFiles();
  }

  Future<void> loadDownloadedFiles() async {
    try {
      final file = File('${appDir.path}/downloaded_files.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          final List<dynamic> filesJson = json.decode(content);
          downloadedFiles.value = filesJson
              .map((json) => AudioFile.fromJson(json))
              .where((audioFile) => File(audioFile.localPath ?? '').existsSync())
              .toList();
        }
      }
    } catch (e) {
      print('Error loading downloaded files: $e');
    }
  }

  Future<void> deleteDownloadedFile(AudioFile audioFile) async {
    try {
      if (audioFile.localPath != null) {
        final file = File(audioFile.localPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
      
      downloadedFiles.removeWhere((f) => 
          f.chapterId == audioFile.chapterId && 
          f.reciterName == audioFile.reciterName);
      
      // Update storage
      final storageFile = File('${appDir.path}/downloaded_files.json');
      final files = downloadedFiles.map((f) => f.toJson()).toList();
      await storageFile.writeAsString(json.encode(files));
      
      Get.snackbar('Deleted', 'File removed successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete file');
    }
  }

  bool isFileDownloaded(int chapterId, String reciterName) {
    return downloadedFiles.any((f) => 
        f.chapterId == chapterId && f.reciterName == reciterName);
  }

  AudioFile? getDownloadedFile(int chapterId, String reciterName) {
    try {
      return downloadedFiles.firstWhere((f) => 
          f.chapterId == chapterId && f.reciterName == reciterName);
    } catch (e) {
      return null;
    }
  }

  String getTotalDownloadedSize() {
    double totalSize = 0;
    for (var file in downloadedFiles) {
      totalSize += file.fileSize;
    }
    return formatBytes(totalSize);
  }

  String formatBytes(double bytes) {
    if (bytes < 1024) return '${bytes.toStringAsFixed(0)} B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}