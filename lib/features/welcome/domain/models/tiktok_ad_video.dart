class TikTokAdVideo {
  final String id;
  final String title;
  final String subtitle;
  final String tiktokUrl;
  final String thumbnailUrl;

  const TikTokAdVideo({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.tiktokUrl,
    required this.thumbnailUrl,
  });

  TikTokAdVideo copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? tiktokUrl,
    String? thumbnailUrl,
  }) {
    return TikTokAdVideo(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      tiktokUrl: tiktokUrl ?? this.tiktokUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'tiktokUrl': tiktokUrl,
      'thumbnailUrl': thumbnailUrl,
    };
  }

  factory TikTokAdVideo.fromMap(Map<String, dynamic> map) {
    return TikTokAdVideo(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? 'BISHE Detailing Reel',
      subtitle: map['subtitle']?.toString() ?? 'Watch on TikTok',
      tiktokUrl: map['tiktokUrl']?.toString() ?? 'https://www.tiktok.com/@bishe_car_wash',
      thumbnailUrl: map['thumbnailUrl']?.toString() ?? '',
    );
  }
}
