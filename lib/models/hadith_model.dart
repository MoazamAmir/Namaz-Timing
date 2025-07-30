class Hadith {
  Hadith({
    required this.metadata,
    required this.hadiths,
    required this.chapter,
  });

  final Metadata? metadata;
  final List<HadithElement> hadiths;
  final Chapter? chapter;

  factory Hadith.fromJson(Map<String, dynamic> json) {
    return Hadith(
      metadata: json["metadata"] == null
          ? null
          : Metadata.fromJson(json["metadata"]),
      hadiths: json["hadiths"] == null
          ? []
          : List<HadithElement>.from(
              json["hadiths"].map((x) => HadithElement.fromJson(x)),
            ),
      chapter: json["chapter"] == null
          ? null
          : Chapter.fromJson(json["chapter"]),
    );
  }
}

class Metadata {
  Metadata({required this.length, required this.arabic, required this.english});

  final int? length;
  final Arabic? arabic;
  final Arabic? english;

  factory Metadata.fromJson(Map<String, dynamic> json) {
    return Metadata(
      length: json["length"],
      arabic: json["arabic"] == null ? null : Arabic.fromJson(json["arabic"]),
      english: json["english"] == null
          ? null
          : Arabic.fromJson(json["english"]),
    );
  }
}

class Arabic {
  Arabic({
    required this.title,
    required this.author,
    required this.introduction,
  });

  final String? title;
  final String? author;
  final String? introduction;

  factory Arabic.fromJson(Map<String, dynamic> json) {
    return Arabic(
      title: json["title"],
      author: json["author"],
      introduction: json["introduction"],
    );
  }
}

class Chapter {
  Chapter({
    required this.id,
    required this.bookId,
    required this.arabic,
    required this.english,
  });

  final int? id;
  final int? bookId;
  final String? arabic;
  final String? english;

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json["id"],
      bookId: json["bookId"],
      arabic: json["arabic"],
      english: json["english"],
    );
  }
}

class HadithElement {
  HadithElement({
    required this.id,
    required this.idInBook,
    required this.chapterId,
    required this.bookId,
    required this.arabic,
    required this.english,
  });

  final int? id;
  final int? idInBook;
  final int? chapterId;
  final int? bookId;
  final String? arabic;
  final English? english;

  factory HadithElement.fromJson(Map<String, dynamic> json) {
    return HadithElement(
      id: json["id"],
      idInBook: json["idInBook"],
      chapterId: json["chapterId"],
      bookId: json["bookId"],
      arabic: json["arabic"],
      english: json["english"] == null
          ? null
          : English.fromJson(json["english"]),
    );
  }
}

class English {
  English({required this.narrator, required this.text});

  final String? narrator;
  final String? text;

  factory English.fromJson(Map<String, dynamic> json) {
    return English(narrator: json["narrator"], text: json["text"]);
  }
}
