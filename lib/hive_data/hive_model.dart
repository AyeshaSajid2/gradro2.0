import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'hive_model.g.dart';

@HiveType(typeId: 0)
class Fruit extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String imagePath;

  @HiveField(2)
  final int spacing;

  @HiveField(3)
  final String sun;

  @HiveField(4)
  final String water;

  @HiveField(5)
  final String season;

  @HiveField(6)
  final String frost;

  @HiveField(7)
  final String description; // Added description field

  @HiveField(8)
  final Offset? position; // Changed to Offset type

  Fruit({
    required this.name,
    required this.imagePath,
    required this.spacing,
    required this.sun,
    required this.water,
    required this.season,
    required this.frost,
    required this.description, // Added description
    this.position,
  });

  // Implementing copyWith method
  Fruit copyWith({
    String? name,
    String? imagePath,
    int? spacing,
    String? sun,
    String? water,
    String? season,
    String? frost,
    String? description, // Added description
    Offset? position,
  }) {
    return Fruit(
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      spacing: spacing ?? this.spacing,
      sun: sun ?? this.sun,
      water: water ?? this.water,
      season: season ?? this.season,
      frost: frost ?? this.frost,
      description: description ?? this.description, // Added description
      position: position ?? this.position,
    );
  }
}
