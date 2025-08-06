class AudioFile {
  final int id;
  final int chapterId;
  final double fileSize;
  final String format;
  final String audioUrl;
  final String reciterName;
  bool isDownloaded;
  String? localPath;

  AudioFile({
    required this.id,
    required this.chapterId,
    required this.fileSize,
    required this.format,
    required this.audioUrl,
    required this.reciterName,
    this.isDownloaded = false,
    this.localPath,
  });

  factory AudioFile.fromJson(Map<String, dynamic> json) {
    String url = json['audio_url'] ?? '';
    Map<String, String> reciterInfo = _extractReciterInfo(url);
    
    return AudioFile(
      id: json['id'] ?? 0,
      chapterId: json['chapter_id'] ?? 0,
      fileSize: json['file_size']?.toDouble() ?? 0.0,
      format: json['format'] ?? 'mp3',
      audioUrl: url,
      reciterName: reciterInfo['name']!,
      isDownloaded: json['isDownloaded'] ?? false,
      localPath: json['localPath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chapter_id': chapterId,
      'file_size': fileSize,
      'format': format,
      'audio_url': audioUrl,
      'reciterName': reciterName,
      'isDownloaded': isDownloaded,
      'localPath': localPath,
    };
  }

  static Map<String, String> _extractReciterInfo(String url) {
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;
    
    String reciterPath = '';
    if (pathSegments.length > 1) {
      reciterPath = pathSegments[1];
    }
    
    String cleanPath = reciterPath.replaceAll('_', ' ').replaceAll('-', ' ');
    return {
      'name': cleanPath.isNotEmpty ? cleanPath : 'Unknown Reciter',
      'arabic': 'قارئ غير معروف'
    };
  }

  String get fileName => 'surah_${chapterId}_${reciterName.replaceAll(' ', '_')}.mp3';
}
