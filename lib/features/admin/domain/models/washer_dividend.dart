class WasherDividend {
  final String washerId;
  final String washerName;
  final int skillLevel;
  final bool isPresent;
  final double percentageShare; // Percentage of the 100% pool (e.g. 25.0)
  final double earnedETB;
  final String? customTierName;

  const WasherDividend({
    required this.washerId,
    required this.washerName,
    required this.skillLevel,
    required this.isPresent,
    required this.percentageShare,
    required this.earnedETB,
    this.customTierName,
  });

  String get tierName {
    if (customTierName != null && customTierName!.isNotEmpty) {
      return customTierName!;
    }
    switch (skillLevel) {
      case 4:
        return 'Lead Specialist (Tier 1)';
      case 3:
        return 'Senior Washer (Tier 2)';
      case 1:
        return 'Junior Washer (Tier 4)';
      case 2:
      default:
        return 'Standard Washer (Tier 3)';
    }
  }
}
