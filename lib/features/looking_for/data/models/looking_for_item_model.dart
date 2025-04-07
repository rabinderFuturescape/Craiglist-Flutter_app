import 'package:flutter/foundation.dart';
import '../../domain/entities/looking_for_item.dart';

/// Model class for LookingForItem entity
class LookingForItemModel extends LookingForItem {
  const LookingForItemModel({
    required String id,
    required String userId,
    required String userName,
    required String title,
    required String description,
    required double maxBudget,
    required List<String> categories,
    required DateTime createdAt,
    required DateTime expiryDate,
    bool isActive = true,
    String? contactInfo,
    String? location,
    List<String>? preferredConditions,
  }) : super(
          id: id,
          userId: userId,
          userName: userName,
          title: title,
          description: description,
          maxBudget: maxBudget,
          categories: categories,
          createdAt: createdAt,
          expiryDate: expiryDate,
          isActive: isActive,
          contactInfo: contactInfo,
          location: location,
          preferredConditions: preferredConditions,
        );

  /// Create a model from JSON
  factory LookingForItemModel.fromJson(Map<String, dynamic> json) {
    return LookingForItemModel(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      title: json['title'],
      description: json['description'],
      maxBudget: (json['maxBudget'] as num).toDouble(),
      categories: List<String>.from(json['categories']),
      createdAt: DateTime.parse(json['createdAt']),
      expiryDate: DateTime.parse(json['expiryDate']),
      isActive: json['isActive'] ?? true,
      contactInfo: json['contactInfo'],
      location: json['location'],
      preferredConditions: json['preferredConditions'] != null
          ? List<String>.from(json['preferredConditions'])
          : null,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'title': title,
      'description': description,
      'maxBudget': maxBudget,
      'categories': categories,
      'createdAt': createdAt.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'isActive': isActive,
      'contactInfo': contactInfo,
      'location': location,
      'preferredConditions': preferredConditions,
    };
  }

  /// Create a copy of this model with the given fields replaced with the new values
  LookingForItemModel copyWithModel({
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
    return LookingForItemModel(
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
}
