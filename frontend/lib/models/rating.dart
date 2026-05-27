class Rating {
  final int? id;
  final int materialId;
  final String? userId;
  final int stars;
  final String? userName;

  Rating({
    this.id,
    required this.materialId,
    this.userId,
    required this.stars,
    this.userName,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'],
      materialId: json['materialId'] ?? 0,
      userId: json['userId'],
      stars: json['stars'] ?? 0,
      userName: json['userName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'materialId': materialId,
      'stars': stars,
    };
  }
}
