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

  String localizedTitle(String langCode) {
    final code = langCode.toUpperCase();
    if (id == 'reel-1') {
      if (code == 'OM') return 'Dhiqannaa Hoomacha Qulqulluu';
      if (code == 'AM') return 'የአረፋ እና የቅድመ-እጥበት ሂደት';
    } else if (id == 'reel-2') {
      if (code == 'OM') return 'Dhiqannaa Dhiibbaa Ol\'aanaa & Isxiimii';
      if (code == 'AM') return 'ከፍተኛ ግፊት ያለው የእንፋሎት እጥበት';
    } else if (id == 'reel-3') {
      if (code == 'OM') return 'Kootingii Saaraamiikii Daayimondii';
      if (code == 'AM') return 'የዳይመንድ ሴራሚክ ኮቲንግ እና ፖሊሽ';
    } else if (id == 'reel-4') {
      if (code == 'OM') return 'Qulqullina Keessaa & Kunuunsa Qodaa';
      if (code == 'AM') return 'የውስጥ ክፍል ጥልቅ እንፋሎት እና ሌዘር እንክብካቤ';
    }
    return title;
  }

  String localizedSubtitle(String langCode) {
    final code = langCode.toUpperCase();
    if (id == 'reel-1') {
      if (code == 'OM') return 'Hoomacha dhangala\'aa fi qulqullina saffisaa • Daawwadhaa';
      if (code == 'AM') return 'ሙሉ አረፋ እና ከቆሻሻ የጸዳ ንጽህና • ይመልከቱ';
    } else if (id == 'reel-2') {
      if (code == 'OM') return 'Kunuunsa injiiniifi gommaa jalaatiin • Daawwadhaa';
      if (code == 'AM') return 'የሞተር እና የታችኛው ክፍል ጥልቅ እጥበት • ይመልከቱ';
    } else if (id == 'reel-3') {
      if (code == 'OM') return 'Calaqqisa addaafi eegumsa makiinaa • Daawwadhaa';
      if (code == 'AM') return 'ልዩ ወዝ እና የመኪና ቀለም ጥበቃ • ይመልከቱ';
    } else if (id == 'reel-4') {
      if (code == 'OM') return 'Qulqullina teessoo gogaafi sagalee dhabamsiisuu • Daawwadhaa';
      if (code == 'AM') return 'የመቀመጫ እና የውስጥ ሽታ ማስወገጃ • ይመልከቱ';
    }
    return subtitle;
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
