import 'package:get/get.dart';
import 'package:namaz_timing/controller/AudioService_controller.dart';
import 'package:namaz_timing/controller/downloadService_controller.dart';
import 'package:namaz_timing/models/audioFile_model.dart';

class RecitersController extends GetxController {
  final RxMap<int, List<AudioFile>> reciterAudioFiles = <int, List<AudioFile>>{}.obs;
  final RxList<int> reciterIds = <int>[].obs;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    Get.put(StorageController());
    Get.put(DownloadService());
    fetchMultipleReciters();
  }

  Future<void> fetchMultipleReciters() async {
    isLoading.value = true;
    error.value = '';
    
    List<int> idsToFetch = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
    
    try {
      for (int id in idsToFetch) {
        final audioFiles = await AudioService.getReciterAudioFiles(id);
        if (audioFiles.isNotEmpty) {
          reciterAudioFiles[id] = audioFiles;
        }
        await Future.delayed(Duration(milliseconds: 200));
      }
      
      reciterIds.value = reciterAudioFiles.keys.toList();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void retry() {
    fetchMultipleReciters();
  }
}