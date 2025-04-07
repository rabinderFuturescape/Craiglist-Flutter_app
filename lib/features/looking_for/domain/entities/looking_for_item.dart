import 'package:flutter/foundation.dart';

/// Entity representing a "Looking For" item - a product that a user is looking to buy
class LookingForItem {
  final String id;
  final String userId;
  final String userName;
  final String title;
  final String description;
  final double maxBudget;
  final List<String> categories;
  final DateTime createdAt;
  final DateTime expiryDate;
  final bool isActive;
  final String? contactInfo;
  final String? location;
  final List<String>? preferredConditions;

  const LookingForItem({
    required this.id,
    required this.userId,
    required this.userName,
    required this.title,
    required this.description,
    required this.maxBudget,
    required this.categories,
    required this.createdAt,
    required this.expiryDate,
    this.isActive = true,
    this.contactInfo,
    this.location,
    this.preferredConditions,
  });

  /// Check if the item is expired
  bool get isExpired => DateTime.now().isAfter(expiryDate);

  /// Create a copy of this item with the given fields replaced with the new values
  LookingForItem copyWith({
    String? id,
    String? userId,
    String? userName,
    String? title,
    String? description,
    double? maxBudget,
    List<String>? categories,
    DateTime? createdAt,
    DateTime? expiryDate,
    bool? isActive,
    String? contactInfo,
    String? location,
    List<String>? preferredConditions,
  }) {
    return LookingForItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      title: title ?? this.title,
      description: description ?? this.description,
      maxBudget: maxBudget ?? this.maxBudget,
      categories: categories ?? this.categories,
      createdAt: createdAt ?? this.createdAt,
      expiryDate: expiryDate ?? this.expiryDate,
      isActive: isActive ?? this.isActive,
      contactInfo: contactInfo ?? this.contactInfo,
      location: location ?? this.location,
      preferredConditions: preferredConditions ?? this.preferredConditions,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is LookingForItem &&
        other.id == id &&
        other.userId == userId &&
        other.userName == userName &&
        other.title == title &&
        other.description == description &&
        other.maxBudget == maxBudget &&
        listEquals(other.categories, categories) &&
        other.createdAt == createdAt &&
        other.expiryDate == expiryDate &&
        other.isActive == isActive &&
        other.contactInfo == contactInfo &&
        other.location == location &&
        listEquals(other.preferredConditions, preferredConditions);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        userName.hashCode ^
        title.hashCode ^
        description.hashCode ^
        maxBudget.hashCode ^
        categories.hashCode ^
        createdAt.hashCode ^
        expiryDate.hashCode ^
        isActive.hashCode ^
        contactInfo.hashCode ^
        location.hashCode ^
        preferredConditions.hashCode;
  }
}
