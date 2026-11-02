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
    } else if (id == 'reel-5') {
      if (code == 'OM') return 'Kunuunsa Gommaa & Qulqullina Rims';
      if (code == 'AM') return 'የጎማ እና የሪም ልዩ ጽዳትና ወዝ';
    } else if (id == 'reel-6') {
      if (code == 'OM') return 'Qulqullina Injiinii & Dhiibbaa Zayitii';
      if (code == 'AM') return 'የሞተር ክፍል ጥልቅ የእንፋሎት እጥበት';
    } else if (id == 'reel-7') {
      if (code == 'OM') return 'Dhiqannaa Bishaaniifi Calaqa Saaraamiikii';
      if (code == 'AM') return 'የውሃ መከላከያና የሃይድሮፎቢክ ከለላ';
    } else if (id == 'reel-8') {
      if (code == 'OM') return 'Tajaajila Makiinaa Socho\'aa Manaatti';
      if (code == 'AM') return 'ተንቀሳቃሽ የቤት ለቤት የእጥበት ቫን';
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
    } else if (id == 'reel-5') {
      if (code == 'OM') return 'Qulqullina gommaa fi calaqqisa cimaa • Daawwadhaa';
      if (code == 'AM') return 'የጎማ ጥልቅ ጥቁረት እና የብሬክ አቧራ ማጽጃ • ይመልከቱ';
    } else if (id == 'reel-6') {
      if (code == 'OM') return 'Dhiqannaa injiinii fi eegumsa shiboo • Daawwadhaa';
      if (code == 'AM') return 'የሞተር ዘይትና ቆሻሻ ማስወገጃ • ይመልከቱ';
    } else if (id == 'reel-7') {
      if (code == 'OM') return 'Eegumsa bishaanii daddafaa calaqqisiisu • Daawwadhaa';
      if (code == 'AM') return 'የውሃ ነጠብጣብ መከላከያና ፈጣን ማድረቂያ • ይመልከቱ';
    } else if (id == 'reel-8') {
      if (code == 'OM') return 'Makiinaa dhufee mana keessanitti dhiqu • Daawwadhaa';
      if (code == 'AM') return 'ቫኑ ደጃፍዎ መጥቶ የሚሰጠው ፈጣን አገልግሎት • ይመልከቱ';
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
      tiktokUrl: (map['tiktokUrl']?.toString().isNotEmpty ?? false)
          ? map['tiktokUrl'].toString()
          : 'https://www.tiktok.com/@bishecarwash',
      thumbnailUrl: map['thumbnailUrl']?.toString() ?? '',
    );
  }
}
