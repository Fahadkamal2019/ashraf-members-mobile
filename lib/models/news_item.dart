class NewsListItem {
  NewsListItem({
    required this.id,
    required this.titleAr,
    required this.prefAr,
    required this.imageUrl,
    required this.createdAt,
  });

  final int id;
  final String? titleAr;
  final String? prefAr;
  final String? imageUrl;
  final DateTime createdAt;

  factory NewsListItem.fromJson(Map<String, dynamic> json) => NewsListItem(
        id: json['id'] as int,
        titleAr: json['titleAr'] as String?,
        prefAr: json['prefAr'] as String?,
        imageUrl: json['imageUrl'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class NewsDetail {
  NewsDetail({
    required this.id,
    required this.titleAr,
    required this.textAr,
    required this.imageUrl,
    required this.createdAt,
  });

  final int id;
  final String? titleAr;
  final String? textAr;
  final String? imageUrl;
  final DateTime createdAt;

  factory NewsDetail.fromJson(Map<String, dynamic> json) => NewsDetail(
        id: json['id'] as int,
        titleAr: json['titleAr'] as String?,
        textAr: json['textAr'] as String?,
        imageUrl: json['imageUrl'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
