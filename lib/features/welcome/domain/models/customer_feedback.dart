/// Moderation lifecycle for customer feedback submissions.
enum FeedbackStatus {
  pending,
  approved,
  ignored;

  static FeedbackStatus fromString(String? value) {
    return FeedbackStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => FeedbackStatus.pending,
    );
  }
}

/// Customer satisfaction rating (1..4 stars) and optional written opinion.
class CustomerFeedback {
  final String id;
  final int stars;
  final String comment;
  final String customerName;
  final DateTime createdAt;
  final FeedbackStatus status;

  static const List<int> validRatings = [1, 2, 3, 4];

  static const Map<int, String> ratingLabelKeys = {
    1: 'star1Good',
    2: 'star2Satisfactory',
    3: 'star3Excellent',
    4: 'star4SuperSatisfied',
  };

  static final RegExp _blockedLinkRegex = RegExp(
    r'(https?://|www\.|t\.me/|bit\.ly|\.(com|net|org|io|et)\b)',
    caseSensitive: false,
  );

  const CustomerFeedback({
    required this.id,
    required this.stars,
    this.comment = '',
    this.customerName = '',
    required this.createdAt,
    this.status = FeedbackStatus.pending,
  });

  String get labelKey => ratingLabelKeys[stars] ?? 'star1Good';

  /// Returns an AppStrings error key if [raw] contains spam links, or null if valid.
  static String? validateOpinion(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    if (_blockedLinkRegex.hasMatch(trimmed)) {
      return 'feedbackLinksBlocked';
    }
    return null;
  }

  CustomerFeedback copyWith({
    String? id,
    int? stars,
    String? comment,
    String? customerName,
    DateTime? createdAt,
    FeedbackStatus? status,
  }) {
    return CustomerFeedback(
      id: id ?? this.id,
      stars: stars ?? this.stars,
      comment: comment ?? this.comment,
      customerName: customerName ?? this.customerName,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'stars': stars,
      'comment': comment,
      'customerName': customerName,
      'createdAt': createdAt.toIso8601String(),
      'status': status.name,
    };
  }

  factory CustomerFeedback.fromMap(Map<String, dynamic> map) {
    final parsedStars = int.tryParse(map['stars']?.toString() ?? '1') ?? 1;
    return CustomerFeedback(
      id: (map['id'] ?? '').toString(),
      stars: parsedStars.clamp(1, 4),
      comment: (map['comment'] ?? '').toString(),
      customerName: (map['customerName'] ?? '').toString(),
      createdAt: DateTime.tryParse((map['createdAt'] ?? '').toString()) ?? DateTime.now(),
      status: FeedbackStatus.fromString(map['status']?.toString()),
    );
  }
}
