import 'dart:convert';

import 'package:namaz_timing/models/audioFile_model.dart';
import 'package:http/http.dart' as http;
class AudioService {
  static const String baseUrl = 'https://api.quran.com/api/v4';

  static Future<List<AudioFile>> getReciterAudioFiles(int reciterId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chapter_recitations/$reciterId'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> audioFilesData = data['audio_files'] ?? [];
        
        return audioFilesData
            .map((json) => AudioFile.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load reciter data: $e');
    }
  }
}
